#include "FirearmVars.as";

void onInit(CBlob@ this)
{
	FirearmVars vars = FirearmVars();
	
	vars.FIRE_INTERVAL = 60;
	vars.INACCURACY = 30;
	vars.BURST = 1;
	
	vars.MAG = 1;
	
	vars.PROJ_SPEED = 4;
	vars.PROJ_AMOUNT = 4;
	vars.PROJ_BLOB = "clusterbullet";
	//vars.PROJ_HITTER_TYPE = "bullet_pistol";
	vars.PROJ_DAMAGE = 12;
	
	vars.FIRE_SOUND = "handgrenade_blast";
	
	vars.MUZZLE_OFFSET = Vec2f(-13.5, -3);
	vars.GUN_TRANS = Vec2f(4.5, -1.5);
	vars.KICKBACK_FORCE = Vec2f(-3, 2);
	
	this.set("firearm_vars", @vars);
	
	//custom
	this.Tag("UniformSpread");
}