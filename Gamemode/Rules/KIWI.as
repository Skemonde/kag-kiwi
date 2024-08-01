//#define SERVER_ONLY

#include "RulesCore"
#include "RespawnSystem"
#include "CTF_Structs"
#include "KIWI_Locales"
#include "Zombattle"
#include "VarsSync"
#include "SteelCrusherCommon"

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
	
	server_AddSoldatInfo(SoldatInfo(player));
	server_SyncPlayerVars(getRules());
	
	player.server_setCoins(250);
	
	if (!isServer()) return;
	CBitStream params;
	this.SendCommand(this.getCommandID("on_player_join"), params);
	
	//this part doesn't work as intended and causes null pointer issues
	/* 
	SoldatInfo@ info = getSoldatInfoFromUsername(player.getUsername());
	if (info is null) {
		server_AddSoldatInfo(SoldatInfo(player));
		CBitStream params;
		this.SendCommand(this.getCommandID("on_player_join"), params);
	}
	 */
}

void onPlayerLeave( CRules@ this, CPlayer@ player )
{
	server_ReassignCommander(player);
	server_RemoveSoldatInfo(player);
	
	server_SyncPlayerVars(this);
}

void onPlayerChangedTeam( CRules@ this, CPlayer@ player, u8 oldteam, u8 newteam )
{
	if (getGameTime()<10) return;
	server_ReassignCommander(player, oldteam);
	server_CheckIfShouldBecomeCommanding(player, newteam);
	server_SyncPlayerVars(this);
}

void onPlayerDie( CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData )
{
	CPlayer@ local = getLocalPlayer();
	if (victim !is local) return;
	Sound::Play2D("mm_clocktower_bell", 10.0f, 1.0f);
}

void onInit(CRules@ this)
{
	this.set_bool("show_gamehelp", true);
	this.set_bool("ammo_usage_enabled", true);
	this.set_bool("cursor_recoil_enabled", true);
	if (!this.exists("default class"))
	{
		//for testing ill make it better way later - skemonde 15.02.23
		this.set_string("default class", "soldat");
	}
	this.addCommandID("on_player_join");
	this.addCommandID("sync_player_vars");
	this.addCommandID("sync_gamemode_vars");
	this.addCommandID("sync_sdf_vars");
	this.addCommandID("sync_soldat_info");
	
	Reset(this);
	
	this.set_u8("wt_channel_max", 10);
	this.set_u8("wt_channel_min", 3);
}

void onMatchStart()
{
	CRules@ rules = getRules();
	if (rules.hasTag("match_has_already_started")) return;
	//print("hello from match starting!!!");
	CBlob@[] crushers;
	getBlobsByName("crusher", crushers);
	for (int crusher_id = 0; crusher_id<crushers.size(); ++crusher_id) {
		CBlob@ crusher = crushers[crusher_id];
		if (crusher is null) continue;
		crusher.set_u32("last_produce", getGameTime()+getProducingInterval()+XORRandom(getProducingInterval()));
	}
	
	rules.Tag("match_has_already_started");
}

void onTick(CRules@ this)
{
	//just in case i want it to be synced from this trigger
	if (getGameTime()%600==0) server_SyncPlayerVars(this);
	if (getGameTime()%600==0) server_SyncGamemodeVars(this);
}

Vec2f getZombSpawnPos()
{
	CBlob@[] portals;
	Vec2f portal_pos = Vec2f_zero;
	if (getBlobsByName("zombieportal", portals)) {
		portal_pos = portals[XORRandom(portals.length)].getPosition();
	}
	return portal_pos;
}

void onCommand( CRules@ this, u8 cmd, CBitStream @params )
{
	if(cmd == this.getCommandID("sync_player_vars"))
	{
		if (isClient())
		{
			string player_name; if (!params.saferead_string(player_name)) return;
			bool helm; if (!params.saferead_bool(helm)) return;
			u8 rank; if (!params.saferead_u8(rank)) return;
			bool pickup; if (!params.saferead_bool(pickup)) return;
			string hat; if (!params.saferead_string(hat)) return;
			string pclass; if (!params.saferead_string(pclass)) return;
			string hat_script; if (!params.saferead_string(hat_script)) return;
			
			this.set_bool(player_name + "helm", helm);
			this.set_u8(player_name + "rank", rank);
			this.set_bool(player_name + "autopickup", pickup);
			this.set_string(player_name + "hat_name", hat);
			this.set_string(player_name + "class", pclass);
			this.set_string(player_name + "hat_script", hat_script);
		}
	}
	if(cmd == this.getCommandID("sync_gamemode_vars"))
	{
		if (!isClient()||isServer()) return;
		bool ammo; if (!params.saferead_bool(ammo)) return;
		u32 match; if (!params.saferead_u32(match)) return;
		f32 blue_points; if (!params.saferead_f32(blue_points)) return;
		f32 red_points; if (!params.saferead_f32(red_points)) return;
		f32 victory_points; if (!params.saferead_f32(victory_points)) return;
		f32 winning_gap; if (!params.saferead_f32(winning_gap)) return;
		u16 daycycle; if (!params.saferead_u16(daycycle)) return;
		bool quit; if (!params.saferead_bool(quit)) return;
		u8 team6flags; if (!params.saferead_u8(team6flags)) return;
		u8 team1flags; if (!params.saferead_u8(team1flags)) return;
		bool recoil; if (!params.saferead_bool(recoil)) return;
		bool free_shops; if (!params.saferead_bool(free_shops)) return;
		u32 tags_6; if (!params.saferead_u32(tags_6)) return;
		u32 tags_1; if (!params.saferead_u32(tags_1)) return;
		
		this.set_bool("ammo_usage_enabled", ammo);
		this.set_u32("match_time", match);
		this.set_f32("blue points", blue_points);
		this.set_f32("red points", red_points);
		this.set_f32("victory points", victory_points);
		this.set_f32("winning gap points", winning_gap);
		this.daycycle_speed = daycycle;
		this.set_bool("quit_on_new_map", quit);
		this.set_u8("team6flags", team6flags);
		this.set_u8("team1flags", team1flags);
		this.set_bool("cursor_recoil_enabled", recoil);
		this.set_bool("free shops", free_shops);
		this.set_u32("team_6_tags", tags_6);
		this.set_u32("team_1_tags", tags_1);
	}
	if(cmd == this.getCommandID("sync_sdf_vars"))
	{
		if (!isClient()||isServer()) return;
		SDFVars@ sdf_vars = SDFVars(params);
		this.set("sdf_vars", @sdf_vars);
	}
	if(cmd == this.getCommandID("sync_soldat_info"))
	{
		if (!isClient()) return;
		
		SoldatInfo@ new_info = SoldatInfo(params);
		
		SoldatInfo@ old_info = getSoldatInfoFromUsername(new_info.username);
		
		SoldatInfo[]@ infos = getSoldatInfosFromRules();
		if (infos is null) return;
		//print("got there");
		int array_idx = getInfoArrayIdx(old_info);
		//if (array_idx < 0) return;
		
		//if client infos got obj for the player we replace it
		if (array_idx > -1)
			infos[array_idx] = new_info;
		//else we crate a new object
		else
			infos.push_back(new_info);
		
		getRules().set("soldat_infos", infos);
	}
}

