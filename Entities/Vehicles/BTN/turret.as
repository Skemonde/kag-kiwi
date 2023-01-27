#include "VehicleCommon.as"
#include "MakeBangEffect.as"

// Tank logic 

void onInit( CBlob@ this )
{
	CSprite@ sprite = this.getSprite();
	sprite.SetRelativeZ(16.0f);
	sprite.asLayer().SetIgnoreParentFacing(true);
	
	CSpriteLayer@ cannon = sprite.addSpriteLayer("cannon", "cannon.png", 12, 7);
	if (cannon !is null)
	{
		cannon.SetOffset(Vec2f(-20, 1.5));
		cannon.SetRelativeZ(-1.0f);
		cannon.SetVisible(true);
	}
	
	// converting
	this.Tag("tank");
	this.Tag("convert on sit");
	this.set_bool("facingLeft", false);
}

void onTick( CBlob@ this )
{	
	CSprite@ sprite = this.getSprite();
	f32 vehicle_angle = (getBlobByNetworkID(this.get_u16("tank_id")) !is null ? getBlobByNetworkID(this.get_u16("tank_id")).getAngleDegrees() : 0);
	
	const int time = this.getTickSinceCreated();
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PILOT");
	if (ap !is null)
	{
		CSpriteLayer@ cannon = sprite.getSpriteLayer("cannon");
		bool facingLeft = this.get_bool("facingLeft");
		ap.SetKeysToTake(key_action1);
		//if (isServer())
		CBlob@ pilot = ap.getOccupied();
		if (pilot !is null)
		{
			cannon.ResetTransform();
			if (getBlobByNetworkID(this.get_u16("tank_id")) !is null)
			{
				Vec2f mousePos = pilot.getAimPos();
				if (mousePos.x < this.getPosition().x)
				{
					facingLeft = true;
				}
				else if (mousePos.x > this.getPosition().x)
				{
					facingLeft = false;
				}
			}
			this.getSprite().asLayer().SetFacingLeft(facingLeft);
			pilot.SetFacingLeft(facingLeft);
			pilot.setAngleDegrees(vehicle_angle);
		}
		else
		{
			this.SetFacingLeft(facingLeft);
			return;
			print("пилот лохfdfd");
		}
		this.set_bool("facingLeft", facingLeft);
		
		const bool flip = this.get_bool("facingLeft");
		const f32 flip_factor = flip ? -1 : 1;
		const u16 angle_flip_factor = flip ? 180 : 0;
		
		const f32 angle = getAimAngle(this, pilot);
		const f32 clampedAngle = (Maths::Clamp(angle, -30, 15) * flip_factor);
		
		u16 interval = this.get_u16("interval");
		if (interval > 0)
		interval--;
		if (interval == 0)
		{
			CBlob@ mogus = getBlobByNetworkID(this.get_u16("tank_id"));
			if (ap.isKeyPressed(key_action1) || this.hasTag("we_shootin"))
			{
				if(isClient())
					Sound::Play("handgrenade_blast", this.getPosition(), 2.0, 0.35f + XORRandom(3)*0.1);
					//Sound::Play("bombita_explode", this.getPosition(), 1.0, 0.5f + (XORRandom(10)-5)*0.01);
				Shoot( this, clampedAngle);
				if (mogus !is null)
					mogus.AddForceAtPosition(Vec2f(-3*flip_factor, -200).RotateBy(vehicle_angle), mogus.getPosition() + Vec2f(100*flip_factor, 5));
				interval = 30;
			}
		}
		this.set_u16("interval", interval);

		cannon.RotateBy(clampedAngle, Vec2f(10 * flip_factor, 0.5));
	}
	else
		print("точка пилота лохsdsd");
}

