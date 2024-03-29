
/*
 * Auto balance teams inside a RulesCore
 * 		does a conservative job to avoid pissing off players
 * 		and to avoid forcing many implementation limitations
 * 		onto rulescore extensions so it can be used out of
 * 		the box for most gamemodes.
 */

#include "PlayerInfo.as";
#include "BaseTeamInfo.as";
#include "RulesCore.as";
#include "KIWI_BalanceInfo.as";
#include "EquipmentCommon"

#define SERVER_ONLY

u32 getAverageScore(int team)
{
	u32 total = 0;
	u32 count = 0;
	u32 len = getPlayerCount();
	for (uint i = 0; i < len; i++)
	{
		CPlayer@ p = getPlayer(i);
		if (p.getTeamNum() == team)
		{
			count++;
			total += p.getScore();
		}
	}

	return (count == 0 ? 0 : total / count);
}

// computes median score using quickselect algorithm - O(n) complexity

u32 getMedianScore(int team)
{
	int[] list;
	int pivot, begin, end, temp;

	for (uint i = 0; i < getPlayerCount(); i++)
		if (getPlayer(i).getTeamNum() == team)
			list.push_back(i);

	begin = 0; end = list.length() - 1;

	while (true)
	{
		pivot = begin + (end - begin) / 2;
		temp = list[end]; list[end] = list[pivot]; list[pivot] = temp; //move pivot to end
		int c = begin;
		for (uint i = begin; i < end; ++i)
		{
			if (getPlayer(list[i]).getScore() < getPlayer(list[end]).getScore())
			{
				temp = list[c]; list[c] = list[i]; list[i] = temp; //move to front
				c++;
			}
		}
		temp = list[c]; list[c] = list[end]; list[end] = temp; //move pivot to middle

		if (list.length() / 2 == c)
			return getPlayer(list[c]).getScore();
		if (list.length() / 2 < c)
			end = c - 1;
		else
			begin = c + 1;
	}
	return 0;
}

///////////////////////////////////////////////////
//pass stuff to the core from each of the hooks

bool haveRestarted = false;

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	this.set_bool("managed teams", true); //core shouldn't try to manage the teams

	//set this here, we need to wait
	//for the other rules script to set up the core

	BalanceInfo[]@ infos;
	if (!this.get("autobalance infos", @infos) || infos is null)
	{
		BuildBalanceArray(this);
	}

	haveRestarted = true;
}

/*
 * build the balance array and store it inside the rules so it can persist
 */

void BuildBalanceArray(CRules@ this)
{
	BalanceInfo[] temp;

	for (int player_step = 0; player_step < getPlayersCount(); ++player_step)
	{
		addBalanceInfo(getPlayer(player_step).getUsername(), temp);
	}

	this.set("autobalance infos", temp);
}

/*
 * Add a player to the balance list and set its team number
 */

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	RulesCore@ core;
	this.get("core", @core);

	BalanceInfo[]@ infos;
	this.get("autobalance infos", @infos);

	if (core is null)
	{
		warn("onNewPlayerJoin: CORE NOT FOUND ");
		return;
	}
	if (infos is null)
	{
		warn("onNewPlayerJoin: infos NOT FOUND ");
		return;
	}

	addBalanceInfo(player.getUsername(), infos);

	if (player.getTeamNum() != this.getSpectatorTeamNum())
	{
		//print("smallest team "+getSmallestTeam(core.teams));
		
		u8 team_to_assign = zombsGotSpawn()?core.teams[0].index:getSmallestTeam(core.teams);
		
		core.ChangePlayerTeam(player, team_to_assign);
	}
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	BalanceInfo[]@ infos;
	this.get("autobalance infos", @infos);

	if (infos is null) return;

	removeBalanceInfo(player.getUsername(), infos);
	
}

void onTick(CRules@ this)
{
	
	if (haveRestarted || (getGameTime() % 1800 == 0))
	{
		//get the core and balance infos
		RulesCore@ core;
		this.get("core", @core);

		BalanceInfo[]@ infos;
		this.get("autobalance infos", @infos);

		if (core is null || infos is null) return;

		if (haveRestarted) //balance all on start
		{
			haveRestarted = false;
			//force all teams balanced
			int type = KILLS_SORT;

			BalanceAll(this, core, infos, type);
		}

		if (getTeamDifference(core.teams) > TEAM_DIFFERENCE_THRESHOLD && !zombsGotSpawn())
		{
			getNet().server_SendMsg("Teams are way imbalanced due to players leaving...");
		}
	}
}

