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
	vars.MUZZLE_OFFSET				= Vec2f(-25.5f, 1.5f);
	vars.SPRITE_TRANSLATION			= Vec2f(7, 1);
	vars.AIM_OFFSET					= Vec2f(0, 2);
	vars.BULLET						= "napalm";
	//AMMO
	vars.CLIP						= 80; 
	vars.TOTAL						= 0;
	vars.AMMO_TYPE.push_back("mat_arrows");
	//RELOAD
	vars.RELOAD_HANDFED_ROUNDS		= 0; 
	vars.EMPTY_RELOAD				= false;
	vars.RELOAD_TIME				= 60; 
	//FIRING
	vars.FIRE_INTERVAL				= 1; 
	vars.FIRE_AUTOMATIC				= true; 
	vars.ONOMATOPOEIA				= "";
	vars.FLASH_SPRITE				= "";
	//EJECTION
	vars.SELF_EJECTING				= true; 
	vars.CART_SPRITE				= ""; 
	vars.CLIP_SPRITE				= "";
	//MULTISHOT
	vars.BURST						= 5;
	vars.BURST_INTERVAL				= vars.FIRE_INTERVAL;
	vars.BUL_PER_SHOT				= 3; 
	vars.B_SPREAD					= 4; 
	vars.UNIFORM_SPREAD				= true;
	//TRAJECTORY
	vars.B_GRAV						= Vec2f(0,0);
	vars.B_SPEED					= 15; 
	vars.B_SPEED_RANDOM				= 2;  
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
	CSpriteLayer@ cap = this.addSpriteLayer("gun_cap", "Flamer.png", 8, 16);
	if (cap !is null) {
		cap.SetFrameIndex(3);
		cap.SetOffset(Vec2f(-2, 0));
	}
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	const bool FLIP = blob.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	CSpriteLayer@ tank = this.getSpriteLayer("tank");
	if (tank !is null) {
		tank.SetOffset(Vec2f(5, -12)+blob.get_Vec2f("gun_trans_from_carrier"));
		if (blob.isAttached())
			tank.SetVisible(false);
		else
			tank.SetVisible(false);
	}
	
	return;
	
	AttachmentPoint@ point = blob.getAttachments().getAttachmentPointByName("PICKUP");
	CBlob@ holder = point.getOccupied();
	//if (holder is null) return;
	
	CSpriteLayer@ cap = this.getSpriteLayer("cap");
	if (cap is null) return;
	
	f32 cap_angle = 0;
	if (holder !is null)
		cap_angle = getAimAngle(blob, holder)-90*FLIP_FACTOR;
	Vec2f bomba_offset = Vec2f(-11, 1)+blob.get_Vec2f("gun_trans_from_carrier");
	if (blob.hasTag("trench_aim"))
		bomba_offset-=Vec2f(trench_aim.x, -trench_aim.y);//it's rotated 90 degrees CCW
	
	Vec2f bomba_offset_rotoff = -Vec2f(bomba_offset.x*FLIP_FACTOR, bomba_offset.y);
	
	cap.ResetTransform();
	cap.SetOffset(bomba_offset);
	cap.RotateBy(cap_angle, bomba_offset_rotoff+blob.get_Vec2f("shoulder"));
	cap.SetVisible(this.isVisible()&&blob.get_u8("clip")>0);
	cap.SetRelativeZ(2);
	
	return;
	if (blob.get_u8("gun_state")==BURSTFIRING||blob.get_u8("actionInterval")<1) {
		bomba_offset+=Vec2f(0, 0);
		cap.SetOffset(bomba_offset);
		bomba_offset_rotoff = -Vec2f(bomba_offset.x*FLIP_FACTOR, bomba_offset.y);
		cap_angle+=90*FLIP_FACTOR;
	}
	cap.RotateBy(cap_angle, bomba_offset_rotoff+blob.get_Vec2f("shoulder"));
}