//common targeting

shared void SetBestTarget(CBrain@ this, CBlob@ blob, const f32&in radius)
{
	//u16[] targetBlobs;
	//if (!getRules().get("target netids", targetBlobs)) return;
	CBlob@[] all; // print all blobs
	getBlobs(@all);
	//print("hey!!");
	
	u16[] targetBlobs;
	for (u16 i = 0; i < all.length; ++ i) {
		if (all[i] !is null && ((all[i].hasTag("player") && all[i].getPlayer() !is null) || all[i].hasTag("spawn") || all[i].hasTag("materiel")) && all[i].getTeamNum() != 3) {
			targetBlobs.push_back(all[i].getNetworkID());
		}
	}
	
	const bool seeThroughWalls = blob.hasTag("see_through_walls");
	const Vec2f pos = blob.getPosition();

	CBlob@ target;
	f32 closest_dist = 999999.9f;
	
	const u16 blobsLength = targetBlobs.length;
	for (u16 i = 0; i < blobsLength; ++i)
	{
		CBlob@ candidate = getBlobByNetworkID(targetBlobs[i]);
		if (candidate is null || candidate.hasTag("dead")) continue;
		
		//print("sus "+candidate.getName());

		const f32 dist = (candidate.getPosition() - pos).Length();
		if (dist < radius && dist < closest_dist && (isTargetVisible(blob, candidate) || seeThroughWalls))
		{
			@target = candidate;
			closest_dist = dist;
		}
	}
	
	if (target !is null)
	{
		this.SetTarget(target);
	}
}

shared const bool isTargetVisible(CBlob@ this, CBlob@ target)
{
	Vec2f col;
	
	if (getMap().rayCastSolid(this.getPosition(), target.getPosition(), col))
	{
		// fix for doors not being considered visible
		CBlob@ obstruction = getMap().getBlobAtPosition(col);
		if (obstruction is null || obstruction !is target)
			return false;
	}
	return true;
}
