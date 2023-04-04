//#define SERVER_ONLY

#include "RulesCore"
#include "RespawnSystem"
#include "CTF_Structs"
#include "KIWI_Locales"
#include "Zombattle"

const u32 first_recess = 5*60*getTicksASecond();
const u32 minor_recess = 2*60*getTicksASecond();
const u32 major_recess = 7*60*getTicksASecond();
u16 zombs_spawned = 0;
u16 zombs_per_wave = 0;

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
				KickPlayer(player);//Clone
				playerBlob.server_SetPlayer(maybePlayer);//switch souls
			}
		}
	}
	
	player.server_setCoins(50);
	this.set_bool(playerName + "autopickup", !this.get_bool(playerName + "autopickup"));
	this.Sync(playerName + "autopickup", true);
	this.set_u8(playerName+"team", 1);
	player.server_setTeamNum(1);
}

void onTick(CRules@ this)
{
	s32 gameTime = getGameTime();
	const u32 day_cycle = this.daycycle_speed * 60;
	const u8 dayNumber = (gameTime / getTicksASecond() / day_cycle) + 1;
	ZombattleVars@ game_vars;
	if (!this.get("zombattle_vars", @game_vars)) return;
	u8 difficulty = Maths::Floor((game_vars.waves_survived+1)/5);
	u32 ticks_left = game_vars.recess_time+game_vars.recess_start-gameTime;
	f32 minutes_left = ticks_left/(60*getTicksASecond());
	f32 seconds_left = (ticks_left%(60*getTicksASecond()))/getTicksASecond();
	
	//TODO: team data class for setting a team's name from locales - skemonde 01.03.23
	
	CBlob@[] zombs;
	getBlobsByTag("undead", zombs);
	
	if (!this.isGameOver()) {
		if (this.isIntermission()) {
			this.SetGlobalMessage("Recess! Next wave in: "+formatFloat(minutes_left, "0", 2, 0)+":"+formatFloat(seconds_left, "0", 2, 0)+
				"\nDay: "+dayNumber+
				"\nWaves survived: "+game_vars.waves_survived+ 
				(zombs.length()<1
					? game_vars.waves_survived == 0 
						? "\nPrepare to fight!"
						: "\nWell done!"
					:("\nZombs left: "+zombs.length()))+
				"\nZombs max: "+(game_vars.zombs_max));
		} else if (this.isMatchRunning()) {
			this.SetGlobalMessage("WAVE "+formatFloat(game_vars.waves_survived+1, "0", 2, 0)+
				"\nWave progression: "+zombs_spawned+"/"+zombs_per_wave);
		}
	}

	if (game_vars.recess_time > 0 && gameTime<game_vars.recess_time+game_vars.recess_start-getTicksASecond()) {
		//WARMUP
		this.SetCurrentState(INTERMISSION);
		CBlob@[] gates;
		if (getBlobsByName("cavedoor", gates))
		{	
			if (gates.length>0) {
				for (int i = 0; i < gates.length; ++i) {
					CBlob@ gate = gates[i];
					if (gate !is null) {
						if ((game_vars.waves_survived+1)%5==0) {
							if (!gate.get_bool("security_state")) {
								CBitStream params;
								params.write_bool(true);
								gate.SendCommand(gate.getCommandID("security_set_state"), params);
								print("opened the door");
							}
						} else {
							if (gate.get_bool("security_state")) {
								CBitStream params;
								params.write_bool(false);
								gate.SendCommand(gate.getCommandID("security_set_state"), params);
								print("closed the door");
							}
						}
					}
				}
			}
		}
	}
	else {
		//GAME
		this.SetCurrentState(GAME);
		zombs_per_wave = 20;
		zombs_per_wave = zombs_per_wave + zombs_per_wave/4*game_vars.waves_survived;
		CBlob@[] portals;
		Vec2f portal_pos = Vec2f_zero;
		bool zombs_have_spawn = false;
		if (getBlobsByName("zombieportal", portals)) {
			zombs_have_spawn = true;
			portal_pos = portals[XORRandom(portals.length)].getPosition();
		}
		
		const u32 spawnRate = getTicksASecond() * (4 - difficulty*0.5);
		if (zombs.length() < game_vars.zombs_max && zombs_have_spawn) {
			if (gameTime % spawnRate == 0) {
				const u32 rand = XORRandom(100);
				string[] zombs;
				zombs.push_back("zombie");
				//zombs.push_back("skeleton");
				
				//if (difficulty>3)
					
				if (difficulty>2)
					zombs.push_back("wraith");
				if (difficulty>1)
					zombs.push_back("zombiesoldat");
				if (difficulty>0)
					zombs.push_back("zombieknight");					
				
				if (isServer()) {
					CBlob@ zomb = server_CreateBlob(zombs[XORRandom(zombs.length)], 3, portal_pos);
					if (zomb !is null) {
						zomb.server_SetHealth(zomb.getInitialHealth()+0.5f*difficulty);
					}
				}
				zombs_spawned += 1;
			}
		}
		
		//before each 5th wave (5, 10, 15) you have a longer break
		if (zombs_per_wave <= zombs_spawned) {
			f32 recess =((game_vars.waves_survived+2)%5==0? major_recess : Maths::Min(3*zombs_per_wave*60*getTicksASecond(), minor_recess));
			//reset spawned zombs amount
			zombs_spawned = 0;
			ZombattleVars new_vars(recess, getGameTime(), game_vars.waves_survived+1);
			this.set("zombattle_vars", @new_vars);
		}
	}
	
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
			if (blob is null && player.get_u32("respawn time") <= gameTime)
			{
				//Respawn(this, player);
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
		string playerName = player.getUsername().split('~')[0];
		this.set_u8(playerName+"team", newteam);
		
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
	if (isClient() && !(isServer())) return null;
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
		
		string playerName = player.getUsername().split('~')[0];
		u8 teamnum = this.get_u8(playerName+"team");
		Vec2f pos = getSpawnLocation(player);
		CBlob@ newBlob = server_CreateBlob(this.get_string("default class"), teamnum, pos);
		Sound::Play("reinforcements.ogg", pos, 0.8, 1);
		newBlob.server_SetPlayer(player);
		newBlob.server_setTeamNum(teamnum);
		CBlob@ gun = server_CreateBlob("revo", -1, newBlob.getPosition());
		// we don't want a million of revolvers to lay around after several deaths
		// so basically blobs with this tag are doomed
		
		//TODO: ANY PLAYER DEATH WILL CAUSE ITEMS WITH THE TAG DIE. Tie supply items to player's usernames and kill the items only on their player's death or when the username cannot be found (player left the server) - skemonde 15.02.23
		
		gun.Tag("supply thing");
		// i'll give them a name of "rusty gun" or something so players can actually know which revolver won't server long
		// TODO: change starter weapon sprite. Maybe make a different types of a starter weapon. Make the revolver to be used only as a starter weapon? - skemonde 15.02.23
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
	ZombattleVars game_vars(first_recess, getGameTime(), 0);
		game_vars.SetZombsMaximum(50);
	this.set("zombattle_vars", @game_vars);

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
	this.SetCurrentState(WARMUP);
}