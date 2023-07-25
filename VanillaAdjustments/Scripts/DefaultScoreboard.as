
// set kills, deaths and assists

#include "AssistCommon.as";

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
				helper.setAssists(helper.getAssists() + 1);
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
						//print("gotthere team isn't the same");
						killer.setKills(killer.getKills() + 1);
						killer.server_setCoins(killer.getCoins()+1);
						u8 killer_rank = this.get_u8(killer.getUsername()+"rank");
						if (Maths::Floor(killer.getKills()/20)>killer_rank&&killer_rank<3) {
							this.add_u8(killer.getUsername()+"rank", 1);
							this.Sync(killer.getUsername() + "rank", true);
						}
					}
				}
			}
		}
	}
}
