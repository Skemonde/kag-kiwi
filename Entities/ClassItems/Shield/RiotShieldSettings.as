//#include "KIWI_Locales"

void onInit(CBlob@ this)
{
	//this.setInventoryName(Na-mes::name_riot_shield);
	//floats
	this.set_f32("bash_damage", 2.1f);
	this.set_f32("bash_force", 250);
	this.set_f32("shielding_angle_min", 90);
	this.set_f32("shielding_angle_max", 120);
	//ints
	this.set_s32("bash_interval", 90);
	this.set_s32("bash_moment", 15);
	this.set_s32("bash_stun", 45);
	//other stuff
	this.Tag("medium weight");
	this.Tag("fake steel");
}