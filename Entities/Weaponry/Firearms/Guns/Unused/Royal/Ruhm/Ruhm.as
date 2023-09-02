#include "FirearmVars"
#include "KIWI_Locales"

void onInit(CBlob@ this)
{
	this.setInventoryName(Names::ruhm);
	this.Tag("has_zoom");
	this.Tag("medium weight");
	
	
	FirearmVars vars = FirearmVars();
	//GUN
	vars.T_TO_DIE 					= -1; 
	vars.C_TAG						= "royal_gun"; 
	vars.MUZZLE_OFFSET				= Vec2f(-38.5,0.5);
	vars.SPRITE_TRANSLATION			= Vec2f(16, -2);
	vars.AIM_OFFSET					= Vec2f(0, 1.0);
	//AMMO
	vars.CLIP						= 20; 
	vars.TOTAL						= 0; 
	vars.AMMO_TYPE.push_back("highpow");
	//RELOAD
	vars.RELOAD_HANDFED_ROUNDS		= 0; 
	vars.EMPTY_RELOAD				= false;
	vars.RELOAD_TIME				= 30; 
	//FIRING
	vars.FIRE_INTERVAL				= 1; 
	vars.FIRE_AUTOMATIC				= true; 
	vars.ONOMATOPOEIA				= "ratta";
	vars.FLASH_SPRITE				= "from_bullet";
	//EJECTION
	vars.SELF_EJECTING				= true; 
	vars.CART_SPRITE				= "BigRoundCase.png"; 
	vars.CLIP_SPRITE				= "ruhm_magazine.png";
	//MULTISHOT
	vars.BURST						= 20;
	vars.BURST_INTERVAL				= vars.FIRE_INTERVAL;
	vars.BUL_PER_SHOT				= 2; 
	vars.B_SPREAD					= 3; 
	vars.UNIFORM_SPREAD				= false;
	//TRAJECTORY
	vars.B_GRAV						= Vec2f(0,0);
	vars.B_SPEED					= 30; 
	vars.B_SPEED_RANDOM				= 5;
	vars.RANGE						= 200*getMap().tilesize;
	//DAMAGE
	vars.B_DAMAGE					= 29; 
	vars.B_HITTER					= HittersKIWI::bullet_hmg;
	vars.B_PENETRATION				= 3; 
	vars.B_KB						= Vec2f(0,0); 
	//COINS
	vars.B_F_COINS					= 0;
	vars.B_O_COINS					= 0;
	//BULLET SOUNDS
	vars.S_FLESH_HIT				= "ArrowHitFlesh.ogg";
	vars.S_OBJECT_HIT				= "BulletImpact.ogg"; 
	//GUN SOUNDS
	vars.FIRE_SOUND					= "ruhm_shot.ogg";
	vars.FIRE_PITCH					= 0.8f;
	vars.CYCLE_SOUND				= "";
	vars.CYCLE_PITCH				= 1.0f;
	vars.LOAD_SOUND					= "smg_load.ogg";
	vars.LOAD_PITCH					= 0.7f;
	vars.RELOAD_SOUND				= "rechamber.ogg";
	vars.RELOAD_PITCH				= 1.0f;
	//BULLET SPRITES
	vars.BULLET_SPRITE				= "mantis_bullet";
	vars.FADE_SPRITE				= "";
	this.set("firearm_vars", @vars);
}