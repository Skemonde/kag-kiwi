#include "VehicleCommon.as"

// Tank logic 

void onInit( CBlob@ this )
{		
	Vehicle_Setup( this,
				   50.0f, // move speed
				   0.01f,  // turn speed
				   Vec2f(0.0f, 0.0f), // jump out velocity
				   false  // inventory access
				 );
	VehicleInfo@ v;
	if (!this.get( "VehicleInfo", @v )) {
		return;
	}

	/* Vehicle_SetupGroundSound( this, v, "WoodenWheelsRolling", // movement sound
							  1.0f, // movement sound volume modifier   0.0f = no manipulation
							  1.0f // movement sound pitch modifier     0.0f = no manipulation
							); */
	//Vehicle_addWheel( this, v, "WoodenWheels.png", 16, 16, 1, Vec2f(-22.0f,4.0f) );
	//Vehicle_addWheel( this, v, "WoodenWheels.png", 16, 16, 0, Vec2f(-15.0f,10.0f) );
	//Vehicle_addWheel( this, v, "WoodenWheels.png", 16, 16, 0, Vec2f(-5.0f,10.0f) );
	//Vehicle_addWheel( this, v, "WoodenWheels.png", 16, 16, 0, Vec2f(5.0f,10.0f) );
	//Vehicle_addWheel( this, v, "WoodenWheels.png", 16, 16, 0, Vec2f(15.0f,10.0f) );
	//Vehicle_addWheel( this, v, "WoodenWheels.png", 16, 16, 1, Vec2f(22.0f,4.0f) );
	
	this.getSprite().SetZ(-50.0f);
	//this.getShape().SetOffset(Vec2f(0,6));

	//Vec2f massCenter(0, 8);
	//this.getShape().SetCenterOfMassOffset(massCenter);
	//this.set_Vec2f("mass center", massCenter);
	
	// converting
	this.Tag("convert on sit");
	this.Tag("bullet_hits");
	this.Tag("non_pierceable");
	this.Tag("vehicle");

	this.set_f32("map dmg modifier", 2.0f);

	//{
	//	Vec2f[] shape = { Vec2f(  2,  8 ),
	//					  Vec2f(  4, -6 ),
	//					  Vec2f( 22, -6 ),
	//					  Vec2f( 26,  8 ) };
	//	this.getShape().AddShape( shape );
	//}

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
	return Vehicle_doesCollideWithBlob_ground( this, blob );
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