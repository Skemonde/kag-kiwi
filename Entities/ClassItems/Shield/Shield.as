#include "Hitters"
#include "HittersKIWI"
#include "FirearmVars"

void onInit(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	sprite.SetRelativeZ(10.0f);

	this.Tag("shield");
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	
	AttachmentPoint@ point = blob.getAttachments().getAttachmentPointByName("PICKUP");
	if(point is null) return;
	CBlob@ holder = point.getOccupied();
	if(holder is null) return;
	
	const bool FLIP = holder.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1: 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	f32 shield_dist = 6;
	this.ResetTransform();
	this.SetOffset(Vec2f(-shield_dist, 2)+blob.get_Vec2f("gun_trans_from_carrier")+(holder.isKeyPressed(key_down)?Vec2f(1,-2):Vec2f()));
	this.ScaleBy(1.0f, 1.0f);
	this.RotateBy(getShieldAngle(holder), Vec2f(shield_dist*FLIP_FACTOR, 0));
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	CSprite@ sprite = this.getSprite();
	sprite.ResetTransform();
	sprite.SetOffset(Vec2f());
	sprite.RotateBy(-90, Vec2f());
}

void onTick(CBlob@ this)
{
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	if(point is null) return;
	CBlob@ holder = point.getOccupied();
	if(holder is null) return;
	
	this.set_f32("shield_angle", getShieldAngle(holder));
	this.setAngleDegrees(0);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return true;
}

f32 getShieldAngle(CBlob@ this)
{
	const bool flip = this.isFacingLeft();
	const f32 flip_factor = flip ? -1: 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	
	Vec2f pos = this.getPosition();
 	Vec2f aimvector = this.getAimPos() - pos;
	f32 angle = aimvector.Angle() + this.getAngleDegrees();
	//return angle_flip_factor-angle;
    return constrainAngle(angle_flip_factor-(angle+flip_factor));
}