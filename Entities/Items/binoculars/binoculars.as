void onInit(CBlob@ this)
{
	this.Tag("has_zoom");
	this.Tag("firearm");
	this.Tag("trench_aim");
}

void onTick(CBlob@ this)
{
	bool flip = this.isFacingLeft();
	f32 flip_factor = flip ? -1 : 1;
	CSprite@ sprite = this.getSprite();
	
	if (sprite !is null)
	{
		sprite.ResetTransform();
		if (this.isAttached())
			sprite.TranslateBy(Vec2f(4*flip_factor, -2.5+this.get_Vec2f("gun_trans_from_carrier").y));
		else
			sprite.TranslateBy(Vec2f(0, 1));
	}
}