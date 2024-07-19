
void AddParachuteSpriteLayer(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	sprite.RemoveSpriteLayer("parachute");
	
	CSpriteLayer@ parachute = sprite.addSpriteLayer("parachute", "ParachuteSL.png", 64, 64);

	if (parachute !is null)
	{
		Animation@ anim = parachute.addAnimation("default", 3, true);
		int[] frames = {0, 1, 2};
		anim.AddFrames(frames);
		parachute.SetVisible(false);
		parachute.SetRelativeZ(-100);
	}
}

void onTick(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();

	CSpriteLayer@ parachute = sprite.getSpriteLayer("parachute");
	
	Vec2f vel = this.getVelocity();
	
	bool parachuting = this.hasTag("parachute") && !this.isAttached() && !this.hasTag("dead") && vel.y>0;
	
	if (parachute is null)
	{
		AddParachuteSpriteLayer(this);
		return;
	}
	
	parachute.SetVisible(parachuting);

	if (!parachuting) return;
	
	const bool FLIP = this.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	
	//Slow down the player's fall speed
	if (!this.isKeyPressed(key_down))
		this.setVelocity(Vec2f(vel.x, vel.y * 0.4f));
	this.AddForce(Vec2f(Maths::Sin(getGameTime() * 0.03f) * 2.0f, -30.0f * this.getVelocity().y));
	this.setAngleDegrees(Maths::Clamp(this.getVelocity().x*7, -35, 35));
	
	parachute.SetFacingLeft(false);

	parachute.SetOffset(Vec2f(0.0f, -23.0f + Maths::Sin(getGameTime() / 5.0f)) + Vec2f(-1,0));
	
	//f32 parachute_angle = (Maths::Sin((this.getOldVelocity().x + this.getVelocity().x)/2)*-10);
	f32 parachute_angle = Maths::Clamp(this.getVelocity().x*20, -35, 35);
	parachute_angle = parachute_angle-this.getAngleDegrees();

	parachute.ResetTransform();
	parachute.RotateBy(parachute_angle, Vec2f(0, 22.0));
}