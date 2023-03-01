#include "FirearmVars"
#include "KIWI_Locales"

void onInit(CBlob@ this)
{
	this.setInventoryName(Names::smg);
	this.Tag("NoAccuracyBonus");
	this.set_string("bullet_blob", "grenade");
	
	
	FirearmVars vars = FirearmVars();
	//GUN
	vars.T_TO_DIE 					= -1;
	vars.C_TAG						= "basic_gun";
	vars.MUZZLE_OFFSET				= Vec2f(7,-2);
	vars.SPRITE_TRANSLATION			= Vec2f(7, -2);
	//AMMO
	vars.CLIP						= 1; 
	vars.TOTAL						= 0; 
	vars.AMMO_TYPE					= "grenades";
	//RELOAD
	vars.RELOAD_HANDFED_ROUNDS		= 0; 
	vars.EMPTY_RELOAD				= false;
	vars.RELOAD_TIME				= 45; 
	//FIRING
	vars.FIRE_INTERVAL				= 0; 
	vars.FIRE_AUTOMATIC				= true; 
	vars.ONOMATOPOEIA				= "pow";
	//EJECTION
	vars.SELF_EJECTING				= false; 
	vars.CART_SPRITE				= "empty_grenade_case.png"; 
	vars.CLIP_SPRITE				= "";
	//MULTISHOT
	vars.BURST						= 1;
	vars.BURST_INTERVAL				= vars.FIRE_INTERVAL;
	vars.BUL_PER_SHOT				= 1; 
	vars.B_SPREAD					= 3; 
	vars.UNIFORM_SPREAD				= false;
	//TRAJECTORY
	vars.B_GRAV						= Vec2f(0,0);
	vars.B_SPEED					= 12; 
	vars.B_SPEED_RANDOM				= 0; 
	vars.B_TTL_TICKS				= 32; 
	vars.RICOCHET_CHANCE			= 10; 
	//DAMAGE
	vars.B_DAMAGE					= 1; 
	vars.B_HITTER					= HittersKIWI::bullet_pistol;
	vars.B_PENETRATION				= 0; 
	vars.B_KB						= Vec2f(0, 0); 
	//COINS
	vars.B_F_COINS					= 0;
	vars.B_O_COINS					= 0;
	//BULLET SOUNDS
	vars.S_FLESH_HIT				= "ArrowHitFlesh.ogg";
	vars.S_OBJECT_HIT				= "BulletImpact.ogg"; 
	//GUN SOUNDS
	vars.FIRE_SOUND					= "grenade_launcher_shot.ogg";
	vars.FIRE_PITCH					= 1.0f;
	vars.CYCLE_SOUND				= "";
	vars.CYCLE_PITCH				= 1.0f;
	vars.LOAD_SOUND					= "grenade_launcher_load.ogg";
	vars.LOAD_PITCH					= 1.0f;
	vars.RELOAD_SOUND				= "rifle_cycle.ogg";
	vars.RELOAD_PITCH				= 1.0f;
	//BULLET SPRITES
	vars.BULLET_SPRITE				= "";
	vars.FADE_SPRITE				= "";
	this.set("firearm_vars", @vars);
}