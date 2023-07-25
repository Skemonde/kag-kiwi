#include "Tunes"

void onInit(CBlob@ this)
{
	this.set_u32("customData", XORRandom(tunes.size()-1));//song number in Tunes.as
}

void onTick(CBlob@ this)
{
	const u32 tune = this.get_u32("customData");
	this.SetInventoryIcon("Tape.png", tune, Vec2f(16, 8));
	this.setInventoryName(songnames[tune]);
	this.getSprite().SetFrameIndex(tune);
}

void onTick(CSprite@ this)
{
	this.SetFacingLeft(false);
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return !(blob.hasTag("flesh") || blob.hasTag("vehicle"));
}