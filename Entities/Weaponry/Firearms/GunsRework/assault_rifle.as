#include "FirearmVars"
#include "KIWI_Locales"

void onInit(CBlob@ this)
{
	this.setInventoryName(Names::assault_rifle);
	//this.Tag("has_zoom");
	
	
	FirearmVars vars = FirearmVars();
	//GUN
	vars.T_TO_DIE 					= -1;
	vars.C_TAG						= "advanced_gun";
	vars.MUZZLE_OFFSET				= Vec2f(-28, -2);
	vars.SPRITE_TRANSLATION			= Vec2f(8, 2);
	//AMMO
	vars.CLIP						= 30; 
	vars.TOTAL						= 0; 
	vars.AMMO_TYPE.push_back("highpow");
	vars.AMMO_TYPE.push_back("froggy");
	//RELOAD
	vars.RELOAD_HANDFED_ROUNDS		= 0; 
	vars.EMPTY_RELOAD				= false;
	vars.RELOAD_TIME				= 60;
	vars.RELOAD_ANGLE				= -10;
	//FIRING
	vars.FIRE_INTERVAL				= 12; 
	vars.FIRE_AUTOMATIC				= true; 
	vars.ONOMATOPOEIA				= "ratta";
	vars.FLASH_SPRITE				= "from_bullet";
	vars.RECOIL						= -30;
	//EJECTION
	vars.SELF_EJECTING				= true; 
	vars.CART_SPRITE				= "BigRoundCase.png"; 
	vars.CLIP_SPRITE				= "m16_mag.png";
	//MULTISHOT
	vars.BURST						= 3;
	vars.BURST_INTERVAL				= 2;
	vars.BUL_PER_SHOT				= 1; 
	vars.B_SPREAD					= 5; 
	vars.UNIFORM_SPREAD				= false;
	//TRAJECTORY
	vars.B_GRAV						= Vec2f(0, 0);
	vars.B_SPEED					= 35; 
	vars.B_SPEED_RANDOM				= 2;
	vars.RANGE						= getMap().tilesize*100;
	//DAMAGE
	vars.B_DAMAGE					= 11; 
	vars.B_HITTER					= HittersKIWI::assault_rifle;
	vars.B_PENETRATION				= 0;
	//BULLET SOUNDS
	vars.S_FLESH_HIT				= "ArrowHitFlesh.ogg";
	vars.S_OBJECT_HIT				= "BulletImpact.ogg"; 
	//GUN SOUNDS
	vars.FIRE_SOUND					= "rifle_powerfull_shot.ogg";
	vars.FIRE_PITCH					= 1.0f;
	vars.CYCLE_SOUND				= "";
	vars.CYCLE_PITCH				= 1.0f;
	vars.LOAD_SOUND					= "smg_load.ogg";
	vars.LOAD_PITCH					= 0.7f;
	vars.RELOAD_SOUND				= "metal_slug_rechamber.ogg";
	vars.RELOAD_PITCH				= 0.8f;
	//BULLET SPRITES
	vars.BULLET_SPRITE				= "smg_bullet";
	vars.FADE_SPRITE				= "";
	this.set("firearm_vars", @vars);
}