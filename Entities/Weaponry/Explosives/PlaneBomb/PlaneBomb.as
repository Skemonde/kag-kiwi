
#include "Hitters"
#include "KIWI_Hitters"
#include "MetroBoomin"
#include "MakeBangEffect"
#include "MakeExplodeParticles"

void onInit(CSprite@ this)
{
	this.SetEmitSound("Shell_Whistle.ogg");
	this.SetEmitSoundPaused(false);
}

void onInit(CBlob@ this)
{
	this.Tag("bullet_hits");
	this.Tag("medium weight");
	this.Tag("bomb");
	this.set_u8("custom_hitter", HittersKIWI::aerial_bomb);
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	Vec2f oldvel = blob.getOldVelocity();
	f32 vellen = oldvel.y;
	if (vellen>5&&!blob.isInInventory())
		this.SetEmitSoundVolume(vellen/5);
	else
		this.SetEmitSoundVolume(0);
	if (vellen<5&&!blob.hasTag("DoExplode"))
		this.RewindEmitSound();
}

void onTick(CBlob@ this) {
	if (this.exists("death_time")) {
		this.setAngleDegrees(0);
		this.setVelocity(Vec2f(0, Maths::Abs(this.getVelocity().y)));
		
		if ((this.get_u32("death_time")-getGameTime())%12==0)
			this.getSprite().PlaySound("missile_beep", 1, 1);
		
		CSprite@ sprite = this.getSprite();
		if (sprite !is null) {
			sprite.ResetTransform();
			sprite.RotateBy(this.get_f32("death_angle"), Vec2f());
		}
		if (!this.hasTag("made_sound")) {
			//Sound::Play("kaboom.ogg", getDriver().getWorldPosFromScreenPos(getDriver().getScreenCenterPos()), 2.0f, 1);
			this.Tag("made_sound");
		}
		if (this.get_u32("death_time")<getGameTime()) {
			this.server_Die();
			//this.getSprite().PlaySound("kaboom", 2, 1);
			this.set_u32("death_time", -1);
		}
	}
}


f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData==Hitters::fall) return 0;
	if (damage>this.getHealth()*2||damage>5.0f) {
		this.Tag("DoExplode");
		this.server_Die();
	}
	return damage;
}

void onDie(CBlob@ this)
{
	if (!this.hasTag("DoExplode")) return;
	this.set_string("custom_explosion_sound", "Dynamite");
	this.set_f32("map_damage_radius", 64);
	this.set_f32("map_damage_ratio", 4);
	this.set_f32("explosion blob radius", 96);
	this.set_Vec2f("custom_explosion_pos", this.getPosition()+Vec2f(0, -8));
	
	if (isServer())
	{
		MakeItBoom(this, this.get_f32("explosion blob radius"), (450+XORRandom(150))/10);
	}
	
	this.set_s32("custom flare amount", 7);
	kiwiExplosionEffects(this);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if (blob !is null ? !blob.isCollidable() : !solid)
	{
		return;
	}

	f32 vellen = this.getOldVelocity().Length();
	if (vellen >= 7.0f && !this.hasTag("dead") && this.getOldVelocity().y>6) 
	{
		Vec2f dir = Vec2f(-normal.x, normal.y);
		
		this.Tag("DoExplode");
		this.set_u32("death_time", getGameTime()+(2.0f*getTicksASecond()));
		this.set_f32("death_angle", this.getAngleDegrees());
		this.getSprite().SetOffset(this.getSprite().getOffset()+Vec2f(0, 4));
		this.setVelocity(Vec2f());
		this.getSprite().SetEmitSoundPaused(true);
		//this.getShape().SetGravityScale(0);
		this.Tag("dead");
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return !this.exists("death_time")&&blob.getShape().isStatic();
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return !this.exists("death_time");
}

bool canBePutInInventory( CBlob@ this, CBlob@ inventoryBlob )
{
	return !this.exists("death_time");
}