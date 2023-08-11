#include "VehicleCommon"
#include "KIWI_Hitters"
#include "FirearmVars"

// Tank logic 
const string[] wheel_names =
{
	"wheel_big",
	"wheel_smaller",
	"wheel_smaller",
	"wheel_smaller",
	"wheel_smaller",
	"wheel_smallest",
	"wheel_smallest",
	"wheel_straw"
};

void onInit( CBlob@ this )
{
	CSprite@ sprite = this.getSprite();
	f32 slow_vel = this.getMass()/5;
	Vehicle_Setup( this,
				   slow_vel, // move speed
				   0.2f,  // turn speed
				   Vec2f(0.0f, -4.0), // jump out velocity
				   true  // inventory access
				 );
	VehicleInfo@ v;
	if (!this.get( "VehicleInfo", @v )) {
		return;
	}
	
	//this.set_u8("amount_of_dead_wheels", 0);
	this.Tag("vehicle");
	this.Tag("ground_vehicle");
	this.Tag("tank");
	this.Tag("non_pierceable");

	Vehicle_SetupGroundSound( this, v, "EngineIdle.ogg", // movement sound
							  1.0f, // movement sound volume modifier   0.0f = no manipulation
							  0.6f // movement sound pitch modifier     0.0f = no manipulation
							);
							
	Vehicle_addWheel( this, v, "arty_wheel.png", 15, 15, 0, Vec2f(-21.0f, 1.0f) );
	Vehicle_addWheel( this, v, "arty_wheel.png", 15, 15, 0, Vec2f(7.0f, 1.0f) );
							
	Vec2f sprite_offset = sprite.getOffset();
	
	sprite.SetZ(-10.0f);
	CSpriteLayer@ wheel1 = this.getSprite().getSpriteLayer("!w 0");
	CSpriteLayer@ wheel2 = this.getSprite().getSpriteLayer("!w 1");
	if (wheel1 !is null && wheel2 !is null) {
		wheel1.SetRelativeZ(-30.0f);
		wheel2.SetRelativeZ(-30.0f);
	}
	
	Vec2f turret_offset = Vec2f(20, -6);
	Vec2f turret_dims = Vec2f(32, 12);
	Vec2f[] upper_part =
	{
		Vec2f(turret_offset.x-turret_dims.x/2, 			turret_offset.y-turret_dims.y/2),
		Vec2f(turret_offset.x+turret_dims.x/2, 			turret_offset.y-turret_dims.y/2),
		Vec2f(turret_offset.x+turret_dims.x/2, 			turret_offset.y+turret_dims.y/2),
		Vec2f(turret_offset.x-turret_dims.x/2, 			turret_offset.y+turret_dims.y/2)
	};
	this.getShape().AddShape(upper_part);
	
	Vec2f massCenter(0, 0);
	this.getShape().SetCenterOfMassOffset(massCenter);
	this.set_Vec2f("mass center", massCenter);
	
	this.set_f32("hit dmg modifier", 20.0f);
	this.set_f32("map dmg modifier", 10.0f);
	
	this.addCommandID("attach vehicle");
	
	if (getNet().isServer()&&false)
	{
		CBlob@ blob = server_CreateBlob("tripod");
		if (blob !is null)
		{
			blob.server_setTeamNum(this.getTeamNum());
			blob.setInventoryName(this.getInventoryName() + "'s Turret");
			blob.getShape().getConsts().collideWhenAttached = true;
			this.server_AttachTo(blob, "FORTRIPOD");
			this.set_u16("turret_id", blob.getNetworkID());
			blob.set_u16("tank_id", this.getNetworkID());
		}
	}
}

void onTick( CBlob@ this )
{	
	CSprite@ sprite = this.getSprite();
	const bool flip = this.isFacingLeft();
	const f32 flip_factor = flip ? -1 : 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	//this.setAngleDegrees(0);

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
	//if(!Vehicle_AddFlipButton( this, caller))
	//	Vehicle_AddAttachButton( this, caller);
}

void onRender(CSprite@ this)
{
}

bool Vehicle_canFire( CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue )
{
	return false;
}

void Vehicle_onFire( CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 _charge ) {}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	//return Vehicle_doesCollideWithBlob_ground( this, blob );
	//print("speed"+(this.getVelocity().Length()));
	return ((blob.getTeamNum() != this.getTeamNum() && this.getVelocity().Length() > 0.2) || blob.hasTag("vehicle") || blob.hasTag("dead"));
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

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return false;
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
		if (attached.hasTag("flesh"))
		{
			//attached.Tag("isInVehicle");
			this.getSprite().PlaySound("EngineStart.ogg");
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
		detached.Untag("isInVehicle");
		this.getSprite().PlaySound("EngineStop.ogg");
	}
}