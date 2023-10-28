#include "VehicleCommon.as"

// Tank logic 

void onInit( CBlob@ this )
{
	CSprite@ sprite = this.getSprite();
	this.getShape().SetRotationsAllowed(false);
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
	
	this.getSprite().SetZ(-100.0f);
	
	// converting
	this.Tag("convert on sit");
	this.Tag("bullet_hits");
	this.Tag("non_pierceable");
	this.Tag("vehicle");
	this.Tag("collides_everything");

	this.set_f32("map dmg modifier", 2.0f);

	{
		Vec2f[] shape = { Vec2f(-13,-21 ),
						  Vec2f( 60,-21 ),
						  Vec2f( 60,-24 ),
						  Vec2f(-13,-24 ) };
		//this.getShape().AddShape( shape );
		//0
	}
	{
		Vec2f[] shape = { Vec2f(-16,-21 ),
						  Vec2f(-13,-21 ),
						  Vec2f(-13,-49 ),
						  Vec2f(-16,-49 ) };
		//this.getShape().AddShape( shape );
		//1
	}
	{
		Vec2f[] shape = { Vec2f(-17,-49 ),
						  Vec2f( 73,-49 ),
						  Vec2f( 78,-68 ),
						  Vec2f(-17,-68 ) };
		//this.getShape().AddShape( shape );
		//2
	}
	
	if (getNet().isServer())
	{
		for (int id = 0; id < 2; ++id) {
			CBlob@ blob = server_CreateBlob("bossshape"+(id+1));
			if (blob !is null)
			{
				blob.server_setTeamNum(this.getTeamNum());
				blob.setInventoryName("");
				blob.getShape().getConsts().collideWhenAttached = true;
				blob.getShape().getConsts().transports = true;
				this.server_AttachTo(blob, "SHAPE_"+(id+1));
				this.set_u16("shape_blob_number"+(id+1)+"_id", blob.getNetworkID());
				blob.set_u16("owner_blob_id", this.getNetworkID());
			}
		}
	}

	this.addCommandID("attach vehicle");
}

void onTick( CBlob@ this )
{	
	this.setVelocity(Vec2f(0.5f, 0));
	CMap@ map = getMap();
	Vec2f pos = this.getPosition();
	for (int counter = 0; counter < 15; ++counter) {
		Vec2f target_pos = pos - Vec2f(-13*map.tilesize-this.getVelocity().x, 12*map.tilesize) + Vec2f(0, counter*map.tilesize);
		int hit = 0;
		while (map.isTileSolid(target_pos)&&hit<20) {
		
			map.server_DestroyTile(target_pos, 1.0f);
			
			if (map.isTileBedrock(map.getTile(target_pos).type))
				map.server_SetTile(target_pos, CMap::tile_empty);
				
			++hit;
		}
	}
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

void RemoveAllShapeBlobs(CBlob@ this)
{
	if (!isServer()) return;
	
	for (int id = 0; id < 2; ++id) {
		CBlob@ shape = getBlobByNetworkID(this.get_u16("shape_blob_number"+(id+1)+"_id"));
		if (shape is null) continue;
		shape.server_Die();
	}
}

void onDie(CBlob@ this)
{
	RemoveAllShapeBlobs(this);
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