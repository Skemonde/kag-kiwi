#include "FirearmVars"
#include "KIWI_Locales"

void onInit(CBlob@ this)
{
	this.setInventoryName("T70 Cannon");
	this.Tag("no_sprite_recoil");
	this.Tag("blobconsuming");
	
	
	FirearmVars vars = FirearmVars();
	//GUN
	vars.T_TO_DIE 					= -1; 
	vars.C_TAG						= "basic_gun"; 
	vars.MUZZLE_OFFSET				= Vec2f(-26, 0.5);
	vars.SPRITE_TRANSLATION			= Vec2f(14, 5);
	vars.AIM_OFFSET					= Vec2f(0, 1.5);
	//AMMO
	vars.CLIP						= 15; 
	vars.TOTAL						= 0; 
	vars.AMMO_TYPE.push_back("draground");
	//RELOAD
	vars.RELOAD_HANDFED_ROUNDS		= 0; 
	vars.EMPTY_RELOAD				= false;
	vars.RELOAD_TIME				= 120; 
	//FIRING
	vars.FIRE_INTERVAL				= 45; 
	vars.FIRE_AUTOMATIC				= true; 
	vars.ONOMATOPOEIA				= "foom";
	vars.FLASH_SPRITE				= "from_bullet";
	//EJECTION
	vars.SELF_EJECTING				= true; 
	vars.CART_SPRITE				= "DragunovCase.png"; 
	vars.CLIP_SPRITE				= "";
	//MULTISHOT
	vars.BURST						= 1;
	vars.BURST_INTERVAL				= vars.FIRE_INTERVAL;
	vars.BUL_PER_SHOT				= 1; 
	vars.B_SPREAD					= 0; 
	vars.UNIFORM_SPREAD				= false;
	//TRAJECTORY
	vars.B_GRAV						= Vec2f(0, 0.02);
	vars.B_SPEED					= 40; 
	vars.B_SPEED_RANDOM				= 0;
	vars.RANGE						= 200*getMap().tilesize;
	//DAMAGE
	vars.B_DAMAGE					= 512; 
	vars.B_HITTER					= HittersKIWI::apc_cannon;
	vars.B_PENETRATION				= 0; 
	vars.B_KB						= Vec2f(0,0); 
	//COINS
	vars.B_F_COINS					= 0;
	vars.B_O_COINS					= 0;
	//BULLET SOUNDS
	vars.S_FLESH_HIT				= "ArrowHitFlesh.ogg";
	vars.S_OBJECT_HIT				= "BulletImpact.ogg"; 
	//GUN SOUNDS
	vars.FIRE_SOUND					= "AMR_Shoot.ogg";
	vars.FIRE_PITCH					= 1.6f;
	vars.CYCLE_SOUND				= "tank_unload.ogg";
	vars.CYCLE_PITCH				= 1.6f;
	vars.LOAD_SOUND					= "smg_load.ogg";
	vars.LOAD_PITCH					= 0.4f;
	vars.RELOAD_SOUND				= "rifle_cycle.ogg";
	vars.RELOAD_PITCH				= 0.4f;
	//BULLET SPRITES
	vars.BULLET_SPRITE				= "smg_bullet";
	vars.FADE_SPRITE				= "";
	this.set("firearm_vars", @vars);
	
	this.set_u8("clip", -1);
	this.set_Vec2f("gun_trans", vars.SPRITE_TRANSLATION);
}