#include "Hitters"
#include "MetroBoomin"
#include "KIWI_Hitters"
//#include "ExplosionAtPos"
#include "MakeExplodeParticles"
#include "WhatShouldProjHit"

const u32 FUEL_TIMER_MAX =  0.750f * getTicksASecond();

void onInit(CBlob@ this)
{
	this.Tag("explosive");
	this.Tag("self explosion immune");
	this.Tag("exact hit");
	this.sendonlyvisible = false;
	
	this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	this.SetMinimapVars("kiwi_minimap_icons.png", 15, Vec2f(8, 8));
	this.SetMinimapRenderAlways(true);
	this.getSprite().PlaySound("bazooka_fire.ogg");
	this.set_u8("custom_hitter", HittersKIWI::bazooka);
}

void onTick(CBlob@ this)
{
	this.setAngleDegrees(-this.getVelocity().getAngle());
	
	CShape@ shape = this.getShape();
	shape.SetGravityScale(0);
	if (FUEL_TIMER_MAX<this.getTickSinceCreated()) {
		shape.SetGravityScale(Maths::Min((this.getTickSinceCreated()-FUEL_TIMER_MAX)/10, 0.98));
	} else {
		Vec2f dir = Vec2f(0, 1);
		dir.RotateBy(this.getAngleDegrees());
		MakeParticle(this, -dir, XORRandom(100) < 30 ? ("SmallSmoke" + (1 + XORRandom(2))) : "SmallExplosion" + (1 + XORRandom(3)));
	}
}

void DoExplosion(CBlob@ this)
{
}

void onDie(CBlob@ this)
{
	this.set_f32("map_damage_radius", 48);
	this.set_f32("map_damage_ratio", 1.00f);
	this.set_f32("explosion blob radius", 48);
	this.set_string("custom_explosion_sound", "bombita_explode");
	
	if (isServer()||true)
	{
		if (!this.exists("custom_explosion_pos")) this.set_Vec2f("custom_explosion_pos", this.getPosition());
		MakeItBoom(this, this.get_f32("explosion blob radius"), 19.0f);
	}
	
	kiwiExplosionEffects(this);
	this.SetMinimapVars("kiwi_minimap_icons.png", 14, Vec2f(8, 8));
	this.SetMinimapOutsideBehaviour(CBlob::minimap_none);
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	this.getSprite().Gib();
	this.server_Die();
	return 0;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return false;
	return !blob.getShape().isStatic()&&blob.isCollidable()&&blob.getTeamNum()!=this.getTeamNum()&&!blob.hasTag("invincible");
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2 )
{
	//it only collides with itself
	if (blob !is null && blob.getName()==this.getName() && blob.getTeamNum()!=this.getTeamNum()) this.server_Die();
}
bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

void MakeParticle(CBlob@ this, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;
	const bool flip = this.getVelocity().x<0;
	const f32 flip_factor = flip ? -1 : 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	int sus = Maths::Max(2, this.getVelocity().Length()/5);

	for(int counter = 0; counter < sus; ++counter) {
		f32 speed_mod = this.getVelocity().Length();
		Vec2f offset = Vec2f(-XORRandom(speed_mod), 0).RotateBy(this.getAngleDegrees());
		offset = -this.getVelocity()/sus*counter;
		CParticle@ p = ParticleAnimated(filename, this.getPosition() + offset, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), 0.1*flip_factor, false);
		if (p !is null) {
			p.growth = -0.05;
			p.setRenderStyle(RenderStyle::outline);
		}
	}
}
