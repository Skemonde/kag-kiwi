
#include "Hitters"
#include "KIWI_Hitters"
#include "Explosion"
#include "MakeBangEffect"
#include "MakeExplodeParticles"

void onInit(CSprite@ this)
{
	this.SetEmitSound("Shell_Whistle.ogg");
	this.SetEmitSoundPaused(false);
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	Vec2f oldvel = blob.getOldVelocity();
	f32 vellen = oldvel.y;
	if (vellen>0&&!blob.isInInventory())
		this.SetEmitSoundVolume(vellen/5);
	else
		this.SetEmitSoundVolume(0);
	if (vellen<5&&!blob.hasTag("DoExplode"))
		this.RewindEmitSound();
}

void onTick(CBlob@ this) {
	if (this.exists("death_time")) {
		this.setAngleDegrees(0);
		this.setVelocity(Vec2f());
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
	this.set_string("custom_explosion_sound", "handgrenade_blast");
	if (isServer())
	{
		this.set_f32("map_damage_radius", 64);
		this.set_f32("map_damage_ratio", 0.5f);
		this.set_u8("custom_hitter", HittersKIWI::handgren);
		Explode(this, 80.0f, (450+XORRandom(150))/10);
	}
	if (isServer())
	for (int idx = 0; idx < 3; ++idx) {
		CBlob@ flare = server_CreateBlob("napalm", this.getTeamNum(), this.getPosition()+Vec2f(0, -6));
		if (flare is null) continue;
		flare.set_f32("particle_scale", 1.5f);
		flare.setVelocity(getRandomVelocity(90, (8+XORRandom(14)), 10));
		flare.SetDamageOwnerPlayer(this.getDamageOwnerPlayer());
	}
	if (isClient())
	{
		Vec2f pos = this.getPosition();
		CMap@ map = getMap();
		
		MakeBangEffect(this, "kaboom", 4.0);
		Sound::Play("handgrenade_blast2", this.getPosition(), 2, 1.0f + XORRandom(2)*0.1);
		u8 particle_amount = 6;
		for (int i = 0; i < particle_amount; i++)
		{
			MakeExplodeParticles(this, Vec2f( XORRandom(64) - 32, XORRandom(64) - 32), getRandomVelocity(360/particle_amount*i, XORRandom(220) * 0.01f, 90));
		}
		
		this.Tag("exploded");
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if (blob !is null ? !blob.isCollidable() : !solid)
	{
		return;
	}

	f32 vellen = this.getOldVelocity().Length();
	if (vellen >= 8.0f && !this.hasTag("dead") && this.getOldVelocity().y>6) 
	{
		Vec2f dir = Vec2f(-normal.x, normal.y);
		
		this.Tag("DoExplode");
		this.set_u32("death_time", getGameTime()+(2.0f*getTicksASecond()));
		this.set_f32("death_angle", this.getAngleDegrees());
		this.getSprite().SetOffset(this.getSprite().getOffset()+Vec2f(0, 4));
		this.setVelocity(Vec2f());
		this.getSprite().SetEmitSoundPaused(true);
		this.getShape().SetGravityScale(0);
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