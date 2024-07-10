#include "FirearmVars"
#include "KIWI_Locales"

void onInit(CBlob@ this)
{
	this.setInventoryName("Toy Sniper");
	this.Tag("has_zoom");
	//this.Tag("heavy weight");
	this.Tag("cant have gun attachments");
	this.Tag("looped_sound");
	this.set_string("pickup sound", "bigger_weapons");
	//this.Tag("shot_force");
	
	
	FirearmVars vars = FirearmVars();
	//GUN
	vars.C_TAG						= "advanced_gun";
	vars.MUZZLE_OFFSET				= Vec2f(-41.5, -0.5);
	vars.SPRITE_TRANSLATION			= Vec2f(18, -1);
	vars.AIM_OFFSET					= Vec2f(0, 0);
	//AMMO
	vars.CLIP						= 80; 
	vars.TOTAL						= 0; 
	vars.AMMO_TYPE.push_back("lowcal");
	//RELOAD
	vars.RELOAD_HANDFED_ROUNDS		= 0; 
	vars.EMPTY_RELOAD				= false;
	vars.RELOAD_TIME				= 1*getTicksASecond();
	vars.RELOAD_ANGLE				= -10;
	//FIRING
	vars.FIRE_INTERVAL				= 1; 
	vars.FIRE_AUTOMATIC				= true; 
	vars.ONOMATOPOEIA				= "";
	vars.FLASH_SPRITE				= "from_bullet";
	//EJECTION
	vars.SELF_EJECTING				= true; 
	vars.CART_SPRITE				= ""; 
	vars.CLIP_SPRITE				= "";
	//MULTISHOT
	vars.BURST						= 0;
	vars.BURST_INTERVAL				= 2;
	vars.BUL_PER_SHOT				= 2; 
	vars.B_SPREAD					= 10; 
	vars.UNIFORM_SPREAD				= false;
	//TRAJECTORY
	vars.B_GRAV						= Vec2f(0, 0.0007);
	vars.B_SPEED					= 20; 
	vars.B_SPEED_RANDOM				= 2;
	vars.RANGE						= 200*getMap().tilesize;
	//DAMAGE
	vars.B_DAMAGE					= 3; 
	vars.B_HITTER					= HittersKIWI::revolver;
	vars.B_PENETRATION				= 0;
	//BULLET SOUNDS
	vars.S_FLESH_HIT				= "ArrowHitFlesh.ogg";
	vars.S_OBJECT_HIT				= "BulletImpact.ogg"; 
	//GUN SOUNDS
	vars.FIRE_SOUND					= "DRRR.ogg";
	vars.FIRE_PITCH					= 1.0f;
	vars.CYCLE_SOUND				= "";
	vars.CYCLE_PITCH				= 0.5f;
	vars.LOAD_SOUND					= "i_need_more_boolets.ogg";
	vars.LOAD_PITCH					= 1.0f;
	vars.RELOAD_SOUND				= "now_that_is_a_weapon.ogg";
	vars.RELOAD_PITCH				= 1.0f;
	vars.FIRE_END_SOUND				= "now_that_is_a_weapon.ogg";
	//BULLET SPRITES
	vars.BULLET_SPRITE				= "smg_bullet";
	vars.FADE_SPRITE				= "";
	this.set("firearm_vars", @vars);
}