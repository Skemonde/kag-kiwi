// Draw a flame sprite layer

#include "FireParticle.as";
#include "FireCommon.as";

void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob !is null) {
		blob.set_bool("wereburning", false);
	}
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	//if we're burning
	if (blob.hasTag(burning_tag))
	{
		CParticle@ p = ParticleAnimated(
		"kiwi_fire.png",                   		// file name
		blob.getPosition() + Vec2f(0,-3) + Vec2f(-XORRandom(Maths::Floor(blob.getVelocity().x)), 0),       // position
		Vec2f((XORRandom(60)-30)*0.01, 0),      // velocity
		0,                              		// rotation
		1.3f,                               	// scale
		3,                                  	// ticks per frame
		(XORRandom(3)+1)*-0.03f,                // gravity
		true);
		if (p !is null) {
			//p.setRenderStyle(RenderStyle::additive);
			p.Z=1500+XORRandom(30)*0.01;
			//p.growth = 0.015;
		}
		blob.set_bool("wereburning", true);
	}
	else
	{
		if (blob.get_bool("wereburning"))
		{
			this.PlaySound("/ExtinguishFire.ogg");
		}
		blob.set_bool("wereburning", false);
	}
}
