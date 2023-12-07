

const int TEAM_DIFFERENCE_THRESHOLD = 1; //max allowed diff

//TODO: store this in rules
enum BalanceType
{
	NOTHING = 0,
	SWAP_BALANCE,
	SCRAMBLE,
	SCORE_SORT,
	KILLS_SORT
};

/**
 * BalanceInfo class
 * simply holds the last time we balanced someone, so we
 * don't make some poor guy angry if he's always balanced
 *
 * we reset this time when you swap team, so that if you
 * imbalance the game, you can be swapped back swiftly
 */

class BalanceInfo
{
	string username;
	s32 lastBalancedTime;

	BalanceInfo() { /*dont use this manually*/ }

	BalanceInfo(string _username)
	{
		username = _username;
		lastBalancedTime = getGameTime();
	}
};

/*
 * Methods on a global array of balance infos to make the
 * actual hooks much cleaner.
 */

// add a balance info from username
void addBalanceInfo(string username, BalanceInfo[]@ infos)
{
	//check if it's already added
	BalanceInfo@ b = getBalanceInfo(username, infos);
	if (b is null)
		infos.push_back(BalanceInfo(username));
	else
		b.lastBalancedTime = getGameTime();
}

// get a balanceinfo from a username
BalanceInfo@ getBalanceInfo(string username, BalanceInfo[]@ infos)
{
	for (uint i = 0; i < infos.length; i++)
	{
		BalanceInfo@ b = infos[i];
		if (b.username == username)
			return b;
	}
	return null;
}

// remove a balanceinfo by username
void removeBalanceInfo(string username, BalanceInfo[]@ infos)
{
	for (uint i = 0; i < infos.length; i++)
	{
		if (infos[i].username == username)
		{
			infos.erase(i);
			return;
		}
	}
}

// get the earliest balance time
s32 getEarliestBalance(BalanceInfo[]@ infos)
{
	s32 min = getGameTime(); //not likely to be earlier ;)
	for (uint i = 0; i < infos.length; i++)
	{
		s32 t = infos[i].lastBalancedTime;
		if (t < min)
			min = t;
	}

	return min;
}

s32 getAverageBalance(BalanceInfo[]@ infos)
{
	s32 total = 0;
	for (uint i = 0; i < infos.length; i++)
		total += infos[i].lastBalancedTime;

	return total / infos.length;
}

bool MoreKills(BalanceInfo@ a, BalanceInfo@ b)
{
	CPlayer@ first = getPlayerByUsername(a.username);
	CPlayer@ second = getPlayerByUsername(a.username);
	if (first is null || second is null) return false;
	return first.getKills() > second.getKills();
}

bool MorePoints(BalanceInfo@ a, BalanceInfo@ b)
{
	CPlayer@ first = getPlayerByUsername(a.username);
	CPlayer@ second = getPlayerByUsername(a.username);
	if (first is null || second is null) return false;
	return first.getScore() > second.getScore();
}

////////////////////////////////
// force balance all teams

void BalanceAll(CRules@ this, RulesCore@ core, BalanceInfo[]@ infos, int type = SCRAMBLE)
{
	u32 len = infos.length;

	switch (type)
	{
		case NOTHING: return;

		case SWAP_BALANCE:

			getNet().server_SendMsg("This balance mode isn't programmed yet!");
			//TODO: swap balance code

			break;

		case SCRAMBLE:

			getNet().server_SendMsg("Scrambling the teams...");

			for (u32 i = 0; i < len; i++)
			{
				uint index = XORRandom(len);
				BalanceInfo b = infos[index];

				infos[index] = infos[i];
				infos[i] = b;
			}
			break;

		case SCORE_SORT:
		case KILLS_SORT:

			getNet().server_SendMsg("Balancing the teams...");

			{
				bool toggle = (type == KILLS_SORT);
				u32 sortedsect = 0;
				u32 j;
				for (u32 i = 1; i < len; i++)
				{
					j = i;
					BalanceInfo a = infos[i];
					while ((toggle ? MoreKills(infos[j - 1], a) : MorePoints(infos[j - 1], a))
					        && j > 0)
					{
						infos[j] = infos[j - 1];
						j--;
					}
					infos[j] = a;
				}
			}


			break;
	}

	//int numTeams = this.getTeamsCount();
	int numTeams = core.teams.length;
	int team = XORRandom(128) % numTeams;

	for (u32 i = 0; i < len; i++)
	{
		BalanceInfo@ b = infos[i];
		CPlayer@ p = getPlayerByUsername(b.username);

		if (p.getTeamNum() != this.getSpectatorTeamNum())
		{
			b.lastBalancedTime = getGameTime();
			int tempteam = team++ % numTeams;
			if (zombsGotSpawn()) tempteam = 0;
			core.ChangePlayerTeam(p, core.teams[tempteam].index);
		}
	}
}

bool zombsGotSpawn()
{
	CBlob@[] portals;
	Vec2f portal_pos = Vec2f_zero;
	if (getBlobsByName("zombieportal", portals)) {
		portal_pos = portals[XORRandom(portals.length)].getPosition();
	}
	return portal_pos!=Vec2f();
}
