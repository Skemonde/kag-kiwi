#include "FirearmVars.as";

void onInit(CBlob@ this)
{
	FirearmVars vars = FirearmVars();
	
	vars.FIRE_INTERVAL = 2;
	vars.INACCURACY = 1;
	vars.BURST = 1;
	
	vars.MAG = 6;
	//vars.CLIP = 0;
	vars.AMMO = "grenades";
	vars.RELOAD = 5;
	vars.RELOAD_SOUND = "grenade_launcher_load";
	
	vars.PROJ_SPEED = 12;
	vars.PROJ_BLOB = "grenade";
	//vars.PROJ_HITTER_TYPE = "bullet_rifle";
	//vars.PROJ_DAMAGE = 2;
	
	vars.FIRE_SOUND = "grenade_launcher_shot";
	
	vars.MUZZLE_OFFSET = Vec2f(-18.5, 0);
	vars.GUN_TRANS = Vec2f(4, -1);
	vars.KICKBACK_FORCE = Vec2f(0, 0);
	
	//vars.RELOAD_SOUND_PITCH = 1.0f;
	//vars.FIRE_SOUND_PITCH = 1.0f;
	vars.RELOAD_ENDING_SOUND_PITCH = 1.3f;
	//vars.CYCLE_SOUND_PITCH = 1.0f;
	
	this.set("firearm_vars", @vars);
	
	//custom
	this.set_string("CustomMuzzleFlash", "");
	this.set_string("EmptyCaseDuringReload", "");
	this.set_string("CustomEmptyCase", "Grenade");
	this.set_string("CustomReloadingEnding", "rifle_cycle");
	this.Tag("ReloadByOneRound");
}