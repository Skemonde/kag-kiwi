void onInit(CBlob@ this)
{
	//floats
	this.set_f32("bash_damage", 8.5f);
	this.set_f32("bash_force", 350);
	this.set_f32("shielding_angle_min", 40);
	this.set_f32("shielding_angle_max", 70);
	//ints
	this.set_s32("bash_interval", 90);
	this.set_s32("bash_moment", 7);
	this.set_s32("bash_stun", 10);
}