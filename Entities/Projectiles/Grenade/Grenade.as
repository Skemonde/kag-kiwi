#include "Hitters"
#include "KIWI_Hitters"
#include "Explosion"
#include "WhatShouldProjHit"
#include "MakeBangEffect"
#include "ExplosionAtPos"
#include "MakeExplodeParticles"
#include "WhatShouldProjHit"

string[] particles =
{
	"SmallSmoke1.png",
	"SmallSmoke2.png",
	"SmallExplosion1.png",
	"SmallExplosion2.png",
	"SmallExplosion3.png",
	"SmallFire1.png",
	"SmallFire2.png"
};

void onInit(CBlob@ this)
{
	this.addCommandID("offblast");

	this.set_f32("map_damage_ratio", 0.1f);
	this.set_f32("map_damage_radius", 16.0f);
	this.set_string("custom_explosion_sound", "explosion3");
	this.set_u8("custom_hitter", HittersKIWI::boom);

	this.Tag("map_damage_dirt");
	this.Tag("projectile");

	this.getShape().SetRotationsAllowed(true);
	this.SetMapEdgeFlags(u8(CBlob::map_collide_none | CBlob::map_collide_left | CBlob::map_collide_right | CBlob::map_collide_nodeath));
	
	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSound("mortar_whistle");
	sprite.SetEmitSoundPaused(true);
	
	CShape@ shape = this.getShape();
	shape.getConsts().mapCollisions = false;
}

void onTick(CBlob@ this)
{
	this.setAngleDegrees(-this.getVelocity().getAngle());
	CMap@ map = getMap();
	
	HitInfo@[] hitInfos;
	
	f32 our_angle = this.getAngleDegrees();
	const bool FLIP = this.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	Vec2f dir = Vec2f(FLIP_FACTOR, 0).RotateBy(our_angle);
		
	if (map.getHitInfosFromRay(this.getPosition()-dir*10, our_angle, Maths::Max(this.getWidth()/2+14, this.getVelocity().Length()), this, @hitInfos)) {}
	
	for (int counter = 0; counter < hitInfos.length; ++counter) {
		CBlob@ doomed = hitInfos[counter].blob;
		if (doomed !is null) {
			if (shouldRaycastHit(doomed, our_angle, this.isFacingLeft(), this.getTeamNum(), HittersKIWI::rocketer, hitInfos[counter].hitpos))
			{
				this.set_Vec2f("custom_explosion_pos", hitInfos[counter].hitpos);
				this.server_Die();
			}
		}
		else
		{
			this.set_Vec2f("custom_explosion_pos", this.getPosition());
			this.server_Die();
		}
	}
	if (this.getTickSinceCreated()<2)
		Sound::Play("mortar_whistle", this.getPosition(), 0.8, 1.2f + (XORRandom(20)-10)*0.01);
	const bool flip = this.isFacingLeft();
	const f32 flip_factor = flip ? -1 : 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	
	for (u8 i = 1; i <= Maths::Min(Maths::Floor(this.getVelocity().Length()), 1); ++i) ParticleAnimated("SmallSmoke" + (XORRandom(1)+1), this.getPosition() + Vec2f(-XORRandom(Maths::Floor(this.getVelocity().x)), 0), Vec2f(0,0), float(XORRandom(360)), 1.0f + XORRandom(100) * 0.01f, 2 + XORRandom(4), XORRandom(100) * -0.00005f, true);
	
	CShape@ shape = this.getShape();
	shape.SetGravityScale( 0.8 );
}

void onDie(CBlob@ this)
{
	DoExplosion(this);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

void DoExplosion(CBlob@ this)
{
	if (this.hasTag("exploded")) return;

	f32 random = XORRandom(32);
	f32 modifier = 1;

	this.set_f32("map_damage_radius", 16);
	this.set_f32("map_damage_ratio", 1.00f);
	this.set_f32("explosion blob radius", 40);
	this.set_string("custom_explosion_sound", "handgrenade_blast");
	
	if (isServer()||true)
	{
		if (!this.exists("custom_explosion_pos")) this.set_Vec2f("custom_explosion_pos", this.getPosition());
		Explode(this, this.get_f32("explosion blob radius"), 13.0f);
	}
	
	kiwiExplosionEffects(this);
}