#include "FirearmVars"
#include "KIWI_Locales"

void onInit(CBlob@ this)
{
	this.setInventoryName(Names::rifle);
	this.Tag("has_zoom");
	
	
	FirearmVars vars = FirearmVars();
	//GUN
	vars.T_TO_DIE 					= -1;
	vars.C_TAG						= "basic_gun";
	vars.MUZZLE_OFFSET				= Vec2f(-26,-3);
	vars.SPRITE_TRANSLATION			= Vec2f(7, -1);
	//AMMO
	vars.CLIP						= 5;
	vars.TOTAL						= 2;
	vars.AMMO_TYPE					= "highpow";
	//RELOAD
	vars.RELOAD_HANDFED_ROUNDS		= 5;
	vars.EMPTY_RELOAD				= false;
	vars.RELOAD_TIME				= 60;
	//FIRING
	vars.FIRE_INTERVAL				= 20;
	vars.FIRE_AUTOMATIC				= false;
	vars.ONOMATOPOEIA				= "bang";
	//EJECTION
	vars.SELF_EJECTING				= true;
	vars.CART_SPRITE				= "RoundCase.png";
	vars.CLIP_SPRITE				= "rifle_magazine.png";
	//MULTISHOT
	vars.BURST						= 1;
	vars.BURST_INTERVAL				= vars.FIRE_INTERVAL;
	vars.BUL_PER_SHOT				= 1;
	vars.B_SPREAD					= 2;
	vars.UNIFORM_SPREAD				= false;
	//TRAJECTORY
	vars.B_GRAV						= Vec2f(0,0);
	vars.B_SPEED					= 60;
	vars.B_SPEED_RANDOM				= 0;
	vars.B_TTL_TICKS				= 30;
	vars.RICOCHET_CHANCE			= 0;
	//DAMAGE
	vars.B_DAMAGE					= 7;
	vars.B_HITTER					= HittersKIWI::bullet_rifle;
	vars.B_PENETRATION				= 0;
	vars.B_KB						= Vec2f(0,0);
	//COINS
	vars.B_F_COINS					= 0;
	vars.B_O_COINS					= 0;
	//BULLET SOUNDS
	vars.S_FLESH_HIT				= "ArrowHitFlesh.ogg";
	vars.S_OBJECT_HIT				= "BulletImpact.ogg"; 
	//GUN SOUNDS
	vars.FIRE_SOUND					= "rifle_shot.ogg";
	vars.FIRE_PITCH					= 1.3f;
	vars.CYCLE_SOUND				= "rifle_cycle.ogg";
	vars.CYCLE_PITCH				= 1.1f;
	vars.LOAD_SOUND					= "sniper_load.ogg";
	vars.LOAD_PITCH					= 1.0f;
	vars.RELOAD_SOUND				= "rifle_cycle.ogg";
	vars.RELOAD_PITCH				= 1.0f;
	//BULLET SPRITES
	vars.BULLET_SPRITE				= "regular_bullet.png";
	vars.FADE_SPRITE				= "";
	this.set("firearm_vars", @vars);
}