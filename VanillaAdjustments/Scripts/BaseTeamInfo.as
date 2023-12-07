
#ifndef INCLUDED_BASETEAMINFO
#define INCLUDED_BASETEAMINFO

shared class BaseTeamInfo
{
	u8 index;
	string name;
	s32 players_count, alive_count;

	bool lost;

	BaseTeamInfo() { index = 0; name = ""; Reset(); }

	BaseTeamInfo(u8 _index, string _name)
	{
		index = _index;
		name = _name;
		Reset();
	}

	void Reset()
	{
		players_count = alive_count = 0;
		lost = false;
	}

};

shared int getUsedTeamsAmount()
{
	return 2;
}

shared s32 getTeamSize(BaseTeamInfo@[]@ teams, int team_num)
{
	//if (team >= 0 && team < teams.length)
	if (teamsHaveThisTeam(teams, team_num))
	{
		return teams[getArrayIndexFromTeamNum(teams, team_num)].players_count;
	}

	return 0;
}

shared int getArrayIndexFromTeamNum(BaseTeamInfo@[]@ teams, u8 team_num)
{
	u8[] team_nums;
	for (u8 team_idx = 0; team_idx < teams.size(); ++team_idx) {
		team_nums.push_back(teams[team_idx].index);
	}
	return team_nums.find(team_num);
}

shared bool teamsHaveThisTeam(BaseTeamInfo@[]@ teams, int team_num)
{
	return getArrayIndexFromTeamNum(teams, team_num)>-1;
}

shared s32 getSmallestTeam(BaseTeamInfo@[]@ teams)
{
	s32 lowestTeam = teams[XORRandom(512) % getUsedTeamsAmount()].index;
	s32 lowestCount = teams[getArrayIndexFromTeamNum(teams, lowestTeam)].players_count;

	for (uint i = 0; i < getUsedTeamsAmount(); i++)
	{
		u8 team_num = teams[i].index;
		int size = getTeamSize(teams, team_num);
		//if (g_debug > 0)
		//	print("size "+size+" team "+team_num+" team_idx "+i);
		if (size < lowestCount)
		{
			lowestCount = size;
			lowestTeam = team_num;
		}
	}
	return lowestTeam;
}

shared int getLargestTeam(BaseTeamInfo@[]@ teams)
{
	s32 largestTeam = teams[XORRandom(512) % getUsedTeamsAmount()].index;
	s32 largestCount = teams[getArrayIndexFromTeamNum(teams, largestTeam)].players_count;

	for (uint i = 0; i < getUsedTeamsAmount(); i++)
	{
		u8 team_num = teams[i].index;
		int size = getTeamSize(teams, team_num);
		//print("size "+size+" team "+team_num+" team_idx "+i);
		if (size > largestCount)
		{
			largestCount = size;
			largestTeam = team_num;
		}
	}
	return largestTeam;}

shared int getTeamDifference(BaseTeamInfo@[]@ teams)
{
	s32 lowestCount = getTeamSize(teams, getSmallestTeam(teams));
	s32 highestCount = getTeamSize(teams, getLargestTeam(teams));

	return (highestCount - lowestCount);
}

#endif
