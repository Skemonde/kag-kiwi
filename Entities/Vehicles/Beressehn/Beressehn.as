#include "VehicleCommon"
#include "KIWI_Hitters"
#include "FirearmVars"
#include "TanksCommon"
#include "MakeBangEffect"
#include "Explosion"
#include "MakeExplodeParticles"

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
				   Vec2f(0.0f, -3.0), // jump out velocity
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
	this.Tag("convert on sit");
	this.Tag("no team lock");

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
	
	//sprite.SetRelativeZ(10.0f);
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
						  Vec2f( 4,-21 )+shape_offset,
						  Vec2f( 4,-48 )+shape_offset,
						  Vec2f(  0,-48 )+shape_offset };
		this.getShape().AddShape( shape );
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
	this.addCommandID("flip_vehicle");
	
	AttachmentPoint@ gunner = this.getAttachments().getAttachmentPointByName("SCHOOL_SHOOTER");
	if (gunner !is null)
	{
		gunner.SetKeysToTake(key_left | key_right | key_up | key_down);
		// pilot.SetMouseTaken(true);
	}
}

void DragGuysInside(CBlob@ this)
{
	return;
	
	const bool flip = this.isFacingLeft();
	const f32 flip_factor = flip ? -1 : 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	
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
}

void onTick( CBlob@ this )
{	
	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ insignia = sprite.getSpriteLayer("insignia");
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
	
	if (insignia !is null)
		insignia.SetOffset(Vec2f(-12, -20+(this.getVelocity().Length()>0.2?jumping_value:0)));
	
	DragGuysInside(this);

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

void onChangeTeam( CBlob@ this, const int oldTeam )
{
	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ insignia = sprite.getSpriteLayer("insignia");
	if (insignia is null) return;
	
	sprite.RemoveSpriteLayer("insignia");
}

void onRender(CSprite@ this)
{
	CSpriteLayer@ insignia = this.getSpriteLayer("insignia");
	
	if (insignia is null) {
		@insignia = getVehicleInsignia(this);
		//insignia.SetOffset(Vec2f(-12, -20));
	}
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
	return ((blob.getTeamNum() != this.getTeamNum() && this.getVelocity().Length() > 0.2) ||
		(blob.isKeyPressed(key_up) && blob.getVelocity().y>0) ||
		!blob.hasTag("player") ||
		blob.hasTag("dead") ||
		(blob.getPosition().y<this.getPosition().y-this.getRadius()&&!blob.isKeyPressed(key_down)));
}

void onHealthChange( CBlob@ this, f32 oldHealth )
{
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	//Vehicle_AddFlipButton(this, caller, Vec2f());
	//return;
	CBlob@ carried = caller.getCarriedBlob();
	f32 crit_angle = 100;
	if (this.getAngleDegrees()<crit_angle||this.getAngleDegrees()>(360-crit_angle)) return;
	
	CButton@ button = caller.CreateGenericButton("$arrow_topleft$", Vec2f(0, -8), this, this.getCommandID("flip_vehicle"), "Flip it!");
	if (button !is null) {
		button.SetEnabled(!caller.isAttached());
	}
}

void onDie(CBlob@ this)
{
	if (!this.hasTag("died naturally")) return;
	this.set_bool("explosive_teamkill", true);
	Explode(this, 80, 16.0f);
	
	if (isServer())
	for (int idx = 0; idx < 6; ++idx) {
		CBlob@ flare = server_CreateBlob("napalm", this.getTeamNum(), this.getPosition()+Vec2f(0, -16));
		if (flare is null) continue;
		flare.setVelocity(getRandomVelocity(90+this.getAngleDegrees(), 12+XORRandom(6), 40));
	}
	
	if (isClient())
	{
		Vec2f pos = this.getPosition();
		CMap@ map = getMap();
		
		MakeBangEffect(this, "bakoom", 4.0);
		Sound::Play("tank_death", this.getPosition(), 2, 1.0f + XORRandom(2)*0.1);
		u8 particle_amount = 6;
		for (int i = 0; i < particle_amount; i++)
		{
			MakeExplodeParticles(this, Vec2f( XORRandom(64) - 32, XORRandom(64) - 32), getRandomVelocity(360/particle_amount*i, XORRandom(220) * 0.01f, 90));
		}
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if(cmd == this.getCommandID("flip_vehicle")) 
	{
		this.setAngleDegrees(0);
		this.SetFacingLeft(!this.isFacingLeft());
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
	if (attached.hasTag("flesh")&&attachedPoint.name!="SCHOOL_SHOOTER") {
		attached.Tag("isInVehicle");
	}
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{
	if (detached.hasTag("flesh")) {
		detached.Untag("isInVehicle");
	}
}