bool enabled_shaders = false;
void onRender(CRules@ this)
{
	return;
	if (!isClient()) return;

	if (!enabled_shaders && getLocalPlayer() !is null)
	{
		Driver@ driver = getDriver();
		
		{
			driver.AddShader("../Mods/kag-kiwi/Shaders/blcknwht", 0.1f);
			driver.SetShader("../Mods/kag-kiwi/Shaders/blcknwht", true);
			driver.RemoveShader("hq2x");

			enabled_shaders = true;
		}

		return;
	}
	
	if (enabled_shaders)
	{
		Driver@ driver = getDriver();
		if (!driver.ShaderState())
		{
			driver.ForceStartShaders();
		}
	}
}

void onRestart(CRules@ this)
{
	//makes server quit. Golden Guy's server restarts after a quittin so it's pretty much a restart
	//it's made so admins don't need to wait for a match ending to restart the game and they can set it to be restaerted
	//with a chat command !reboot
	if (this.get_bool("quit_on_new_map")&&isServer()) {
		QuitGame();
	}
	
	Reset(this);
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

void PrintAllCommandNames(CRules@ this)
{
	int cmd_idx = 0;
	while (cmd_idx<256)
	{
		print(""+this.getNameFromCommandID(cmd_idx));
		++cmd_idx;
	}
}

void Reset(CRules@ this)
{		
	this.Untag("match_has_already_started");
	
	ZombattleVars game_vars(0, getGameTime(), 0);
		game_vars.SetZombsMaximum(50);
	this.set("zombattle_vars", @game_vars);
	
	SDFVars@ sdf_vars;
	if (!this.get("sdf_vars", @sdf_vars)) {
		@sdf_vars = SDFVars(0);
		sdf_vars.SetMatchEngingTime(getTicksFromMinutes(30));
		this.set("sdf_vars", @sdf_vars);
	}
	else {
		sdf_vars.SetMatchTime(0);
		sdf_vars.SetMatchEngingTime(getTicksFromMinutes(30));
	}

	Players players();

	SoldatInfo[] soldat_infos;
	for(u8 i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ p = getPlayer(i);
		if(p !is null)
		{
			p.set_u32("respawn time", getGameTime() + (30 * 1));
			p.server_setCoins(250);

			//p.server_setTeamNum(p.getTeamNum());
			p.setKills(0);
			//this.set_u8(p.getUsername()+"rank", 0);
			players.list.push_back(CTFPlayerInfo(p.getUsername(),0,""));
			
			SoldatInfo@ soldat_info = SoldatInfo(p);
			soldat_infos.push_back(soldat_info);
		}
	}
	this.set("soldat_infos", soldat_infos);
	server_SyncPlayerVars(this);
	
	//reseting platoon leader roles
	this.set_string("0leader", "");
	this.set_string("1leader", "");
	
	this.set_s32("tickets_6", 1.0f*getMap().tilemapwidth/8);
	this.set_s32("tickets_1", 1.0f*getMap().tilemapwidth/8);
	
	this.set_u8("team6flags", 0);
	this.set_u8("team1flags", 0);
	
	this.set_u32("team_6_tags", 2000);
	this.set_u32("team_1_tags", 2000);
	
	this.set_bool("quit_on_new_map", false);
	this.set_bool("free shops", false);
	this.set_bool("ammo_usage_enabled", true);
	this.set_u32("match_time", 0);
	this.set_u8("seconds_pinging", 0);
	//ToW stuff
	this.set_f32("blue points", 0);
	this.set_f32("red points", 0);
	this.set_f32("victory points", 10000);
	this.set_f32("winning gap points", 1000);
	//end of tow stuff
	
	this.SetGlobalMessage("XENO - SUSIK");
	this.set("players", @players);
	this.SetCurrentState(GAME);
	
	this.SetGlobalMessage("\n\nTAKE A GUN\nCOMMIT A WARCRIME :3\n\n");
	//getMap().MakeMiniMap();
}