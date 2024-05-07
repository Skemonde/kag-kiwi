#include "RulesCore"
#include "KIWI_Players&Teams"
#include "BaseTeamInfo"

shared class KIWICore : RulesCore
{
	KIWIPlayerInfo@[] kiwi_players;
	
	KIWICore(CRules@ _rules, RespawnSystem@ _respawns)
	{
		super(_rules, _respawns);
	}
	
	void SetupTeams()
	{
		teams.clear();

		//sky-blue
		AddTeam(6, "bluz");
		//garish-red
		AddTeam(1, "redz");
		//purple
		AddTeam(3, "undead");
	}
	
	void AddTeam(u8 team_num, string team_name)
	{
		KIWITeamInfo t(team_num, team_name);
		teams.push_back(t);
	}

	void AddPlayer(CPlayer@ player, u8 team = 0, string default_config = "")
	{
		if (getRules().hasTag("singleplayer"))
		{
			team = 2;
		}
		else
		{
			team = player.getTeamNum();
		}
		KIWIPlayerInfo p(player.getUsername(), team, "soldat");
		players.push_back(p);
		kiwi_players.push_back(p);
		ChangeTeamPlayerCount(p.team, 1);
		resetHeadwearFromUsername(player.getUsername());
	}
	
	KIWIPlayerInfo@ getKIWIInfoFromName(string username)
	{
		for (uint k = 0; k < kiwi_players.length; k++)
		{
			if (kiwi_players[k].username == username)
			{
				return kiwi_players[k];
			}
		}

		return null;
	}

	KIWIPlayerInfo@ getKIWIInfoFromPlayer(CPlayer@ player)
	{
		if (player !is null)
		{
			return getKIWIInfoFromName(player.getUsername());
		}
		else
		{
			return null;
		}
	}
	
	void ChangePlayerTeam(CPlayer@ player, int newTeamNum)
	{
		PlayerInfo@ p = getInfoFromName(player.getUsername());

		if (p.team != newTeamNum)
		{
			if (g_debug > 0)
				print("CHANGING PLAYER TEAM FROM " + p.team + " to " + newTeamNum);
		}
		else
		{
			return;
		}

		//if (newTeamNum >= teams.size() && newTeamNum != getRules().getSpectatorTeamNum())
		//{
		//	warn(player.getUsername() + " attempted switch to illegal team " + newTeamNum + ", ignoring");
		//	return;
		//}

		bool is_spawning = false;
		if (respawns !is null && respawns.isSpawning(player))
		{
			is_spawning = true;
			respawns.RemovePlayerFromSpawn(player);
		}

		ChangeTeamPlayerCount(p.team, -1);
		ChangeTeamPlayerCount(newTeamNum, 1);

		RemovePlayerBlob(player);

		u8 oldteam = player.getTeamNum();
		p.setTeam(newTeamNum);
		player.server_setTeamNum(newTeamNum);

		// vvv this breaks spawning on team change ~~~Norill
		//if(is_spawning || oldteam == rules.getSpectatorTeamNum())
		{
			respawns.AddPlayerToSpawn(player);
		}

	}
	
	BaseTeamInfo@ getTeam(int teamNum)
	{
		if (teamsHaveThisTeam(teams, teamNum))
		{
			return teams[getArrayIndexFromTeamNum(teams, teamNum)];
		}

		return null;
	}

	void ChangeTeamPlayerCount(int teamNum, int amountBy)
	{
		BaseTeamInfo@ t = getTeam(teamNum);

		if (t !is null) { t.players_count += amountBy; }
	}

	void onPlayerDie(CPlayer@ victim, CPlayer@ killer, u8 customData)
	{
		// doesn't work :(
		//victim.client_RequestSpawn();
	}
}