#include "FirearmVars.as";

void onInit(CBlob@ this)
{
	FirearmVars vars = FirearmVars();
	
	vars.FIRE_INTERVAL = 4;
	vars.INACCURACY = 15;
	vars.BURST = 1;
	
	vars.MAG = 8;
	
	vars.PROJ_SPEED = 30;
	//vars.PROJ_BLOB = "fraggrenade";
	//vars.PROJ_HITTER_TYPE = "bullet_pistol";
	vars.PROJ_DAMAGE = 1.5;
	vars.PROJ_RANGE = 216;
	
	vars.FIRE_SOUND = "cock_shot";
	
	vars.MUZZLE_OFFSET = Vec2f(-13.5, -3);
	vars.GUN_TRANS = Vec2f(4.5, -1.5);
	vars.KICKBACK_FORCE = Vec2f(-3, 2);
	
	//vars.RELOAD_SOUND_PITCH = 1.0f;
	vars.FIRE_SOUND_PITCH = 1.2f;
	//vars.RELOAD_ENDING_SOUND_PITCH = 1.0f;
	//vars.CYCLE_SOUND_PITCH = 1.0f;
	
	this.set("firearm_vars", @vars);
	
	// custom
	//this.set_string("EmptyCaseDuringReload", "");
}