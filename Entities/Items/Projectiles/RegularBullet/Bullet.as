#include "Hitters.as";
#include "HittersKIWI.as";
#include "ShieldCommon.as";
#include "ArcherCommon.as";
#include "TeamStructureNear.as";
#include "Knocked.as"
#include "MakeDustParticle.as";
#include "ParticleSparks.as";
#include "WhatShouldProjHit.as";

void onInit( CBlob@ this )
{
    CShape@ shape = this.getShape();
	shape.SetGravityScale(0);
	shape.SetRotationsAllowed(true);
	ShapeConsts@ consts = shape.getConsts();
    consts.mapCollisions = false;	 // weh ave our own map collision
	consts.bullet = true;
	this.SetMapEdgeFlags(u8(CBlob::map_collide_none | CBlob::map_collide_left | CBlob::map_collide_right | CBlob::map_collide_nodeath));
	//consts.net_threshold_multiplier = 4.0f;
	this.server_SetTimeToDie( 1.5f );	
	this.Tag("projectile");
	
	this.set_Vec2f("velocity_before_watur", Vec2f(1,0));
	this.set_f32("damage", 1.0f);
	this.set_f32("range", 1.0f);
	this.set_u16("rico", 0);
	this.set_u8("hitter", 0);
	this.set_Vec2f("start_pos", this.getPosition());
	
	// glow
	this.SetLight(true);
	this.SetLightRadius(32.0f);
	this.SetLightColor(SColor(255, 255, 240, 210));
	
	if (this.getName()=="pellet")this.getSprite().setRenderStyle(RenderStyle::additive);
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1 )
{
	if (blob !is null)
	{
		Pierce( this, blob );
		if (doesCollideWithBlob( this, blob ) && !this.hasTag("collided"))
		{
			f32 dmg = this.get_f32("damage");
			
			if (blob.hasTag("dead") && !blob.hasTag("undead"))
			{
				//funny magic number
				dmg *= 69;
			}
			
			if (blob.hasTag("player")) blob.getSprite().PlaySound( "ManHit" + (XORRandom(3) + 1), 1.9, 1.0 );
			
			this.server_Hit( blob, point1, Vec2f(0, 1), dmg, this.get_u8("hitter"));
			this.Tag("collided");
			this.server_Die();
		}
	}
}

void onTick( CBlob@ this )
{
	CShape@ shape = this.getShape();
	Vec2f pos = this.getPosition();
	f32 range = this.get_f32("range");
	f32 covered_range = 1 + (pos - this.get_Vec2f("start_pos")).Length();
	//f32 ticks_till_death = this.get_f32("range")/this.get_Vec2f("velocity_before_watur").Length();
	//if (!(ticks_till_death == 0)) this.Tag("cluster_bullet");
	//if (this.getTickSinceCreated() >= ticks_till_death)
	if (range <= covered_range)
	{
		this.server_Die();
	}
	
	if (this.isInWater()) this.setVelocity(this.get_Vec2f("velocity_before_watur") * 0.4);
	else this.setVelocity(this.get_Vec2f("velocity_before_watur")
		//+ Vec2f(0, 1) * (0.0001f + this.getTickSinceCreated()*0.0f)
		);
	
	if (pos.x < 0.1f or pos.x > (getMap().tilemapwidth * getMap().tilesize) - 0.1f)
	{
		this.server_Die();
		return;
	}
    f32 angle = (this.getVelocity()).Angle();
    this.setAngleDegrees(-angle);
	
    Pierce( this ); //map
	//this.AddForce( Vec2f(0,1) * (0.001f + this.getTickSinceCreated()*0.001f) );
	//shape.SetGravityScale( 0.3f + this.getTickSinceCreated()*0.1f );
}

void Pierce(CBlob @this, CBlob@ blob = null)
{
	Vec2f end;
	CMap@ map = this.getMap();
	Vec2f position = blob is null ? this.getPosition() + this.getVelocity() : blob.getPosition() + blob.getVelocity();

	if (map.rayCastSolidNoBlobs(this.getShape().getVars().oldpos, position, end))
	{
		HitMap(this, end, this.getOldVelocity(), 0.5f, Hitters::arrow);
	}
}

/*
f32 HitBlob( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData )
{
    if (hitBlob !is null)
    {
		// check if shielded
		const bool hitShield = (hitBlob.hasTag("shielded") && blockAttack(hitBlob, velocity, 0.0f));

		// play sound
		if (!hitShield)
		{
			if (hitBlob.hasTag("flesh"))
			{
				this.getSprite().PlaySound( "ArrowHitFlesh.ogg" );
			}
			else
			{
				this.getSprite().PlaySound( "BulletImpact.ogg" );	
			}
		}

        this.server_Die();
    }

	return damage;
}
*/

void HitMap( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, u8 customData )
{
	CMap@ map = this.getMap();
	f32 powe = 40;
	u16 ded = 1;
	if(this.get_u16("rico") < ded)
	{
		Sound::Play("dirt_ricochet_" + XORRandom(4), this.getPosition(), 0.21 + XORRandom(5)*0.1, 1.0f);
		MakeDustParticle(worldPoint, "/DustSmall.png");
		/*
		Vec2f sus_vec;
		{ TileType tile = map.getTile(worldPoint + Vec2f(0, -10)).type;
		if (map.isTileSolid(tile)) sus_vec = Vec2f(0, -powe); }
		
		{ TileType tile = map.getTile(worldPoint + Vec2f(0, 10)).type;
		if (map.isTileSolid(tile)) sus_vec = Vec2f(0, powe); }
		
		{ TileType tile = map.getTile(worldPoint + Vec2f(-10, 0)).type;
		if (map.isTileSolid(tile)) sus_vec = Vec2f(powe, 0); }
		
		{ TileType tile = map.getTile(worldPoint + Vec2f(10, 0)).type;
		if (map.isTileSolid(tile)) sus_vec = Vec2f(-powe, 0); }
		
		sus_vec += this.getVelocity();
		this.set_Vec2f("velocity_before_watur", sus_vec);
		this.setVelocity(sus_vec);
		*/
		this.add_u16("rico", 1);
	}
	else
		this.server_Die();
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	return 0.0f;
}