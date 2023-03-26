#include "VehicleCommon"
#include "HittersKIWI"
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
	f32 slow_vel = this.getMass()/12;
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
							
	Vec2f sprite_offset = sprite.getOffset();
	Vec2f wheel_offset = Vec2f(-4 + sprite_offset.x, sprite_offset.y-7);
	{
		Vehicle_addWheel( this, v, wheel_names[0], 13, 13, 0, Vec2f(-17.5f, 6.5f) + wheel_offset );
		
		Vehicle_addWheel( this, v, wheel_names[1], 8, 8, 0, Vec2f(14.0f, 15.0f) + wheel_offset );
		Vehicle_addWheel( this, v, wheel_names[2], 8, 8, 0, Vec2f(7.0f, 15.0f) + wheel_offset );
		Vehicle_addWheel( this, v, wheel_names[3], 8, 8, 0, Vec2f(-2.0f, 15.0f) + wheel_offset );
		Vehicle_addWheel( this, v, wheel_names[4], 8, 8, 0, Vec2f(-9.0f, 15.0f) + wheel_offset );
		
		Vehicle_addWheel( this, v, wheel_names[5], 5, 5, 0, Vec2f(9.5f, 4.5f) + wheel_offset );
		Vehicle_addWheel( this, v, wheel_names[6], 5, 5, 0, Vec2f(-7.5f, 3.5f) + wheel_offset );
		
		Vehicle_addWheel( this, v, wheel_names[7], 16, 16, 0, Vec2f(24.0f, 7.0f) + wheel_offset );
	}
	
	sprite.SetZ(-10.0f);
	
	CSpriteLayer@ upperpart = sprite.addSpriteLayer("upperpart", "tank_upperpart.png", 64, 40, this.getTeamNum(), 0);
	if (upperpart !is null)
	{
		upperpart.SetRelativeZ(15.0f);
		upperpart.SetOffset(sprite_offset);
	}
	this.set_Vec2f("upperpart_offset", upperpart.getOffset());

	// set up tracks (positions are relative to this blob's sprite texture)
	Vec2f[] tracks_points = {
		Vec2f(9, 6),
		Vec2f(33,7),
		Vec2f(56, 5),
		Vec2f(58, 17),
		Vec2f(45, 23),
		Vec2f(18, 23),
		Vec2f(8, 17)
	};
	this.set("tracks_points", tracks_points);
	this.set_f32("tracks_distanced", 6.0f);
	this.set_Vec2f("tracks_rotation_center", Vec2f(64, 24)/2.0f - sprite_offset);
	this.set_Vec2f("tracks_rotation_offset", Vec2f_zero);
	this.set_string("tracks_texture", "tank_track.png");
	// thats it
	
	CSpriteLayer@ flag = sprite.addSpriteLayer("flag", "../Base/Entities/Vehicles/Ballista/Ballista.png", 32, 32);
	if (flag !is null)
	{
		flag.addAnimation("default", 3, true);
		int[] frames = { 15, 14, 13 };
		flag.animation.AddFrames(frames);
		flag.SetRelativeZ(-60.0f);
		flag.SetOffset(sprite_offset + Vec2f(29, -28));
	}

	Vec2f massCenter(0, 0);
	this.getShape().SetCenterOfMassOffset(massCenter);
	this.set_Vec2f("mass center", massCenter);
	
	this.set_f32("hit dmg modifier", 20.0f);
	this.set_f32("map dmg modifier", 10.0f);
	
	{
		AttachmentPoint@ turret_point = this.getAttachments().getAttachmentPointByName("TURRET");
		Vec2f turret_offset = Vec2f_zero;
		Vec2f turret_dims = Vec2f(32, 12);
		if (turret_point !is null) {
			turret_offset = turret_point.offset;
		}
		turret_offset += Vec2f(28, 14);
		Vec2f[] turret =
		{
			Vec2f(turret_offset.x-turret_dims.x/2, 			turret_offset.y-turret_dims.y/2),
			Vec2f(turret_offset.x+turret_dims.x/2, 			turret_offset.y-turret_dims.y/2),
			Vec2f(turret_offset.x+turret_dims.x/2, 			turret_offset.y+turret_dims.y/2),
			Vec2f(turret_offset.x-turret_dims.x/2, 			turret_offset.y+turret_dims.y/2)
		};
		//this.getShape().AddShape(turret);
	}
	//this.getShape().AddPlatformDirection(Vec2f(1, 1), 270, false);
	
	this.addCommandID("attach vehicle");
	this.addCommandID("play_shoot_sound");
	
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
	}
	sprite.PlaySound("emerald_tank.ogg", 0.3f, 1.0f);
	
	FirearmVars vars = FirearmVars();
	vars.BUL_PER_SHOT				= 1;
	vars.B_SPREAD					= 13;
	
	vars.B_GRAV						= Vec2f_zero;
	vars.B_DAMAGE					= 2;
	vars.B_HITTER					= HittersKIWI::bullet_hmg;
	vars.B_TTL_TICKS				= 100;
	vars.B_KB						= Vec2f_zero;
	vars.B_SPEED					= 12;
	vars.B_PENETRATION				= 0;
	vars.FIRE_SOUND					= "hmg_shot.ogg";
	vars.BULLET_SPRITE				= "nt_idpd_bullet.png";
	vars.CART_SPRITE				= "";
	vars.ONOMATOPOEIA				= "";
	this.set("firearm_vars", @vars);
	this.set_Vec2f("gun_trans", Vec2f(10, 0));
	
	this.Tag("NoAccuracyBonus");
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
	CSpriteLayer@ tracks = sprite.getSpriteLayer("tracks");
	CSpriteLayer@ turret = sprite.getSpriteLayer("turret");
	CSpriteLayer@ cannon = sprite.getSpriteLayer("cannon");
	CSpriteLayer@ upperpart = sprite.getSpriteLayer("upperpart");
	f32 speed = 4;
	f32 jumping_value = (getGameTime()%speed)/(speed/2)-0.5;
	if (this.getVelocity().Length()>0.2) {
		upperpart.SetOffset(Vec2f(this.get_Vec2f("upperpart_offset").x,this.get_Vec2f("upperpart_offset").y
			+jumping_value));
	}
	else
		upperpart.SetOffset(this.get_Vec2f("upperpart_offset"));
	bool turret_facing = false;
	
	AttachmentPoint@ turret_point = this.getAttachments().getAttachmentPointByName("TURRET");
	if (turret_point !is null) {
		turret_point.offset = Vec2f(3.5, -25.5);
		if (this.getVelocity().Length()>0.2f) {
			turret_point.offset = turret_point.offset + Vec2f(0, jumping_value);
		}
	}
	
	AttachmentPoint@ pilot_point = this.getAttachments().getAttachmentPointByName("PILOT");
	if (pilot_point !is null) {
		CBlob@ pilot = pilot_point.getOccupied();
		if (pilot !is null) {
			Vec2f mousePos = pilot.getAimPos();
			if (mousePos.x < this.getPosition().x) {
				turret_facing = true;
			}
			else if (mousePos.x > this.getPosition().x) {
				turret_facing = false;
			}
			pilot.SetFacingLeft(turret_facing);
		}
	}
	f32 turret_flip_factor = turret_facing ? -1 : 1;
	
	if (turret !is null && cannon !is null) {
		turret.SetOffset(sprite.getOffset()+Vec2f((turret_facing ? 3 : -3)*flip_factor, -27));
		turret.SetFacingLeft(turret_facing);
		cannon.SetOffset(sprite.getOffset()+Vec2f((turret_facing ? -17 : -23)*flip_factor, -24.5));
		cannon.SetFacingLeft(turret_facing);
	}
	
	u8 moving_formula = (Maths::Abs(this.getVelocity().x) > 0.1 ? Maths::Max(5-Maths::Floor(Maths::Abs(this.getVelocity().x*2)), 2) : 0);
	if (tracks !is null) {
		tracks.animation.time = moving_formula;
	}
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("DRIVER");
	CBlob@ driver = ap.getOccupied();
	
	if (ap !is null) {		
		if (driver !is null) {
			driver.getSprite().SetRelativeZ(-60);
			f32 angle = 0;
			
			//calculating after setting facing direction
			const bool flip = this.isFacingLeft();
			const f32 flip_factor = flip ? -1 : 1;
			const u16 angle_flip_factor = flip ? 180 : 0;
			
			u8 interval = this.get_u8("interval");
			
			if (interval > 0) {
				setHelpText("\ninterval: "+interval+"  ");
				interval--;
			}
			else if (interval == 0)
			{
				//it either controlled by script itself or a player can shoot it
				if ((driver !is null && ap.isKeyPressed(key_action1)))
				{
					if (isServer()) {
						Vec2f muzzle = Vec2f(25*flip_factor,-13.5).RotateBy(angle+this.getAngleDegrees());
						
						shootGun(this.getNetworkID(), angle+this.getAngleDegrees(), this.getNetworkID(), this.getPosition() + muzzle);
						
						CBitStream params;
						params.write_Vec2f(muzzle);
						this.SendCommand(this.getCommandID("play_shoot_sound"), params);
						interval = 3;
						if (XORRandom(100)<100)
							this.TakeBlob("highpow", 1);
					}
					
				}
			}
			if (isServer())
				this.set_u8("interval", interval);
			this.Sync("interval", true);
		}
	}
}

