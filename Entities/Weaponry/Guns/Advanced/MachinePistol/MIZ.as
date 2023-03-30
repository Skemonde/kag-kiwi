#include "FirearmVars"
#include "KIWI_Locales"

void onInit(CBlob@ this)
{
	this.setInventoryName(Names::mp);
	this.Tag("NoAccuracyBonus");
	
	
	FirearmVars vars = FirearmVars();
	//GUN
	vars.T_TO_DIE 					= -1; 
	vars.C_TAG						= "advanced_gun";
	vars.MUZZLE_OFFSET				= Vec2f(-20,-3);
	vars.SPRITE_TRANSLATION			= Vec2f(5, -1);
	//AMMO
	vars.CLIP						= 10; 
	vars.TOTAL						= 0; 
	vars.AMMO_TYPE					= "lowcal";
	//RELOAD
	vars.RELOAD_HANDFED_ROUNDS		= 0; 
	vars.EMPTY_RELOAD				= false;
	vars.RELOAD_TIME				= 15; 
	//FIRING
	vars.FIRE_INTERVAL				= 2; 
	vars.FIRE_AUTOMATIC				= true; 
	vars.ONOMATOPOEIA				= "ratta";
	//EJECTION
	vars.SELF_EJECTING				= true; 
	vars.CART_SPRITE				= "RoundCase.png";
	vars.CLIP_SPRITE				= ""; 
	//MULTISHOT
	vars.BURST						= 1; 
	vars.BURST_INTERVAL				= vars.FIRE_INTERVAL; 
	vars.BUL_PER_SHOT				= 1; 
	vars.B_SPREAD					= 15; 
	vars.UNIFORM_SPREAD				= false;
	//TRAJECTORY
	vars.B_GRAV						= Vec2f(0,0);
	vars.B_SPEED					= 10; 
	vars.B_SPEED_RANDOM				= 0; 
	vars.B_TTL_TICKS				= 24; 
	vars.RICOCHET_CHANCE			= 10; 
	//DAMAGE
	vars.B_DAMAGE					= 2; 
	vars.B_HITTER					= HittersKIWI::bullet_pistol;
	vars.B_PENETRATION				= 0; 
	vars.B_KB						= Vec2f(0,0); 
	//COINS
	vars.B_F_COINS					= 0;
	vars.B_O_COINS					= 0;
	//BULLET SOUNDS
	vars.S_FLESH_HIT				= "ArrowHitFlesh.ogg";
	vars.S_OBJECT_HIT				= "BulletImpact.ogg"; 
	//GUN SOUNDS
	vars.FIRE_SOUND					= "miz_shot.ogg";
	vars.FIRE_PITCH					= 1.0f;
	vars.CYCLE_SOUND				= "";
	vars.CYCLE_PITCH				= 1.0f;
	vars.LOAD_SOUND					= "pistol_load.ogg";
	vars.LOAD_PITCH					= 1.0f;
	vars.RELOAD_SOUND				= "1911_reload.ogg";
	vars.RELOAD_PITCH				= 0.85f;
	//BULLET SPRITES
	vars.BULLET_SPRITE				= "smg_bullet.png";
	vars.FADE_SPRITE				= "";
	this.set("firearm_vars", @vars);
}