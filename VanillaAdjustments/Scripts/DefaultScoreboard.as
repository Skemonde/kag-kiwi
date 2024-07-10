
// set kills, deaths and assists

#include "AssistCommon"
#include "SoldatInfo"
#include "VarsSync"

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
					//print("gotthere team isn't the same");
					SoldatInfo[]@ infos = getSoldatInfosFromRules();
					if (infos is null) return;
					SoldatInfo our_info = getSoldatInfoFromUsername(helper.getUsername());
					if (our_info is null) return;
					int info_idx = getInfoArrayIdx(our_info);
						
					helper.setKills(helper.getKills() + 1);
					
					bool commanding = our_info.commanding;
					u8 helper_rank = our_info.rank;
					int commander_start = 5;
					int soldier_max = 3;
					int commander_max = 8;
					int helper_max = commanding?commander_max:soldier_max;
					int rank_value = Maths::Floor(helper.getKills()/10);
					
					if ((rank_value+(commanding?commander_start:0))>helper_rank&&helper_rank<helper_max) {
						infos[info_idx].rank = rank_value;
						getRules().set("soldat_infos", infos);
						server_SyncPlayerVars(getRules());							
					}
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
						//print("gotthere team isn't the same");
						SoldatInfo[]@ infos = getSoldatInfosFromRules();
						if (infos is null) return;
						SoldatInfo our_info = getSoldatInfoFromUsername(killer.getUsername());
						if (our_info is null) return;
						int info_idx = getInfoArrayIdx(our_info);
						
						killer.setKills(killer.getKills() + 1);
						
						bool commanding = our_info.commanding;
						u8 killer_rank = our_info.rank;
						int commander_start = 5;
						int soldier_max = 3;
						int commander_max = 8;
						int killer_max = commanding?commander_max:soldier_max;
						int rank_value = Maths::Floor(killer.getKills()/10);
						
						if ((rank_value+(commanding?commander_start:0))>killer_rank&&killer_rank<killer_max) {
							infos[info_idx].rank = rank_value;
							getRules().set("soldat_infos", infos);
							server_SyncPlayerVars(getRules());							
						}
					}
				}
			}
		}
	}
}
