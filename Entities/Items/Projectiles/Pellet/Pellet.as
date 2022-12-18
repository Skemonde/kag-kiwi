#include "Hitters.as";
#include "HittersKAWI.as";
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
	ShapeConsts@ consts = shape.getConsts();
    consts.mapCollisions = false;	 // weh ave our own map collision
	consts.bullet = true;
	this.SetMapEdgeFlags(u8(CBlob::map_collide_none | CBlob::map_collide_left | CBlob::map_collide_right | CBlob::map_collide_nodeath));
	//this.server_SetTimeToDie( 1.5f );	
	this.Tag("projectile");
	this.set_f32("damage", 1.0f);
	this.set_f32("range", 1.0f);
	
	// glow
	this.SetLight(true);
	this.SetLightRadius(32.0f);
	this.SetLightColor(SColor(255, 255, 240, 210));
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1 )
{
    if (blob !is null && doesCollideWithBlob( this, blob ) && !this.hasTag("collided"))
    {
		if (!solid && !blob.hasTag("flesh") && (blob.getName() != "mounted_bow" || this.getTeamNum() != blob.getTeamNum()))
		{
			return;
		}

		f32 dmg = this.get_f32("damage");
		
		if (blob.hasTag("dead"))
		{
			dmg *= 69;
		}
		
		if (blob.hasTag("player")) Sound::Play("ManHit" + (XORRandom(3) + 1), this.getPosition(), 2.0, 1.0f);
		
		this.server_Hit( blob, point1, normal, dmg, HittersKAWI::bullet_pistol);
		this.server_Hit( blob, point1, normal, 0.2, Hitters::fire);
		f32 force = -2.0f * Maths::Sqrt(blob.getMass()+1);
		blob.AddForce( blob.getVelocity() * force );
		this.server_Die();
	}
}

void onTick( CBlob@ this )
{
	Vec2f pos = this.getPosition();
	f32 ticks_till_death = this.get_f32("range")/this.get_Vec2f("velocity_before_watur").Length();
	//f32 ticks_till_death = 90;
	if (!(ticks_till_death == 0)) this.Tag("cluster_bullet");
	if (this.getTickSinceCreated() >= ticks_till_death)
	{
		this.server_Die();
	}
	
	if (this.isInWater()) this.setVelocity(this.get_Vec2f("velocity_before_watur") * 0.4);
	else this.setVelocity(this.get_Vec2f("velocity_before_watur")* Maths::Max((1-(this.getTickSinceCreated()/Maths::Max(ticks_till_death, 1))) + 0.4, 0.1));
	
	if (pos.x < 0.1f or pos.x > (getMap().tilemapwidth * getMap().tilesize) - 0.1f)
	{
		this.server_Die();
		return;
	}
	
    f32 angle = (this.getVelocity()).Angle();
    Pierce( this ); //map
    this.setAngleDegrees(-angle);

	CShape@ shape = this.getShape();
	shape.SetGravityScale(0);
}

void Pierce( CBlob @this )
{
    CMap@ map = this.getMap();
	Vec2f end;
	if (map.rayCastSolidNoBlobs(this.getShape().getVars().oldpos, this.getPosition() ,end))
	{
		HitMap( this, end, this.getOldVelocity(), 0.5f, Hitters::stab );
	}
}

void HitMap( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, u8 customData )
{
	Sound::Play("dirt_ricochet_" + XORRandom(4), this.getPosition(), 0.21 + XORRandom(5)*0.1, 1.0f);
	MakeDustParticle(worldPoint, "/DustSmall.png");
	this.server_Die();
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	return 0.0f;
}