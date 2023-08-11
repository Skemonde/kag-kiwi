//#define SERVER_ONLY

#include "RulesCore"
#include "RespawnSystem"
#include "CTF_Structs"
#include "KIWI_Locales"
#include "Zombattle"
#include "SDF"
#include "TugOfWarPoints"
#include "SteelCrusherCommon"

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

void onPlayerRequestHeadChange( CRules@ this, CPlayer@ player, u8 head )
{
	//dunno if it works tho...
	if (player !is null) {
		CBlob@ blob = player.getBlob();
		if (blob !is null) {
			//this updates hat layer :P
			blob.getSprite().RemoveSpriteLayer("hat");
			blob.getSprite().RemoveSpriteLayer("head");
			print("guy asked for a new head uwu");
		}
	}
}

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
				//KickPlayer(player);//Clone
				//playerBlob.server_SetPlayer(maybePlayer);//switch souls
			}
		}
	}
	
	if (!this.exists(playerName+"autopickup")) {
		player.server_setCoins(50);
		this.set_bool(playerName + "autopickup", true);
	}
	if (!this.exists(playerName+"rank"))
		this.set_u8(playerName + "rank", 0);
}

void onPlayerDie( CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData )
{
	CPlayer@ local = getLocalPlayer();
	if (victim !is local) return;
	Sound::Play2D("mm_clocktower_bell", 30.0f, 1.0f);
}

