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
	ShapeConsts@ consts = shape.getConsts();
    consts.mapCollisions = false;	 // weh ave our own map collision
	consts.bullet = true;
	this.SetMapEdgeFlags(u8(CBlob::map_collide_none | CBlob::map_collide_left | CBlob::map_collide_right | CBlob::map_collide_nodeath));
	//consts.net_threshold_multiplier = 4.0f;
	//this.server_SetTimeToDie( 0.5f );	
	this.Tag("projectile");
	//this.Tag("upon_impact");
	this.set_f32("damage", 1.0f);
	
	// glow
	this.SetLight(true);
	this.SetLightRadius(32.0f);
	this.SetLightColor(SColor(255, 255, 240, 210));
	
	this.getSprite().setRenderStyle(RenderStyle::additive);
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1 )
{
    if (blob !is null && !this.hasTag("collided"))
    {
		if (doesCollideWithBlob( this, blob ))
		{
			//if (!solid && !blob.hasTag("flesh") && (blob.getName() != "mounted_bow" || this.getTeamNum() != blob.getTeamNum()))
			//{
			//	return;
			//}
	
			f32 dmg = this.get_f32("damage");
			
			if (blob.hasTag("dead"))
			{
				dmg *= 69;
			}
			
			//u16 sound_num = XORRandom(3) + 1;
			if (blob.hasTag("player")) blob.getSprite().PlaySound( "ManHit" + (XORRandom(3) + 1), 2.0, 1.0 );
			
			this.server_Hit( blob, point1, normal, dmg, HittersKIWI::bullet_pistol);
			//f32 force = -2.0f * Maths::Sqrt(blob.getMass()+1);
			//blob.AddForce( blob.getVelocity() * force );
			this.server_Die();
		}
		else if (solid) this.server_Die();
	}
}

void onTick( CBlob@ this )
{
	Vec2f pos = this.getPosition();
	f32 range = this.get_f32("range");
	f32 covered_range = (pos - this.get_Vec2f("start_pos")).Length();
	if (range <= covered_range)
	{
		//this.Untag("upon_impact");
		this.server_Die();
	}
	
	if (this.isInWater()) this.setVelocity(this.get_Vec2f("velocity_before_watur") * 0.4);
	else this.setVelocity(this.get_Vec2f("velocity_before_watur") * Maths::Max((1-(Maths::Min(covered_range, 1)/range)), 0.1)
		+ Vec2f(0, 1) * (0.001f + this.getTickSinceCreated()*0.03f));
	
	if (pos.x < 0.1f or pos.x > (getMap().tilemapwidth * getMap().tilesize) - 0.1f)
	{
		this.server_Die();
		return;
	}
    f32 angle = (this.getVelocity()).Angle();
    this.setAngleDegrees(-angle);
	
    Pierce( this ); //map

	//CShape@ shape = this.getShape();
	////shape.SetGravityScale( 0.2f + this.getTickSinceCreated()*0.1f );
	//shape.SetGravityScale(0);
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

void onDie(CBlob@ this)
{
	DoExplosion(this);
	Sound::Play("handgrenade_blast", this.getPosition(), 2.0, 0.35f + XORRandom(3)*0.1);
}

void DoExplosion(CBlob@ this)
{
	if (this is null) return;
	//standard stuff
	const bool flip = this.isFacingLeft();
	const f32 flip_factor = flip ? -1: 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	Vec2f pos = this.getPosition();
	
	//values that aren't changed from projectile to projectile
	f32 inaccuracy_angle = 10;	
	u16 bullet_amount = this.get_f32("damage");
	f32 angle = -(this.getVelocity()).Angle();
	
	for (u8 i = 0; i < bullet_amount; ++i)
	{
		CBlob@ bullet_blob = server_CreateBlobNoInit( "shrapnel" );
		if (bullet_blob !is null)
		{			
			Vec2f velocity(1,0);
			f32 spread = XORRandom(inaccuracy_angle) * flip_factor - inaccuracy_angle / 2 * flip_factor;
			
			//angle stuff
			f32 bullet_angle = 360/bullet_amount*i;
			
			f32 bullet_speed = 5;
			for (u8 i = 0; i< XORRandom(3)+2; ++i) bullet_speed += XORRandom(2);
			//we want out bullet to go teh same direction it looks in right?
			velocity.RotateBy( bullet_angle );
			//we combine all velocity stuff together
			velocity = velocity * bullet_speed + this.getVelocity();
			
			//assigning values to bullet blob
			bullet_blob.setPosition( pos );
			bullet_blob.setVelocity( velocity );
			bullet_blob.server_setTeamNum( this.getTeamNum() );
			bullet_blob.IgnoreCollisionWhileOverlapped( this );
            bullet_blob.SetDamageOwnerPlayer( this.getPlayer() );
			
			//we do assign some values after Init to rewrite default ones blob got on Init ?_?
			bullet_blob.Init();
			bullet_blob.set_Vec2f("velocity_before_watur",  velocity );
			//we share 80 hearts of damage between our projectiles in this case
			bullet_blob.set_f32("damage", 80/bullet_amount);
			bullet_blob.set_f32("range", 512);
			bullet_blob.set_Vec2f("start_pos", this.get_Vec2f("start_pos") );
		}
	}
}

void HitMap( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, u8 customData )
{
	this.server_Die();
}