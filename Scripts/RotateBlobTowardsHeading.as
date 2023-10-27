
void onTick(CBlob@ this)
{
	//no rotating if blob is attached to something
	if (this.isAttached()) return;
	
	Vec2f vel = this.getVelocity();
	f32 vellen = vel.Length();
	
	// no rotation if the speed is small
	if (vellen < 2) return;
	
	this.setAngleDegrees(-vel.Angle());
}