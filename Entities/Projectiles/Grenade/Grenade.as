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
	sprite.SetEmitSoundPaused(false);
	
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
			this.set_Vec2f("custom_explosion_pos", hitInfos[counter].hitpos);
			this.server_Die();
		}
	}
	//if (this.getTickSinceCreated()<2)
	//	Sound::Play("mortar_whistle", this.getPosition(), 0.8, 1.0f + (XORRandom(20)-10)*0.01);
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
	return;
	if (solid)
	{
		if (false)//!this.hasTag("grenade collided"))
		{
			this.Tag("grenade collided");
			this.server_SetTimeToDie(0.6);
		}	
		else
			this.server_Die();

		if (isClient() && !this.hasTag("dead") && this.getOldVelocity().Length() > 2.0f) this.getSprite().PlaySound("launcher_boing" + XORRandom(2), 0.2f, 1.0f);
	}
	//else if ((blob !is null && doesCollideWithBlob(this, blob)))
	this.server_Die();
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

void DoExplosion(CBlob@ this)
{
	CRules@ rules = getRules();
	//if (!shouldExplode(this, rules))
	//{
	//	addToNextTick(this, rules, DoExplosion);
	//	return;
	//}
	
	if (this.hasTag("dead")) return;
	this.Tag("dead");

	f32 random = XORRandom(16);
	f32 modifier = 1 + Maths::Log(this.getQuantity());
	f32 angle = -this.get_f32("bomb angle");
	CMap@ map = getMap();

	f32 radius = 16;/* 
	f32 damage = 15;
	f32 map_radius = 16;
	f32 map_damage = 0.005;
	ExplosionAtPos(
		this.getPosition(),
		map,
		radius,
		damage,
		map_radius,
		map_damage,
		false,
		false,
		this
	); */
	int particle_amount = Maths::Ceil(radius/map.tilesize);
	this.set_f32("map_damage_radius", 16);
	this.set_f32("map_damage_ratio", 0.5f);
	Explode(this, 48.0f, 5.0f);
	
	
	if (isClient())
	{
		Vec2f pos = this.getPosition();
		
		MakeBangEffect(this, "kaboom", 4.0);
		Sound::Play("handgrenade_blast2", this.getPosition(), 2, 1.0f + XORRandom(2)*0.1);
		for (int i = 0; i < particle_amount; i++)
		{
			MakeExplodeParticles(this.getPosition()+Vec2f( XORRandom(64) - 32, XORRandom(64) - 32), getRandomVelocity(360/particle_amount*i, XORRandom(220) * 0.01f, 90));
		}
		
		this.Tag("exploded");
	}
}