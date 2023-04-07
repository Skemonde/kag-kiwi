#include "FirearmVars"
#include "KIWI_Locales"

void onInit(CBlob@ this)
{
	this.setInventoryName(Names::sniper);
	this.Tag("has_zoom");
	
	
	FirearmVars vars = FirearmVars();
	//GUN
	vars.T_TO_DIE 					= -1; 
	vars.C_TAG						= "advanced_gun"; 
	vars.MUZZLE_OFFSET				= Vec2f(6,-1.5);
	vars.SPRITE_TRANSLATION			= Vec2f(9.5, -1.5);
	//AMMO
	vars.CLIP						= 4; 
	vars.TOTAL						= 0; 
	vars.AMMO_TYPE					= "highpow";
	//RELOAD
	vars.RELOAD_HANDFED_ROUNDS		= 4; 
	vars.EMPTY_RELOAD				= false;
	vars.RELOAD_TIME				= 60; 
	//FIRING
	vars.FIRE_INTERVAL				= 45; 
	vars.FIRE_AUTOMATIC				= false;
	vars.ONOMATOPOEIA				= "pew";
	//EJECTION
	vars.SELF_EJECTING				= true; 
	vars.CART_SPRITE				= "RoundCase.png"; 
	vars.CLIP_SPRITE				= "sniper_clip.png";
	//MULTISHOT
	vars.BURST						= 1;
	vars.BURST_INTERVAL				= vars.FIRE_INTERVAL;
	vars.BUL_PER_SHOT				= 1; 
	vars.B_SPREAD					= 0; 
	vars.UNIFORM_SPREAD				= true;
	//TRAJECTORY
	vars.B_GRAV						= Vec2f(0,0);
	vars.B_SPEED					= 60; 
	vars.B_SPEED_RANDOM				= 0; 
	vars.B_TTL_TICKS				= 24; 
	vars.RICOCHET_CHANCE			= 5; 
	//DAMAGE
	vars.B_DAMAGE					= 6; 
	vars.B_HITTER					= HittersKIWI::bullet_rifle;
	vars.B_PENETRATION				= 2; 
	vars.B_KB						= Vec2f(0,0); 
	//COINS
	vars.B_F_COINS					= 0;
	vars.B_O_COINS					= 0;
	//BULLET SOUNDS
	vars.S_FLESH_HIT				= "ArrowHitFlesh.ogg";
	vars.S_OBJECT_HIT				= "BulletImpact.ogg"; 
	//GUN SOUNDS
	vars.FIRE_SOUND					= "rifle_powerfull_shot.ogg";
	vars.FIRE_PITCH					= 1.0f;
	vars.CYCLE_SOUND				= "rifle_cycle.ogg";
	vars.CYCLE_PITCH				= 1.0f;
	vars.LOAD_SOUND					= "sniper_load.ogg";
	vars.LOAD_PITCH					= 1.0f;
	vars.RELOAD_SOUND				= "rifle_cycle.ogg";
	vars.RELOAD_PITCH				= 1.0f;
	//BULLET SPRITES
	vars.BULLET_SPRITE				= "piercing_bullet.png";
	vars.FADE_SPRITE				= "";
	this.set("firearm_vars", @vars);
}