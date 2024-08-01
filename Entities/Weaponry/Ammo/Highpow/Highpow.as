#include "KIWI_Locales"

void onInit(CBlob@ this)
{
	this.setInventoryName(Names::highpow);
	
	if (getNet().isServer())
	{
	this.set_u8('decay step', 2);
	}
	
	this.Tag("ammo");
	
	this.maxQuantity = 30;
	
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}