void onPlayerRequestTeamChange(CRules@ this, CPlayer@ player, u8 newTeam)
{
	RulesCore@ core;
	this.get("core", @core);
	if (core is null) return;

	int oldTeam = player.getTeamNum();
	bool spect = (oldTeam == this.getSpectatorTeamNum());
	// print("---request team change--- " + oldTeam + " -> " + newTeam);
	
	//no changing teams if we just changed our head
	CBlob@ player_blob = player.getBlob();
	if (player_blob !is null) {
		bool head_changed = player.getHead() != player_blob.getHeadNum();
		if (head_changed) {
			
			CBlob@ newBlob = server_CreateBlob(player_blob.getName(), player_blob.getTeamNum(), player_blob.getPosition());
			CBlob@ carried = player_blob.getCarriedBlob();
			f32 old_health = player_blob.getHealth();
					
			//im dying.. i have to get sprite from newBlob so check does actually work like it should
			//if i do newBlob !is null it fucking passes when the blob does not exist!!!!!! >:(
			if (newBlob.getSprite() !is null)
			{
				if (newBlob.server_SetPlayer(player)) {
					player_blob.MoveInventoryTo(newBlob);
					player_blob.server_Die();
					newBlob.server_SetHealth(old_health);
					newBlob.set_u32("last_hit_time", getGameTime());
					newBlob.set_u32("custom immunity time", 0);
					addHatScript(newBlob);
					if (carried !is null)
						newBlob.server_Pickup(carried);
				}
			}
			
			return;
		}
	}

	//if a player changes to team 255 (-1), auto-assign
	if (newTeam == 255)
	{
		newTeam = getSmallestTeam(core.teams);
	}
	//if a player changing from team 255 (-1), auto-assign
	if (oldTeam == 255)
	{
		oldTeam = getSmallestTeam(core.teams);
		newTeam = oldTeam;
	}

	int newSize = getTeamSize(core.teams, newTeam);
	int oldSize = getTeamSize(core.teams, oldTeam);

	if (!getSecurity().checkAccess_Feature(player, "always_change_team")
	        && (!spect && newSize + 1 > oldSize - 1 + TEAM_DIFFERENCE_THRESHOLD //changing to bigger team
	            || spect && newTeam == getLargestTeam(core.teams)
	            && getTeamDifference(core.teams) + 1 > TEAM_DIFFERENCE_THRESHOLD //or changing to bigger team from spect
	           )
			&& !zombsGotSpawn()
		)
	{
		//awww shit, thats a SERVER_ONLY script :/
		// if(player.isMyPlayer())
		// 	client_AddToChat("Can't change teams now - it would imbalance them.");

		getNet().server_SendMsg("Switching " + player.getUsername() + " back - teams unbalanced");

		return;
	}

	core.ChangePlayerTeam(player, newTeam);
}

void onPlayerRequestSpawn(CRules@ this, CPlayer@ player)
{
	RulesCore@ core;
	this.get("core", @core);

	BalanceInfo[]@ infos;
	this.get("autobalance infos", @infos);

	if (core is null || infos is null) return;

	BalanceInfo@ b = getBalanceInfo(player.getUsername(), infos);
	if (b is null) return;
	
	//zombie mode -> no balance
	if (zombsGotSpawn())
		core.ChangePlayerTeam(player, core.teams[0].index);
		return;

	//player is already in smallest team -> no balance
	if (player.getTeamNum() == getSmallestTeam(core.teams))
		return;

	//difference is worth swapping for
	if (getTeamDifference(core.teams) <= TEAM_DIFFERENCE_THRESHOLD)
		return;

	//player swapped/joined team ages ago -> no balance
	if (b.lastBalancedTime < getAverageBalance(infos))
		return;

	//check if the player doesn't suck - dont swap top half of the team
	u32 median = getMedianScore(player.getTeamNum());
	if (player.getScore() > median)
		return;

	s32 newTeam = getSmallestTeam(core.teams);
	core.ChangePlayerTeam(player, newTeam);
	getNet().server_SendMsg("Balancing " + b.username + " to " + core.teams[getArrayIndexFromTeamNum(core.teams, newTeam)].name);
	b.lastBalancedTime = getEarliestBalance(infos) - 10; //don't balance this guy again for approximately ever

	// print("DOING BALANCE AND SETTING TEAM - requested "+ player.getTeamNum()
	// 	+ " set " + getSmallestTeam( core.teams ));
}
