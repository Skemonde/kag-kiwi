//#include "KIWI_Locales"

void onInit(CBlob@ this)
{
	//this.setInventoryName(Names::name_knight_shield);
	//floats
	this.set_f32("bash_damage", 0.1f);
	this.set_f32("bash_force", 400);
	this.set_f32("shielding_angle_min", 90);
	this.set_f32("shielding_angle_max", 120);
	//ints
	this.set_s32("bash_interval", 65);
	this.set_s32("bash_moment", 15);
	this.set_s32("bash_stun", 20);
}