#include "FirearmVars.as";

void onInit(CBlob@ this)
{
	FirearmVars vars = FirearmVars();
	
	vars.FIRE_INTERVAL = 7;
	vars.INACCURACY = 7;
	vars.BURST = 0;
	
	vars.MAG = 10; // round capacity
	//vars.CLIP = 0; // rounds at firearm's init
	vars.AMMO = "lowcal"; // ammo blob
	vars.RELOAD = 25; // reloading time. Set in ticks
	vars.RELOAD_SOUND = "pistol_load"; // reloading sound
	
	vars.PROJ_SPEED = 15;
	vars.PROJ_AMOUNT = 1;
	//vars.PROJ_BLOB = "regular_bullet";
	vars.PROJ_HITTER = HittersKIWI::bullet_pistol;
	vars.PROJ_DAMAGE = 2;
	vars.PROJ_RANGE = 360; // how far should bullet go? Set in pixels
	
	vars.FIRE_SOUND = "mp_shot";
	
	vars.MUZZLE_OFFSET = Vec2f(-15, -2.5);
	vars.GUN_TRANS = Vec2f(6, -1);
	vars.KICKBACK_FORCE = Vec2f(-3, 2);
	
	//vars.RELOAD_SOUND_PITCH = 1.0f;
	//vars.FIRE_SOUND_PITCH = 1.0f;
	//vars.RELOAD_ENDING_SOUND_PITCH = 1.0f;
	//vars.CYCLE_SOUND_PITCH = 1.0f;
	
	
	this.set("firearm_vars", @vars);
	
	//custom
	this.Tag("NoBurstPenalty");
	this.Tag("NoAccuracyBonus");
}