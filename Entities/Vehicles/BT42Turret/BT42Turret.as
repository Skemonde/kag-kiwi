#include "FirearmVars"
#include "MakeBangEffect"
#include "Skemlib"
#include "BulletCase"
#include "TanksCommon"

const int tank_hatch_offset = 10;

void onInit( CBlob@ this )
{
	CSprite@ sprite = this.getSprite();
	sprite.SetRelativeZ(16.0f);
	
	CSpriteLayer@ cannon = sprite.addSpriteLayer("cannon", "bt42_cannon.png", 12, 7);
	if (cannon !is null)
	{
		cannon.SetOffset(Vec2f(-20, 1.5));
		cannon.SetRelativeZ(-3.0f);
		cannon.SetVisible(true);
	}
	CSpriteLayer@ turret = sprite.addSpriteLayer("turret", "bt42_turret.png", 34, 18);
	if (turret !is null)
	{
		turret.SetOffset(Vec2f(0, 0));
		turret.SetRelativeZ(0.5f);
		turret.SetVisible(true);
	}
	CSpriteLayer@ hatchet = sprite.addSpriteLayer("hatchet", "bt42_hatchet.png", 15, 11);
	if (hatchet !is null)
	{
		hatchet.SetOffset(Vec2f(0, 0));
		hatchet.SetRelativeZ(-60.3f);
		hatchet.SetVisible(true);
	}
	CSpriteLayer@ chamber = sprite.addSpriteLayer("chamber", "cannon_chamber.png", 16, 16);
	if (chamber !is null)
	{
		chamber.addAnimation("default", 3, false);
		int[] frames = { 3, 2, 1, 0 };
		chamber.animation.AddFrames(frames);
		
		chamber.SetRelativeZ(10.0f);
		chamber.SetOffset(Vec2f(29, -25));
	}
	
	AttachmentPoint@ pipo = this.getAttachments().getAttachmentPointByName("AMOGUS");
	this.set_Vec2f("pilot_offset", pipo.offset);
	this.set_Vec2f("initial_pilot_offset", pipo.offset);
	
	// add turret ladder
	getMap().server_AddMovingSector(Vec2f(-6.0f, 16.0f), Vec2f(6.0f, -8.0f), "ladder", this.getNetworkID());
	
	// converting
	this.set_u8("interval", 0);
	this.Tag("tank");
	this.Tag("vehicle");
	this.Tag("convert on sit");
	this.Tag("replenishButton");
	//this.Tag("default_bullet_pos");
	
	this.set_bool("facingLeft", false);
	this.set_bool("case is ejected", false);
	this.set_bool("turning", true);
	this.set_bool("shell in chamber", true);
	this.addCommandID("play_shoot_sound");
	this.addCommandID("empty_cannon_chamber");
	
	FirearmVars vars = FirearmVars();
	vars.BUL_PER_SHOT				= 1;
	vars.BULLET						= "bullet";
	vars.B_SPREAD					= 0;
	
	vars.B_GRAV						= Vec2f(0, 0.033)*0.75;
	vars.B_DAMAGE					= 1000;
	vars.B_HITTER					= HittersKIWI::tank_cannon;
	vars.B_TTL_TICKS				= 100;
	vars.B_KB						= Vec2f_zero;
	vars.B_SPEED					= 20*0.75;
	vars.B_PENETRATION				= 0;
	vars.FIRE_SOUND					= "";//"anime_bang.ogg";
	vars.FIRE_PITCH					= 0.8f;
	vars.CART_SPRITE				= "TankShellCase.png";
	vars.ONOMATOPOEIA				= "";
	vars.AMMO_TYPE.push_back("tankshells");
	vars.BULLET_SPRITE				= "tank";
	//vars.FADE_SPRITE				= "CoalFade";
	vars.RICOCHET_CHANCE 			= 0;
	vars.RANGE			 			= 3000;
	//EXPLOSIVE LOGIC
	vars.EXPLOSIVE					= false;
	vars.EXPL_RADIUS 				= 64;
	vars.EXPL_DAMAGE 				= 100;
	vars.EXPL_MAP_RADIUS 			= 40;
	vars.EXPL_MAP_DAMAGE 			= 0.4;
	vars.EXPL_RAYCAST 				= false;
	vars.EXPL_TEAMKILL 				= false;
	//this.set_string("bullet_blob", "grenade");
	this.set("firearm_vars", @vars);
	
	this.Tag("NoAccuracyBonus");
	this.set_u16("shotcount", 0);
}

