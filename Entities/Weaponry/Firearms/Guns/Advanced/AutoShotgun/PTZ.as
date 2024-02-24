#include "FirearmVars"
#include "KIWI_Locales"

void onInit(CBlob@ this)
{
	this.setInventoryName(Names::fa_shotgun);
	this.Tag("shot_force");
	
	
	FirearmVars vars = FirearmVars();
	//GUN
	vars.T_TO_DIE 					= -1;
	vars.C_TAG						= "advanced_gun";
	vars.MUZZLE_OFFSET				= Vec2f(-27,-1.5);
	vars.SPRITE_TRANSLATION			= Vec2f(6.5, -1);
	vars.AIM_OFFSET					= Vec2f(0, -1.0);
	//AMMO
	vars.CLIP						= 8;
	vars.TOTAL						= 0;
	vars.AMMO_TYPE.push_back("shells");
	//RELOAD
	vars.RELOAD_HANDFED_ROUNDS		= 0;
	vars.EMPTY_RELOAD				= false;
	vars.RELOAD_TIME				= 140;
	//FIRING
	vars.FIRE_INTERVAL				= 7;
	vars.FIRE_AUTOMATIC				= true;
	vars.ONOMATOPOEIA				= "pow";
	vars.FLASH_SPRITE				= "from_bullet";
	//EJECTION
	vars.SELF_EJECTING				= true;
	vars.CART_SPRITE				= "ShellCase";
	vars.CLIP_SPRITE				= "";
	//MULTISHOT
	vars.BURST						= 1;
	vars.BURST_INTERVAL				= 1;
	vars.BUL_PER_SHOT				= 4;
	vars.B_SPREAD					= 7;
	vars.UNIFORM_SPREAD				= true;
	//TRAJECTORY
	vars.B_GRAV						= Vec2f(0,0);
	vars.B_SPEED					= 10;
	vars.B_SPEED_RANDOM				= 7;
	vars.B_TTL_TICKS				= 15;
	vars.RICOCHET_CHANCE			= 100;
	vars.RANGE						= getMap().tilesize*25;
	//DAMAGE
	vars.B_DAMAGE					= 14;
	vars.B_HITTER					= HittersKIWI::ptz;
	vars.B_PENETRATION				= 1;
	vars.B_KB						= Vec2f(0, 0);
	//COINS
	vars.B_F_COINS					= 0;
	vars.B_O_COINS					= 0;
	//BULLET SOUNDS
	vars.S_FLESH_HIT				= "ArrowHitFlesh.ogg";
	vars.S_OBJECT_HIT				= "BulletImpact.ogg"; 
	//GUN SOUNDS
	vars.FIRE_SOUND					= "shotgun_fire.ogg";
	vars.FIRE_PITCH					= 1.0f;
	vars.CYCLE_SOUND				= "";
	vars.CYCLE_PITCH				= 1.0f;
	vars.LOAD_SOUND					= "sniper_load.ogg";
	vars.LOAD_PITCH					= 0.7f;
	vars.RELOAD_SOUND				= "shotgun_cycle.ogg";
	vars.RELOAD_PITCH				= 1.0f;
	//BULLET SPRITES
	vars.BULLET_SPRITE				= "smg_bullet";
	vars.FADE_SPRITE				= "";
	this.set("firearm_vars", @vars);
}