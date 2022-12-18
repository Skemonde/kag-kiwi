#include "FirearmVars.as";

void onInit(CBlob@ this)
{
	FirearmVars vars = FirearmVars();
	
	vars.FIRE_INTERVAL = 1;
	vars.INACCURACY = 20;
	vars.BURST = 0;
	
	vars.MAG = 40;
	
	vars.PROJ_SPEED = 12;
	//vars.PROJ_BLOB = "grenade";
	vars.PROJ_HITTER = HittersKIWI::bullet_pistol;
	vars.PROJ_DAMAGE = 1.4f;
	vars.PROJ_RANGE = 360;
	
	vars.FIRE_SOUND = "uzi_shot";
	
	vars.MUZZLE_OFFSET = Vec2f(-16, -3);
	vars.GUN_TRANS = Vec2f(7, -0.5);
	vars.KICKBACK_FORCE = Vec2f(-3, 4);
	
	//vars.RELOAD_SOUND_PITCH = 1.0f;
	vars.FIRE_SOUND_PITCH = 0.8f;
	//vars.RELOAD_ENDING_SOUND_PITCH = 1.0f;
	//vars.CYCLE_SOUND_PITCH = 1.0f;
	
	this.set("firearm_vars", @vars);
	
	// custom
	this.set_f32("ClampedAimangle", 20);
	this.set_string("CustomReloadingEnding", "Rechamber");
	this.Tag("EmptyMagazineParticle");
}