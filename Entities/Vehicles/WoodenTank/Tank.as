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

	Vehicle_SetupGroundSound( this, v, "WoodenWheelsRolling", // movement sound
							  1.0f, // movement sound volume modifier   0.0f = no manipulation
							  1.0f // movement sound pitch modifier     0.0f = no manipulation
							);
	Vehicle_addWheel( this, v, "WoodenWheels.png", 16, 16, 1, Vec2f(-22.0f,4.0f) );
	Vehicle_addWheel( this, v, "WoodenWheels.png", 16, 16, 0, Vec2f(-15.0f,10.0f) );
	Vehicle_addWheel( this, v, "WoodenWheels.png", 16, 16, 0, Vec2f(-5.0f,10.0f) );
	Vehicle_addWheel( this, v, "WoodenWheels.png", 16, 16, 0, Vec2f(5.0f,10.0f) );
	Vehicle_addWheel( this, v, "WoodenWheels.png", 16, 16, 0, Vec2f(15.0f,10.0f) );
	Vehicle_addWheel( this, v, "WoodenWheels.png", 16, 16, 1, Vec2f(22.0f,4.0f) );
	
	this.getSprite().SetZ(-50.0f);
	this.getShape().SetOffset(Vec2f(0,6));

	Vec2f massCenter(0, 8);
	this.getShape().SetCenterOfMassOffset(massCenter);
	this.set_Vec2f("mass center", massCenter);
	
	// converting
	this.Tag("convert on sit");
	this.Tag("bullet_hits");
	this.Tag("non_pierceable");
	this.Tag("vehicle");

	this.set_f32("map dmg modifier", 2.0f);

	{
		Vec2f[] shape = { Vec2f(  2,  8 ),
						  Vec2f(  4, -6 ),
						  Vec2f( 22, -6 ),
						  Vec2f( 26,  8 ) };
		this.getShape().AddShape( shape );
	}

	this.addCommandID("attach vehicle");
	if (getNet().isServer())
	{
		CBlob@ blob = server_CreateBlob("donotspawnthiswithacommand_bt42turret");
		if (blob !is null)
		{
			blob.server_setTeamNum(this.getTeamNum());
			blob.setInventoryName(this.getInventoryName() + "'s Turret");
			blob.getShape().getConsts().collideWhenAttached = true;
			this.server_AttachTo(blob, "TURRET");
			this.set_u16("turret_id", blob.getNetworkID());
			blob.set_u16("tank_id", this.getNetworkID());
		}
		CBlob@ blob2 = server_CreateBlob("donotspawnthiswithacommand_bt42turret");
		if (blob2 !is null)
		{
			blob2.server_setTeamNum(this.getTeamNum());
			blob2.setInventoryName(this.getInventoryName() + "'s Turret");
			blob2.getShape().getConsts().collideWhenAttached = true;
			this.server_AttachTo(blob2, "TURRET2");
			this.set_u16("turret_id", blob2.getNetworkID());
			blob2.set_u16("tank_id", this.getNetworkID());
			blob2.set_bool("turning", false);
		}
	}
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
	const bool FLIP = this.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	CSprite@ sprite = this.getSprite();
	//this.setAngleDegrees(this.getAngleDegrees()+(this.getVelocity()).Length()*-3*FLIP_FACTOR);
	//sprite.ResetTransform();
	//sprite.RotateBy((this.getVelocity()).Length()*-3*FLIP_FACTOR, Vec2f());
	uint sprites = sprite.getSpriteLayerCount();
	for (uint spritelayer_index = 0; spritelayer_index < sprites; spritelayer_index++) {
		CSpriteLayer@ wheel = sprite.getSpriteLayer(spritelayer_index);
		if (wheel is null) continue;
		if (wheel.name.substr(0, 2) != "!w") continue;
		if (!this.exists("!w"+spritelayer_index+"offset"))
			this.set_Vec2f("!w"+spritelayer_index+"offset", wheel.getOffset());
		
		Vec2f wheel_init_offset = this.get_Vec2f("!w"+spritelayer_index+"offset");
		Vec2f wheel_worldpos = this.getPosition()+Vec2f(-wheel_init_offset.x*FLIP_FACTOR, wheel_init_offset.y).RotateBy(this.getAngleDegrees());
		Vec2f hitPos;
		
		HitInfo@[] hitInfos;
		bool blobHit = getMap().getHitInfosFromRay(wheel_worldpos, 90+this.getAngleDegrees(), 40, this, @hitInfos);
		for (int index = 0; index < hitInfos.size(); ++index) {
			HitInfo@ hit = hitInfos[index];
			CBlob@ target = @hit.blob;
			if (target !is null && doesCollideWithBlob(this, target)) {
				hitPos = hit.hitpos;
				break;
			}
			else {
				hitPos = hit.hitpos;
				//break;
			}
		}
		f32 length = Maths::Min(11, (hitPos - wheel_worldpos).Length());
		
		wheel.SetOffset(wheel_init_offset+Vec2f(0, length-7));
		//this.setPosition(Vec2f(this.getPosition().x, this.getPosition().y-length));
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
	const f32 threshold = this.getInitialHealth() * 0.25f;	
	
	if (this.getHealth() < threshold && oldHealth >= threshold)
	{	
		CSpriteLayer@ wheel = this.getSprite().getSpriteLayer("!w 2");
		if (wheel !is null)
			wheel.SetVisible( false );

		makeGibParticle( "Entities/Vehicles/Common/WoodenWheels.png", 
			this.getPosition()+wheel.getOffset(), this.getVelocity() + getRandomVelocity( 90, 5, 80 ), 
			0, 0, Vec2f (16,16), 2.0f, 20, "/material_drop", 0 );

	}
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
	if (blob !is null) {
		TryToAttachVehicle( this, blob );
	}
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{
}