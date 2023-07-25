#include "FirearmVars"

void onInit(CBlob@ this)
{
	this.set_u8("alt_fire_item", AltFire::UnderbarrelNader);
	this.set_u16("alt_fire_interval", 60);
}
