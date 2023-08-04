#define SERVER_ONLY

#include "RespawnCommon"

const string startClass = "soldat";  	//the class that players will spawn as
const u32 spawnTimeLeniency = 30;     	//players can insta-respawn for this many seconds after dawn comes
const u32 spawnTimeMargin = 8;        	//max amount of random seconds we can give to respawns
const u32 spawnTimeSeconds = 3;       	//respawn duration during insta-respawn seconds
const u16 dayRespawnUndeadMax = 5;    	//amount of zombies allowed before we disable full day insta respawns

void onInit(CRules@ this)
{
	Respawn[] respawns;
	this.set("respawns", respawns);
}

void onRestart(CRules@ this)
{
	this.clear("respawns");
	
	const u32 gameTime = getGameTime();
	const u8 plyCount = getPlayerCount();
	for (u8 i = 0; i < plyCount; i++)
	{
		addRespawn(this, getPlayer(i), gameTime + 90);
		
		CPlayer@ player = getPlayer(i);
		string player_name = player.getUsername();
		this.set_bool(player_name + "helm", false);
	}
}

void onTick(CRules@ this)
{
	const u32 gametime = getGameTime();
	if (gametime % 30 == 0)
	{
		Respawn[]@ respawns;
		if (!this.get("respawns", @respawns)) return;
		
		for (u8 i = 0; i < respawns.length; i++)
		{
			Respawn@ r = respawns[i];
			if (r.timeStarted > gametime) continue;
			
			spawnPlayer(this, getPlayerByUsername(r.username));
			respawns.erase(i);
			i = 0;
		}
	}
}

void onBlobDie(CRules@ this, CBlob@ blob)
{
	Respawn[]@ respawns;
	if (!this.get("respawns", @respawns)) return;
	
	CPlayer@ player = blob.getPlayer();
	
	if (player !is null) {
		string player_name = player.getUsername();
		this.set_bool(player_name + "helm", false);
		this.set_string(player_name + "class", blob.getName());
		if (!isRespawnAdded(this, player.getUsername()))
		{
			addRespawn(this, player, getGameTime() + 60);
		}
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	string playerName = player.getUsername().split('~')[0];
	this.set_u8(playerName+"team", 1);
	player.server_setTeamNum(XORRandom(2));
	addRespawn(this, player, getTimeTillRespawn(this));
}

void onPlayerRequestSpawn(CRules@ this, CPlayer@ player)
{
	
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
		
		if (player !is null) {
			if (!isRespawnAdded(this, player.getUsername()))
			{
				addRespawn(this, player, getGameTime() + 60);
			}
		}
	}
}

void addRespawn(CRules@ this, CPlayer@ player, const int&in timeTillRespawn)
{
	Respawn r(player.getUsername(), timeTillRespawn);
	this.push("respawns", r);
	syncRespawnTime(this, player, timeTillRespawn);
}

const bool isRespawnAdded(CRules@ this, const string&in username)
{
	Respawn[]@ respawns;
	if (this.get("respawns", @respawns))
	{
		const u8 respawnLength = respawns.length;
		for (u8 i = 0; i < respawnLength; i++)
		{
			Respawn@ r = respawns[i];
			if (r.username == username)
				return true;
		}
	}
	return false;
}

void clearIfRespawnAdded(CRules@ this, const string&in username)
{
	Respawn[]@ respawns;
	if (this.get("respawns", @respawns))
	{
		const u8 respawnLength = respawns.length;
		for (u8 i = 0; i < respawnLength; i++)
		{
			Respawn@ r = respawns[i];
			if (r.username == username)
				respawns.erase(i);
		}
	}
}

const int getTimeTillRespawn(CRules@ this)
{
	const u32 gametime = getGameTime();
	const u32 day_cycle = this.daycycle_speed * 60;
	
	const u32 timeElapsed = (gametime / getTicksASecond()) % day_cycle;
	const int timeTillDawn = (day_cycle - timeElapsed + XORRandom(spawnTimeMargin)) * getTicksASecond();
	
	const bool skipWait = skipRespawnWait(this, timeElapsed);
	const int timeTillRespawn = skipWait ? spawnTimeSeconds * getTicksASecond() : timeTillDawn;
	
	return 90 + gametime;
}

const bool skipRespawnWait(CRules@ this, const u32&in timeElapsed)
{
	CMap@ map = getMap();
	return
		(this.isWarmup()) ||
		(timeElapsed <= spawnTimeLeniency) ||
		(this.get_u16("undead count") <= dayRespawnUndeadMax && map.getDayTime() > 0.2f && map.getDayTime() < 0.7f);
}

void spawnPlayer(CRules@ this, CPlayer@ player)
{
	if (player !is null)
	{
		player.client_RequestSpawn();
	}
	if (player !is null)
	{
		//remove previous players blob
		CBlob@ blob = player.getBlob();
		if (blob !is null)
		{
			if (!blob.hasTag("dead")) return;
				
			blob.server_SetPlayer(null);
			blob.server_Die();
		}

		string playerName = player.getUsername().split('~')[0];
		u8 teamnum = this.get_u8(playerName+"team");
		teamnum = player.getTeamNum();
		if (teamnum == this.getSpectatorTeamNum()) return;
		Vec2f spawnPos = getSpawnLocation(teamnum);
		string player_class = this.get_string(playerName + "class");
		CBlob@ newBlob = server_CreateBlob(player_class.empty()?"soldat":player_class, teamnum, spawnPos);
		newBlob.server_SetPlayer(player);
		if (newBlob.getName()=="soldat") {
			newBlob.Tag("needs_weps");
		}
		CBitStream params;
		params.write_Vec2f(spawnPos);
		this.SendCommand(this.getCommandID("make_respawn_animation"),params);
	}
}

Vec2f getSpawnLocation(const u8 teamnum = 7)
{
	CMap@ map = getMap();
	Vec2f spawnPos = Vec2f(XORRandom(map.tilemapwidth * map.tilesize), 0);
	
	CBlob@[] spawns;
	CBlob@[] team_spawns;
	if (getBlobsByTag("spawn", spawns)) {
		for (int counter = 0; counter<spawns.size(); ++counter) {
			CBlob@ spawn = spawns[counter];
			if (spawn !is null) {
				if (spawn.getTeamNum() == teamnum)
					team_spawns.push_back(spawn);
			}
		}
		if (team_spawns.size() != 0)
			return team_spawns[XORRandom(team_spawns.size())].getPosition();
		else
			return spawnPos;
	}
	return spawnPos;
}

void syncRespawnTime(CRules@ this, CPlayer@ player, const u32&in time)
{
	this.set_u32("respawn time", time);
	this.SyncToPlayer("respawn time", player);
}
