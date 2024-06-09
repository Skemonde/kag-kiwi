#include "Hitters"
#include "Explosion"
#include "KIWI_Hitters"
#include "ExplosionAtPos"

const u32 FUEL_TIMER_MAX =  0.250f * getTicksASecond();

void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	//this.setVelocity(Vec2f(0, -4));
}

void findTarget(CBlob@ this)
{
	CBlob@[] blobs_around;
	if (!getMap().getBlobsInRadius(this.getPosition(), 256, blobs_around)) return;
	for (u32 idx = 0; idx < blobs_around.size(); ++idx) {
		CBlob@ blob = blobs_around[idx];
		if (blob is null) continue;
	//print("got there");
		if (blob.getTeamNum()==this.getTeamNum()) continue;
		if (!blob.hasTag("player")) continue;
		this.set_u16("target_nid", blob.getNetworkID());
	}
}

void angleToTarget(CBlob@ this)
{
	//if (!isServer()) return;
	CBlob@ target = getBlobByNetworkID(this.get_u16("target_nid"));
	if (target is null) {
		findTarget(this);
		return;
	}
	
	Vec2f t_pos = target.getPosition();
	Vec2f m_pos = this.getPosition();
	
	bool target_right = t_pos.x>m_pos.x;
	
	if (getLocalPlayer() !is null) {
		//print("len "+(t_pos-m_pos).Length());
		u16 beep_mod = Maths::Max(3, (t_pos-m_pos).Length()*0.05f);
		if (getGameTime()%beep_mod==0) {
			//Sound::Play("AirSlashStart");
		}
	}
	
	f32 vel_angle = (this.getVelocity().AngleDegrees());
	f32 pos_angle = ((t_pos-m_pos).AngleDegrees());
	f32 diff = vel_angle-pos_angle;
	print("vel ang "+vel_angle);
	this.setVelocity((this.getVelocity().RotateBy(diff))*1.006f);
}

f32 constrainAngle(f32 x)
{
	x = (x + 180) % 360;
	if (x < 0) x += 360;
	return x - 180;
}

void onTick(CBlob@ this)
{
	//this.setVelocity(Vec2f(-3, 4));
	
	this.setAngleDegrees(-this.getVelocity().getAngle());
	CShape@ shape = this.getShape();
	//shape.SetGravityScale(0);
	shape.SetGravityScale(Maths::Min((this.getTickSinceCreated()-FUEL_TIMER_MAX)/10, 0.98));
	
	Vec2f dir = Vec2f(0, 1);
	dir.RotateBy(this.getAngleDegrees());
	MakeParticle(this, -dir, XORRandom(100) < 30 ? ("SmallSmoke" + (1 + XORRandom(2))) : "SmallExplosion" + (1 + XORRandom(3)));
	
	if (FUEL_TIMER_MAX>this.getTickSinceCreated()) {
	} else {
		angleToTarget(this);
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
	return !blob.getShape().isStatic()&&blob.isCollidable()&&blob.getTeamNum()!=this.getTeamNum()&&!blob.hasTag("invincible");
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2 )
{
	if (solid) {
		DestroyTilesInRadius(point2-this.getVelocity(), 1);
		this.server_Die();
	}
	if (blob !is null && doesCollideWithBlob(this, blob)) {
		this.server_Hit( blob, point1, normal, 12+XORRandom(100)*0.01, HittersKIWI::rocketer);
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
