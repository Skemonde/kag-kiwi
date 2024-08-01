#include "KIWI_Locales"

void onInit(CBlob@ this)
{
	this.setInventoryName(Names::shotgunshells);
	
	if (getNet().isServer())
	{
	this.set_u8('decay step', 2);
	}
	
	this.Tag("ammo");
	
	this.maxQuantity = 24;

	this.AddScript("DoTicksInInventory.as");
  //this.getCurrentScript().runFlags |= Script::remove_after_this;
}

void onDie(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	Vec2f pos = blob.getPosition();
	//todo: make this particle when one stack is gone
	if(!isClient()){return;}
	CParticle@ box   = makeGibParticle("EmptyBox.png", pos, Vec2f(0.5*(XORRandom(2) == 1 ? 1 : -1), -3), 0, 0, Vec2f(16, 16), 2.0f, 20, "/BodyGibFall", 0);
}