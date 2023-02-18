#include "KIWI_Locales.as";

void onInit(CBlob@ this) 
{
	this.setInventoryName(Names::mp);
	this.Tag("looped_sound");
	this.Tag("NoAccuracyBonus");
	this.set_string("bullet_blob", "napalm");
}