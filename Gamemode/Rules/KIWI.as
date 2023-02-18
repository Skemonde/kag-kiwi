#define SERVER_ONLY

#include "RulesCore.as";
#include "RespawnSystem.as";
#include "CTF_Structs.as";
#include "KIWI_Locales.as";

shared class Players
{
	CTFPlayerInfo@[] list;
	Players(){}
};

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	Players@ players;
	this.get("players", @players);

	if (players is null || player is null){
		return;
	}

	int localtime = Time_Local();
	int regtime = player.getRegistrationTime();

	int reg_month = Time_Month(regtime);
	int reg_day = Time_MonthDate(regtime);
	int reg_year = Time_Year(regtime);

	int loc_month = Time_Month(localtime);
	int loc_day = Time_MonthDate(localtime);
	int loc_year = Time_Year(localtime);
	
	string playerName = player.getUsername().split('~')[0];
	
	CPlayer@ maybePlayer = getPlayerByUsername(playerName);//See if we already exist
	if(maybePlayer !is null)
	{
		CBlob@ playerBlob = maybePlayer.getBlob();
		if(playerBlob !is null)
		{
			if(maybePlayer.getUsername() != player.getUsername())//do not change, playerName is stripped
			{
				KickPlayer(maybePlayer);//Clone
				playerBlob.server_SetPlayer(player);//switch souls
			}
		}
	}
	
	player.server_setCoins(50);
	this.set_bool(playerName + "autopickup", !this.get_bool(playerName + "autopickup"));
	this.Sync(playerName + "autopickup", true);
	player.server_setTeamNum(1);
}

void onTick(CRules@ this)
{
	s32 gametime = getGameTime();
	
	if (noSpawns()) {
		//teamnum is 3 because in my mod that's zombie team
		//if i decide to make some kind of playable zombies they'll hear a winning fanfare upon.. emm ..winning?
		this.SetTeamWon(3);   //game over!
		this.SetCurrentState(GAME_OVER);
		this.SetGlobalMessage("NO RESPAWNS AVAILABLE\nMANKIND HAVE LOST THE WAR");
	}
	
	for (u8 i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if (player !is null)
		{
			CBlob@ blob = player.getBlob();
			if (blob is null && player.get_u32("respawn time") <= gametime)
			{
				Respawn(this, player);
			}
		}
		
	}
}

void onInit(CRules@ this)
{
	if (!this.exists("default class"))
	{
		//for testing ill make it better way later - skemonde 15.02.23
		this.set_string("default class", "soldat");
	}
	
	Reset(this);
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void onPlayerRequestSpawn(CRules@ this, CPlayer@ player)
{
	//Respawn(this, player);
}

void onPlayerRequestTeamChange(CRules@ this, CPlayer@ player, u8 newteam)
{
	if (player !is null)
	{
		player.server_setTeamNum(newteam);
		
		if (newteam == this.getSpectatorTeamNum()) {
			CBlob@ blob = player.getBlob();
			if (blob !is null)
				blob.server_Die();
		}
	}
}

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
	if (victim is null)
	{
		return;
	}
	
	s32 respawn_time = 30 * 6;
	victim.set_u32("respawn time", getGameTime() + respawn_time);
	CBlob@[] supplies;
	if (getBlobsByTag("supply thing", supplies)) {
		for (int i = 0; i < supplies.length(); ++i) {
			if (supplies[i] !is null)
				supplies[i].server_Die();
		}
	}
}

CBlob@ Respawn(CRules@ this, CPlayer@ player)
{
	if (player !is null)
	{
		// we don't spawn spectators
		if (player.getTeamNum() == this.getSpectatorTeamNum() || noSpawns())
			return null;
		// remove previous players blob
		CBlob @blob = player.getBlob();

		if (blob !is null)
		{
			CBlob @blob = player.getBlob();
			blob.server_SetPlayer(null);
			blob.server_Die();
		}
		
		int team = 1;
		
		CBlob@ newBlob = server_CreateBlob(this.get_string("default class"), player.getTeamNum(), getSpawnLocation(player));
		newBlob.server_SetPlayer(player);
		CBlob@ gun = server_CreateBlob("revo", -1, newBlob.getPosition());
		// we don't want a million of revolvers to lay around after several deaths
		// so basically blobs with this tag are doomed
		
		//TODO: ANY PLAYER DEATH WILL CAUSE ITEMS WITH THE TAG DIE. Tie supply items to player's usernames and kill the items only on their player's death or when the username cannot be found (player left the server) - skemonde 15.02.23
		
		gun.Tag("supply thing");
		// i'll give them a name of "rusty gun" or something so players can actually know which revolver won't server long
		// TODO: change starter weapon sprite. Maybe make a different types of a starter weapon. Make the revolver to be used only as a starter weapon? - skemonde 15.02.23
		gun.setInventoryName(Names::starter_handgun);
		newBlob.server_PutInInventory(gun);
		CBlob@ ammo = server_CreateBlob("lowcal", -1, newBlob.getPosition());
		// this kills ammo that you have bought and that was merged with ammo that is tagged as a supply thing
		// which is not very convenient :<
		// ammo.Tag("supply thing");
		ammo.server_SetQuantity(18);
		newBlob.server_PutInInventory(ammo);
		return newBlob;
	}

	return null;
}

Vec2f getSpawnLocation(CPlayer@ player)
{
	CRules@ rules = getRules();
	CBlob@[] spawns;

	//no comments
	if (getBlobsByTag("spawn", spawns)) {
		return spawns[XORRandom(spawns.length)].getPosition();
	}

	return Vec2f(0, 0);
}

bool noSpawns()
{
	CRules@ rules = getRules();
	CBlob@[] spawns;

	if (getBlobsByTag("spawn", spawns)) {
		return false;
	}
	else
		return true;
}

void Reset(CRules@ this)
{
	printf("Restarting rules script: " + getCurrentScriptName());

	Players players();

	for(u8 i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ p = getPlayer(i);
		if(p !is null)
		{
			p.set_u32("respawn time", getGameTime() + (30 * 1));
			p.server_setCoins(50);

			p.server_setTeamNum(p.getTeamNum());
			players.list.push_back(CTFPlayerInfo(p.getUsername(),0,""));
		}
	}

	this.SetGlobalMessage("XENO - SUSIK");
	this.set("players", @players);
	this.SetCurrentState(GAME);
}