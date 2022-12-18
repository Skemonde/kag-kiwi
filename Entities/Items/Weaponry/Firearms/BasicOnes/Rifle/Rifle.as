#include "FirearmVars.as";

void onInit(CBlob@ this)
{
	FirearmVars vars = FirearmVars();
	
	vars.FIRE_INTERVAL = 20;
	vars.INACCURACY = 5;
	vars.BURST = 1;
	
	vars.MAG = 5;
	//vars.CLIP = 0;
	vars.AMMO = "highpow";
	vars.RELOAD = 45;
	vars.RELOAD_SOUND = "sniper_load";
	
	vars.PROJ_SPEED = 25;
	//vars.PROJ_AMOUNT = 10;
	vars.PROJ_BLOB = "bullet";
	vars.PROJ_HITTER = HittersKIWI::bullet_rifle;
	vars.PROJ_DAMAGE = 4;
	vars.PROJ_RANGE = 512;
	
	vars.FIRE_SOUND = "rifle_shot";
	
	vars.MUZZLE_OFFSET = Vec2f(-20, -2);
	vars.GUN_TRANS = Vec2f(7, -1);
	vars.KICKBACK_FORCE = Vec2f(-3, 4);
	
	//vars.RELOAD_SOUND_PITCH = 1.0f;
	vars.FIRE_SOUND_PITCH = 1.3f;
	//vars.RELOAD_ENDING_SOUND_PITCH = 1.0f;
	//vars.CYCLE_SOUND_PITCH = 1.0f;
	
	this.set("firearm_vars", @vars);
	
	//custom
	this.set_string("CustomCycleSound", "rifle_cycle");
	//this.set_string("CustomReloadingEnding", "rifle_cycle");
	this.Tag("EmptyMagazineParticle");
	//this.Tag("CustomReloadByOne");
}