#include "FirearmVars.as";

void onInit(CBlob@ this)
{
	FirearmVars vars = FirearmVars();
	
	vars.FIRE_INTERVAL = 45;
	vars.INACCURACY = 0;
	vars.BURST = 1;
	
	vars.MAG = 4;
	//vars.CLIP = 0;
	vars.AMMO = "highpow";
	vars.RELOAD = 60;
	vars.RELOAD_SOUND = "sniper_load";
	
	vars.PROJ_SPEED = 15;
	//vars.PROJ_AMOUNT = 10;
	vars.PROJ_BLOB = "piercing_bullet";
	vars.PROJ_HITTER = HittersKIWI::bullet_rifle;
	vars.PROJ_DAMAGE = 6;
	vars.PROJ_RANGE = 512;
	
	vars.FIRE_SOUND = "rifle_powerfull_shot";
	
	vars.MUZZLE_OFFSET = Vec2f(-20, -2);
	vars.GUN_TRANS = Vec2f(7.5, -2);
	vars.KICKBACK_FORCE = Vec2f(-3, 4);
	
	//vars.RELOAD_SOUND_PITCH = 1.0f;
	//vars.FIRE_SOUND_PITCH = 1.3f;
	//vars.RELOAD_ENDING_SOUND_PITCH = 1.0f;
	//vars.CYCLE_SOUND_PITCH = 1.0f;
	
	this.set("firearm_vars", @vars);
	
	//custom
	this.set_string("CustomMuzzleFlash", "flash_piercing_bullet.png");
	this.set_string("CustomShotFX", "pew");
	this.Tag("EmptyMagazineParticle");
}