#include "Tunes.as";

void onInit(CBlob@ this)
{
	this.set_u32("customData", XORRandom(tunes.length()-1));//song number in Tunes.as
}

void onTick(CBlob@ this)
{
	this.SetInventoryIcon("Tape.png", this.get_u32("customData"), Vec2f(16, 8));
	this.getSprite().SetFrameIndex(this.get_u32("customData"));
}

void onTick(CSprite@ this)
{
	this.SetFacingLeft(false);
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return !(blob.hasTag("player") || blob.hasTag("vehicle"));
}