void onInit(CRules@ this)
{
	this.set_bool("ammo_usage_enabled", true);
	if (!this.exists("default class"))
	{
		//for testing ill make it better way later - skemonde 15.02.23
		this.set_string("default class", "soldat");
	}
	this.addCommandID("make_respawn_animation");
	this.addCommandID("sync_player_vars");
	this.addCommandID("sync_gamemode_vars");
	this.addCommandID("sync_sdf_vars");
	Reset(this);
	
	//RespawnSystem@ respawn_system;
	//this.set("respawn system", respawn_system);
	//RulesCore@ core = RulesCore(this, respawn_system);
	//this.set("core", @core);
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
	server_SyncPlayerVars(this);
	server_SyncGamemodeVars(this);
	
	s32 gameTime = getGameTime();
	const u32 day_cycle = this.daycycle_speed>0?(this.daycycle_speed * 60):-1;
	const u8 dayNumber = (gameTime / getTicksASecond() / day_cycle) + 1;
	//this.set_u8("TheCustomerManrank", 8);
	this.set_u8("Artisrank", 4);
	this.set_u8("Ferrezinhrerank", 3);
	
	ZombattleVars@ game_vars;
	if (!this.get("zombattle_vars", @game_vars)) return;
	SDFVars@ sdf_vars;
	if (!this.get("sdf_vars", @sdf_vars)) return;
	
	u32 ticks_left = Maths::Max(0, sdf_vars.getMatchTime()-gameTime);
	f32 minutes_left = ticks_left/(getTicksFromSeconds(60));
	f32 seconds_left = (ticks_left%(getTicksFromSeconds(60)))/getTicksASecond();
	if (ticks_left > 0)
		this.set_u32("match_time", ticks_left);
	//TODO: team data class for setting a team's name from locales - skemonde 01.03.23
	
	if (ticks_left == 0)
		onMatchStart();
	
	Vec2f zomb_spawn_pos = getZombSpawnPos();
	bool zombs_have_spawn = zomb_spawn_pos!=Vec2f_zero;
	
	u32 ticks_to_enging = Maths::Max(0, sdf_vars.getMatchEngingTime()-gameTime);
	f32 minutes_to_enging = ticks_to_enging/(getTicksFromSeconds(60));
	f32 seconds_to_enging = (ticks_to_enging%(getTicksFromSeconds(60)))/getTicksASecond();
	
	string minute_timer = formatFloat(minutes_left, "0", 2, 0)+":"+formatFloat(seconds_left, "0", 2, 0);
	string enging_timer = formatFloat(minutes_to_enging, "0", 2, 0)+":"+formatFloat(seconds_to_enging, "0", 2, 0);
	
	if (!this.isGameOver() && !zombs_have_spawn) {
		this.set_u8("seconds_pinging", 20);
		this.SetGlobalMessage(ticks_left>0?("Build defenses!!\n\n"+minute_timer):("Capture as many flags as possible!!\n\n"+enging_timer));
		f32 blue_points = this.get_f32("blue points");
		f32 red_points = this.get_f32("red points");
		f32 victory_points = this.get_f32("victory points");
		f32 winning_gap_points = this.get_f32("winning gap points");
		f32 points_diff = blue_points-red_points;
		
		if (ticks_to_enging<1) {
			u8 blue_flags = this.get_u8("team0flags");
			u8 red_flags = this.get_u8("team1flags");
			if (red_flags>blue_flags) {
				this.SetTeamWon(0);   //game over!
				this.SetCurrentState(GAME_OVER);
				this.SetGlobalMessage("Clettan army has won!");
			} else
			if (blue_flags>red_flags) {
				this.SetTeamWon(1);   //game over!
				this.SetCurrentState(GAME_OVER);
				this.SetGlobalMessage("Army of Imperata has won!");
			} else
			if (blue_flags==red_flags) {
				sdf_vars.SetMatchEngingTime(sdf_vars.getMatchEngingTime()+(getTicksFromMinutes(5)));
			}
		}
		
		if (Maths::Abs(points_diff) > winning_gap_points) {
			if (blue_points>=victory_points && points_diff > 0) {
				this.SetTeamWon(0);   //game over!
				this.SetCurrentState(GAME_OVER);
				this.SetGlobalMessage("Clettan army has won!");
			} else if (red_points>=victory_points) {
				this.SetTeamWon(1);   //game over!
				this.SetCurrentState(GAME_OVER);
				this.SetGlobalMessage("Army of Imperata has won!");
			}
		}
		
		//adding points
		if (ticks_left==0 && gameTime % (getTicksASecond()*5) == 0) {
			this.SetCurrentState(GAME);
			this.add_f32("blue points", getPointsPerTick_Zones(0, 5));
			this.add_f32("red points", getPointsPerTick_Zones(1, 5));
		}
	}
	
	//IF GAMEMODE IS ABOUT ZOMBS
	if (zombs_have_spawn) {
		this.set_u8("seconds_pinging", 30);
		//gameover for zombs mode
		if (noSpawns()) {
			//teamnum is 3 because in my mod that's zombie team
			//if i decide to make some kind of playable zombies they'll hear a winning fanfare upon.. emm ..winning?
			this.SetTeamWon(3);   //game over!
			this.SetCurrentState(GAME_OVER);
			this.SetGlobalMessage("NO RESPAWNS AVAILABLE\nMANKIND HAVE LOST THE WAR");
		}
		ticks_left = Maths::Max(0, game_vars.recess_time+game_vars.recess_start-gameTime);
		minutes_left = ticks_left/(60*getTicksASecond());
		seconds_left = (ticks_left%(60*getTicksASecond()))/getTicksASecond();
		CBlob@[] zombs;
		getBlobsByTag("undead", zombs);
		u8 difficulty = Maths::Floor((game_vars.waves_survived+1)/5);
		if (!this.isGameOver()) {
			if (this.isIntermission()) {
				this.SetGlobalMessage("Recess! Next wave in: "+formatFloat(minutes_left, "0", 2, 0)+":"+formatFloat(seconds_left, "0", 2, 0)+
					"\nDay: "+dayNumber+
					"\nWaves survived: "+game_vars.waves_survived+ 
					(zombs.size()<1
						? game_vars.waves_survived == 0 
							? "\nPrepare to fight!"
							: "\nWell done!"
						:("\nZombs left: "+zombs.size()))+
					"\nZombs max: "+(game_vars.zombs_max));
			} else if (this.isMatchRunning()) {
				this.SetGlobalMessage("WAVE "+formatFloat(game_vars.waves_survived+1, "0", 2, 0)+
					"\nWave progression: "+zombs_spawned+"/"+zombs_per_wave);
			}
		}
	
		if (game_vars.recess_time > 0 && ticks_left!=0) {
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
			
			const u32 spawnRate = getTicksASecond() * (4 - difficulty*0.5);
			if (zombs.size() < game_vars.zombs_max && zombs_have_spawn) {
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
						CBlob@ zomb = server_CreateBlob(zombs[XORRandom(zombs.length)], 3, zomb_spawn_pos);
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
	}
	//this.set_u32("match_time", ticks_left);
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

void server_SyncPlayerVars(CRules@ this)
{
	if (isServer())
	{
		for (u8 player_idx = 0; player_idx < getPlayerCount(); player_idx++)
		{
			CPlayer@ player = getPlayer(player_idx);
			if (player is null) return;
			CBitStream stream;
			string player_name = player.getUsername();
			stream.write_string(player_name);
			stream.write_bool(this.get_bool(player_name + "helm"));
			stream.write_u8(this.get_u8(player_name+"rank"));
			stream.write_bool(this.get_bool(player_name + "autopickup"));
			stream.write_string(this.get_string(player_name + "hat_name"));
			stream.write_string(this.get_string(player_name + "class"));
			stream.write_string(this.get_string(player_name + "hat_script"));
			
			this.SendCommand(this.getCommandID("sync_player_vars"), stream);
		}
	}
}

void server_SyncGamemodeVars(CRules@ this)
{
	if (!isServer()||isClient()) return;
	
	CBitStream stream;
	stream.write_bool(this.get_bool("ammo_usage_enabled"));
	stream.write_u32(this.get_u32("match_time"));
	
	stream.write_f32(this.get_f32("blue points"));
	stream.write_f32(this.get_f32("red points"));
	stream.write_f32(this.get_f32("victory points"));
	stream.write_f32(this.get_f32("winning gap points"));
	stream.write_u16(this.daycycle_speed);
	stream.write_bool(this.get_bool("quit_on_new_map"));
	stream.write_u8(this.get_u8("team0flags"));
	stream.write_u8(this.get_u8("team1flags"));
	
	
	this.SendCommand(this.getCommandID("sync_gamemode_vars"), stream);
	
	SDFVars@ sdf_vars;
	if (!this.get("sdf_vars", @sdf_vars)) return;
	CBitStream SDFparams;
	sdf_vars.serialize(SDFparams);
	this.SendCommand(this.getCommandID("sync_sdf_vars"), SDFparams);
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
		u8 team0flags; if (!params.saferead_u8(team0flags)) return;
		u8 team1flags; if (!params.saferead_u8(team1flags)) return;
		
		this.set_bool("ammo_usage_enabled", ammo);
		this.set_u32("match_time", match);
		this.set_f32("blue points", blue_points);
		this.set_f32("red points", red_points);
		this.set_f32("victory points", victory_points);
		this.set_f32("winning gap points", winning_gap);
		this.daycycle_speed = daycycle;
		this.set_bool("quit_on_new_map", quit);
		this.set_u8("team0flags", team0flags);
		this.set_u8("team1flags", team1flags);
	}
	if(cmd == this.getCommandID("sync_sdf_vars"))
	{
		if (!isClient()||isServer()) return;
		SDFVars@ sdf_vars = SDFVars(params);
		this.set("sdf_vars", @sdf_vars);
	}
}

void onRestart(CRules@ this)
{
	//makes server quit. Golden Guy's server restarts after a quittin so it's pretty much a restart
	//it's made so admins don't need to way for a match ending to restart the game and they can set it to be restaerted
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

void Reset(CRules@ this)
{	
	this.Untag("match_has_already_started");
	ZombattleVars game_vars(first_recess, getGameTime(), 0);
		game_vars.SetZombsMaximum(50);
	this.set("zombattle_vars", @game_vars);
	
	SDFVars@ sdf_vars;
	if (!this.get("sdf_vars", @sdf_vars)) {
		@sdf_vars = SDFVars(getTicksFromMinutes(3));
		sdf_vars.SetMatchEngingTime(getTicksFromMinutes(30));
		this.set("sdf_vars", @sdf_vars);
	}
	else {
		sdf_vars.SetMatchTime(getTicksFromMinutes(3));
		sdf_vars.SetMatchEngingTime(getTicksFromMinutes(30));
	}

	Players players();

	for(u8 i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ p = getPlayer(i);
		if(p !is null)
		{
			p.set_u32("respawn time", getGameTime() + (30 * 1));
			p.server_setCoins(50);

			//p.server_setTeamNum(p.getTeamNum());
			p.setKills(0);
			this.set_u8(p.getUsername()+"rank", 0);
			players.list.push_back(CTFPlayerInfo(p.getUsername(),0,""));
		}
	}
	
	//reseting platoon leader roles
	this.set_string("0leader", "");
	this.set_string("1leader", "");
	
	this.set_u8("team0flags", 0);
	this.set_u8("team1flags", 0);
	
	this.set_bool("quit_on_new_map", false);
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
	this.SetCurrentState(WARMUP);
	//getMap().MakeMiniMap();
}