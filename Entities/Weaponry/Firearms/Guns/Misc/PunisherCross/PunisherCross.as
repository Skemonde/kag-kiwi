#include "FirearmVars"
#include "KIWI_Locales"

void onInit(CBlob@ this)
{
	this.setInventoryName("Punisher's Cross");
	this.Tag("looped_sound");
	
	
	FirearmVars vars = FirearmVars();
	//GUN
	vars.C_TAG						= "advanced_gun";
	vars.MUZZLE_OFFSET				= Vec2f(-33,1);
	vars.SPRITE_TRANSLATION			= Vec2f(6.5, -0.5);
	//AMMO
	vars.CLIP						= 160; 
	vars.TOTAL						= 0; 
	vars.AMMO_TYPE.push_back("highpow");
	//RELOAD
	vars.RELOAD_HANDFED_ROUNDS		= 0; 
	vars.EMPTY_RELOAD				= false;
	vars.RELOAD_TIME				= 60; 
	//FIRING
	vars.FIRE_INTERVAL				= 3; 
	vars.FIRE_AUTOMATIC				= true; 
	vars.ONOMATOPOEIA				= "ratta";
	//EJECTION
	vars.SELF_EJECTING				= true; 
	vars.CART_SPRITE				= "RoundCase.png"; 
	vars.CLIP_SPRITE				= "";
	//MULTISHOT
	vars.BURST						= 1;
	vars.BURST_INTERVAL				= vars.FIRE_INTERVAL;
	vars.BUL_PER_SHOT				= 2; 
	vars.B_SPREAD					= 4; 
	vars.UNIFORM_SPREAD				= true;
	//TRAJECTORY
	vars.B_GRAV						= Vec2f(0,0);
	vars.B_SPEED					= 40; 
	vars.B_SPEED_RANDOM				= 2;
	vars.RICOCHET_CHANCE			= 10;
	vars.RANGE						= 1600;
	//DAMAGE
	vars.B_DAMAGE					= 3; 
	vars.B_HITTER					= HittersKIWI::bullet_hmg;
	vars.B_PENETRATION				= 0;
	//BULLET SOUNDS
	vars.S_FLESH_HIT				= "ArrowHitFlesh.ogg";
	vars.S_OBJECT_HIT				= "BulletImpact.ogg"; 
	//GUN SOUNDS
	vars.FIRE_SOUND					= "Minigun_Shoot.ogg";
	vars.FIRE_PITCH					= 1.0f;
	vars.CYCLE_SOUND				= "";
	vars.CYCLE_PITCH				= 1.0f;
	vars.LOAD_SOUND					= "smg_load.ogg";
	vars.LOAD_PITCH					= 0.6f;
	vars.RELOAD_SOUND				= "metal_slug_fullok.ogg";
	vars.RELOAD_PITCH				= 1.0f;
	//BULLET SPRITES
	vars.BULLET_SPRITE				= "smg_bullet";
	vars.FADE_SPRITE				= "";
	this.set("firearm_vars", @vars);
}

void manageCrossLayer(CSprite@ this)
{
	CSpriteLayer@ cross = this.getSpriteLayer("cross");
	if (cross is null) {
		@cross = this.addSpriteLayer("cross", "PunisherCrossPacked.png", 35, 25);
		//cross.SetRelativeZ(-30.0f);
		//cross.SetOffset(Vec2f(10, 0));
		//cross.SetVisible(true);
	}
	else
	{
	}
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	const bool FLIP = blob.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	AttachmentPoint@ point = blob.getAttachments().getAttachmentPointByName("PICKUP");
    CBlob@ holder = point.getOccupied();
	const bool flip = blob.isFacingLeft();
	const f32 flip_factor = flip ? -1 : 1;
	if (holder !is null) {
		manageCrossLayer(holder.getSprite());
		CSpriteLayer@ cross = holder.getSprite().getSpriteLayer("cross");
		if (cross !is null && cross.isVisible()) {
			f32 speed = 4;
			f32 jumping_value = (getGameTime()%speed)/(speed/2)-0.5;
			cross.ResetTransform();
			cross.SetOffset(Vec2f(5, -12)+blob.get_Vec2f("gun_trans_from_carrier")+(holder.getVelocity().Length()>0.2?Vec2f(0,jumping_value):Vec2f_zero));
			//cross.SetVisible(true);
			cross.RotateBy((70+(holder.getVelocity().Length()>0.2?jumping_value*2:0))*flip_factor, Vec2f_zero);
		}
	}
}

void onThisAddToInventory( CBlob@ this, CBlob@ inventoryBlob )
{
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
    CBlob@ holder = point.getOccupied();
	if (holder is null) return;
	inventoryBlob.getSprite().RemoveSpriteLayer("cross");
}

void onThisRemoveFromInventory( CBlob@ this, CBlob@ inventoryBlob )
{
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
    CBlob@ holder = point.getOccupied();
	if (holder is null) return;
}