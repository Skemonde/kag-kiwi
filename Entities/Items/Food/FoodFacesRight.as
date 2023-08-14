void onTick(CSprite@ this)
{
	if (!isClient()) return;
	this.SetFacingLeft(false);
}