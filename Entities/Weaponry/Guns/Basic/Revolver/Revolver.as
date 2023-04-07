#include "FirearmVars"
#include "KIWI_Locales"

void onInit(CBlob@ this)
{
	this.setInventoryName(Names::revolver);
	
	
	FirearmVars vars = FirearmVars();
	//GUN
	vars.T_TO_DIE 					= -1;
	vars.C_TAG						= "basic_gun";
	vars.MUZZLE_OFFSET				= Vec2f(-22,0.5);
	vars.SPRITE_TRANSLATION			= Vec2f(3.5, -1.5);
	//AMMO
	vars.CLIP						= 6;
	vars.TOTAL						= 0;
	vars.AMMO_TYPE					= "lowcal";
	//RELOAD
	vars.RELOAD_HANDFED_ROUNDS		= 1;
	vars.EMPTY_RELOAD				= false;
	vars.RELOAD_TIME				= 7;
	//FIRING
	vars.FIRE_INTERVAL				= 2;
	vars.FIRE_AUTOMATIC				= false;
	vars.ONOMATOPOEIA				= "bang";
	//EJECTION
	vars.SELF_EJECTING				= false;
	vars.CART_SPRITE				= "RoundCase.png";
	vars.CLIP_SPRITE				= "";
	//MULTISHOT
	vars.BURST						= 1;
	vars.BURST_INTERVAL				= vars.FIRE_INTERVAL;
	vars.BUL_PER_SHOT				= 1;
	vars.B_SPREAD					= 5;
	vars.UNIFORM_SPREAD				= false;
	//TRAJECTORY
	vars.B_GRAV						= Vec2f(0,0);
	vars.B_SPEED					= 10;
	vars.B_SPEED_RANDOM				= 0; 
	vars.B_TTL_TICKS				= 24;
	vars.RICOCHET_CHANCE			= 10;
	//DAMAGE
	vars.B_DAMAGE					= 2;
	vars.B_HITTER					= HittersKIWI::bullet_pistol;
	vars.B_PENETRATION				= 0;
	vars.B_KB						= Vec2f(0,0);
	//COINS
	vars.B_F_COINS					= 0;
	vars.B_O_COINS					= 0;
	//BULLET SOUNDS
	vars.S_FLESH_HIT				= "ArrowHitFlesh.ogg";
	vars.S_OBJECT_HIT				= "BulletImpact.ogg"; 
	//GUN SOUNDS
	vars.FIRE_SOUND					= "revolver_shot.ogg";
	vars.FIRE_PITCH					= 1.0f;
	vars.CYCLE_SOUND				= "";
	vars.CYCLE_PITCH				= 1.0f;
	vars.LOAD_SOUND					= "revolver_load.ogg";
	vars.LOAD_PITCH					= 1.0f;
	vars.RELOAD_SOUND				= "revolver_roll.ogg";
	vars.RELOAD_PITCH				= 1.0f;
	//BULLET SPRITES
	vars.BULLET_SPRITE				= "smg_bullet.png";
	vars.FADE_SPRITE				= "";
	this.set("firearm_vars", @vars);
}

void onTick(CBlob@ this)
{
	if (!getNet().isClient())
		return;
	CSprite@ sprite = this.getSprite();
	if (this.hasTag("supply thing") && !this.hasTag("look updated")) {
		Vec2f sprite_dims = Vec2f(sprite.getFrameWidth(), sprite.getFrameHeight());
		sprite.ReloadSprite("rusty_"+this.getName(), sprite_dims.x, sprite_dims.y);
		this.SetInventoryIcon("rusty_"+this.getName(), 0, sprite_dims);
		this.setInventoryName(Names::starter_handgun);
		this.Tag("look updated");
	}
}