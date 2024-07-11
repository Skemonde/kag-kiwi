
// set kills, deaths and assists

#include "AssistCommon"
#include "SoldatInfo"

void onBlobDie(CRules@ this, CBlob@ blob)
{
	if (!this.isGameOver() && !this.isWarmup())	//Only count kills, deaths and assists when the game is on
	{
		//print("gotthere having the right game state");
		if (blob !is null)
		{
			//print("gotthere blob isn't null");
			CPlayer@ killer = blob.getPlayerOfRecentDamage();
			CPlayer@ victim = blob.getPlayer();
			CPlayer@ helper = getAssistPlayer(victim, killer);

			if (helper !is null)
			{
				//helper.setAssists(helper.getAssists() + 1);
				if (helper.getTeamNum() != blob.getTeamNum())
				{	
					helper.setKills(helper.getKills() + 1);
					SetProperRank(helper);
				}
			}

			if (victim !is null)
			{
				//print("gotthere victim isn't null");
				victim.setDeaths(victim.getDeaths() + 1);

				if (killer !is null) //requires victim so that killing trees matters
				{
					//print("gotthere killer isn't null");
					if (killer.getTeamNum() != blob.getTeamNum())
					{
						killer.setKills(killer.getKills() + 1);
					} 
					else if (killer !is victim)
					{
						killer.setKills(Maths::Max(0, (1.0f*killer.getKills() - 1)));
					}
					SetProperRank(killer);
				}
			}
		}
	}
}
