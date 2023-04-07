#include "FirearmVars"
#include "KIWI_Locales"

void onInit(CBlob@ this)
{
	this.setInventoryName(Names::fa_shotgun);
	this.Tag("NoAccuracyBonus");
	
	
	FirearmVars vars = FirearmVars();
	//GUN
	vars.T_TO_DIE 					= -1;
	vars.C_TAG						= "advanced_gun";
	vars.MUZZLE_OFFSET				= Vec2f(-27,-1.5);
	vars.SPRITE_TRANSLATION			= Vec2f(6.5, -1);
	//AMMO
	vars.CLIP						= 8;
	vars.TOTAL						= 0;
	vars.AMMO_TYPE					= "shells";
	//RELOAD
	vars.RELOAD_HANDFED_ROUNDS		= 1;
	vars.EMPTY_RELOAD				= false;
	vars.RELOAD_TIME				= 10;
	//FIRING
	vars.FIRE_INTERVAL				= 10;
	vars.FIRE_AUTOMATIC				= true;
	vars.ONOMATOPOEIA				= "pow";
	//EJECTION
	vars.SELF_EJECTING				= true;
	vars.CART_SPRITE				= "ShellCase.png";
	vars.CLIP_SPRITE				= "";
	//MULTISHOT
	vars.BURST						= 1;
	vars.BURST_INTERVAL				= 1;
	vars.BUL_PER_SHOT				= 5;
	vars.B_SPREAD					= 7;
	vars.UNIFORM_SPREAD				= true;
	//TRAJECTORY
	vars.B_GRAV						= Vec2f(0,0);
	vars.B_SPEED					= 11;
	vars.B_SPEED_RANDOM				= 4;
	vars.B_TTL_TICKS				= 15;
	vars.RICOCHET_CHANCE			= 100;
	//DAMAGE
	vars.B_DAMAGE					= 1;
	vars.B_HITTER					= HittersKIWI::pellet;
	vars.B_PENETRATION				= 0;
	vars.B_KB						= Vec2f(0, 0);
	//COINS
	vars.B_F_COINS					= 0;
	vars.B_O_COINS					= 0;
	//BULLET SOUNDS
	vars.S_FLESH_HIT				= "ArrowHitFlesh.ogg";
	vars.S_OBJECT_HIT				= "BulletImpact.ogg"; 
	//GUN SOUNDS
	vars.FIRE_SOUND					= "autoshotgun_shot.ogg";
	vars.FIRE_PITCH					= 1.0f;
	vars.CYCLE_SOUND				= "";
	vars.CYCLE_PITCH				= 1.0f;
	vars.LOAD_SOUND					= "shotgun_load.ogg";
	vars.LOAD_PITCH					= 1.0f;
	vars.RELOAD_SOUND				= "shotgun_cycle.ogg";
	vars.RELOAD_PITCH				= 1.0f;
	//BULLET SPRITES
	vars.BULLET_SPRITE				= "shotgun_pellet.png";
	vars.FADE_SPRITE				= "";
	this.set("firearm_vars", @vars);
}