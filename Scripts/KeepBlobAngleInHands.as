
void onTick(CBlob@ this)
{
	AttachmentPoint@ pickup = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (pickup is null) return;
    CBlob@ holder = pickup.getOccupied();
	if (holder is null) return;
	
	f32 hand_angle_offset = this.get_f32("hand angle offset");
	
	this.setAngleDegrees(hand_angle_offset);
}