void shootGun(const u16 gunID, const f32 aimangle, const u16 hoomanID, const Vec2f pos) 
{
	CRules@ rules = getRules();
	CBitStream params;

	params.write_netid(hoomanID);
	params.write_netid(gunID);
	params.write_f32(aimangle);
	params.write_Vec2f(pos);
	rules.SendCommand(rules.getCommandID("fireGun"), params);
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	//f(!Vehicle_AddFlipButton( this, caller))
	//	Vehicle_AddAttachButton( this, caller);
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	const bool flip = this.isFacingLeft();
	const f32 flip_factor = flip ? -1 : 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	
	Vec2f weak_point = Vec2f(flip_factor*(-this.getShape().getWidth()/2+8), -this.getShape().getHeight()/2)+this.getPosition();
	if ((worldPoint - weak_point).Length() < 6)
		return damage *= 120;
	return damage *=1;
}

void onRender(CSprite@ this)
{
	//good for testing C:
	return;
	CBlob@ blob = this.getBlob();
	const bool flip = blob.isFacingLeft();
	const f32 flip_factor = flip ? -1 : 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	Vec2f weak_point = Vec2f(flip_factor*(-blob.getShape().getWidth()/2+8), -blob.getShape().getHeight()/2)+blob.getPosition();
	weak_point = getDriver().getScreenPosFromWorldPos(weak_point);
	GUI::DrawRectangle(weak_point, weak_point + Vec2f(4, 4), SColor(255, 0, 0, 255));
}

bool Vehicle_canFire( CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue )
{
	return false;
}

void Vehicle_onFire( CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 _charge ) {}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if(cmd == this.getCommandID("play_shoot_sound")) 
	{
		CSpriteLayer@ head = this.getSprite().getSpriteLayer("head");
		if (head !is null) {
			head.SetAnimation("shooting");
			head.SetFrameIndex(0);
		}
	}
}

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