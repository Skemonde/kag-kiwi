
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

void onInit(CBlob@ this)
{
	this.Tag("bullet_hits");
	this.Tag("heavy weight");
	this.Tag("bomb");
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
		
		//if ((this.get_u32("death_time")-getGameTime())%12==0)
		//	this.getSprite().PlaySound("missile_beep", 1, 1);
		
		CSprite@ sprite = this.getSprite();
		if (sprite !is null) {
			sprite.ResetTransform();
			sprite.RotateBy(this.get_f32("death_angle"), Vec2f());
		}
		if (!this.hasTag("made_sound")) {
			Sound::Play("wazaaa.ogg", this.getPosition(), 2.0f, 1);
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
	this.set_f32("map_damage_radius", 128);
	this.set_f32("map_damage_ratio", 30);
	this.set_f32("explosion blob radius", 176);
	this.set_u8("custom_hitter", HittersKIWI::handgren);
	
	if (isServer() && this.hasTag("DoExplode"))
	{
		CBlob@ boom = server_CreateBlobNoInit("nukeexplosion");
		boom.setPosition(this.getPosition());
		//boom.set_f32("flash_distance", 512);
		boom.set_u8("boom_start", 10);
		boom.set_u8("boom_end", 40);
		boom.set_u8("boom_frequency", 5);
		boom.Tag("no mithril");
		boom.Tag("no flash");
		boom.Init();
		
		boom.SetDamageOwnerPlayer(this.getDamageOwnerPlayer());
	}
	return;
	
	if (isServer())
	{
		Explode(this, this.get_f32("explosion blob radius"), 80);
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
	if (vellen >= 9.0f && !this.hasTag("dead") && this.getOldVelocity().y>6) 
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