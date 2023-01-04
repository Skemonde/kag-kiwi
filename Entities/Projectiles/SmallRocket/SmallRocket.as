#include "Hitters.as";
#include "Explosion.as";

const u32 fuel_timer_max = 30 * 0.50f;

void onInit(CBlob@ this)
{
	this.set_f32("map_damage_ratio", 0.5f);
	this.set_f32("map_damage_radius", 24.0f);
	this.set_string("custom_explosion_sound", "Keg.ogg");

	this.set_u32("fuel_timer", 0);
	this.set_f32("velocity", 10.0f);

	this.Tag("aerial");
	this.Tag("projectile");

	this.getShape().SetRotationsAllowed(true);

	this.SetMapEdgeFlags(CBlob::map_collide_left | CBlob::map_collide_right);

	this.set_u32("fuel_timer", getGameTime() + fuel_timer_max + XORRandom(15));

	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSound("VerySus");
	sprite.SetEmitSoundSpeed(0.8f);
	sprite.SetEmitSoundPaused(false);

	this.SetLight(true);
	this.SetLightRadius(64.0f);
	this.SetLightColor(SColor(255, 255, 100, 0));
}

void onTick(CBlob@ this)
{
	if (this.get_u32("fuel_timer") > getGameTime())
	{
		this.set_f32("velocity", Maths::Min(this.get_f32("velocity") + 0.15f, 15.0f));

		Vec2f dir = Vec2f(0, 1);
		dir.RotateBy(this.getAngleDegrees());

		//this.setVelocity(dir * -this.get_f32("velocity") + Vec2f(0, this.getTickSinceCreated() > 5 ? XORRandom(50) / 100.0f : 0));
		this.setVelocity(this.get_Vec2f("velocity_before_watur"));

		if(isClient())
		{
			//MakeParticle(this, -dir, XORRandom(100) < 30 ? ("SmallSmoke" + (1 + XORRandom(2))) : "SmallExplosion" + (1 + XORRandom(3)));
			for (u8 i = 1; i <= Maths::Min(Maths::Floor(this.getVelocity().Length()), 4); ++i) ParticleAnimated("SmallSteam", this.getPosition(), Vec2f(0,0), float(XORRandom(360)), 1.0f + XORRandom(100) * 0.01f, 2 + XORRandom(4), XORRandom(100) * -0.00005f, true);
		}

		this.setAngleDegrees(-this.getVelocity().Angle() + 90);
	}
	else
	{
		this.setAngleDegrees(-this.getVelocity().Angle() + 90);
		//this.getSprite().SetEmitSoundPaused(true);
	}
}
/*
void onTick( CBlob@ this )
{
	Vec2f pos = this.getPosition();
	
	//this.getSprite().setVisible(false);
	
	if (this.isInWater()) this.setVelocity(this.get_Vec2f("velocity_before_watur") * 0.4);
	else this.setVelocity(this.get_Vec2f("velocity_before_watur"));
	
	if (pos.x < 0.1f or pos.x > (getMap().tilemapwidth * getMap().tilesize) - 0.1f)
	{
		this.server_Die();
		return;
	}
	
    f32 angle = (this.getVelocity()).Angle() - 90;
    //Pierce( this ); //map
    this.setAngleDegrees(-angle);

	CShape@ shape = this.getShape();
	//shape.SetGravityScale( 0.3f + this.getTickSinceCreated()*0.1f );
	shape.SetGravityScale( 1.2f );
}
*/
/*
void MakeParticle(CBlob@ this, const Vec2f vel, const string filename = "SmallSteam")
{
	Vec2f offset = Vec2f(XORRandom(16)-8, XORRandom(8)-4).RotateBy(this.getAngleDegrees());
	CMap@ map = getMap(); // fire things up if standing under
	if (isServer() && map !is null)
	{
		for (u8 i = 0; i < 10; i++)
		{
			map.server_setFireWorldspace(this.getPosition()+offset+Vec2f(XORRandom(24)-12, XORRandom(32)-16), true);
		}
	}
	if (!isClient()) return;
	ParticleAnimated(filename, this.getPosition() + offset, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}
*/
void DoExplosion(CBlob@ this, Vec2f velocity)
{
	//CRules@ rules = getRules();
	//if (!shouldExplode(this, rules))
	//{
	//	addToNextTick(this, rules, velocity, DoExplosion);
	//	return;
	//}

	if (this.hasTag("dead")) return;
	this.Tag("dead");

	this.set_Vec2f("explosion_offset", Vec2f(0, -16).RotateBy(this.getAngleDegrees()));

	Explode(this, 12.0f, 4.0f);
	for (int i = 0; i < 4; i++)
	{
		Vec2f dir = Vec2f(1 - i / 2.0f, -1 + i / 2.0f);
		Vec2f jitter = Vec2f((XORRandom(200) - 100) / 200.0f, (XORRandom(200) - 100) / 200.0f);

		LinearExplosion(this, Vec2f(dir.x * jitter.x, dir.y * jitter.y), 16.0f + XORRandom(16), 10.0f, 4, 5.0f, Hitters::explosion);
	}

	this.server_Die();
	this.getSprite().Gib();
}

void onDie(CBlob@ this)
{
	DoExplosion(this, Vec2f(0, 0));
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return this.getTickSinceCreated() > 5 && this.getTeamNum() != blob.getTeamNum() && blob.isCollidable();
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (isServer())
	{
		if (this.getTickSinceCreated() > 10 && (solid ? true : (blob !is null && blob.isCollidable() && this.getTeamNum() != blob.getTeamNum())))
		{
			this.server_Die();
		}
	}
}

// void GetButtonsFor(CBlob@ this, CBlob@ caller)
// {
	// AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	// if (point is null) return;

	// if (point.getOccupied() is null)
	// {
		// CBitStream params;
		// caller.CreateGenericButton(11, Vec2f(0.0f, 0.0f), this, this.getCommandID("offblast"), "Off blast!", params);
	// }
// }

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
	// AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PILOT");
	// if (point is null) return true;

	// CBlob@ holder = point.getOccupied();
	// if (holder is null) return true;
	// else return false;
}
