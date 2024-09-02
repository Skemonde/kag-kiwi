
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
				KillOwnedItems(victim, blob);
				string tickets_prop = "tickets_"+victim.getTeamNum();
				
				//print("gotthere victim isn't null");
				victim.setDeaths(victim.getDeaths() + 1);

				if (killer !is null) //requires victim so that killing trees matters
				{
					this.sub_s32(tickets_prop, 1);
					this.set_s32(tickets_prop, Maths::Max(this.get_s32(tickets_prop), 0));
					this.Sync(tickets_prop, true);
					
					CheckIfTeamShouldLose(victim);
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

void KillOwnedItems(CPlayer@ victim, CBlob@ blob)
{
	if (!isServer()) return;
	if (victim is null) return;
	
	CBlob@[] all_blobs;
	getMap().getBlobsInRadius(blob.getPosition(), 80, @all_blobs);
	
	//print(""+all_blobs.size());
	
	//return;
	for (int idx = 0; idx < all_blobs.size(); ++idx)
	{
		CBlob@ cur_blob = all_blobs[idx];
		if (cur_blob is null) continue;
		if (!cur_blob.exists("item_owner_id")) continue;
		if (cur_blob.get_u16("item_owner_id")!=victim.getNetworkID()) continue;
		
		cur_blob.server_Die();
	}
}

void CheckIfTeamShouldLose(CPlayer@ victim)
{
	CRules@ this = getRules();
	string tickets_prop = "tickets_"+victim.getTeamNum();
	int tickets = this.get_s32(tickets_prop);
	
	if (tickets > 0) return;
	
	for (u32 idx = 0; idx < getPlayersCount(); ++idx)
	{
		CPlayer@ player = getPlayer(idx);
		if (player is null) continue;
		if (player.getTeamNum()!=victim.getTeamNum()) continue;
		//if a team still has a healthy player - play on!!
		if (player.getBlob() !is null && !player.getBlob().hasTag("halfdead")) return;
	}
	
	if (victim.getTeamNum()==1)
	{
		this.SetGlobalMessage("Red team ran out of lives!");
		this.SetTeamWon(6);
	}
	else if (victim.getTeamNum()==6)
	{
		this.SetGlobalMessage("Blue team ran out of lives!");
		this.SetTeamWon(1);
	}
	
	this.SetCurrentState(GAME_OVER);
}
