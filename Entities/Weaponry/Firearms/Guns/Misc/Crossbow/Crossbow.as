#include "FirearmVars"
#include "KIWI_Locales"

void onInit(CBlob@ this)
{
	this.setInventoryName("Crossbow");
	this.Tag("has_zoom");
	
	
	FirearmVars vars = FirearmVars();
	//GUN
	vars.T_TO_DIE 					= -1;
	vars.C_TAG						= "advanced_gun";
	vars.MUZZLE_OFFSET				= Vec2f(-18,1);
	vars.SPRITE_TRANSLATION			= Vec2f(4, -1.5);
	vars.BULLET						= "raycast";
	//AMMO
	vars.CLIP						= 1; 
	vars.TOTAL						= 0; 
	vars.AMMO_TYPE.push_back("mat_arrows");
	//RELOAD
	vars.RELOAD_HANDFED_ROUNDS		= 0; 
	vars.EMPTY_RELOAD				= false;
	vars.RELOAD_TIME				= 5*getTicksASecond();
	vars.RELOAD_ANGLE				= -10;
	//FIRING
	vars.FIRE_INTERVAL				= 15; 
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
	vars.B_GRAV						= Vec2f(0,0);
	vars.B_SPEED					= 16; 
	vars.B_SPEED_RANDOM				= 2; 
	vars.B_TTL_TICKS				= 32; 
	vars.RANGE						= 70*getMap().tilesize; 
	//DAMAGE
	vars.B_DAMAGE					= 25; 
	vars.B_HITTER					= Hitters::arrow;
	vars.B_PENETRATION				= 0; 
	vars.B_KB						= Vec2f(0, 0); 
	//COINS
	vars.B_F_COINS					= 0;
	vars.B_O_COINS					= 0;
	//BULLET SOUNDS
	vars.S_FLESH_HIT				= "ArrowHitFlesh.ogg";
	vars.S_OBJECT_HIT				= "BulletImpact.ogg"; 
	//GUN SOUNDS
	vars.FIRE_SOUND					= "BowFire.ogg";
	vars.FIRE_PITCH					= 1.4f;
	vars.CYCLE_SOUND				= "";
	vars.CYCLE_PITCH				= 1.0f;
	vars.LOAD_SOUND					= "smg_load.ogg";
	vars.LOAD_PITCH					= 1.0f;
	vars.RELOAD_SOUND				= "metal_slug_fullok.ogg";
	vars.RELOAD_PITCH				= 1.0f;
	//BULLET SPRITES
	vars.BULLET_SPRITE				= "laser";
	vars.FADE_SPRITE				= "";
	this.set("firearm_vars", @vars);
}