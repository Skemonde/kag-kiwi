
void onTick(CBlob@ this)
{
	AttachmentPoint@ pickup = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (pickup is null) return;
    CBlob@ holder = pickup.getOccupied();
	if (holder is null) return;
	
	const bool FLIP = holder.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	bool changes_facing = this.hasTag("sprite doesnt change facing");
	f32 facing_factor = changes_facing?0:ANGLE_FLIP_FACTOR;
	f32 hand_angle_offset = this.get_f32("hand angle offset");
	
	this.setAngleDegrees(hand_angle_offset+facing_factor+180-(holder.getPosition()-holder.getAimPos()-Vec2f(pickup.offset.x*FLIP_FACTOR, pickup.offset.y)).Angle());
}