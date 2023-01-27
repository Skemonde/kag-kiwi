#include "VehicleCommon.as"

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
	Vehicle_Setup( this,
				   52.0f, // move speed
				   1.0f,  // turn speed
				   Vec2f(0.0f, -4.0f), // jump out velocity
				   false  // inventory access
				 );
	VehicleInfo@ v;
	if (!this.get( "VehicleInfo", @v )) {
		return;
	}
	
	//this.set_u8("amount_of_dead_wheels", 0);
	this.Tag("tank");

	Vehicle_SetupGroundSound( this, v, "TankEngine.ogg", // movement sound
							  2.0f, // movement sound volume modifier   0.0f = no manipulation
							  0.3f // movement sound pitch modifier     0.0f = no manipulation
							);
							
	Vec2f sprite_offset = sprite.getOffset();
	Vec2f wheel_offset = Vec2f(-4 + sprite_offset.x, sprite.getOffset().y);
	{
		Vehicle_addWheel( this, v, wheel_names[0], 13, 13, 0, Vec2f(-21.5f, 5.5f) + wheel_offset );
		
		Vehicle_addWheel( this, v, wheel_names[1], 8, 8, 0, Vec2f(14.0f, 15.0f) + wheel_offset );
		Vehicle_addWheel( this, v, wheel_names[2], 8, 8, 0, Vec2f(7.0f, 15.0f) + wheel_offset );
		Vehicle_addWheel( this, v, wheel_names[3], 8, 8, 0, Vec2f(-3.0f, 15.0f) + wheel_offset );
		Vehicle_addWheel( this, v, wheel_names[4], 8, 8, 0, Vec2f(-11.0f, 15.0f) + wheel_offset );
		
		Vehicle_addWheel( this, v, wheel_names[5], 5, 5, 0, Vec2f(9.5f, 4.5f) + wheel_offset );
		Vehicle_addWheel( this, v, wheel_names[6], 5, 5, 0, Vec2f(-7.5f, 3.5f) + wheel_offset );
		
		Vehicle_addWheel( this, v, wheel_names[7], 16, 16, 0, Vec2f(25.0f, 6.0f) + wheel_offset );
	}
	
	sprite.SetZ(-50.0f);
	
	CSpriteLayer@ tracks = sprite.addSpriteLayer("tracks", "tracks.png", 64, 40, this.getTeamNum(), 0);
	if (tracks !is null)
	{
		tracks.addAnimation("default", 3, true);
		int[] frames = { 0, 1, 2, 3, 4, 5 };
		tracks.animation.AddFrames(frames);
		tracks.SetRelativeZ(11.0f);
		tracks.SetOffset(sprite.getOffset());
	}
	
	CSpriteLayer@ upper_body = sprite.addSpriteLayer("upper_body", "upper_body.png", 64, 40, this.getTeamNum(), 0);
	if (upper_body !is null)
	{
		upper_body.SetRelativeZ(15.0f);
		upper_body.SetOffset(sprite.getOffset());
	}
	
	CSpriteLayer@ shovel = sprite.addSpriteLayer("shovel", "shovel.png", 18, 8, this.getTeamNum(), 0);
	if (shovel !is null)
	{
		shovel.SetRelativeZ(16.0f);
		shovel.SetOffset(sprite.getOffset() + Vec2f(5, -7));
	}
	
	CSpriteLayer@ flag = sprite.addSpriteLayer("flag", "../Base/Entities/Vehicles/Ballista/Ballista.png", 32, 32);
	if (flag !is null)
	{
		flag.addAnimation("default", 3, true);
		int[] frames = { 15, 14, 13 };
		flag.animation.AddFrames(frames);
		flag.SetRelativeZ(-2.0f);
		flag.SetOffset(sprite.getOffset() + Vec2f(29, -25));
	}

	Vec2f massCenter(0, 0);
	this.getShape().SetCenterOfMassOffset(massCenter);
	this.set_Vec2f("mass center", massCenter);
	
	this.set_f32("hit dmg modifier", 20.0f);
	this.set_f32("map dmg modifier", 100.0f);
	
	{
		Vec2f[] upper_part_of_upper_body =
		{ 
			Vec2f(  7,   11 ),
			Vec2f(  27,   4 ),
			Vec2f(  41,   4 ),
			Vec2f(  53,  12 ),
			Vec2f(  60,  17 ),
			Vec2f(   3,  23 )
		};
		this.getShape().AddShape( upper_part_of_upper_body );
	}
	{
		Vec2f[] turret =
		{
			Vec2f(  18,   4 ),
			Vec2f(  18, -8 ),
			Vec2f(  50,   4 ),
			Vec2f(  50, -8 )
		};
		this.getShape().AddShape( turret );
	}

	this.addCommandID("attach vehicle");
	
	if (getNet().isServer())
	{
		CBlob@ blob = server_CreateBlob("donotspawnthiswithacommand_btnturret");
		if (blob !is null)
		{
			blob.server_setTeamNum(this.getTeamNum());
			blob.setInventoryName(this.getInventoryName() + "'s Turret");
			//blob.getShape().getConsts().collideWhenAttached;
			this.server_AttachTo(blob, "TURRET");
			this.set_u16("turret_id", blob.getNetworkID());
			blob.set_u16("tank_id", this.getNetworkID());
		}
	}
	if (getNet().isServer())
	{
		CBlob@ blob = server_CreateBlob("flashlight_light");
		if (blob !is null)
		{
			blob.server_setTeamNum(this.getTeamNum());
			this.server_AttachTo(blob, "LIGHT");
			this.set_u16("light_id", blob.getNetworkID());
		}
	}
}

