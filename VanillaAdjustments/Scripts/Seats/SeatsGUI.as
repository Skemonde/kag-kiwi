
// optimization: we use script globals here cause all seats GUI use the same value for this
f32 bounce;
u32 lastBounceTime;

const f32 arrowVisibleRadius = 15.0f;

void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;
		
	if (this is null) //can happen with bad reload
		return;

	// draw only for local player
	CBlob@ localBlob = getLocalPlayerBlob();
	CBlob@ blob = this.getBlob();
	
	if (localBlob is null || localBlob.isAttached() || localBlob.isInInventory() || blob.isInInventory() || blob.isAttachedToPoint("PICKUP"))
		return;

	//too far away
	if ((localBlob.getPosition() - blob.getPosition()).getLength() > blob.getRadius() + arrowVisibleRadius)
		return;
		
	if (localBlob.hasTag("halfdead"))
		return;
		
	bool can_get_in = blob.hasTag("no team lock");
			
	CBlob@[] defenders;
	getMap().getBlobsInRadius(blob.getPosition(), blob.getRadius()*2, defenders);
	
	for (int idx = 0; idx < defenders.size(); ++idx) {
		CBlob@ r_blob = defenders[idx];
		if (r_blob is null) continue;
		
		if (r_blob.hasTag("player") && r_blob.getTeamNum() == blob.getTeamNum()) {
			can_get_in = false;
			break;
		}
	}

	//not same team
	if ((blob.getTeamNum() <= 8 && blob.getTeamNum() != localBlob.getTeamNum()) && !can_get_in)
		return;

	//behind solid blocks
	if (getMap().rayCastSolid(localBlob.getPosition(), blob.getPosition()))
		return;

	// dont draw if angle is upside down
	const f32 angle = blob.getAngleDegrees();
	if (angle > 70.0f && angle < 290.0f)
		return;

	// draw arrows pointing towards seats
	if (lastBounceTime != getGameTime())
	{
		bounce = Maths::Sin((getGameTime() + blob.getNetworkID()) / 4.5f);
		lastBounceTime = getGameTime();
	}

	if (bounce > 0.8f)
		return;

	AttachmentPoint@[] aps;
	if (!blob.getAttachmentPoints(@aps))
		return;

	string lastPointName;
	for (uint i = 0; i < aps.length; i++)
	{
		AttachmentPoint@ ap = aps[i];
		if (ap.getOccupied() is null && ap.socket && ap.getKeysToTake() > 0 && ap.radius > 0.0f && lastPointName != ap.name) // gather empty controllers attachments/seats
		{
			const bool driver = ap.name == "DRIVER";  // HACK:
			if (driver && blob.hasTag("immobile")) continue;

			if (!driver || (driver && !blob.isAttached()))
			{
				Vec2f pos = getDriver().getScreenPosFromWorldPos(ap.getPosition());
				pos.y += -3.0f + 10.0f * bounce;
				if (blob.isFacingLeft())
				{
					pos.x -= 8.0f;
				}

				GUI::DrawIconByName("$down_arrow$", pos);

				if (g_debug == 0)
				{
					lastPointName = ap.name;  // draw just one of a kind
				}
			}
		}
	}
}
