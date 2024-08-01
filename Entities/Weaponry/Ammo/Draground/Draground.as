#include "Hitters"
#include "MetroBoomin"
#include "KIWI_Locales"

void onInit(CBlob@ this)
{  
	this.setInventoryName(Names::draground);
	
	this.Tag("ammo");
	this.Tag("crate pickup");
	this.Tag("bullet_hits");
	
	this.maxQuantity = 1;
	
	//this.getCurrentScript().runFlags |= Script::remove_after_this;
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2 )
{
	const f32 vellen = this.getOldVelocity().Length();
	if (solid) {			
		if (vellen > 1.7f)
		{
			Sound::Play("BombBounce", this.getPosition(), 1, 1.3f + XORRandom(2)*0.1);
		}
	}
	
	if (vellen >= 8.0f && solid)
	{
		//print("vellen "+vellen);
		this.server_Hit(this, this.getPosition(), Vec2f(), 2.0f, 0);
	}
}

void onDie( CBlob@ this )
{
	if (this.getTickSinceCreated()>=3) {
		this.set_u8("custom_hitter", Hitters::fire);
		this.set_string("custom_explosion_sound", "explosion2.ogg");
		MakeItBoom(this, 16, 5.0f);
	}
	
	CParticle@ p = ParticleAnimated(
	"kiwi_fire_v2.png", // file name
	this.getPosition(), // position
	Vec2f(),      		// velocity
	0,                  // rotation
	4.0f,               // scale
	1,                  // ticks per frame
	0,                	// gravity
	true);
	if (p !is null) {
		p.setRenderStyle(RenderStyle::additive);
		p.Z=1500+XORRandom(30)*0.01;
	}
}