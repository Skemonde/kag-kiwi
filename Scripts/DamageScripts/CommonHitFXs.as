#include "Hitters.as"
#include "HittersKIWI.as"
#include "ParticleSparks.as";

void playNoDamage(CBlob@ this, Vec2f worldPoint)
{
	this.getSprite().PlaySound("clang3.ogg", 1.0f, float(90+XORRandom(21))*0.01f);//nodamage.ogg
	sparks(worldPoint, 1, 0.1f);
}

void shieldHit(f32 damage, Vec2f velocity, Vec2f worldPoint)
{
	Sound::Play("Entities/Characters/Knight/ShieldHit.ogg", worldPoint);
	const f32 vellen = velocity.Length();
	sparks(worldPoint, -velocity.Angle(), Maths::Max(vellen * 0.05f, damage));
}

void makeDamageIndicator(CBlob@ this, int damage)
{
	//if it's not a fleshy thing (a player, a bison) why do we need numbers?
	//if it's steel it's fine tho
	if (!this.hasTag("flesh") && !this.hasTag("steel")) return;
	this.set_u16("endured_damage", 0);
	
	CParticle@ damage_thing = ParticleAnimated(
	"digit"+damage,                   					// file name
	this.get_Vec2f("hitpoint"),            								// position
	Vec2f((XORRandom(4)-2) * 0.1, -(0.5)),              // velocity
	0,                              		// rotation
	1.0f + (XORRandom(4*2)-4)*0.01,                		// scale
	16 + XORRandom(2),                              	// ticks per frame
	0.0f,                               				// gravity
	true);		                          				// self lit
	
	if (damage_thing !is null) {
		damage_thing.collides = false;
		damage_thing.deadeffect = 0;
		damage_thing.setRenderStyle(RenderStyle::additive);
		damage_thing.Z = 1000;
	}
}