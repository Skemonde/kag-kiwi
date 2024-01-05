#include "FirearmVars"
#include "KIWI_Locales"

void onInit(CBlob@ this)
{
	this.setInventoryName("Tera Gun");
	this.Tag("has_zoom");
	this.Tag("heavy weight");
	//this.Tag("cant have gun attachments");
	this.Tag("shot_force");
	
	
	FirearmVars vars = FirearmVars();
	//GUN
	vars.T_TO_DIE 					= -1; 
	vars.C_TAG						= "fuck is that?"; 
	vars.MUZZLE_OFFSET				= Vec2f(-28, 2);
	vars.SPRITE_TRANSLATION			= Vec2f(8.5, 2.5);
	vars.AIM_OFFSET					= Vec2f(0, 3);
	//AMMO
	vars.CLIP						= 120; 
	vars.TOTAL						= 0; 
	vars.AMMO_TYPE.push_back("highpow");
	//RELOAD
	vars.RELOAD_HANDFED_ROUNDS		= 0; 
	vars.EMPTY_RELOAD				= false;
	vars.RELOAD_TIME				= 90; 
	vars.RELOAD_ANGLE				= -40; 
	//FIRING
	vars.FIRE_INTERVAL				= 10; 
	vars.FIRE_AUTOMATIC				= true; 
	vars.ONOMATOPOEIA				= "ratta";
	vars.FLASH_SPRITE				= "from_bullet";
	//EJECTION
	vars.SELF_EJECTING				= true; 
	vars.CART_SPRITE				= "BigRoundCase.png"; 
	vars.CLIP_SPRITE				= "";
	//MULTISHOT
	vars.BURST						= 1;
	vars.BURST_INTERVAL				= vars.FIRE_INTERVAL;
	vars.BUL_PER_SHOT				= 2; 
	vars.B_SPREAD					= 8; 
	vars.UNIFORM_SPREAD				= false;
	//TRAJECTORY
	vars.B_GRAV						= Vec2f(0,0);
	vars.B_SPEED					= 7; 
	vars.B_SPEED_RANDOM				= 10;
	vars.RICOCHET_CHANCE			= 40;
	vars.RANGE						= getMap().tilesize*148;
	//DAMAGE
	vars.B_DAMAGE					= 37/2; 
	vars.B_HITTER					= HittersKIWI::hmg;
	vars.B_PENETRATION				= 0; 
	vars.B_KB						= Vec2f(0,0); 
	//COINS
	vars.B_F_COINS					= 0;
	vars.B_O_COINS					= 0;
	//BULLET SOUNDS
	vars.S_FLESH_HIT				= "ArrowHitFlesh.ogg";
	vars.S_OBJECT_HIT				= "BulletImpact.ogg"; 
	//GUN SOUNDS
	vars.FIRE_SOUND					= "mini_gun_fire.ogg";
	vars.FIRE_PITCH					= 1.0f;
	vars.CYCLE_SOUND				= "";
	vars.CYCLE_PITCH				= 1.0f;
	vars.LOAD_SOUND					= "smg_load.ogg";
	vars.LOAD_PITCH					= 0.5f;
	vars.RELOAD_SOUND				= "rechamber.ogg";
	vars.RELOAD_PITCH				= 0.7f;
	//BULLET SPRITES
	vars.BULLET_SPRITE				= "smg_bullet";
	vars.FADE_SPRITE				= "";
	this.set("firearm_vars", @vars);
}