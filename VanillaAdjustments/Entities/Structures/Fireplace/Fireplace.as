// Fireplace

#include "ProductionCommon.as";
#include "Requirements.as";
#include "MakeFood.as";
#include "FireParticle.as";
#include "Hitters.as";
#include "KIWI_Locales.as";

void onInit(CBlob@ this)
{
	//this.getCurrentScript().tickFrequency = 9;
	this.getSprite().SetEmitSound("CampfireSound.ogg");
	this.getSprite().SetEmitSoundPaused(false);
	
	this.getSprite().SetAnimation("fire");
	this.getSprite().PlaySound("/FireFwoosh.ogg");
	
	this.getSprite().SetFacingLeft(XORRandom(2) == 0);
	
	this.setInventoryName(Names::campfire);

	this.SetLight(true);
	this.SetLightRadius(164.0f);
	this.SetLightColor(SColor(255, 255, 240, 171));

	this.Tag("fire source");

	this.addCommandID("extinguish");
}

void onTick(CBlob@ this)
{
	if (isClient()&&this.getSprite().isAnimation("fire"))
	{
		CParticle@ p = ParticleAnimated(
		"kiwi_fire.png",                   		// file name
		this.getPosition() + Vec2f(0,-3) + Vec2f(-XORRandom(Maths::Floor(this.getVelocity().x)), 0),       // position
		Vec2f((XORRandom(60)-30)*0.01, 0),      // velocity
		0,                              		// rotation
		1.0f,                               	// scale
		3,                                  	// ticks per frame
		(XORRandom(3)+1)*-0.03f,                // gravity
		true);
		if (p !is null) {
			p.setRenderStyle(RenderStyle::additive);
			p.Z=-30+XORRandom(30)*0.01;
			p.growth = 0.015;
		}
	}

	if (this.isInWater())
	{
		Extinguish(this);
	}

	if (this.isInFlames())
	{
		Ignite(this);
	}
}


void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{	
	if (blob !is null && this.getSprite().isAnimation("fire"))
	{
		CBlob@ food = cookFood(blob);
		if (food !is null)
		{
			food.setVelocity(blob.getVelocity().opMul(0.5f));
		}
	}
}

void onInit(CSprite@ this)
{
	this.SetZ(-50); //background
}

void Extinguish(CBlob@ this)
{
	if (this.getSprite().isAnimation("nofire")) return;

	this.SetLight(false);
	this.Untag("fire source");

	this.getSprite().SetAnimation("nofire");
	this.getSprite().SetEmitSoundPaused(true);
	this.getSprite().PlaySound("/ExtinguishFire.ogg");
	
	makeSmokeParticle(this.getPosition()); //*poof*
}

void Ignite(CBlob@ this)
{
	if (this.getSprite().isAnimation("fire")) return;

	this.SetLight(true);
	this.Tag("fire source");

	this.getSprite().SetAnimation("fire");
	this.getSprite().SetEmitSoundPaused(false);
	this.getSprite().PlaySound("/FireFwoosh.ogg");
	
	CSpriteLayer@ fire = this.getSprite().getSpriteLayer("fire_animation_large");
	if (fire !is null)
	{
		fire.SetVisible(true);
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::water)
	{
		Extinguish(this);
	}
	return damage;
}
