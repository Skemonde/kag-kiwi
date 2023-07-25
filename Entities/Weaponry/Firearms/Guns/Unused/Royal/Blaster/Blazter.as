#include "FirearmVars"
#include "KIWI_Locales"

void onInit(CBlob@ this)
{
	this.setInventoryName(Names::kushana);
	this.Tag("NoAccuracyBonus");
	this.Tag("handgun");
	
	
	FirearmVars vars = FirearmVars();
	//GUN
	vars.T_TO_DIE 					= -1; 
	vars.C_TAG						= "royal_gun"; 
	vars.MUZZLE_OFFSET				= Vec2f(-22.5,-1.5);
	vars.SPRITE_TRANSLATION			= Vec2f(5, -1);
	//AMMO
	vars.CLIP						= 8; 
	vars.TOTAL						= 0; 
	vars.AMMO_TYPE.push_back("lowcal");
	//RELOAD
	vars.RELOAD_HANDFED_ROUNDS		= 0; 
	vars.EMPTY_RELOAD				= false;
	vars.RELOAD_TIME				= 10; 
	//FIRING
	vars.FIRE_INTERVAL				= 12; 
	vars.FIRE_AUTOMATIC				= true; 
	vars.ONOMATOPOEIA				= "bang";
	//EJECTION
	vars.SELF_EJECTING				= true; 
	vars.CART_SPRITE				= "RoundCase.png";
	vars.CLIP_SPRITE				= ""; 
	//MULTISHOT
	vars.BURST						= 1;
	vars.BURST_INTERVAL				= vars.FIRE_INTERVAL;
	vars.BUL_PER_SHOT				= 1; 
	vars.B_SPREAD					= 4; 
	vars.UNIFORM_SPREAD				= false;
	//TRAJECTORY
	vars.B_GRAV						= Vec2f(0,0);
	vars.B_SPEED					= 30; 
	vars.B_SPEED_RANDOM				= 2; 
	vars.B_TTL_TICKS				= 32; 
	vars.RICOCHET_CHANCE			= 1;
	vars.RANGE						= 320;
	//DAMAGE
	vars.B_DAMAGE					= 4; 
	vars.B_HITTER					= HittersKIWI::cos_will;
	vars.B_PENETRATION				= 0; 
	vars.B_KB						= Vec2f(0,0); 
	//COINS
	vars.B_F_COINS					= 0;
	vars.B_O_COINS					= 0;
	//BULLET SOUNDS
	vars.S_FLESH_HIT				= "ArrowHitFlesh.ogg";
	vars.S_OBJECT_HIT				= "BulletImpact.ogg"; 
	//GUN SOUNDS
	vars.FIRE_SOUND					= "blaster_shot.ogg";
	vars.FIRE_PITCH					= 1.0f;
	vars.CYCLE_SOUND				= "";
	vars.CYCLE_PITCH				= 1.0f;
	vars.LOAD_SOUND					= "pistol_load.ogg";
	vars.LOAD_PITCH					= 1.0f;
	vars.RELOAD_SOUND				= "";
	vars.RELOAD_PITCH				= 1.0f;
	//BULLET SPRITES
	vars.BULLET_SPRITE				= "smg_bullet.png";
	vars.FADE_SPRITE				= "";
	this.set("firearm_vars", @vars);
}