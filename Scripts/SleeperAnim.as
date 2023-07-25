CSpriteLayer@ sleeper (CSprite@ this)
{
	this.RemoveSpriteLayer("zzz");
	CBlob@ blob = this.getBlob();
	if (blob is null) return null;
	this.SetEmitSoundPaused(true);
	this.RewindEmitSound();
	if (!blob.exists("sleeper_name") || blob.get_string("sleeper_name").empty()) return null;
	
	this.SetEmitSound("MigrantSleep.ogg");
	this.SetEmitSoundPaused(false);
	this.SetEmitSoundVolume(0.25f);
	
	CSpriteLayer@ zzz = this.addSpriteLayer("zzz", "Quarters.png", 8, 8);
	if (zzz !is null)
	{
		{
			zzz.addAnimation("default", 15, true);
			int[] frames = {96, 97, 98, 98, 99};
			zzz.animation.AddFrames(frames);
		}
		zzz.SetOffset(Vec2f(2, -8));
		zzz.SetLighting(false);
		zzz.SetRelativeZ(this.getZ()+4);
		zzz.SetVisible(true);
	}
	
	return zzz;
}

void onTick(CSprite@ this)
{
	CSpriteLayer@ zzz = this.getSpriteLayer("zzz");
	if (zzz is null) @zzz = sleeper(this);
}

void onPlayerInfoChanged(CSprite@ this)
{
	CSpriteLayer@ zzz = sleeper(this);
}