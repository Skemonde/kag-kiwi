#include "FirearmVars"
#include "KIWI_Locales"

void onInit(CBlob@ this)
{
	this.setInventoryName("");
	this.Tag("has_zoom");
	this.Tag("heavy weight");
	//this.Tag("cant have gun attachments");
	this.Tag("shot_force");
	
	
	FirearmVars vars = FirearmVars();
	//GUN
	vars.C_TAG						= "advanced_gun";
	vars.MUZZLE_OFFSET				= Vec2f(-34, -4);
	vars.SPRITE_TRANSLATION			= Vec2f(8, 0);
	//AMMO
	vars.CLIP						= 1; 
	vars.TOTAL						= 0; 
	vars.AMMO_TYPE.push_back("draground");
	//RELOAD
	vars.RELOAD_HANDFED_ROUNDS		= 0; 
	vars.EMPTY_RELOAD				= false;
	vars.RELOAD_TIME				= 7*getTicksASecond();
	vars.RELOAD_ANGLE				= -10;
	//FIRING
	vars.FIRE_INTERVAL				= 30; 
	vars.FIRE_AUTOMATIC				= true; 
	vars.ONOMATOPOEIA				= "foom";
	vars.FLASH_SPRITE				= "from_bullet";
	//EJECTION
	vars.SELF_EJECTING				= true; 
	vars.CART_SPRITE				= "DragunovCase"; 
	vars.CLIP_SPRITE				= "";
	//MULTISHOT
	vars.BURST						= 0;
	vars.BURST_INTERVAL				= 2;
	vars.BUL_PER_SHOT				= 1; 
	vars.B_SPREAD					= 0; 
	vars.UNIFORM_SPREAD				= false;
	//TRAJECTORY
	vars.B_GRAV						= Vec2f(0, 0.02);
	vars.B_SPEED					= 30; 
	vars.B_SPEED_RANDOM				= 0;
	vars.RANGE						= 900*getMap().tilesize;
	//DAMAGE
	vars.B_DAMAGE					= 512; 
	vars.B_HITTER					= HittersKIWI::apc_cannon;
	vars.B_PENETRATION				= 0;
	//BULLET SOUNDS
	vars.S_FLESH_HIT				= "ArrowHitFlesh.ogg";
	vars.S_OBJECT_HIT				= "BulletImpact.ogg"; 
	//GUN SOUNDS
	vars.FIRE_SOUND					= "PatriotExplosion.ogg";
	vars.FIRE_PITCH					= 1.5f;
	vars.CYCLE_SOUND				= "tank_unload.ogg";
	vars.CYCLE_PITCH				= 1.6f;
	vars.LOAD_SOUND					= "smg_load.ogg";
	vars.LOAD_PITCH					= 0.4f;
	vars.RELOAD_SOUND				= "rifle_cycle.ogg";
	vars.RELOAD_PITCH				= 0.5f;
	//BULLET SPRITES
	vars.BULLET_SPRITE				= "smg_bullet";
	vars.FADE_SPRITE				= "";
	this.set("firearm_vars", @vars);
}