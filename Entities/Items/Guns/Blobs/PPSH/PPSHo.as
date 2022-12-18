#include "FirearmVars.as";

void onInit(CBlob@ this)
{
	FirearmVars vars = FirearmVars();
	
	//vars.FIRE_INTERVAL = 2;
	//vars.INACCURACY = 10;
	//vars.BURST = 0;
	
	//vars.MAG = 80;
	//vars.RELOAD = 90;
	
	vars.PROJ_SPEED = 12;
	vars.PROJ_HITTER = HittersKIWI::bullet_pistol;
	vars.PROJ_DAMAGE = 1.4f;
	vars.PROJ_RANGE = 360;
	
	vars.FIRE_SOUND = "ppsh_shot";
	
	vars.MUZZLE_OFFSET = Vec2f(-17.5, -3);
	vars.GUN_TRANS = Vec2f(4.5, 0);
	vars.KICKBACK_FORCE = Vec2f(-3, 4);
	
	vars.RELOAD_SOUND_PITCH = 0.8f;
	vars.FIRE_SOUND_PITCH = 1.2f;
    
	this.set("firearm_vars", @vars);
	
	//custom
	this.set_f32("ClampedAimangle", 20);
	this.Tag("EmptyMagazineParticle");
}