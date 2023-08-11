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
	Vec2f sprite_offset = sprite.getOffset();
	f32 slow_vel = this.getMass()/5;
	Vehicle_Setup( this,
				   slow_vel, // move speed
				   1.7f,  // turn speed
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
							
	//Vehicle_addWheel( this, v, "rubber_wheel.png", 12, 12, 0, Vec2f(-22.0f, 2.0f) );
	//Vehicle_addWheel( this, v, "rubber_wheel.png", 12, 12, 0, Vec2f(-4.0f, 2.0f) );
	//Vehicle_addWheel( this, v, "rubber_wheel.png", 12, 12, 0, Vec2f(8.0f, 2.0f) );
	Vehicle_addWheel( this, v, "rubber_wheel.png", 12, 12, 0, Vec2f(sprite_offset.x-16.0f, sprite_offset.y+11.0f) );
	Vehicle_addWheel( this, v, "rubber_wheel.png", 12, 12, 0, Vec2f(sprite_offset.x+2.0f, sprite_offset.y+11.0f) );
	Vehicle_addWheel( this, v, "rubber_wheel.png", 12, 12, 0, Vec2f(sprite_offset.x+13.0f, sprite_offset.y+11.0f) );
	
	sprite.SetRelativeZ(10.0f);
	CSpriteLayer@ wheel1 = this.getSprite().getSpriteLayer("!w 0");
	CSpriteLayer@ wheel2 = this.getSprite().getSpriteLayer("!w 1");
	CSpriteLayer@ wheel3 = this.getSprite().getSpriteLayer("!w 2");
	if (wheel1 !is null && wheel2 !is null && wheel3 !is null) {
		wheel1.SetRelativeZ(sprite.getRelativeZ()+1);
		wheel2.SetRelativeZ(sprite.getRelativeZ()+1);
		wheel3.SetRelativeZ(sprite.getRelativeZ()+1);
	}
	
	{
		Vec2f shape_offset = Vec2f(3,8);
		Vec2f[] shape = { Vec2f(  6,-21 )+shape_offset,
						  Vec2f( 40,-21 )+shape_offset,
						  Vec2f( 36,-24 )+shape_offset,
						  Vec2f(  6,-24 )+shape_offset };
		this.getShape().AddShape( shape );
		//0
	}
	{
		Vec2f shape_offset = Vec2f(3,33);
		Vec2f[] shape = { Vec2f(  0,-21 )+shape_offset,
						  Vec2f( 30,-21 )+shape_offset,
						  Vec2f( 30,-24 )+shape_offset,
						  Vec2f(  0,-24 )+shape_offset };
		//this.getShape().AddShape( shape );
		//0
	}
	{
		Vec2f shape_offset = Vec2f(0,0);
		Vec2f[] shape = { Vec2f(  26.0,	8.0 )+shape_offset,
						  Vec2f(  46.0,	-10.0 )+shape_offset,
						  Vec2f(  55.0,	0.0 )+shape_offset,
						  Vec2f(  40.0,	12.0 )+shape_offset,
						  Vec2f(  26.0,	12.0 )+shape_offset };
		this.getShape().AddShape( shape );
		//0
	}
	
	Vec2f massCenter(6, -4);
	this.getShape().SetCenterOfMassOffset(massCenter);
	this.set_Vec2f("mass center", massCenter);
	
	this.set_f32("hit dmg modifier", 20.0f);
	this.set_f32("map dmg modifier", 10.0f);
	this.set_Vec2f("original_offset", sprite.getOffset());
	
	this.addCommandID("attach vehicle");
	this.addCommandID("unload guys");
}

void onTick( CBlob@ this )
{	
	CSprite@ sprite = this.getSprite();
	const bool flip = this.isFacingLeft();
	const f32 flip_factor = flip ? -1 : 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	f32 speed = 4;
	f32 jumping_value = (getGameTime()%speed)/(speed/2)-0.5;
	if (this.getVelocity().Length()>0.2) {
		sprite.SetOffset(Vec2f(this.get_Vec2f("original_offset").x,this.get_Vec2f("original_offset").y
			+jumping_value));
	}
	else
		sprite.SetOffset(this.get_Vec2f("original_offset"));
	//this.setAngleDegrees(0);
	
	Vec2f APC_center = this.getPosition()+Vec2f((-2)*flip_factor, -12).RotateBy(this.getAngleDegrees());
	CBlob@[] guys_inside;
	if (getMap().getBlobsInRadius(APC_center, this.getRadius()*0.55, guys_inside)) {
		for (int counter = 0; counter < guys_inside.length(); ++counter) {
			CBlob@ guy_inside = guys_inside[counter];
			if (guy_inside.getTeamNum() == this.getTeamNum() && guy_inside.getName() != "brsn" && this.getVelocity().Length()>0.5 && guy_inside.hasTag("player") && guy_inside.getHealth() > 1/2) {
				guy_inside.setPosition(APC_center);
				//guy_inside.getSprite().SetRelativeZ(-30);
			}
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
	return !blob.isOnGround() || blob.getTeamNum() != this.getTeamNum() || !blob.isKeyPressed(key_down);
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
	if (attached !is null)
	{
		if (attached.hasTag("flesh"))
		{
			attached.Tag("isInVehicle");
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