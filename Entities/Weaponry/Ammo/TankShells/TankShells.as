#include "FirearmVars"
#include "ExplosionAtPos"

void onInit(CBlob@ this)
{  
	this.Tag("no auto pickup");
	this.Tag("heavy weight");
	this.Tag("explosive");
	this.Tag("sprite doesnt change facing");
	
	this.maxQuantity = 1;
	this.server_setTeamNum(-1);
	this.setAngleDegrees(XORRandom(360));


	FirearmVars vars = FirearmVars();
	vars.BUL_PER_SHOT = 40;
	vars.B_SPREAD = 720;
	vars.B_HITTER = HittersKIWI::shag;
	vars.FIRE_AUTOMATIC = false;
	vars.UNIFORM_SPREAD = false;
	vars.MUZZLE_OFFSET = Vec2f_zero;
	vars.B_SPEED = 4;
	vars.B_SPEED_RANDOM	= 24; 
	vars.B_DAMAGE = 63;
	vars.RANGE = 120*getMap().tilesize; 
	vars.FIRE_SOUND	= "";
	vars.ONOMATOPOEIA = "";
	vars.BULLET = "bullet";
	vars.BULLET_SPRITE = "x";
	this.set("firearm_vars", @vars);
	
	//this.getCurrentScript().runFlags |= Script::remove_after_this;
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return !isVanished(this);
}

bool canBePutInInventory( CBlob@ this, CBlob@ inventoryBlob )
{
	return !isVanished(this);
}

void onTick(CSprite@ this)
{
	this.SetVisible(!isVanished(this.getBlob()));
}

bool isVanished(CBlob@ this)
{
	return this.getHealth()!=this.getInitialHealth();
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return (!(blob.hasTag("flesh") || blob.hasTag("vehicle")))&&!isVanished(this);
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2 )
{
	if (isVanished(this)) return;
	const f32 vellen = this.getOldVelocity().Length();
	if (solid) {			
		if (vellen > 1.7f)
		{
			Sound::Play("GrenadeDrop1", this.getPosition(), 1, 0.5f + XORRandom(2)*0.1);
		}
		if (vellen > 7.3f)
		{
			print("vellen "+vellen);
			this.server_Hit(this, this.getPosition(), Vec2f(), 0.1f, 0);
		}
	}
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	this.setInventoryName("");
	this.server_SetTimeToDie(2);
	this.Untag("explosive");
	this.Tag("invincible");
	Sound::Play("cluster_bullet_blast", this.getPosition(), 2.0, 0.35f + XORRandom(3)*0.1);
	DestroyTilesInRadius(this.getPosition(), 2);
	
	if (isServer())
		shootGun(this.getNetworkID(), (worldPoint-this.getPosition()).getAngleDegrees(), this.getNetworkID(), this.getPosition());
			
	return damage;
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	const bool FLIP = this.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	this.setAngleDegrees(-90*FLIP_FACTOR);
}

void shootGun(const u16 gunID, const f32 aimangle, const u16 hoomanID, const Vec2f pos, const bool altfire = false) 
{
	CRules@ rules = getRules();
	CBitStream params;

	params.write_netid(hoomanID);
	params.write_netid(gunID);
	params.write_f32(aimangle);
	params.write_Vec2f(pos);
	params.write_bool(altfire);
	rules.SendCommand(rules.getCommandID("fireGun"), params);
}