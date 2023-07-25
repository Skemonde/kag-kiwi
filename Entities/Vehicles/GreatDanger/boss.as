#include "VehicleCommon.as"

// Tank logic 

void onInit( CBlob@ this )
{
	CSprite@ sprite = this.getSprite();
	this.getShape().getConsts().transports = true;
	f32 slow_vel = this.getMass()/64;
	Vehicle_Setup( this,
				   slow_vel, // move speed
				   0.01f,  // turn speed
				   Vec2f(0.0f, -3.0f), // jump out velocity
				   true  // inventory access
				 );
	VehicleInfo@ v;
	if (!this.get( "VehicleInfo", @v )) {
		return;
	}

	Vehicle_SetupGroundSound( this, v, "EngineIdle.ogg", // movement sound
							  1.0f, // movement sound volume modifier   0.0f = no manipulation
							  0.4f // movement sound pitch modifier     0.0f = no manipulation
							);
	
	this.getSprite().SetZ(-50.0f);
	
	// converting
	this.Tag("convert on sit");
	this.Tag("bullet_hits");
	this.Tag("non_pierceable");
	this.Tag("vehicle");

	this.set_f32("map dmg modifier", 2.0f);

	{
		Vec2f[] shape = { Vec2f(-13,-21 ),
						  Vec2f( 60,-21 ),
						  Vec2f( 60,-24 ),
						  Vec2f(-13,-24 ) };
		this.getShape().AddShape( shape );
		//0
	}
	{
		Vec2f[] shape = { Vec2f(-16,-21 ),
						  Vec2f(-13,-21 ),
						  Vec2f(-13,-49 ),
						  Vec2f(-16,-49 ) };
		this.getShape().AddShape( shape );
		//1
	}
	{
		Vec2f[] shape = { Vec2f(-17,-49 ),
						  Vec2f( 73,-49 ),
						  Vec2f( 78,-68 ),
						  Vec2f(-17,-68 ) };
		this.getShape().AddShape( shape );
		//2
	}

	this.addCommandID("attach vehicle");
}

void onTick( CBlob@ this )
{	
	const int time = this.getTickSinceCreated();
	if (this.hasAttached() || time < 30) //driver, seat or gunner, or just created
	{
		VehicleInfo@ v;
		if (!this.get( "VehicleInfo", @v )) {
			return;
		}

		// load new item if present in inventory
		Vehicle_StandardControls( this, v );
	}
	else if(time % 30 == 0)
	{
		VehicleInfo@ v;
		if (!this.get( "VehicleInfo", @v )) {
			return;
		}
		Vehicle_StandardControls( this, v ); //just make sure it's updated
	}
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

void Vehicle_onFire( CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 _charge ) {}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("attach vehicle"))
	{
		CBlob@ vehicle = getBlobByNetworkID( params.read_netid() );
		if (vehicle !is null)
		{
			vehicle.server_AttachTo( this, "VEHICLE" );
		}
	}
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return true;
}

void onHealthChange( CBlob@ this, f32 oldHealth )
{
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
	if (blob !is null) {
		TryToAttachVehicle( this, blob );
	}
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	VehicleInfo@ v;
	if (!this.get( "VehicleInfo", @v )) {
		return;
	}
	Vehicle_onAttach( this, v, attached, attachedPoint );
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{
	VehicleInfo@ v;
	if (!this.get( "VehicleInfo", @v )) {
		return;
	}
	Vehicle_onDetach( this, v, detached, attachedPoint );
}