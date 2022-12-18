#include "FirearmVars.as";

void onInit(CBlob@ this)
{
	FirearmVars vars = FirearmVars();
	
	vars.FIRE_INTERVAL = 2;
	vars.INACCURACY = 0;
	vars.BURST = 0;
	
	vars.MAG = 666;
	//vars.CLIP = 0;
	vars.AMMO = "lowcal";
	vars.RELOAD = 20;
	//vars.RELOAD_SOUND = "LeverRifle_Load";
	
	vars.PROJ_SPEED = 40;
	vars.PROJ_BLOB = "cata_rock";
	//vars.PROJ_HITTER_TYPE = "bullet_rifle";
	vars.PROJ_DAMAGE = 30;
	vars.PROJ_RANGE = 640;
	
	vars.FIRE_SOUND = "uzi_shot";
	
	vars.MUZZLE_OFFSET = Vec2f(-16, -2);
	vars.GUN_TRANS = Vec2f(5, -15);
	vars.KICKBACK_FORCE = Vec2f(-3, 4);
	
	//vars.RELOAD_SOUND_PITCH = 1.0f;
	vars.FIRE_SOUND_PITCH = 0.8f;
	//vars.RELOAD_ENDING_SOUND_PITCH = 1.0f;
	//vars.CYCLE_SOUND_PITCH = 1.0f;
	
	this.set("firearm_vars", @vars);
}