#include "MakeBangEffect"

void MakeExplodeParticles(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	if (this is null) return;
	MakeExplodeParticles(this.getPosition()+pos, vel, filename);
}

void MakeExplodeParticles(const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;
	CParticle@ p = ParticleAnimated(
	"explosion64.png",                   	// file name
	pos,            						// position
	vel,                         			// velocity
	float(XORRandom(360)),                  // rotation
	0.5f + XORRandom(100) * 0.01f,			// scale
	5,                                  	// ticks per frame
	0.0f,                               	// gravity
	true);
}

void kiwiExplosionEffects(CBlob@ this)
{
	this.SetMinimapVars("kiwi_minimap_icons.png", 14, Vec2f(8, 8));
	this.SetMinimapOutsideBehaviour(CBlob::minimap_none);
	
	f32 radius = this.get_f32("explosion blob radius");
	
	int flares = this.exists("custom flare amount")?this.get_s32("custom flare amount"):3;
	if (!this.exists("custom_explosion_pos")) this.set_Vec2f("custom_explosion_pos", this.getPosition());
	
	if (isServer())
	for (int idx = 0; idx < flares; ++idx) {
		CBlob@ flare = server_CreateBlob("napalm", this.getTeamNum(), this.get_Vec2f("custom_explosion_pos")+Vec2f(0, -4));
		if (flare is null) continue;
		flare.set_f32("particle_scale", 1.5f);
		flare.setVelocity(getRandomVelocity(90, (8+XORRandom(14)), 10));
		flare.SetDamageOwnerPlayer(this.getDamageOwnerPlayer());
	}
	
	Vec2f ray_hitpos;
	if (getMap().rayCastSolid(this.get_Vec2f("custom_explosion_pos"), this.getPosition(), ray_hitpos)) return;
	
	f32 scale = radius/16;
	
	if (isClient())
	{
		Vec2f pos = this.getPosition();
		CMap@ map = getMap();
		
		MakeBangEffect(this, "kaboom", radius/15);
		//Sound::Play("handgrenade_blast2", this.getPosition(), 2, 1.0f + XORRandom(2)*0.1);
		u8 particle_amount = radius/6;
		for (int i = 0; i < particle_amount; i++)
		{
			MakeExplodeParticles(this, Vec2f(radius-16, 0).RotateBy(360/particle_amount*i), getRandomVelocity(360/particle_amount*i, 0, 90));
		}
		
		this.Tag("exploded");
	}
	
	int fire_amount = Maths::Max(1, radius/2.6);
	
	for (int idx = 0; idx < fire_amount; ++idx) {
		CParticle@ p = ParticleAnimated(
		"kiwi_fire_v2_no_smoke.png",							// file name
		this.getPosition() + Vec2f(scale*(idx>fire_amount/2?7:3)+XORRandom(idx), 0).RotateBy(360/(1.0f*fire_amount/2)*idx),	// position
		Vec2f((XORRandom(60)-30)*0.01, 0),      				// velocity
		0,                              						// rotation
		scale*(idx>fire_amount/2?1.7:1)/2/2,		            // scale
		2+XORRandom(2),                        					// ticks per frame
		0,                										// gravity
		true);
		if (p !is null) {
			p.setRenderStyle(RenderStyle::additive);
			p.Z=1500+XORRandom(30)*0.01;
			p.growth = -0.015;
			p.freerotation = true;
		}
	}
}