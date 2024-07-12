void onTick(CBlob@ this)
{
	if (!this.exists("def_edgeflags"))
	{
		this.set_u8("def_edgeflags", this.getMapEdgeFlags());
	}
	if (!this.exists("def_drag"))
	{
		this.set_f32("def_drag", this.getShape().getDrag());
	}
	if (!this.exists("had_rotation_script"))
	{
		this.set_bool("had_rotation_script", this.hasScript("RotateBlobTowardsHeading.as"));
	}
	//this.getShape().setDrag(0.2f);
	if (!this.hasScript("RotateBlobTowardsHeading.as")&&!this.hasScript("Material_Explosive.as"))
	{
		this.AddScript("RotateBlobTowardsHeading.as");
	}
	
	if (!this.hasTag("parachute"))
	{
		this.Tag("parachute");
	}
	
	const bool FLIP = this.getVelocity().x<0;
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	//f32 rotation_scale = 20;
	//this.setAngleDegrees(getGameTime()%(360/rotation_scale)*rotation_scale*FLIP_FACTOR);
	
	Vec2f dir = Vec2f(0, 1);
	dir.RotateBy(this.getAngleDegrees());
	Vec2f vel = -dir;
	
	const bool flip = this.getVelocity().x<0;
	const f32 flip_factor = flip ? -1 : 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	int sus = Maths::Max(2, this.getVelocity().Length()/5);

	for(int counter = 0; counter < sus; ++counter) {
		f32 speed_mod = this.getVelocity().Length();
		Vec2f offset = Vec2f(-XORRandom(speed_mod), 0).RotateBy(this.getAngleDegrees());
		offset = -this.getVelocity()/sus*counter;
		CParticle@ p = ParticleAnimated("SmallSteam", this.getPosition() + offset, Vec2f(), float(XORRandom(360)), 1.0f, 2 + XORRandom(3), 0, false);
		if (p !is null) {
			//p.growth = -0.05;
			p.deadeffect = -1;
			p.setRenderStyle(RenderStyle::outline);
		}
	}
	this.SetMapEdgeFlags(u8(CBlob::map_collide_none | CBlob::map_collide_left | CBlob::map_collide_right | CBlob::map_collide_nodeath));
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2 )
{
	if (blob !is null && !blob.getShape().getConsts().collidable) return;
	
	if (!this.get_bool("had_rotation_script"))
	{
		this.RemoveScript("RotateBlobTowardsHeading.as");
	}
	
	this.getShape().setDrag(this.get_f32("def_drag"));
	this.SetMapEdgeFlags(this.get_u8("def_edgeflags"));
	this.setAngleDegrees(0);
	
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}