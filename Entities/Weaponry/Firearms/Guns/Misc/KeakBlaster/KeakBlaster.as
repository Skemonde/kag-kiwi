#include "FirearmVars"
#include "KIWI_Locales"

void onInit(CBlob@ this)
{
	this.setInventoryName("Keak's Blaster");
	this.Tag("has_zoom");
	this.Tag("cant have gun attachments");
	this.Tag("handgun");
	
	
	FirearmVars vars = FirearmVars();
	//GUN
	vars.T_TO_DIE 					= -1; 
	vars.C_TAG						= "advanced_gun";
	vars.MUZZLE_OFFSET				= Vec2f(-23.5,-1.5);
	vars.SPRITE_TRANSLATION			= Vec2f(6, 0);
	vars.AIM_OFFSET					= Vec2f(0, -0.5);
	//AMMO
	vars.CLIP						= 20; 
	vars.TOTAL						= 0; 
	vars.AMMO_TYPE.push_back("highpow");
	//RELOAD
	vars.RELOAD_HANDFED_ROUNDS		= 0; 
	vars.EMPTY_RELOAD				= true;
	vars.RELOAD_TIME				= 10;
	vars.RELOAD_ANGLE				= -40;
	//FIRING
	vars.FIRE_INTERVAL				= 12; 
	vars.FIRE_AUTOMATIC				= true; 
	vars.ONOMATOPOEIA				= "bang";
	vars.FLASH_SPRITE				= "from_bullet";
	vars.COOLING_INTERVAL			= 20;
	//EJECTION
	vars.SELF_EJECTING				= true; 
	vars.CART_SPRITE				= "BigRoundCase.png";
	vars.CLIP_SPRITE				= "uzi_mag.png"; 
	//MULTISHOT
	vars.BURST						= 1; 
	vars.BURST_INTERVAL				= vars.FIRE_INTERVAL; 
	vars.BUL_PER_SHOT				= 1; 
	vars.B_SPREAD					= 30; 
	vars.UNIFORM_SPREAD				= false;
	//TRAJECTORY
	vars.B_GRAV						= Vec2f(0,0);
	vars.B_SPEED					= 35; 
	vars.B_SPEED_RANDOM				= 2;
	vars.RANGE						= getMap().tilesize*118;
	//DAMAGE
	vars.B_DAMAGE					= 36; 
	vars.B_HITTER					= HittersKIWI::miz;
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
	vars.LOAD_PITCH					= 0.8f;
	vars.RELOAD_SOUND				= "1911_reload.ogg";
	vars.RELOAD_PITCH				= 0.85f;
	//BULLET SPRITES
	vars.BULLET_SPRITE				= "smg_bullet";
	vars.FADE_SPRITE				= "";
	this.set("firearm_vars", @vars);
}