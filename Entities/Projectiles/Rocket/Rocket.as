#include "Hitters"
#include "Explosion"
#include "KIWI_Hitters"
#include "ExplosionAtPos"

const u32 FUEL_TIMER_MAX =  0.750f * getTicksASecond();

void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
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
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return !blob.getShape().isStatic()&&blob.isCollidable();
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2 )
{
	if (solid) {
		DestroyTilesInRadius(point2, 2);
		this.server_Die();
	}
	if (blob !is null && doesCollideWithBlob(this, blob)) {
		this.server_Hit( blob, point1, normal, 50+XORRandom(100)*0.01, HittersKIWI::rocketer);
		this.server_Die();
	}
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

	for(int counter = 0; counter < 5; ++counter) {
		f32 speed_mod = this.getVelocity().Length();
		Vec2f offset = Vec2f(-XORRandom(speed_mod), 0).RotateBy(this.getAngleDegrees());
		CParticle@ p = ParticleAnimated(filename, this.getPosition() + offset, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), 0.1*flip_factor, false);
		if (p !is null) {
			p.growth = -0.05;
			p.setRenderStyle(RenderStyle::outline);
		}
	}
}
