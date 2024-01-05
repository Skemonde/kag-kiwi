void onTick(CBlob@ this)
{
	this.Tag("vehicle");
	CSprite@ sprite = this.getSprite();
	CShape@ shape = this.getShape();
	shape.SetGravityScale(1);
	f32 angles_per_frame = 360/16;
	sprite.SetFrameIndex(16-(this.getAngleDegrees()-angles_per_frame)/angles_per_frame);
	sprite.ResetTransform();
	f32 scaling = 2;
	//sprite.ScaleBy(scaling, scaling);
	
	AttachmentPoint@ pilot_point = this.getAttachments().getAttachmentPointByName("PILOT");
	if (pilot_point is null) return;
	
	CBlob@ pilot = pilot_point.getOccupied();
	if (pilot is null) return;
	pilot.getSprite().SetVisible(false);
	//pilot.SetFacingLeft(!this.isFacingLeft());
	shape.SetGravityScale(0.2);
	
	const bool FLIP = pilot.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	bool changes_facing = this.hasTag("sprite doesnt change facing");
	f32 facing_factor = changes_facing?0:ANGLE_FLIP_FACTOR;
	f32 hand_angle_offset = this.get_f32("hand angle offset");
	
	this.setAngleDegrees(hand_angle_offset+facing_factor+180-(pilot.getPosition()-pilot.getAimPos()-Vec2f(pilot_point.offset.x*FLIP_FACTOR, pilot_point.offset.y)).Angle());
	
	if (pilot.isKeyPressed(key_up))
		this.AddForce(Vec2f(FLIP_FACTOR*120,0).RotateBy(this.getAngleDegrees()));
}