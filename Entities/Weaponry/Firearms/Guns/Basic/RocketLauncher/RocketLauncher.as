#include "FirearmVars"
#include "KIWI_Locales"

void onInit(CBlob@ this)
{
	this.setInventoryName("Rocketer");
	//this.Tag("has_zoom");
	this.Tag("medium weight");
	
	
	FirearmVars vars = FirearmVars();
	//GUN
	vars.T_TO_DIE 					= -1;
	vars.C_TAG						= "advanced_gun";
	vars.MUZZLE_OFFSET				= Vec2f(-28.5,0);
	vars.SPRITE_TRANSLATION			= Vec2f(-1, -1.5);
	vars.AIM_OFFSET					= Vec2f(0, 0.5);
	vars.BULLET						= "rocket";
	vars.TRENCH_AIM					= 1;
	//AMMO
	vars.CLIP						= 4; 
	vars.TOTAL						= 0; 
	vars.AMMO_TYPE.push_back("froggy");
	//RELOAD
	vars.RELOAD_HANDFED_ROUNDS		= 1; 
	vars.EMPTY_RELOAD				= false;
	vars.RELOAD_TIME				= 24;
	vars.RELOAD_ANGLE				= 50;
	//FIRING
	vars.FIRE_INTERVAL				= vars.RELOAD_TIME; 
	vars.FIRE_AUTOMATIC				= false; 
	vars.ONOMATOPOEIA				= "";
	vars.FLASH_SPRITE				= "";
	//EJECTION
	vars.SELF_EJECTING				= true; 
	vars.CART_SPRITE				= ""; 
	vars.CLIP_SPRITE				= "";
	//MULTISHOT
	vars.BURST						= 1;
	vars.BURST_INTERVAL				= vars.FIRE_INTERVAL;
	vars.BUL_PER_SHOT				= 1; 
	vars.B_SPREAD					= 0; 
	vars.UNIFORM_SPREAD				= false;
	//TRAJECTORY
	vars.B_GRAV						= Vec2f(0, 0.033);
	vars.B_SPEED					= 12; 
	vars.B_SPEED_RANDOM				= 0;
	vars.RANGE						= 140*getMap().tilesize; 
	//DAMAGE
	vars.B_DAMAGE					= 0; 
	vars.B_HITTER					= HittersKIWI::rocketer;
	//EXPLOSIVE LOGIC
	vars.EXPLOSIVE					= true;
	vars.EXPL_RADIUS 				= 64;
	vars.EXPL_DAMAGE 				= 24;
	vars.EXPL_MAP_RADIUS 			= 40;
	vars.EXPL_MAP_DAMAGE 			= 0.4;
	vars.EXPL_RAYCAST 				= false;
	vars.EXPL_TEAMKILL 				= false;
	//BULLET SOUNDS
	vars.S_FLESH_HIT				= "ArrowHitFlesh.ogg";
	vars.S_OBJECT_HIT				= "BulletImpact.ogg"; 
	//GUN SOUNDS
	vars.FIRE_SOUND					= "bazooka_fire.ogg";
	vars.FIRE_PITCH					= 1.0f;
	vars.CYCLE_SOUND				= "";
	vars.CYCLE_PITCH				= 1.0f;
	vars.LOAD_SOUND					= "rocketer_cycle.ogg";
	vars.LOAD_PITCH					= 0.8f;
	vars.RELOAD_SOUND				= "";
	vars.RELOAD_PITCH				= 1.0f;
	//BULLET SPRITES
	vars.BULLET_SPRITE				= "";
	vars.FADE_SPRITE				= "";
	this.set("firearm_vars", @vars);
}