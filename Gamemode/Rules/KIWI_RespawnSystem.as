#include "RespawnSystem"
#include "RulesCore"
#include "KIWI_Players&Teams"
#include "KIWI_Locales"
#include "KIWI_RulesCore"


void onRestart(CRules@ this)
{
	Reset(this);
}

void onInit(CRules@ this)
{
	Reset(this);
}

void Reset(CRules@ this)
{
	KIWIRespawn spawns();
	KIWICore core(this, spawns);
	this.set("core", @core);
}
	
void onPlayerDie( CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData )
{
	victim.client_RequestSpawn();
	resetHeadwearFromUsername(victim.getUsername());
}

shared class KIWIRespawn : RespawnSystem
{
	KIWICore@ rules_core;
	
	s32 limit;
	
	void SetCore(RulesCore@ _core)
	{
		RespawnSystem::SetCore(_core);
		@rules_core = cast < KIWICore@ > (core);
		
		limit = 1;
	}

	void Update()
	{
		for (uint team_idx = 0; team_idx < rules_core.teams.length; ++team_idx)
		{
			KIWITeamInfo@ team = cast < KIWITeamInfo@ > (rules_core.teams[team_idx]);

			for (uint i = 0; i < team.spawns.length; i++)
			{
				KIWIPlayerInfo@ info = cast < KIWIPlayerInfo@ > (team.spawns[i]);

				UpdateSpawnTime(info, i);

				DoSpawnPlayer(info);
			}
		}
	}

	void UpdateSpawnTime(KIWIPlayerInfo@ info, int i)
	{
		if (info !is null)
		{
			u8 spawn_property = 255;

			if (info.can_spawn_time > 0)
			{
				info.can_spawn_time--;
				spawn_property = u8(Maths::Min(250, (info.can_spawn_time / 30)));
			}

			string propname = "kiwi spawn time " + info.username;

			rules_core.rules.set_u8(propname, spawn_property);
			rules_core.rules.SyncToPlayer(propname, getPlayerByUsername(info.username));
		}

	}

	void DoSpawnPlayer(PlayerInfo@ p_info)
	{
		if (canSpawnPlayer(p_info))
		{
			//limit how many spawn per second
			if (limit > 0)
			{
				limit--;
				return;
			}
			else
			{
				limit = 1;
			}
			
			Vec2f spawn_pos = getSpawnLocation(p_info);
			
			if (spawn_pos == Vec2f()) return;

			// tutorials hack
			if (getRules().hasTag("singleplayer"))
			{
				p_info.team = 0;
			}

			// spawn as builder in warmup
			if (getRules().isWarmup())
			{
				//p_info.blob_name = "engi";
			}

			CBlob@ spawnBlob = getSpawnBlob(p_info);

			if (spawnBlob !is null)
			{
				if (spawnBlob.exists("custom respawn immunity"))
				{
					p_info.customImmunityTime = spawnBlob.get_u8("custom respawn immunity");
				}
			}

			CPlayer@ player = getPlayerByUsername(p_info.username); // is still connected?

			if (player is null)
			{
				RemovePlayerFromSpawn(p_info);
				return;
			}
			if (player.getTeamNum() != int(p_info.team))
			{
				player.server_setTeamNum(p_info.team);
			}

			//NUH UH
			// remove previous players blob
			//if (player.getBlob() !is null)
			//{
			//	CBlob @blob = player.getBlob();
			//	blob.server_SetPlayer(null);
			//	blob.server_Die();
			//}

			CBlob@ playerBlob = SpawnPlayerIntoWorld(spawn_pos, p_info);

			if (playerBlob !is null)
			{
				// spawn resources
				p_info.spawnsCount++;
				RemovePlayerFromSpawn(player);
				
				playerBlob.Tag("needs_weps");
				playerBlob.SendCommand(playerBlob.getCommandID("set head to update"));
			}
		}
	}

	bool canSpawnPlayer(PlayerInfo@ p_info)
	{
		KIWIPlayerInfo@ info = cast < KIWIPlayerInfo@ > (p_info);

		if (info is null) { warn("KIWI LOGIC: Couldn't get player info ( in bool canSpawnPlayer(PlayerInfo@ p_info) ) "); return false; }

		//print (""+info.can_spawn_time <= 0);
		return info.can_spawn_time <= 0;
	}

	Vec2f getSpawnLocation(PlayerInfo@ p_info)
	{
		KIWIPlayerInfo@ c_info = cast < KIWIPlayerInfo@ > (p_info);
		
		if (c_info is null) return Vec2f();
		
		CMap@ map = getMap();
		Vec2f spawnPos = Vec2f(XORRandom(map.tilemapwidth * map.tilesize), 0);
		
		CBlob@[] spawns;
		CBlob@[] team_spawns;
		if (getBlobsByTag("spawn", spawns)) {
			for (int counter = 0; counter<spawns.size(); ++counter) {
				CBlob@ spawn = spawns[counter];
				if (spawn is null) continue;
				
				if (spawn.getTeamNum() == p_info.team)
					team_spawns.push_back(spawn);
			}
			if (team_spawns.size() != 0)
				return team_spawns[XORRandom(team_spawns.size())].getPosition()+Vec2f(-8+XORRandom(16),0);
			else
				return spawnPos;
		}

		return Vec2f();
	}

	CBlob@ getSpawnBlob(PlayerInfo@ p_info)
	{
		KIWIPlayerInfo@ c_info = cast < KIWIPlayerInfo@ > (p_info);
		
		if (c_info is null) return null;
		
		CMap@ map = getMap();
		Vec2f spawnPos = Vec2f(XORRandom(map.tilemapwidth * map.tilesize), 0);
		
		CBlob@[] spawns;
		CBlob@[] team_spawns;
		
		int choosen_spawn = -1;
		
		if (getBlobsByTag("spawn", spawns)) {
			for (int counter = 0; counter<spawns.size(); ++counter) {
				CBlob@ spawn = spawns[counter];
				if (spawn is null) continue;
				
				if (spawn.getTeamNum() == p_info.team)
					team_spawns.push_back(spawn);
			}
			if (team_spawns.size() != 0) {
				choosen_spawn = XORRandom(team_spawns.size());
				return team_spawns[choosen_spawn];
			}
			else
				return null;
		}

		return null;
	}

	void RemovePlayerFromSpawn(CPlayer@ player)
	{
		RemovePlayerFromSpawn(core.getInfoFromPlayer(player));
	}

	void RemovePlayerFromSpawn(PlayerInfo@ p_info)
	{
		KIWIPlayerInfo@ info = cast < KIWIPlayerInfo@ > (p_info);

		if (info is null) { warn("Couldn't get player info ( in void RemovePlayerFromSpawn(PlayerInfo@ p_info) )"); return; }

		string propname = "kiwi spawn time " + info.username;

		for (uint i = 0; i < rules_core.teams.length; i++)
		{
			KIWITeamInfo@ team = cast < KIWITeamInfo@ > (rules_core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1)
			{
				team.spawns.erase(pos);
				break;
			}
		}

		rules_core.rules.set_u8(propname, 255);   //not respawning
		rules_core.rules.SyncToPlayer(propname, getPlayerByUsername(info.username));

		//DONT set this zero - we can re-use it if we didn't actually spawn
		//info.can_spawn_time = 0;
	}

	void AddPlayerToSpawn(CPlayer@ player)
	{
		s32 tickspawndelay = s32(6*getTicksASecond());
		tickspawndelay = 1;

		KIWIPlayerInfo@ info = cast < KIWIPlayerInfo@ > (core.getInfoFromPlayer(player));

		if (info is null) { warn("Couldn't get player info  ( in void AddPlayerToSpawn(CPlayer@ player) )"); return; }

		//clamp it so old bad values don't get propagated
		s32 old_spawn_time = Maths::Max(0, Maths::Min(info.can_spawn_time, tickspawndelay));

		RemovePlayerFromSpawn(player);
		if (player.getTeamNum() == core.rules.getSpectatorTeamNum())
			return;

		//if (info.team < rules_core.teams.length)
		if (teamsHaveThisTeam(rules_core.teams, info.team))
		{
			KIWITeamInfo@ team = cast < KIWITeamInfo@ > (rules_core.teams[getArrayIndexFromTeamNum(rules_core.teams, info.team)]);

			info.can_spawn_time = ((old_spawn_time > 30) ? old_spawn_time : tickspawndelay);

			info.spawn_point = player.getSpawnPoint();
			team.spawns.push_back(info);
		}
		else
		{
			error("PLAYER TEAM NOT SET CORRECTLY! " + info.team + " / " + rules_core.teams.length);
		}
	}

	bool isSpawning(CPlayer@ player)
	{
		KIWIPlayerInfo@ info = cast < KIWIPlayerInfo@ > (core.getInfoFromPlayer(player));
		for (uint i = 0; i < rules_core.teams.length; i++)
		{
			KIWITeamInfo@ team = cast < KIWITeamInfo@ > (rules_core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1)
			{
				return true;
			}
		}
		return false;
	}
};