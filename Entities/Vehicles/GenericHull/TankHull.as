#include "VehicleCommon"
#include "KIWI_Hitters"
#include "FirearmVars"
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

const int weak_point_radius = 6;

void onInit( CBlob@ this )
{
	CSprite@ sprite = this.getSprite();
	
	if (g_locale == "ru") {
		sprite.PlaySound("emerald_tank.ogg", 0.3f, 1.0f);
	} else
		//sprite.PlaySound("walkie_talkie_lad_2.ogg", 2.0f, 1.0f);
		Sound::Play("walkie_talkie_lad_2.ogg", this.getPosition(), 1.0f, 1.0f);
	
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
	this.Tag("convert on sit");
	this.Tag("no team lock");

	Vehicle_SetupGroundSound( this, v, "med_tank_tracks1.ogg", // movement sound
							  2.0f, // movement sound volume modifier   0.0f = no manipulation
							  0.0f // movement sound pitch modifier     0.0f = no manipulation
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
		upperpart.SetFrame(1);
		//upperpart.SetVisible(false);
	}
		//sprite.SetVisible(false);
	this.set_Vec2f("upperpart_offset", upperpart.getOffset());

	// set up tracks (positions are relative to this blob's sprite texture)
	Vec2f[] tracks_points = {
		Vec2f(9, 6),
		Vec2f(33,7),
		Vec2f(56, 5),
		Vec2f(58, 15),
		Vec2f(45, 23),
		Vec2f(21, 22),
		Vec2f(8, 17)
	};
	this.set("tracks_points", tracks_points);
	this.set_f32("tracks_distanced", 6.0f);
	this.set_Vec2f("tracks_rotation_center", Vec2f(64, 24)/2.0f - sprite_offset);
	this.set_Vec2f("tracks_rotation_offset", Vec2f_zero);
	this.set_string("tracks_texture", "tank_track.png");
	// thats it
	this.set_f32("suspension_height", 1);
	
	CSpriteLayer@ flag = sprite.addSpriteLayer("flag", "tank_banner.png", 32, 32);
	if (flag !is null)
	{
		flag.addAnimation("default", 3, true);
		int[] frames = { 2, 1, 0 };
		flag.animation.AddFrames(frames);
		flag.SetRelativeZ(-60.0f);
		flag.SetOffset(sprite_offset + Vec2f(29, -25));
		flag.SetVisible(false);
	}
	
	CSpriteLayer@ key = sprite.addSpriteLayer("goofy_ahh_key", "clockwork_key.png", 18, 16);
	if (key !is null)
	{
		key.addAnimation("default", 3, true);
		int[] frames = { 0, 1, 2, 3 };
		key.animation.AddFrames(frames);
		key.SetRelativeZ(1.0f);
		key.SetOffset(sprite_offset + Vec2f(24, -19));
		key.SetVisible(false);
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
		this.getShape().AddShape(turret);
	}
	//this.getShape().AddPlatformDirection(Vec2f(1, 1), 270, false);
	
	this.addCommandID("attach vehicle");
	this.addCommandID("play_shoot_sound");
	this.addCommandID("flip_vehicle");
	
	if (getNet().isServer())
	{
		CBlob@ blob = server_CreateBlob("donotspawnthiswithacommand_bt42turret");
		if (blob !is null)
		{
			blob.server_setTeamNum(this.getTeamNum());
			blob.setInventoryName("");
			blob.getShape().getConsts().collideWhenAttached = true;
			this.server_AttachTo(blob, "TURRET");
			this.set_u16("turret_id", blob.getNetworkID());
			blob.set_u16("tank_id", this.getNetworkID());
		}
	}
	
	FirearmVars vars = FirearmVars();
	vars.BUL_PER_SHOT				= 1;
	vars.B_SPREAD					= 13;
	
	vars.B_GRAV						= Vec2f_zero;
	vars.B_DAMAGE					= 31;
	vars.B_HITTER					= HittersKIWI::tank_mg;
	vars.B_TTL_TICKS				= 100;
	vars.B_KB						= Vec2f_zero;
	vars.B_SPEED					= 12;
	vars.B_PENETRATION				= 0;
	vars.FIRE_SOUND					= "hmg_shot.ogg";
	vars.BULLET_SPRITE				= "nt_idpd_bullet";
	vars.CART_SPRITE				= "";
	vars.ONOMATOPOEIA				= "";
	vars.RANGE			 			= 3000;
	this.set("firearm_vars", @vars);
	this.set_Vec2f("gun_trans", Vec2f(10, 0));
	
	this.Tag("NoAccuracyBonus");
}

