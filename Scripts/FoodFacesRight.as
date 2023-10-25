void onInit(CBlob@ this)
{
	this.Tag("sprite doesnt change facing");
}

void onTick(CSprite@ this)
{
	if (!isClient()) return;
	this.SetFacingLeft(false);
}