void Shoot (CBlob@ this, f32 angle)
{
	const bool flip = this.get_bool("facingLeft");
	const f32 flip_factor = flip ? -1 : 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	
	f32 inaccuracy_angle = 4;
	f32 proj_amount = 1;
	f32 speed = 30;
	f32 damage = 4;
	f32 range = 640;
	f32 vehicle_angle = (getBlobByNetworkID(this.get_u16("tank_id")) !is null ? getBlobByNetworkID(this.get_u16("tank_id")).getAngleDegrees() : 0);
	
	MakeBangEffect(this, "foom");
	
	for (u8 i = 0; i < proj_amount; ++i)
	{
		if (isServer())
		{
			CBlob@ bullet_blob = server_CreateBlobNoInit( "grenade" );
			if (bullet_blob !is null)
			{			
				Vec2f velocity(1,0);
				f32 spread = this.hasTag("UniformSpread")
					? (- inaccuracy_angle / 2 + inaccuracy_angle/(proj_amount-1)*i)*flip_factor
					: XORRandom(inaccuracy_angle) * flip_factor - inaccuracy_angle / 2 * flip_factor;
				
				//angle stuff
				f32 bullet_angle = angle + angle_flip_factor + spread
					+ vehicle_angle;
			
				//offset stuff
				Vec2f bullet_offset = Vec2f(30 * flip_factor, 1.5);
				bullet_offset.RotateBy( bullet_angle + angle_flip_factor, Vec2f(10 * flip_factor, 0.5) );
				
				f32 random_speed = XORRandom(speed/4)-speed/8;
				
				f32 bullet_speed = speed + (this.hasTag("UniformSpeed") ? 0 : random_speed);
				//we want out bullet to go teh same direction it looks in right?
				velocity.RotateBy( bullet_angle );
				//we combine all velocity stuff together
				velocity = velocity * bullet_speed + this.getVelocity();
				
				//assigning values to bullet blob
				bullet_blob.setPosition( this.getPosition() + bullet_offset );
				//this.set_Vec2f("laser_offset", this.getPosition() + offset);
				//this.set_f32("laser_angle", angle + angle_flip_factor);
				bullet_blob.setVelocity( velocity );
				bullet_blob.IgnoreCollisionWhileOverlapped( this );
				//bullet_blob.SetDamageOwnerPlayer( holder.getPlayer() );
				bullet_blob.server_setTeamNum( this.getTeamNum() );
				
				//we do assign some values after Init to rewrite default ones blob got on Init ?_?
				bullet_blob.Init();
				bullet_blob.set_Vec2f("velocity_before_watur",  velocity );
				//we share 80 hearts of damage between our projectiles in this case
				bullet_blob.set_f32("damage", damage);
				bullet_blob.set_f32("range", range);
				bullet_blob.set_Vec2f("start_pos", this.getPosition() + bullet_offset);
				bullet_blob.set_u16("death_timer", 2);
			}
		}
	}
	Vec2f knockback = Vec2f(-12 * flip_factor,0).RotateBy(angle + vehicle_angle, Vec2f_zero ); //this rotates vector
	CSpriteLayer@ cannon = this.getSprite().getSpriteLayer("cannon");
	cannon.TranslateBy(knockback);
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	//f(!Vehicle_AddFlipButton( this, caller))
	//	Vehicle_AddAttachButton( this, caller);
}

bool Vehicle_canFire( CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue )
{
	return false;
}

void Vehicle_onFire( CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 _charge )
{
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return Vehicle_doesCollideWithBlob_ground( this, blob );
}

void onHealthChange( CBlob@ this, f32 oldHealth )
{
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
	//if (blob !is null) {
	//	TryToAttachVehicle( this, blob );
	//}
}

f32 getAimAngle( CBlob@ this, CBlob@ holder, Vec2f muzzle_offset = Vec2f(-69, -69) )
{
	const bool flip = this.isFacingLeft();
	const f32 flip_factor = flip ? -1: 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	const Vec2f shoulder_joint = Vec2f(-3 * flip_factor, -3);
	
	//FirearmVars@ vars;
	//this.get("firearm_vars", @vars);
	
	// находим координату дула пушки
	muzzle_offset =
		// условие...
		(muzzle_offset == Vec2f(-69, -69)
			// ...верно?
			? Vec2f(flip_factor*this.get_Vec2f("gun_trans").x*0,
				(this.get_Vec2f("gun_trans").y))//+vars.MUZZLE_OFFSET.y))
			// если нет, то используем параметр, который получили при вызове функции
			: muzzle_offset);
	
	// вращаем конец ствола пушки вокруг плеча персонажа через угол между курсором и этим самым плечом
	// но из-за этого не выходит избежать погрешности, пуля отходит от направления, но это едва заметно :P
	// получи пушку "uzi" и убедись, как здорово работает эта формула!!
	Vec2f pos = this.getPosition() + muzzle_offset.RotateBy(
	constrainAngle(angle_flip_factor-((holder.getAimPos() - holder.getPosition()).Angle())), shoulder_joint);
	
 	Vec2f aimvector = holder.getAimPos() - pos;
	f32 angle = aimvector.Angle() + this.getAngleDegrees();
    return constrainAngle(angle_flip_factor-(angle+flip_factor))*flip_factor;
}

f32 constrainAngle(f32 x)
{
	x = (x + 180) % 360;
	if (x < 0) x += 360;
	return x - 180;
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	VehicleInfo@ v;
	if (!this.get( "VehicleInfo", @v )) {
		return;
	}
	Vehicle_onAttach( this, v, attached, attachedPoint );
	if (attached !is null)
	{
		//if (attached.hasTag("flesh"))
		{
			attached.getSprite().SetRelativeZ(-100);
		}
	}
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{
	VehicleInfo@ v;
	if (!this.get( "VehicleInfo", @v )) {
		return;
	}
	Vehicle_onDetach( this, v, detached, attachedPoint );
	if (detached !is null)
	{
		detached.getSprite().SetRelativeZ(0);
	}
}