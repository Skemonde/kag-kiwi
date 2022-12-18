#include "FirearmVars.as";

void onInit(CBlob@ this)
{
	FirearmVars vars = FirearmVars();
	
	vars.FIRE_INTERVAL = 2;
	vars.INACCURACY = 3;
	vars.BURST = 3;
	
	vars.MAG = 12;
	vars.AMMO = "highpow";
	vars.RELOAD = 60;
	
	vars.PROJ_SPEED = 25;
	//vars.PROJ_BLOB;
	//vars.PROJ_HITTER_TYPE = "bullet_rifle";
	vars.PROJ_DAMAGE = 3;
	vars.PROJ_RANGE = 512;
	
	vars.FIRE_SOUND = "kastengewehr_shot";
	
	vars.MUZZLE_OFFSET = Vec2f(-18.5, 0);
	vars.GUN_TRANS = Vec2f(5.5, -1.5);
	vars.KICKBACK_FORCE = Vec2f(-3, 4);
	
	this.set("firearm_vars", @vars);
	
	//custom
	this.Tag("EmptyMagazineParticle");
}