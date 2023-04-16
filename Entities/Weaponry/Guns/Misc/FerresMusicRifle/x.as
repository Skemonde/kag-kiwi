// Blame Fuzzle.

#include "Hitters.as";
#include "ShieldCommon.as";
#include "LimitedAttacks.as";
#include "MakeDustParticle.as";
#include "ParticleSparks.as";

const f32 ARROW_PUSH_FORCE = 22.0f;
const f32 MEDIUM_SPEED = 17.0f;
const f32 FAST_SPEED = 22.0f;
// Speed required to pierce Wooden tiles.

void onInit(CBlob@ this)
{

	this.set_u8("blocks_pierced", 0);
	this.set_bool("static", false);

	this.server_SetTimeToDie(2.0);
	this.getShape().SetGravityScale(0.0f);
	this.getShape().getConsts().mapCollisions = true;
	this.getShape().getConsts().bullet = true;
	this.getShape().getConsts().net_threshold_multiplier = 1.0f;

	LimitedAttack_setup(this);

	u32[] offsets;
	this.set("offsets", offsets);
	// Offsets of the tiles that have been hit.

	this.Tag("projectile");
	this.getSprite().SetFrame(0);
	this.getSprite().getConsts().accurateLighting = true;
	this.getSprite().SetFacingLeft(!this.getSprite().isFacingLeft());

	this.SetMapEdgeFlags(CBlob::map_collide_left | CBlob::map_collide_right);

}

void onTick(CBlob@ this)
{

	f32 angle = 0;

	if (!this.get_bool("static"))
	{

		Vec2f velocity = this.getVelocity();
		angle = velocity.Angle();
		Pierce(this);


	}
	else
	{

		angle = Maths::get360DegreesFrom256(this.get_u8("angle"));

		this.setVelocity(Vec2f_zero);
		this.setPosition(Vec2f(this.get_f32("lock_x"), this.get_f32("lock_y")));
		this.getShape().SetStatic(true);
		this.doTickScripts = false;
		this.server_Die();

	}

	this.setAngleDegrees(-angle + 180.0f);

}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{

	if(blob.hasTag("projectile"))
{
return false;
}

bool check = this.getTeamNum() != blob.getTeamNum();
if(!check)
{
CShape@ shape = blob.getShape();
check = (shape.isStatic() && !shape.getConsts().platform);
}

if (check)
{
return true;
}

return false;

}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (blob !is null && doesCollideWithBlob(this, blob) && !this.hasTag("collided") && !blob.hasTag("dead") )
	{
	if (!solid && !blob.hasTag("flesh"))
		{
			return;
		}
		this.set_u8("custom_hitter", Hitters::fall);
		this.server_Hit(blob, point1, normal, 1.0f+XORRandom(4), Hitters::fall);
		this.getSprite().PlaySound("note_dos" + XORRandom(9) + ".ogg");
	}
	this.getSprite().PlaySound("note_dos" + XORRandom(9) + ".ogg");

}


void Pierce(CBlob @this)
{
	CMap@ map = this.getMap();
	Vec2f end;
	if (map.rayCastSolidNoBlobs(this.getShape().getVars().oldpos, this.getPosition() ,end))
	{
		HitMap(this, end, this.getOldVelocity(), 0.5f, Hitters::fall);
	}
}

void HitMap(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, u8 customData)
{
	//this.getSprite().PlaySound(XORRandom(0) == 0 ? "note_dos2.ogg" : "note_dos2.ogg");
	MakeDustParticle(worldPoint, "/DustSmall.png");
	CMap@ map = this.getMap();
	f32 vellen = velocity.Length();
	TileType tile = map.getTile(worldPoint).type;
	if (map.isTileCastle(tile) || map.isTileStone(tile))
	{
		sparks (worldPoint, -velocity.Angle(), Maths::Max(vellen*0.05f, damage));
	}
	this.server_Die();
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	// unbomb, stick to blob
	if (this !is hitBlob && customData == Hitters::fall)
	{
		// affect players velocity
		f32 force = (ARROW_PUSH_FORCE * -0.5f) * Maths::Sqrt(hitBlob.getMass()+1);
		hitBlob.AddForce(velocity * force);
	}
}


bool CollidesWithPlatform(CBlob@ this, CBlob@ blob, Vec2f velocity)
{
	f32 platform_angle = blob.getAngleDegrees();	
	Vec2f direction = Vec2f(0.0f, -1.0f);
	direction.RotateBy(platform_angle);
	float velocity_angle = direction.AngleWith(velocity);

	return !(velocity_angle > -90.0f && velocity_angle < 90.0f);
}
