#include "FirearmVars"
#include "KIWI_Locales"

void onInit(CBlob@ this)
{
	this.setInventoryName(Names::pump_shotgun);
	this.Tag("shot_force");
	
	
	FirearmVars vars = FirearmVars();
	//GUN
	vars.T_TO_DIE 					= -1; 
	vars.C_TAG						= "basic_gun"; 
	vars.MUZZLE_OFFSET				= Vec2f(-26, -2);
	vars.SPRITE_TRANSLATION			= Vec2f(5, 2);
	//AMMO
	vars.CLIP						= 4; 
	vars.TOTAL						= 0; 
	vars.AMMO_TYPE.push_back("shells");
	//RELOAD
	vars.RELOAD_HANDFED_ROUNDS		= 1; 
	vars.EMPTY_RELOAD				= false;
	vars.RELOAD_TIME				= 13; 
	//FIRING
	vars.FIRE_INTERVAL				= 35; 
	vars.FIRE_AUTOMATIC				= false;
	vars.ONOMATOPOEIA				= "pow";
	vars.FLASH_SPRITE				= "flash_shotgun_pellet";
	//EJECTION
	vars.SELF_EJECTING				= true; 
	vars.CART_SPRITE				= "ShellCase";
	vars.CLIP_SPRITE				= ""; 
	//MULTISHOT
	vars.BURST						= 1;
	vars.BURST_INTERVAL				= vars.FIRE_INTERVAL;
	vars.BUL_PER_SHOT				= 9; 
	vars.B_SPREAD					= 8; 
	vars.UNIFORM_SPREAD				= true;
	//TRAJECTORY
	vars.B_GRAV						= Vec2f(0,0);
	vars.B_SPEED					= 14; 
	vars.B_SPEED_RANDOM				= 7; 
	vars.B_TTL_TICKS				= 15; 
	vars.RICOCHET_CHANCE			= 100;
	vars.RANGE						= getMap().tilesize*35;
	//DAMAGE
	vars.B_DAMAGE					= 17; 
	vars.B_HITTER					= HittersKIWI::pump_shotgun;
	vars.B_PENETRATION				= 0; 
	vars.B_KB						= Vec2f(0, 0); 
	//COINS
	vars.B_F_COINS					= 0;
	vars.B_O_COINS					= 0;
	//BULLET SOUNDS
	vars.S_FLESH_HIT				= "ArrowHitFlesh.ogg";
	vars.S_OBJECT_HIT				= "BulletImpact.ogg"; 
	//GUN SOUNDS
	vars.FIRE_SOUND					= "shotgun_dbl_fire.ogg";
	vars.FIRE_PITCH					= 1.0f;
	vars.CYCLE_SOUND				= "shotgun_cycle.ogg";
	vars.CYCLE_PITCH				= 1.0f;
	vars.LOAD_SOUND					= "shotgun_load.ogg";
	vars.LOAD_PITCH					= 1.0f;
	vars.RELOAD_SOUND				= "metal_slug_shotgun.ogg";
	vars.RELOAD_PITCH				= 1.0f;
	//BULLET SPRITES
	vars.BULLET_SPRITE				= "smg_bullet";
	vars.FADE_SPRITE				= "";
	this.set("firearm_vars", @vars);
}