void onTick( CBlob@ this )
{	
	CSprite@ sprite = this.getSprite();
	FirearmVars@ vars;
	this.get("firearm_vars", @vars);
	f32 vehicle_angle = (getBlobByNetworkID(this.get_u16("tank_id")) !is null ? getBlobByNetworkID(this.get_u16("tank_id")).getAngleDegrees() : 0);
	
	const int time = this.getTickSinceCreated();
	bool facingLeft = this.get_bool("facingLeft");
	bool got_shell = this.get_bool("shell in chamber");
	
	
	u8 interval = this.get_u8("interval");
	if (interval > 0) {
		interval--;
		this.set_u8("interval", interval);
		this.Sync("interval", true);
	}
	
	CSpriteLayer@ cannon = sprite.getSpriteLayer("cannon");
	CSpriteLayer@ chamber = sprite.getSpriteLayer("chamber");
	Animation@ chamber_anim = chamber.getAnimation("default");
	
	if (!got_shell) {
		if (interval < 1) {
			chamber.SetFrameIndex(0);
			if (!this.get_bool("case is ejected") && isServer())
				this.SendCommand(this.getCommandID("empty_cannon_chamber"));
		}
		chamber_anim.time=0;
	} else {
		chamber_anim.time=3;
	}
	
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("AMOGUS");
	Vec2f p_offset = this.get_Vec2f("initial_pilot_offset");
	CBlob@ tank = getBlobByNetworkID(this.get_u16("tank_id"));
	if (tank is null) return;
	
	//tag turning defines if the turret can even turn
	//and if it cannot we reset cannon's transform and make it face the direction the tank's facing
	if (tank !is null && !this.get_bool("turning") || this.getTickSinceCreated()<10) {
		facingLeft = tank.isFacingLeft();
		if (cannon !is null)
		cannon.ResetTransform();
	}
	
	if (!this.hasTag("pilotInside"))
		this.set_Vec2f("pilot_offset", Vec2f(p_offset.x, p_offset.y));
	
	f32 angle = 0;
	u32 fire_interval = 180;
	this.set_bool("facingLeft", facingLeft);
	this.Sync("facingLeft", true);
	
	if (ap !is null)
	{
		ap.offsetZ = -30;
		ap.offset = this.get_Vec2f("pilot_offset")
			//point offset depends of turret blob facing direction
			//previously we found facing direction of cannon and we invert it if the turret blob was made facing left due to the hull
			//the turret is attached to
			+(this.isFacingLeft()
			?(facingLeft ? Vec2f_zero : Vec2f(tank_hatch_offset,0))
			:(facingLeft ? Vec2f(tank_hatch_offset,0) : Vec2f_zero));
		
		ap.SetKeysToTake(key_left);
		CBlob@ pilot = ap.getOccupied();
		CBlob@ carried = null;
		bool gun_in_hands = false;
		
		if (pilot !is null)
		{
			CBlob@ carried = pilot.getCarriedBlob();
			gun_in_hands = carried !is null && carried.hasTag("firearm") && carried.getName()!="bino";
			cannon.ResetTransform();
			//if pilot and tank are present and we can turn we turn
			if (tank !is null && this.get_bool("turning"))
			{
				Vec2f mousePos = pilot.getAimPos();
				if (Maths::Abs(mousePos.x-pilot.getPosition().x)>32) {
					if (mousePos.x < tank.getPosition().x)
					{
						facingLeft = true;
					}
					else if (mousePos.x > tank.getPosition().x)
					{
						facingLeft = false;
					}
				}
			}
			if (!pilot.isKeyPressed(key_action2))
			{
				//pilot.SetFacingLeft(facingLeft);
				if (carried !is null) {
					carried.SetFacingLeft(facingLeft);
					//carried.getSprite().SetZ(1500);
				}
				pilot.getSprite().SetRelativeZ(-60);
				pilot.setAngleDegrees(vehicle_angle);
				//print("X cord: "+pilot.getAimPos().x/8);
			}
		}
		else
		{
			return;
		}
		if (pilot is null || !pilot.isKeyPressed(key_action2)) {
			this.set_bool("facingLeft", facingLeft);
		}
		angle = getCannonAngle(this, pilot);
		
		const bool flip = this.get_bool("facingLeft");
		const f32 flip_factor = flip ? -1 : 1;
		const u16 angle_flip_factor = flip ? 180 : 0;
		
		f32 clampedAngle = this.get_f32("gun_angle");
		if (pilot is null || !pilot.isKeyPressed(key_action2))
		{
			clampedAngle = (Maths::Clamp(angle, -20, 15) * flip_factor);
			this.set_f32("gun_angle", clampedAngle);
		}
		
		if (pilot !is null) {
			AttachmentPoint@ pilot_pickup = pilot.getAttachments().getAttachmentPointByName("PICKUP");
			if (pilot_pickup !is null) {
				pilot_pickup.offsetZ = 30;
			}
			this.set_f32("gun_angle", clampedAngle);
			
			if (ap.isKeyPressed(key_down) && !pilot.hasTag("isInVehicle") && getGameTime()-this.get_u32("last_visit")>17) {
				this.Tag("pilotInside");
				pilot.Tag("isInVehicle");
				this.set_u32("last_visit", getGameTime());
			} else
			if (ap.isKeyPressed(key_up) && this.hasTag("pilotInside") && getGameTime()-this.get_u32("last_visit")>(17+5)) {
				this.set_Vec2f("pilot_offset", Vec2f(p_offset.x, p_offset.y));
				pilot.Untag("isInVehicle");
				this.Untag("pilotInside");
			}
			if(this.hasTag("pilotInside")) {
				this.set_Vec2f("pilot_offset", Vec2f(p_offset.x, p_offset.y+Maths::Min(17,getGameTime()-this.get_u32("last_visit"))/17*16));
				if (Maths::Min(17,getGameTime()-this.get_u32("last_visit"))/17 == 1 && !pilot.hasTag("isInVehicle")) {
					
					Sound::Play("GetInVehicle.ogg", pilot.getPosition());
					//print("pilot's safe C:");
				}
				ap.SetKeysToTake(key_action1 | key_action2);
			}
		}
		
		Vec2f muzzle = Vec2f(30 * flip_factor, 1.5).RotateBy( clampedAngle+this.getAngleDegrees(), Vec2f(10 * flip_factor, 0.5) );
		this.set_Vec2f("muzzle_pos", muzzle);
		
		if (got_shell && interval<1)
		{
			bool ammo_enabled = getRules().get_bool("ammo_usage_enabled");
			if ((pilot !is null && ap.isKeyPressed(key_action1))&&(got_shell||GetItemAmount(this, vars.AMMO_TYPE[0])>0||!ammo_enabled)&&!(gun_in_hands&&!this.hasTag("pilotInside")))
			{
				interval = 30;
				this.set_u32("shot_moment", getGameTime());
				ShakeScreen( 9*3, 2, this.getPosition() );
				
				if (pilot.isMyPlayer()&&this.get_u32("last_shot")<getGameTime()+5) {
					//if (carried !is null && carried.getName()!="bino") return;
					shootGun(this.getNetworkID(), clampedAngle+this.getAngleDegrees(), pilot.getNetworkID(), this.getPosition() + muzzle);
					
					CBitStream params;
					params.write_Vec2f(muzzle);
					this.SendCommand(this.getCommandID("play_shoot_sound"),params);
				}
				if (isServer()) {
					if (XORRandom(100)<100&&ammo_enabled)
						this.TakeBlob(vars.AMMO_TYPE[0], 1);
					if (tank !is null && getRules().get_bool("cursor_recoil_enabled")) {
						f32 mass = tank.getMass();
						//adding a bit of force for an epic physics effect
						tank.AddForceAtPosition(Vec2f(-3*flip_factor, -mass/4+(30-Maths::Abs(clampedAngle))*(-mass/256)).RotateBy(vehicle_angle), tank.getPosition() + Vec2f(100*flip_factor, 5));
					}
				}
				
				this.set_bool("case is ejected", false);
				this.Sync("case is ejected", true);
				this.set_bool("shell in chamber", false);
				this.Sync("shell in chamber", true);
			}
		}
		
		
		cannon.RotateBy(clampedAngle, Vec2f(8 * flip_factor, 0.5));
	}
	this.set_u8("interval", interval);
	this.Sync("interval", true);
	this.set_f32("interval_perc", 1.0f*interval / fire_interval);
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if(cmd == this.getCommandID("empty_cannon_chamber")) 
	{
		this.set_bool("case is ejected", true);
		this.Sync("case is ejected", true);
		if (!isClient()) return;
		
		CBlob@ tank = getBlobByNetworkID(this.get_u16("tank_id"));
		if (tank is null) return;
		
		const bool flip = this.get_bool("facingLeft");
		const f32 flip_factor = flip ? -1 : 1;
		const f32 tank_flip_factor = tank.isFacingLeft() ? -1 : 1;
		const u16 angle_flip_factor = flip ? 180 : 0;
		
		MakeEmptyShellParticle(this, "TankShellCase.png", 1, Vec2f(flip_factor*tank_flip_factor*(XORRandom(30)/10-7.5f), -0.1).RotateBy(this.getAngleDegrees()*tank_flip_factor), this, "GrenadeDrop1.ogg", this.getPosition()+Vec2f(-flip_factor*16, -1).RotateBy(this.getAngleDegrees(), Vec2f()));
		
		Sound::Play("tank_unload.ogg", this.getPosition(), 1, 1.0f+XORRandom(100)*0.001-0.1);
	}
	if(cmd == this.getCommandID("play_shoot_sound")) 
	{
		const bool flip = this.get_bool("facingLeft");
		const f32 flip_factor = flip ? -1 : 1;
		const u16 angle_flip_factor = flip ? 180 : 0;
		
		this.set_u32("last_shot", getGameTime());
		
		Vec2f muzzle = params.read_Vec2f();
		this.getSprite().PlaySound("long_range_mortar_shot", 1, 0.60f + XORRandom(21)*0.01);
		MakeBangEffect(this, "foom", 1.5f, false, Vec2f((XORRandom(10)-5) * 0.1, -(3/2)), muzzle + Vec2f(XORRandom(11)-5,-XORRandom(4)-1));
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
	CBlob@ blob = this.getBlob();
	const f32 scalex = getDriver().getResolutionScaleFactor();
	const f32 zoom = getCamera().targetDistance * scalex;
	CMap@ map = getMap();
	const bool flip = blob.get_bool("facingLeft");
	const f32 flip_factor = flip ? -1 : 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	FirearmVars@ vars;
	blob.get("firearm_vars", @vars);
	CPlayer@ localplayer = getLocalPlayer();
	if (localplayer is null) return;
	
	u32 shot_moment = blob.get_u32("shot_moment");
	u32 ticks_from_shot = getGameTime()-shot_moment;
	CSpriteLayer@ turret = this.getSpriteLayer("turret");
	CSpriteLayer@ cannon = this.getSpriteLayer("cannon");
	CSpriteLayer@ hatchet = this.getSpriteLayer("hatchet");
	CSpriteLayer@ chamber = this.getSpriteLayer("chamber");
	CSpriteLayer@ insignia = this.getSpriteLayer("insignia");
	
	if (insignia is null) {
		@insignia = getVehicleInsignia(this);
		insignia.SetOffset(Vec2f(-3, 4));
	}
	
	turret.SetFacingLeft(blob.get_bool("facingLeft"));
	cannon.SetFacingLeft(blob.get_bool("facingLeft"));
	cannon.SetOffset(Vec2f(-20, 1.5));
	cannon.SetOffset(cannon.getOffset()
		+Vec2f(float(20-Maths::Min(20, ticks_from_shot))/3,0).RotateBy(-blob.get_f32("gun_angle") * flip_factor));
	hatchet.SetFacingLeft(blob.get_bool("facingLeft"));
	hatchet.SetOffset(Vec2f(3.5,-6.5));
	hatchet.ResetTransform();
	hatchet.RotateBy(-120*flip_factor, Vec2f(6*flip_factor,0));
	if (blob.hasTag("pilotInside"))
		hatchet.RotateBy(Maths::Min(20,getGameTime()-blob.get_u32("last_visit"))/20*120*flip_factor, Vec2f(6*flip_factor,0));
	chamber.SetOffset(Vec2f(16, -1));
	chamber.SetFacingLeft(blob.get_bool("facingLeft"));
	insignia.SetFacingLeft(blob.get_bool("facingLeft"));
	
	if (g_videorecording) return; // F6
	Vec2f pos = blob.getInterpolatedScreenPos();
	
	Vec2f reload_bar_pos = pos + Vec2f(0, 64);
	if (false && blob.get_f32("interval_perc") > 0 && getLocalPlayerBlob() !is null && getLocalPlayerBlob().getTeamNum() == blob.getTeamNum())
		GUI::DrawProgressBar(reload_bar_pos-Vec2f(64, 8), reload_bar_pos+Vec2f(64, 8), blob.get_f32("interval_perc"));
	
	AttachmentPoint@ ap = blob.getAttachments().getAttachmentPointByName("AMOGUS");
	if (ap !is null) {
		CBlob@ pilot = ap.getOccupied();
		if (pilot !is null && pilot is getLocalPlayerBlob() && pilot.isMyPlayer()) {
			GUI::SetFont("smallest");
			GUI::SetFont("menu");
			GUI::DrawTextCentered("Gun angle: "+
				formatFloat(Maths::Round(-blob.get_f32("gun_angle")*flip_factor), "", 0, 0)+
				"\nHold RMB to lock the Cannon", Vec2f(pos.x, pos.y + 120*zoom + Maths::Sin(getGameTime() / 10.0f) * 10.0f), SColor(0xfffffcf0));
			GUI::SetFont("menu");
			const f32 angle = blob.get_f32("gun_angle")+blob.getAngleDegrees();
			//magic Vec2f
			Vec2f muzzle = blob.get_Vec2f("muzzle_pos") + blob.getPosition() + Vec2f(-10*flip_factor, 1).RotateBy(angle);
			Vec2f tracer = getDriver().getScreenPosFromWorldPos(muzzle);
			Vec2f CurrentPos = tracer;
			if (vars !is null && pilot.getCarriedBlob() !is null && pilot.getCarriedBlob().getName()=="bino" && !pilot.hasTag("isInVehicle")) {
				for (int counter = 0; counter < 40*zoom*4; ++counter) {
					Vec2f dir = Vec2f((flip ? -1 : 1), 0.0f).RotateBy(angle);
					//magic number 1.94 ( i have no idea where it does come from )
					CurrentPos += ((dir * vars.B_SPEED) - (-vars.B_GRAV * vars.B_SPEED/zoom/1.97 * counter));
					Vec2f world_pos = getDriver().getWorldPosFromScreenPos(CurrentPos);
					TileType tile = map.getTile(world_pos).type;
					//if tracer meets side of a map or solid blocks it stops
					if (map.isTileSolid(tile) || world_pos.x > map.tilemapwidth*map.tilesize || world_pos.x < 0)
						break;
					f32 dot_size = 2;
					GUI::DrawRectangle(CurrentPos - Vec2f(dot_size, dot_size), CurrentPos + Vec2f(dot_size, dot_size), SColor(255, 0, 255, 0));
				}
			}
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
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	//return Vehicle_doesCollideWithBlob_ground( this, blob );
	//print("speed"+(this.getVelocity().Length()));
	return ((blob.getTeamNum() != this.getTeamNum() && this.getVelocity().Length() > 0.2) ||
		(blob.isKeyPressed(key_up) && blob.getVelocity().y>0) ||
		blob.hasTag("vehicle") ||
		blob.hasTag("dead") ||
		(blob.getPosition().y<this.getPosition().y-this.getRadius()*0.5f&&!blob.isKeyPressed(key_down)));
}

void onHealthChange( CBlob@ this, f32 oldHealth )
{
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
	//if (blob !is null) {
	//	TryToAttachVehicle( this, blob );
	//}
}

bool isInventoryAccessible( CBlob@ this, CBlob@ forBlob )
{
	return false;
	return forBlob.getTeamNum()==this.getTeamNum();
}

f32 getCannonAngle( CBlob@ this, CBlob@ holder, Vec2f muzzle_offset = Vec2f(-69, -69) )
{
	if (this is null) return 0;
	const bool flip = this.get_bool("facingLeft");
	const f32 flip_factor = flip ? -1: 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	const Vec2f shoulder_joint = Vec2f(-3 * flip_factor, -3);
	
	//FirearmVars@ vars;
	//this.get("firearm_vars", @vars);
	
	// находим координату дула пушки
	muzzle_offset =
		(muzzle_offset == Vec2f(-69, -69)
			? Vec2f(flip_factor*this.get_Vec2f("gun_trans").x*0,
				(this.get_Vec2f("gun_trans").y))//+vars.MUZZLE_OFFSET.y))
			: muzzle_offset);

	Vec2f pos = this.getPosition() + muzzle_offset.RotateBy(
	constrainAngle(angle_flip_factor-((holder.getAimPos() - holder.getPosition()).Angle())), shoulder_joint);
	
 	Vec2f aimvector = holder.getAimPos() - pos;
	f32 angle = aimvector.Angle() + this.getAngleDegrees();
    return constrainAngle(angle_flip_factor-(angle+flip_factor))*flip_factor;
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	if (this.hasTag("pilotInside"))
		attached.Tag("isInVehicle");
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{
	if (detached !is null)
	{
		if (detached.hasTag("flesh")) {
			detached.Untag("isInVehicle");
			this.Untag("pilotInside");
			detached.AddForce(Vec2f(0.0f, -4.0)*detached.getMass());
		}
	}
}