void onInit(CRules@ this)
{
}

void onTick(CRules@ this)
{
}

void makeDamageIndicator(CBlob@ this, int damage)
{	
	CParticle@ damage_thing = ParticleAnimated(
	"digit"+damage,                   					// file name
	this.getPosition(),            								// position
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

void onRestart(CRules@ this)
{
}