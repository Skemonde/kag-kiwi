#include "Hitters.as";
#include "KIWI_Hitters.as";
#include "ShieldCommon.as";
#include "ArcherCommon.as";
#include "TeamStructureNear.as";
#include "Knocked.as"
#include "MakeDustParticle.as";
#include "ParticleSparks.as";
#include "WhatShouldProjHit.as";
#include "FirearmVars"

void onInit( CBlob@ this )
{
    CShape@ shape = this.getShape();
	ShapeConsts@ consts = shape.getConsts();
    consts.mapCollisions = false;	 // weh ave our own map collision
	consts.bullet = true;
	this.SetMapEdgeFlags(u8(CBlob::map_collide_none | CBlob::map_collide_left | CBlob::map_collide_right | CBlob::map_collide_nodeath));
	//consts.net_threshold_multiplier = 4.0f;
	this.server_SetTimeToDie( 6 );	
	this.Tag("projectile");
	this.Tag("upon_impact");
	this.set_f32("damage", 1.0f);
	
	// glow
	this.SetLight(true);
	this.SetLightRadius(2.0f);
	this.SetLightColor(SColor(255, 255, 255, 255));
	
	//this.getSprite().setRenderStyle(RenderStyle::additive);
	this.getSprite().ScaleBy(Vec2f(0.65f, 0.65f));
	this.getSprite().SetZ(700);
	FirearmVars vars = FirearmVars();
	vars.BUL_PER_SHOT = 30;
	vars.B_SPREAD = 7;
	vars.B_HITTER = HittersKIWI::shag;
	vars.FIRE_AUTOMATIC = false;
	vars.UNIFORM_SPREAD = false;
	vars.MUZZLE_OFFSET = Vec2f_zero;
	vars.B_SPEED = 4;
	vars.B_SPEED_RANDOM	= 24; 
	vars.B_DAMAGE = 43;
	vars.RANGE = 120*getMap().tilesize; 
	vars.FIRE_SOUND	= "";
	//vars.BULLET_SPRITE = "shotgun_pellet.png";
	vars.BULLET = "bullet";
	vars.BULLET_SPRITE = "cluster";
	this.set("firearm_vars", @vars);
	this.set_Vec2f("start_pos", this.getPosition());
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1 )
{
    if (blob !is null && !this.hasTag("collided"))
    {
		if (doesCollideWithBlob( this, blob )&&!this.hasTag("made a shot"))
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
			
			this.server_Hit( blob, point1, normal, 90+XORRandom(100)*0.01, HittersKIWI::boom);
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
	f32 range = 48;
	f32 covered_range = (pos - this.get_Vec2f("start_pos")).Length();
	this.getSprite().RotateBy(6, Vec2f());
	if (range <= covered_range)
	{
		this.Untag("upon_impact");
		if (!this.hasTag("upon_impact"))
		{
			DoExplosion(this);
		}
	}
	
	//if (this.isInWater()) this.setVelocity(this.get_Vec2f("velocity_before_watur") * 0.4);
	//else this.setVelocity(this.get_Vec2f("velocity_before_watur") * Maths::Max((1-(Maths::Min(covered_range, 1)/range)), 0.1)
	//	+ Vec2f(0, 1) * (0.001f + this.getTickSinceCreated()*0.03f));
	
	if (pos.x < 0.1f or pos.x > (getMap().tilemapwidth * getMap().tilesize) - 0.1f)
	{
		this.server_Die();
		return;
	}
    f32 angle = (this.getVelocity()).Angle();
    this.setAngleDegrees(-angle);
	
    Pierce( this ); //map

	CShape@ shape = this.getShape();
	shape.SetGravityScale( 0.2f + this.getTickSinceCreated()*0.1f );
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

void onDie(CBlob@ this)
{
	this.getSprite().SetEmitSoundPaused(true);
	if (!this.hasTag("upon_impact"))
	{
		//DoExplosion(this);
	}
	else
	{
		Sound::Play("dry_hit", this.getPosition(), 2.0, 1.0f + XORRandom(2)*0.1);
	}
}

void shootGun(const u16 gunID, const f32 aimangle, const u16 hoomanID, const Vec2f pos, const bool altfire = false) 
{
	CRules@ rules = getRules();
	CBitStream params;

	params.write_netid(hoomanID);
	params.write_netid(gunID);
	params.write_f32(aimangle);
	params.write_Vec2f(pos);
	params.write_bool(altfire);
	rules.SendCommand(rules.getCommandID("fireGun"), params);
}

void DoExplosion(CBlob@ this)
{
	if (this.hasTag("made a shot")) return;
	Sound::Play("cluster_bullet_blast", this.getPosition(), 2.0, 0.35f + XORRandom(3)*0.1);
	//standard stuff
	const bool flip = this.isFacingLeft();
	const f32 flip_factor = flip ? -1: 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	Vec2f pos = this.getPosition();
	
	//values that aren't changed from projectile to projectile
	f32 angle = -(this.getVelocity()).Angle();
	CPlayer@ owner = this.getDamageOwnerPlayer();
	if (owner !is null) {
		CBlob@ owner_blob = owner.getBlob();
		if (owner_blob is null) return;
		
		shootGun(this.getNetworkID(), angle, this.getNetworkID(), this.getPosition());
		this.Tag("made a shot");
		this.getSprite().SetVisible(false);
		this.Tag("invincible");
		//this.server_Die();
	}
	
	return;/* 
	for (int counter = 0; counter < bullet_amount; ++counter) {
		CPlayer@ owner = this.getDamageOwnerPlayer();
		if (owner is null) return;
		CBlob@ owner_blob = owner.getBlob();
		if (owner_blob is null) return;
		Vec2f velocity(1,0);
		f32 spread = XORRandom(inaccuracy_angle) * flip_factor - inaccuracy_angle / 2 * flip_factor;
		
		//angle stuff
		f32 bullet_angle = angle + spread;
		
		//offset stuff
		//we change Y so they don't go out the same point and X is different for each proj. for the same reason
		Vec2f bullet_offset = Vec2f(-XORRandom(bullet_amount), (this.hasTag("cluster_bullet")) ? (spread + XORRandom(10)-5)*2 : 0);
		//this is important, ye
		bullet_offset = Vec2f(bullet_offset.x, bullet_offset.y * flip_factor);
		//this is SUPER important
		bullet_offset.RotateBy( bullet_angle );
		
		f32 bullet_speed = 5;
		for (u8 i = 0; i< XORRandom(3)+2; ++i) bullet_speed += XORRandom(2);
		//we want out bullet to go teh same direction it looks in right?
		velocity.RotateBy( bullet_angle );
		//we combine all velocity stuff together
		velocity = velocity * bullet_speed + this.getVelocity();
		
		shootGun(this.getNetworkID(), bullet_angle, owner_blob.getNetworkID(), pos + Vec2f(-bullet_offset.x*flip_factor, bullet_offset.y)); 
	}
	
	for (u8 i = 0; i < 0; ++i)
	{
		CBlob@ bullet_blob = server_CreateBlobNoInit( "pellet" );
		if (bullet_blob !is null)
		{			
			Vec2f velocity(1,0);
			f32 spread = XORRandom(inaccuracy_angle) * flip_factor - inaccuracy_angle / 2 * flip_factor;
			
			//angle stuff
			f32 bullet_angle = angle + angle_flip_factor + spread;
		
			//offset stuff
			//we change Y so they don't go out the same point and X is different for each proj. for the same reason
			Vec2f bullet_offset = Vec2f(-XORRandom(bullet_amount), (this.hasTag("cluster_bullet")) ? (spread + XORRandom(10)-5)*2 : 0);
			//this is important, ye
			bullet_offset = Vec2f(bullet_offset.x, bullet_offset.y * flip_factor);
			//this is SUPER important
			bullet_offset.RotateBy( bullet_angle );
			
			f32 bullet_speed = 5;
			for (u8 i = 0; i< XORRandom(3)+2; ++i) bullet_speed += XORRandom(2);
			//we want out bullet to go teh same direction it looks in right?
			velocity.RotateBy( bullet_angle );
			//we combine all velocity stuff together
			velocity = velocity * bullet_speed + this.getVelocity();
			
			//assigning values to bullet blob
			bullet_blob.setPosition( pos + Vec2f(-bullet_offset.x*flip_factor, bullet_offset.y) );
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
	} */
}

void HitMap( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, u8 customData )
{
	this.server_Die();
}