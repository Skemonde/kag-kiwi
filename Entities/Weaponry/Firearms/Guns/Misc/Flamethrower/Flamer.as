#include "FirearmVars"
#include "KIWI_Locales"

void onInit(CBlob@ this)
{
	this.setInventoryName("Flamer");
	this.Tag("looped_sound");
	this.Tag("NoAccuracyBonus");
	this.Tag("not_a_shotgun");
	
	
	FirearmVars vars = FirearmVars();
	//GUN
	vars.T_TO_DIE 					= -1;
	vars.C_TAG						= "advanced_gun";
	vars.MUZZLE_OFFSET				= Vec2f(-13,-3);
	vars.SPRITE_TRANSLATION			= Vec2f(7, -0.5);
	vars.BULLET						= "napalm";
	//AMMO
	vars.CLIP						= 40; 
	vars.TOTAL						= 0;
	vars.AMMO_TYPE.push_back("mat_arrows");
	//RELOAD
	vars.RELOAD_HANDFED_ROUNDS		= 0; 
	vars.EMPTY_RELOAD				= false;
	vars.RELOAD_TIME				= 60; 
	//FIRING
	vars.FIRE_INTERVAL				= 0; 
	vars.FIRE_AUTOMATIC				= true; 
	vars.ONOMATOPOEIA				= "";
	vars.FLASH_SPRITE				= "";
	//EJECTION
	vars.SELF_EJECTING				= true; 
	vars.CART_SPRITE				= ""; 
	vars.CLIP_SPRITE				= "";
	//MULTISHOT
	vars.BURST						= 1;
	vars.BURST_INTERVAL				= vars.FIRE_INTERVAL;
	vars.BUL_PER_SHOT				= 1; 
	vars.B_SPREAD					= 30; 
	vars.UNIFORM_SPREAD				= true;
	//TRAJECTORY
	vars.B_GRAV						= Vec2f(0,0);
	vars.B_SPEED					= 5; 
	vars.B_SPEED_RANDOM				= 2; 
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
	vars.FIRE_SOUND					= "flamethrower_fire.ogg";
	vars.FIRE_PITCH					= 1.0f;
	vars.CYCLE_SOUND				= "";
	vars.CYCLE_PITCH				= 1.0f;
	vars.LOAD_SOUND					= "smg_load.ogg";
	vars.LOAD_PITCH					= 1.0f;
	vars.RELOAD_SOUND				= "metal_slug_fullok.ogg";
	vars.RELOAD_PITCH				= 1.0f;
	vars.FIRE_START_SOUND			= "flamethrower_flash.ogg";
	//BULLET SPRITES
	vars.BULLET_SPRITE				= "";
	vars.FADE_SPRITE				= "";
	this.set("firearm_vars", @vars);
}

void onInit(CSprite@ this)
{
	CSpriteLayer@ tank = this.addSpriteLayer("tank", "SteamEngine.png", 32, 32);
	if (tank !is null)
	{
		tank.SetRelativeZ(-30.0f);
		tank.SetOffset(Vec2f(10, 0));
		tank.SetVisible(false);
	}
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	CSpriteLayer@ tank = this.getSpriteLayer("tank");
	if (tank !is null) {
		tank.SetOffset(Vec2f(5, -12)+blob.get_Vec2f("gun_trans_from_carrier"));
		if (blob.isAttached())
			tank.SetVisible(true);
		else
			tank.SetVisible(false);
	}
}