#include "FirearmVars.as";

void onInit(CBlob@ this)
{
	FirearmVars vars = FirearmVars();
	
	vars.FIRE_INTERVAL = 10;
	vars.INACCURACY = 30;
	vars.BURST = 0;
	
	vars.MAG = 8;
	//vars.CLIP = 0;
	vars.AMMO = "shells";
	vars.RELOAD = 10;
	vars.RELOAD_SOUND = "shotgun_load";
	
	vars.PROJ_SPEED = 15;
	vars.PROJ_AMOUNT = 7;
	vars.PROJ_BLOB = "pellet";
	vars.PROJ_HITTER = HittersKIWI::pellet;
	vars.PROJ_DAMAGE = 1.4f;
	vars.PROJ_RANGE = 256;
	
	vars.FIRE_SOUND = "shotgun_shot";
	
	vars.MUZZLE_OFFSET = Vec2f(-18, -2);
	vars.GUN_TRANS = Vec2f(5, -1);
	vars.KICKBACK_FORCE = Vec2f(-3, 4);
	
	//vars.RELOAD_SOUND_PITCH = 1.0f;
	//vars.FIRE_SOUND_PITCH = 1.0f;
	//vars.RELOAD_ENDING_SOUND_PITCH = 1.0f;
	//vars.CYCLE_SOUND_PITCH = 1.0f;
	
	this.set("firearm_vars", @vars);
	
	//custom
	this.set_string("CustomCycleSound", "shotgun_cycle");
	this.set_string("CustomReloadingEnding", "shotgun_cycle");
	this.set_string("CustomEmptyCase", "ShellCase");
	this.set_string("CustomShotFX", "pow");
	
	this.Tag("ReloadByOneRound");
	this.Tag("NoAccuracyBonus");
	this.Tag("NoBurstPenalty");
}