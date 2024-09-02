
void onTick(CBlob@ this)
{
	AttachmentPoint@ pickup = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (pickup is null) return;
    CBlob@ holder = pickup.getOccupied();
	if (holder is null) return;
	
	bool ap_rotates_too = this.hasTag("rotate pickup point");
	
	const bool FLIP = holder.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	bool changes_facing = this.hasTag("sprite doesnt change facing");
	f32 facing_factor = changes_facing?0:ANGLE_FLIP_FACTOR;
	f32 hand_angle_offset = this.get_f32("hand angle offset");
	
	Vec2f point_offset = ap_rotates_too?Vec2f():Vec2f(pickup.offset.x*FLIP_FACTOR, pickup.offset.y);
	
	f32 angle = facing_factor+180-(holder.getPosition()-holder.getAimPos()-point_offset).Angle();
	
	if (ap_rotates_too)
	{
		AttachmentPoint@ holder_pickup = holder.getAttachments().getAttachmentPointByName("PICKUP");
		if (holder_pickup is null) return;
		
		f32 flip_facing_factor = changes_facing?FLIP_FACTOR:1;
	
		if (!this.exists("initial pickup offset"))
			this.set_Vec2f("initial pickup offset", pickup.offset);
		else
		{
			holder_pickup.occupied_offset = Vec2f(this.get_Vec2f("initial pickup offset").x*flip_facing_factor, this.get_Vec2f("initial pickup offset").y).RotateBy(angle*FLIP_FACTOR);
		}
	}
	
	this.setAngleDegrees(hand_angle_offset+angle);
}