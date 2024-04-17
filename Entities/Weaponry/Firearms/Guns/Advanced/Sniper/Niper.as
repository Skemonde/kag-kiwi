#include "FirearmVars"
#include "KIWI_Locales"

void onInit(CBlob@ this)
{
	this.setInventoryName(Names::sniper);
	//this.Tag("has_zoom");
	this.Tag("medium weight");
	//this.Tag("cant have gun attachments");
	this.Tag("shot_force");
	
	
	FirearmVars vars = FirearmVars();
	//GUN
	vars.C_TAG						= "advanced_gun"; 
	vars.MUZZLE_OFFSET				= Vec2f(-32.5,-1);
	vars.SPRITE_TRANSLATION			= Vec2f(9.5, -1.5);
	vars.ALT_FIRE					= AltFire::LaserPointer;
	//AMMO
	vars.CLIP						= 3; 
	vars.TOTAL						= 0; 
	vars.AMMO_TYPE.push_back("highpow");
	//RELOAD
	vars.RELOAD_HANDFED_ROUNDS		= 0; 
	vars.EMPTY_RELOAD				= true;
	vars.RELOAD_TIME				= 5*getTicksASecond(); 
	//FIRING
	vars.FIRE_INTERVAL				= 2*getTicksASecond(); 
	vars.FIRE_AUTOMATIC				= false;
	vars.ONOMATOPOEIA				= "pew";
	vars.FLASH_SPRITE				= "from_bullet";
	//EJECTION
	vars.SELF_EJECTING				= true; 
	vars.CART_SPRITE				= "BigRoundCase.png"; 
	vars.CLIP_SPRITE				= "sniper_clip.png";
	//MULTISHOT
	vars.BURST						= 1;
	vars.BURST_INTERVAL				= vars.FIRE_INTERVAL;
	vars.BUL_PER_SHOT				= 1; 
	vars.B_SPREAD					= 0; 
	vars.UNIFORM_SPREAD				= false;
	//TRAJECTORY
	vars.B_GRAV						= Vec2f(0,0);
	vars.B_SPEED					= 50; 
	vars.B_SPEED_RANDOM				= 2;
	vars.RANGE						= 200*getMap().tilesize;
	//DAMAGE
	vars.B_DAMAGE					= 135; 
	vars.B_HITTER					= HittersKIWI::hord;
	vars.B_PENETRATION				= 0;
	//BULLET SOUNDS
	vars.S_FLESH_HIT				= "ArrowHitFlesh.ogg";
	vars.S_OBJECT_HIT				= "BulletImpact.ogg"; 
	//GUN SOUNDS
	vars.FIRE_SOUND					= "heavy_rifle_fire.ogg";
	vars.FIRE_PITCH					= 0.8f;
	vars.CYCLE_SOUND				= "rifle_cycle.ogg";
	vars.CYCLE_PITCH				= 1.0f;
	vars.LOAD_SOUND					= "sniper_load.ogg";
	vars.LOAD_PITCH					= 1.0f;
	vars.RELOAD_SOUND				= "rifle_cycle.ogg";
	vars.RELOAD_PITCH				= 1.0f;
	//BULLET SPRITES
	vars.BULLET_SPRITE				= "mantis_bullet";
	vars.FADE_SPRITE				= "";
	this.set("firearm_vars", @vars);
}