void onTick( CBlob@ this )
{	
	this.SetMinimapRenderAlways(true);
	this.SetMinimapVars("kiwi_minimap_icons.png", (this.isFacingLeft()?1:0), Vec2f(1,1)*16);
	this.SetMinimapOutsideBehaviour(CBlob::minimap_none);
	
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
	CSpriteLayer@ flag = sprite.getSpriteLayer("flag");
	
	if (flag !is null) {
		flag.ResetTransform();
		flag.RotateBy(-16*flip_factor, Vec2f(0,16));
	}
	
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
			for (u8 i = 1; i <= Maths::Floor(Maths::Abs(this.getVelocity().x))*2; ++i) ParticleAnimated("SmallSmoke" + (XORRandom(1)+1), this.getPosition() + Vec2f(-28*flip_factor, -5).RotateBy(this.getAngleDegrees()), Vec2f(-1*flip_factor,2).RotateBy(this.getAngleDegrees()), float(XORRandom(360)), 1.0f + XORRandom(100) * 0.01f, 2 + XORRandom(4), XORRandom(50) * -0.005f, true);
			
			driver.getSprite().SetRelativeZ(-60);
			f32 angle = 0;
			
			//calculating after setting facing direction
			const bool flip = this.isFacingLeft();
			const f32 flip_factor = flip ? -1 : 1;
			const u16 angle_flip_factor = flip ? 180 : 0;
			
			u8 interval = this.get_u8("interval");
			
			if (interval > 0) {
				//setHelpText("\ninterval: "+interval+"  ");
				interval--;
			}
			else if (interval == 0)
			{
				CInventory@ driver_pockets = driver.getInventory();
				//it either controlled by script itself or a player can shoot it
				if ((driver !is null && ap.isKeyPressed(key_action1)) && driver_pockets !is null && driver_pockets.getCount("lowcal")>0)
				{
					if (isServer()) {
						Vec2f muzzle = Vec2f(25*flip_factor,-13.5).RotateBy(angle+this.getAngleDegrees());
						
						shootGun(this.getNetworkID(), angle+this.getAngleDegrees(), this.getNetworkID(), this.getPosition() + muzzle);
						
						CBitStream params;
						params.write_Vec2f(muzzle);
						this.SendCommand(this.getCommandID("play_shoot_sound"), params);
						interval = 1;
						if (XORRandom(100)<100)
							driver.TakeBlob("lowcal", 1);
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

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	const bool flip = this.isFacingLeft();
	const f32 flip_factor = flip ? -1 : 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	
	Vec2f weak_point = this.getPosition();
	weak_point += Vec2f(flip_factor*(-this.getShape().getWidth()/2+13), -this.getShape().getHeight()/2+10).RotateBy(this.getAngleDegrees());
	if ((worldPoint - weak_point).Length() < weak_point_radius) {
		MakeBangEffect(this, "crit", 1.0f, false, Vec2f((XORRandom(10)-5) * 0.1, -(3/2)), weak_point-this.getPosition());
		return damage *= 13;
	}
	return damage *=1;
}

void onRender(CSprite@ this)
{
	//good for testing C:
	if (g_debug < 1) return;
	const f32 scalex = getDriver().getResolutionScaleFactor();
	const f32 zoom = getCamera().targetDistance * scalex;
	CBlob@ blob = this.getBlob();
	const bool flip = blob.isFacingLeft();
	const f32 flip_factor = flip ? -1 : 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	Vec2f weak_point = blob.getPosition();
	weak_point += Vec2f(flip_factor*(-blob.getShape().getWidth()/2+13), -blob.getShape().getHeight()/2+10).RotateBy(blob.getAngleDegrees());
	weak_point = getDriver().getScreenPosFromWorldPos(weak_point);
	GUI::DrawRectangle(weak_point - Vec2f(1, 1)*2, weak_point + Vec2f(1, 1)*2, SColor(255, 0, 0, 255));
	GUI::DrawCircle(weak_point, 2*weak_point_radius*zoom, SColor(255, 0, 0, 255));
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
	if(cmd == this.getCommandID("flip_vehicle")) 
	{
		this.setAngleDegrees(0);
		this.SetFacingLeft(!this.isFacingLeft());
	}
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	//return Vehicle_doesCollideWithBlob_ground( this, blob );
	//print("speed"+(this.getVelocity().Length()));
	return ((blob.getTeamNum() != this.getTeamNum() && this.getVelocity().Length() > 0.2) ||
		(blob.isKeyPressed(key_up) && blob.getVelocity().y>0) ||
		blob.hasTag("vehicle") ||
		blob.hasTag("dead") ||
		blob.hasTag("scenary") ||
		blob.getName().find("tree")>-1 ||
		(blob.getPosition().y<this.getPosition().y-this.getRadius()&&!blob.isKeyPressed(key_down)));
}

void onHealthChange( CBlob@ this, f32 oldHealth )
{
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2 )
{
	const bool flip = this.isFacingLeft();
	const f32 flip_factor = flip ? -1 : 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	f32 vehicle_angle = this.getAngleDegrees();
		
	if (blob !is null) {
		TryToAttachVehicle( this, blob );
	} else {
		if (Maths::Abs(point1.y-this.getPosition().y+6)>10 || Maths::Abs(vehicle_angle)>12) return;
		f32 bumb_flip_factor = (point2.x>this.getPosition().x?1:-1);
		//print("hello");
		f32 mass = this.getMass();
		f32 vellen = this.getVelocity().Length();
		this.AddForceAtPosition(Vec2f(-3*flip_factor, -mass/4+vellen*(-mass/256)).RotateBy(vehicle_angle), this.getPosition() + Vec2f(100*bumb_flip_factor, 5));
	}
}

void onChangeTeam( CBlob@ this, const int oldTeam )
{
	if (this.exists("turret_id"))
	{
		CBlob@ turret = getBlobByNetworkID(this.get_u16("turret_id"));
		if (turret is null) return;
		turret.server_setTeamNum(this.getTeamNum());
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
	if (this.exists("turret_id"))
	{
		CBlob@ tank = getBlobByNetworkID(this.get_u16("turret_id"));
		if (tank !is null)
		{
			tank.server_Die();
		}
	}
	if (!this.hasTag("died naturally")) return;
	this.set_bool("explosive_teamkill", true);
	Explode(this, 80, 16.0f);
	
	if (isServer())
	for (int idx = 0; idx < 6; ++idx) {
		CBlob@ flare = server_CreateBlob("napalm", this.getTeamNum(), this.getPosition());
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
		
		u8 team = this.getTeamNum();
		Vec2f vel = this.getVelocity();
		vel.y -= 3.0f;
		f32 hp = Maths::Min(Maths::Abs(this.getHealth()), 2.0f) + 1.0f;
		for (int i = 0; i < 7; ++i) {
			CParticle@ tank_part = makeGibParticle("bt_gibs.png", pos, vel + getRandomVelocity(90+(-3.5+i)*(180/7), XORRandom(3), 0)*2, 0, 7-i, Vec2f(24, 24), 2.0f, 20, "tank_death", team);
		}
	}
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	if (attached.hasTag("flesh")) {
		attached.Tag("isInVehicle");
	}
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{
	if (detached.hasTag("flesh")) {
		detached.Untag("isInVehicle");
	}
}