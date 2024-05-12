#include "CommonHitFXs"

void onInit(CBlob@ this)
{
	this.Tag("non_pierceable");
	this.getShape().getConsts().collideWhenAttached = true;
	
	CSprite@ sprite = this.getSprite();
	
	CSpriteLayer@ shield = sprite.addSpriteLayer("shield", "DemonShield.png", 16, 64, this.getTeamNum(), 0);
	if (shield !is null)
	{
		Animation@ anim = shield.addAnimation("default", 3, false);
		
		anim.AddFrame(0);
		anim.AddFrame(1);
		anim.AddFrame(2);
		anim.AddFrame(3);
		anim.AddFrame(4);
		anim.AddFrame(5);
		anim.AddFrame(6);
		anim.AddFrame(7);
		
		shield.SetRelativeZ(-1.0f);
		shield.SetVisible(true);
		shield.setRenderStyle(RenderStyle::outline_front);
		shield.SetIgnoreParentFacing(true);
	}
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	CSpriteLayer@ shield = this.getSpriteLayer("shield");
	if (shield is null) return;
	
	shield.SetVisible(true);
	shield.setRenderStyle(RenderStyle::outline_front);
	
	//shield.SetFrameIndex(0);
	shield.SetAnimation("default");
	
	shield.ResetTransform();
	shield.SetRelativeZ(700);
	shield.TranslateBy(Vec2f(10, 0));
	shield.ScaleBy(1, 0.5);
	shield.RotateBy(-(blob.get_Vec2f("last_hit_offset")).AngleDegrees(), Vec2f());
	
	u32 time_from_last_hit = getGameTime()-blob.get_u32("last_hit_time");
	if (time_from_last_hit < 2)
		shield.SetFrameIndex(0);
		
	AttachmentPoint@ point = blob.getAttachments().getAttachmentPointByName("SHIELD");
    CBlob@ owner = point.getOccupied();
	
	if (owner is null) return;
	if (owner.hasTag("invincible"))
	{
		if (owner.isKeyPressed(key_action1))
			blob.Tag("bullet_hits");
		else
			blob.Untag("bullet_hits");
	} else {
		blob.Tag("bullet_hits");
	}
}

void onTick(CBlob@ this)
{
	if (this.getTickSinceCreated()<30) return;
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("SHIELD");
    CBlob@ owner = point.getOccupied();
	if (owner is null)
		this.server_Die();
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return false;
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("SHIELD");
    CBlob@ owner = point.getOccupied();
	
	if (owner is null) return false;
	if (owner.hasTag("invincible")) {
		if (owner.isKeyPressed(key_action1)){
			//we hit
		} else {
			return false;
		}
	}
	
	return (blob.hasTag("player")||blob.hasTag("vehicle"))&&blob.getTeamNum()!=this.getTeamNum()&&!(blob.hasTag("dead")||blob.hasTag("halfdead"));
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2 )
{
	if (blob is null || !doesCollideWithBlob(this, blob)) return;
	const bool flip = this.isFacingLeft();
	const f32 flip_factor = flip ? -1 : 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	this.set_Vec2f("last_hit_offset", blob.getPosition()-this.getPosition());
	this.set_u32("last_hit_time", getGameTime());
	this.getSprite().PlaySound("DemonicBoing.ogg", 1.0f, float(90+XORRandom(21)+10)*0.01f);//nodamage.ogg
	blob.AddForce(Vec2f(10*Maths::Max(1, blob.getMass()),0).RotateBy(this.get_Vec2f("last_hit_offset").Angle()*flip_factor));
	this.server_Hit(blob, this.getPosition(), Vec2f(0, 0), 1.0f, 12);
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	//this.set_Vec2f("last_hit_world", worldPoint);
	this.set_Vec2f("last_hit_offset", hitterBlob.getPosition()-this.getPosition());
	//this.set_Vec2f("last_hit_vel", velocity);
	//this.set_f32("last_hit_dmg", damage);
	//this.set_u16("last_hit_guy", hitterBlob.getNetworkID());
	//this.set_u8("last_hit_type", customData);
	this.set_u32("last_hit_time", getGameTime());
	
	//playNoDamage(this, worldPoint, false);
	this.getSprite().PlaySound("DemonicBoing.ogg", 1.0f, float(90+XORRandom(21))*0.01f);//nodamage.ogg
	
	return 0;
}