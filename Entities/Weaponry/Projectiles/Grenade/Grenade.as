#include "Hitters"
#include "KIWI_Hitters"
#include "MetroBoomin"
#include "MakeBangEffect"
#include "MakeExplodeParticles"

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
	
	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSound("mortar_whistle");
	sprite.SetEmitSoundPaused(true);
}

void onTick(CBlob@ this)
{
	const bool FLIP = this.getVelocity().x<0;
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	f32 rotation_scale = 20;
	this.setAngleDegrees(getGameTime()%(360/rotation_scale)*rotation_scale*FLIP_FACTOR);
	
	for (u8 i = 1; i <= Maths::Min(Maths::Floor(this.getVelocity().Length()), 1); ++i) ParticleAnimated("SmallSmoke" + (XORRandom(1)+1), this.getPosition() + Vec2f(-XORRandom(Maths::Floor(this.getVelocity().x)), 0), Vec2f(0,0), float(XORRandom(360)), 1.0f + XORRandom(100) * 0.01f, 2 + XORRandom(4), XORRandom(100) * -0.00005f, true);
	
	CShape@ shape = this.getShape();
	shape.SetGravityScale( 0.8 );
}

void onDie(CBlob@ this)
{
	DoExplosion(this);
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
		MakeItBoom(this, this.get_f32("explosion blob radius"), 13.0f);
	}
	
	kiwiExplosionEffects(this);
}