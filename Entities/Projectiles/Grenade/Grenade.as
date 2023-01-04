#include "Hitters.as";
#include "Explosion.as";
#include "WhatShouldProjHit.as";

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

	this.set_f32("map_damage_ratio", 1.0f);
	this.set_f32("map_damage_radius", 32.0f);
	this.set_string("custom_explosion_sound", "explosion3");

	this.Tag("map_damage_dirt");
	this.Tag("projectile");

	this.getShape().SetRotationsAllowed(true);
	this.SetMapEdgeFlags(u8(CBlob::map_collide_none | CBlob::map_collide_left | CBlob::map_collide_right | CBlob::map_collide_nodeath));
	
	//Sound::Play("falling_whistle", this.getPosition(), 0.8, 3.2f + XORRandom(2)*0.1);
}

void onTick(CBlob@ this)
{	
	const bool flip = this.isFacingLeft();
	const f32 flip_factor = flip ? -1 : 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	
	//bool once = this.get_bool("once");
	//if(!this.hasTag("grenade collided"))
	{
		//this.setAngleDegrees(-this.getVelocity().Angle());
		//this.set_bool("once", !once);
		//this.set_Vec2f("velocity_before_watur", this.getVelocity());
	}
	
	this.setAngleDegrees(-this.getVelocity().Angle());
	
	for (u8 i = 1; i <= Maths::Min(Maths::Floor(this.getVelocity().Length()), 1); ++i) ParticleAnimated("SmallSmoke" + (XORRandom(1)+1), this.getPosition() + Vec2f(-XORRandom(Maths::Floor(this.getVelocity().x)), 0), Vec2f(0,0), float(XORRandom(360)), 1.0f + XORRandom(100) * 0.01f, 2 + XORRandom(4), XORRandom(100) * -0.00005f, true);
	
	CShape@ shape = this.getShape();
	shape.SetGravityScale( 0.8f );
}

void onDie(CBlob@ this)
{
	DoExplosion(this);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (solid)
	{
		if (!this.hasTag("grenade collided"))
		{
			this.Tag("grenade collided");
			this.server_SetTimeToDie(0.6);
		}	
		else
			this.server_Die();

		if (isClient() && !this.hasTag("dead") && this.getOldVelocity().Length() > 2.0f) this.getSprite().PlaySound("launcher_boing" + XORRandom(2), 0.2f, 1.0f);
	}
	else if ((blob !is null && doesCollideWithBlob(this, blob)))
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
	// print("Modifier: " + modifier + "; Quantity: " + this.getQuantity());

	this.set_f32("map_damage_radius", (24.0f + random) * modifier);
	this.set_f32("map_damage_ratio", 0.25f);

	Explode(this, 24.0f + random, 3.0f);

	for (int i = 0; i < 4 * modifier; i++)
	{
		Vec2f dir = getRandomVelocity(angle, 1, 120);
		dir.x *= 2;
		dir.Normalize();

		LinearExplosion(this, dir, 8.0f + XORRandom(8) + (modifier * 8), 8 + XORRandom(24), 2, 0.125f, Hitters::explosion);
	}
	if(isClient())
	{
		Vec2f pos = this.getPosition();
		CMap@ map = getMap();

		for (int i = 0; i < 1; i++)
		{
			MakeParticle(this, Vec2f_zero, Vec2f_zero, particles[XORRandom(particles.length)]);
		}

		//this.getSprite().Gib();
	}
	
}

void MakeParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	//ParticleAnimated(filename, this.getPosition() + pos, vel, float(XORRandom(360)), 1.0f + XORRandom(100) * 0.01f, 2 + XORRandom(4), XORRandom(100) * -0.00005f, true);
	ParticleAnimated(
	"explosion64.png",                   // file name
	this.getPosition() + pos,            // position
	vel,                         // velocity
	float(XORRandom(360)),                              // rotation
	1.0f,                               // scale
	3,                                  // ticks per frame
	0.0f,                               // gravity
	true);
}
