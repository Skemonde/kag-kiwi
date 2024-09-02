#include "FirearmVars"

void onInit(CBlob@ this)
{
	this.setInventoryName("Bolt Action Rifle");
	this.Tag("has_zoom");
	
	
	FirearmVars vars = FirearmVars();
	//GUN
	vars.T_TO_DIE 					= -1;
	vars.C_TAG						= "basic_gun";
	vars.MUZZLE_OFFSET				= Vec2f(-27,-2);
	vars.SPRITE_TRANSLATION			= Vec2f(8, 2);
	//AMMO
	vars.CLIP						= 5;
	vars.TOTAL						= 2;
	vars.AMMO_TYPE.push_back("highpow");
	//RELOAD
	vars.RELOAD_HANDFED_ROUNDS		= vars.CLIP;
	vars.EMPTY_RELOAD				= false;
	vars.RELOAD_TIME				= 30;
	vars.RELOAD_ANGLE				= -10;
	//FIRING
	vars.FIRE_INTERVAL				= 45;
	vars.FIRE_AUTOMATIC				= false;
	vars.ONOMATOPOEIA				= "bang";
	vars.FLASH_SPRITE				= "from_bullet";
	vars.CHARGE_INTERVAL			= 10;
	//EJECTION
	vars.SELF_EJECTING				= true;
	vars.CART_SPRITE				= "BigRoundCase.png";
	vars.CLIP_SPRITE				= "svt_mag.png";
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
	vars.RANGE						= getMap().tilesize*190;
	//DAMAGE
	vars.B_DAMAGE					= 40;
	vars.B_HITTER					= HittersKIWI::semi_auto_rifle;
	vars.B_PENETRATION				= 2; 
	vars.B_KB						= Vec2f(0,0);
	//COINS
	vars.B_F_COINS					= 0;
	vars.B_O_COINS					= 0;
	//BULLET SOUNDS
	vars.S_FLESH_HIT				= "ArrowHitFlesh.ogg";
	vars.S_OBJECT_HIT				= "BulletImpact.ogg"; 
	//GUN SOUNDS
	vars.FIRE_SOUND					= "rifle_fire.ogg";
	vars.FIRE_PITCH					= 0.6f;
	vars.CYCLE_SOUND				= "rifle_cycle.ogg";
	vars.CYCLE_PITCH				= 0.6f;
	vars.LOAD_SOUND					= "sniper_load.ogg";
	vars.LOAD_PITCH					= 0.6f;
	vars.RELOAD_SOUND				= "rifle_cycle.ogg";
	vars.RELOAD_PITCH				= 0.6f;
	//BULLET SPRITES
	vars.BULLET_SPRITE				= "smg_bullet";
	vars.FADE_SPRITE				= "";
	this.set("firearm_vars", @vars);
}