void onTick( CBlob@ this )
{	
	CSprite@ sprite = this.getSprite();
	const bool flip = this.isFacingLeft();
	const f32 flip_factor = flip ? -1 : 1;
	const u16 angle_flip_factor = flip ? 180 : 0;

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
	CSpriteLayer@ flag = sprite.getSpriteLayer("flag");
	CSpriteLayer@ tracks = sprite.getSpriteLayer("tracks");
	u8 moving_formula = (Maths::Abs(this.getVelocity().x) > 0.1 ? 5-Maths::Floor(Maths::Abs(this.getVelocity().x*2)) : 0);
	if (flag !is null)
	{
		flag.animation.time = moving_formula;
	}
	if (tracks !is null)
	{
		tracks.animation.time = moving_formula;
	}
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("DRIVER");
	if (ap !is null)
	{
		CBlob@ driver = ap.getOccupied();
		if (driver !is null)
			for (u8 i = 1; i <= Maths::Floor(Maths::Abs(this.getVelocity().x))*2; ++i) ParticleAnimated("SmallSmoke" + (XORRandom(1)+1), this.getPosition() + Vec2f(-32*flip_factor, -12).RotateBy(this.getAngleDegrees()), Vec2f(-1*flip_factor,2).RotateBy(this.getAngleDegrees()), float(XORRandom(360)), 1.0f + XORRandom(100) * 0.01f, 2 + XORRandom(4), XORRandom(50) * -0.005f, true);
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
	//return Vehicle_doesCollideWithBlob_ground( this, blob );
	return (blob.getTeamNum() != this.getTeamNum());
}

void onHealthChange( CBlob@ this, f32 oldHealth )
{
	//const f32 threshold = this.getInitialHealth() * 0.25f;	
	//
	//if (this.getHealth() < threshold && oldHealth >= threshold)
	//{	
	//	u8 wheel_to_kill = 78;
	//	//for(u8 i = 0; i < dead_wheels_numbers.length; ++ i)
	//	{
	//		if (dead_wheels_numbers[this.get_u8("amount_of_dead_wheels")] == wheel_to_kill)
	//			wheel_to_kill = XORRandom(7);
	//		//else
	//		//	break;
	//	}
	//	CSpriteLayer@ wheel = this.getSprite().getSpriteLayer("!w " + wheel_to_kill);
	//	if (wheel !is null)
	//	{
	//		wheel.SetVisible( false );
	//
	//		makeGibParticle( wheel_names[wheel_to_kill], 
	//			this.getPosition()+wheel.getOffset(), this.getVelocity() + getRandomVelocity( 90, 5, 80 ), 
	//			0, 0, Vec2f (16,16), 2.0f, 20, "/material_drop", 0 );
	//		
	//		this.add_u8("amount_of_dead_wheels", 1);
	//	}
	//	
	//	dead_wheels_numbers[this.get_u8("amount_of_dead_wheels")-1] = wheel_to_kill;
	//}
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
	if (blob !is null) {
		TryToAttachVehicle( this, blob );
	}
}

void onDie(CBlob@ this)
{
	if (this.exists("light_id"))
	{
		CBlob@ lantern = getBlobByNetworkID(this.get_u16("light_id"));
		if (lantern !is null)
		{
			lantern.server_Die();
		}
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