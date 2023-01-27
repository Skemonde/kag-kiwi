f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (this !is null && hitterBlob !is null)
		this.set_u16("killer_id", hitterBlob.getNetworkID());
	return 0;
}

void onDie(CBlob@ this)
{
	if (this is null) return;
	CBlob@ killer_blob = getBlobByNetworkID(this.get_u16("killer_id"));
	if (killer_blob !is null)
	{
		CPlayer@ killer = killer_blob.getPlayer();
		if (killer_blob !is null)
		{
			if (killer.getTeamNum() != this.getTeamNum())
			{
				killer.setKills(killer.getKills() + 1);
				killer.server_setCoins(killer.getCoins()+1);
			}
		}	
	}
}