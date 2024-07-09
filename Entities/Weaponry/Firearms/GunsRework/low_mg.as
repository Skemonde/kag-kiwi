#include "FirearmVars"
#include "KIWI_Locales"

void onInit(CBlob@ this)
{
	this.setInventoryName("Low MG");
	this.Tag("medium weight");
	
	
	FirearmVars vars = FirearmVars();
	//GUN
	vars.T_TO_DIE 					= -1;
	vars.C_TAG						= "advanced_gun";
	vars.MUZZLE_OFFSET				= Vec2f(-29, -4);
	vars.SPRITE_TRANSLATION			= Vec2f(9, 3);
	//AMMO
	vars.CLIP						= 80; 
	vars.TOTAL						= 0; 
	vars.AMMO_TYPE.push_back("lowcal");
	//RELOAD
	vars.RELOAD_HANDFED_ROUNDS		= 0; 
	vars.EMPTY_RELOAD				= false;
	vars.RELOAD_TIME				= 210;
	vars.RELOAD_ANGLE				= -10;
	//FIRING
	vars.FIRE_INTERVAL				= 1; 
	vars.FIRE_AUTOMATIC				= true; 
	vars.ONOMATOPOEIA				= "ratta";
	vars.FLASH_SPRITE				= "from_bullet";
	vars.RECOIL						= -20;
	//EJECTION
	vars.SELF_EJECTING				= true; 
	vars.CART_SPRITE				= "RoundCase.png"; 
	vars.CLIP_SPRITE				= "";
	//MULTISHOT
	vars.BURST						= 0;
	vars.BURST_INTERVAL				= 2;
	vars.BUL_PER_SHOT				= 1; 
	vars.B_SPREAD					= 5; 
	vars.UNIFORM_SPREAD				= false;
	//TRAJECTORY
	vars.B_GRAV						= Vec2f(0, 0);
	vars.B_SPEED					= 25; 
	vars.B_SPEED_RANDOM				= 2;
	vars.RANGE						= getMap().tilesize*100;
	//DAMAGE
	vars.B_DAMAGE					= 8; 
	vars.B_HITTER					= HittersKIWI::tesr;
	vars.B_PENETRATION				= 0;
	//BULLET SOUNDS
	vars.S_FLESH_HIT				= "ArrowHitFlesh.ogg";
	vars.S_OBJECT_HIT				= "BulletImpact.ogg"; 
	//GUN SOUNDS
	vars.FIRE_SOUND					= "lmg_shot.ogg";
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