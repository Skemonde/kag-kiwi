#include "FirearmVars"
#include "MakeBangEffect"
#include "Skemlib"

const int tank_hatch_offset = 10;

void onInit( CBlob@ this )
{
	CSprite@ sprite = this.getSprite();
	sprite.SetRelativeZ(16.0f);
	
	CSpriteLayer@ cannon = sprite.addSpriteLayer("cannon", "howitzer_cannon.png", 48, 16);
	if (cannon !is null)
	{
		cannon.SetOffset(Vec2f(-15, -5.5));
		this.set_Vec2f("cannon_def_offset", cannon.getOffset());
		cannon.SetRelativeZ(-3.0f);
		cannon.SetVisible(true);
	}
	CSpriteLayer@ rail = sprite.addSpriteLayer("rail", "howitzer_rail.png", 48, 16);
	if (rail !is null)
	{
		rail.SetOffset(Vec2f(-15, 6.5));
		rail.SetRelativeZ(-3.0f);
		rail.SetVisible(true);
	}
	CSpriteLayer@ tail = sprite.addSpriteLayer("tail", "howitzer_tail.png", 48, 16);
	if (tail !is null)
	{
		tail.SetOffset(Vec2f(14, 3));
		tail.SetRelativeZ(-60.3f);
		tail.SetVisible(true);
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
	//this.Tag("default_bullet_pos");
	
	this.set_bool("facingLeft", false);
	this.set_bool("turning", true);
	this.addCommandID("play_shoot_sound");
	
	FirearmVars vars = FirearmVars();
	vars.BUL_PER_SHOT				= 1;
	vars.BULLET						= "bullet";
	vars.B_SPREAD					= 0;
	
	vars.B_GRAV						= Vec2f(0, 0.033)*0.75;
	vars.B_DAMAGE					= 1000;
	vars.B_HITTER					= HittersKIWI::boom;
	vars.B_TTL_TICKS				= 100;
	vars.B_KB						= Vec2f_zero;
	vars.B_SPEED					= 20*0.75;
	vars.B_PENETRATION				= 0;
	vars.FIRE_SOUND					= "";//"anime_bang.ogg";
	vars.FIRE_PITCH					= 0.8f;
	vars.CART_SPRITE				= "empty_tank_shell.png";
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
	bool flip = this.isFacingLeft();
	f32 flip_factor = flip ? -1 : 1;
	u16 angle_flip_factor = flip ? 180 : 0;
	CSprite@ sprite = this.getSprite();
	FirearmVars@ vars;
	this.get("firearm_vars", @vars);
	f32 vehicle_angle = (getBlobByNetworkID(this.get_u16("tank_id")) !is null ? getBlobByNetworkID(this.get_u16("tank_id")).getAngleDegrees() : 0);
	
	const int time = this.getTickSinceCreated();
	bool facingLeft = this.get_bool("facingLeft");
	
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("AMOGUS");
	if (ap is null) return;
	Vec2f p_offset = this.get_Vec2f("initial_pilot_offset");
	CSpriteLayer@ cannon = sprite.getSpriteLayer("cannon");
	CSpriteLayer@ rail = sprite.getSpriteLayer("rail");
	//tag turning defines if the turret can even turn
	//and if it cannot we reset cannon's transform and make it face the direction the tank's facing
	if (!this.get_bool("turning") || this.getTickSinceCreated()<10) {
		facingLeft = this.isFacingLeft();
		if (cannon !is null)
		cannon.ResetTransform();
		rail.ResetTransform();
	}
	
	if (!this.hasTag("pilotInside"))
		this.set_Vec2f("pilot_offset", Vec2f(p_offset.x, p_offset.y));
	
	f32 angle = 0;
	f32 target_angle = 0;
	u8 interval = this.get_u8("interval");
	u32 fire_interval = 180;
	this.set_bool("facingLeft", facingLeft);
	
	ap.offsetZ = 10;
	ap.SetKeysToTake(key_action1);
	CBlob@ pilot = ap.getOccupied();
	CBlob@ carried = null;
	
	if (pilot !is null && !pilot.isKeyPressed(key_action2)) {
		Vec2f mousePos = pilot.getAimPos();
		if (Maths::Abs(mousePos.x-pilot.getPosition().x)>32*flip_factor) {
			if (mousePos.x < pilot.getPosition().x)
			{
				facingLeft = true;
			}
			else if (mousePos.x > pilot.getPosition().x)
			{
				facingLeft = false;
			}
		}
		this.SetFacingLeft(facingLeft);
		target_angle = getCannonAngle(this, pilot);
	}
	
	flip = this.isFacingLeft();
	flip_factor = flip ? -1 : 1;
	angle_flip_factor = flip ? 180 : 0;
	
	f32 clampedAngle = this.get_f32("gun_angle");
	if (pilot is null || !pilot.isKeyPressed(key_action2))
	{
		angle = target_angle;
		
		clampedAngle = (Maths::Clamp(angle, -18, -5) * flip_factor);
		this.set_f32("gun_angle", clampedAngle);
	}
	
	Vec2f muzzle = Vec2f(30 * flip_factor, 1.5).RotateBy( clampedAngle+this.getAngleDegrees(), Vec2f(10 * flip_factor, 0.5) );
	this.set_Vec2f("muzzle_pos", muzzle);
	if (interval > 0) {
		interval--;
	}
	else if (interval == 0)
	{
		if ((pilot !is null && ap.isKeyPressed(key_action1))/* ||GetItemAmount(this, vars.AMMO_TYPE[0])>0 */)
		{
			interval = fire_interval;
			this.set_u32("shot_moment", getGameTime());
			ShakeScreen( 9*3, 7, this.getPosition() );
			
			if (pilot.isMyPlayer()&&this.get_u32("last_shot")<getGameTime()+fire_interval-2) {
				//if (carried !is null && carried.getName()!="bino") return;
				shootGun(this.getNetworkID(), clampedAngle+this.getAngleDegrees(), pilot.getNetworkID(), this.getPosition() + muzzle);
				
				CBitStream params;
				params.write_Vec2f(muzzle);
				this.SendCommand(this.getCommandID("play_shoot_sound"),params);
			}
			if (isServer()&&getRules().get_bool("cursor_recoil_enabled")) {
				if (XORRandom(100)<100)
					this.TakeBlob(vars.AMMO_TYPE[0], 1);
			}
		}
	}
		
	cannon.ResetTransform();
	rail.ResetTransform();
	cannon.RotateBy(clampedAngle, Vec2f(15 * flip_factor, 0.5+4));
	rail.RotateBy(clampedAngle, Vec2f(15 * flip_factor, -11.5+4));
		
	this.set_u8("interval", interval);
	this.Sync("interval", true);
	this.set_f32("interval_perc", 1.0f*interval / fire_interval);
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if(cmd == this.getCommandID("play_shoot_sound")) 
	{
		this.set_u32("last_shot", getGameTime());
		Vec2f muzzle = params.read_Vec2f();
		this.getSprite().PlaySound("long_range_mortar_shot", 1, 0.60f + XORRandom(21)*0.01);
		MakeBangEffect(this, "foom", 1.5f, false, Vec2f((XORRandom(10)-5) * 0.1, -(3/2)), muzzle + Vec2f(XORRandom(11)-5,-XORRandom(4)-1));
	}
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	const f32 scalex = getDriver().getResolutionScaleFactor();
	const f32 zoom = getCamera().targetDistance * scalex;
	CMap@ map = getMap();
	const bool flip = blob.isFacingLeft();
	const f32 flip_factor = flip ? -1 : 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	
	CSpriteLayer@ cannon = this.getSpriteLayer("cannon");
	u32 shot_moment = blob.get_u32("shot_moment");
	u32 ticks_from_shot = getGameTime()-shot_moment;
	cannon.SetOffset(blob.get_Vec2f("cannon_def_offset"));
	f32 cannon_kickback = 40;
	cannon.SetOffset(cannon.getOffset()
		+Vec2f(float(cannon_kickback-Maths::Min(cannon_kickback, ticks_from_shot))/4,0).RotateBy(-blob.get_f32("gun_angle") * flip_factor));
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
	return true;
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

f32 getCannonAngle( CBlob@ this, CBlob@ holder, Vec2f muzzle_offset = Vec2f(-69, -69) )
{
	if (this is null) return 0;
	const bool flip = this.isFacingLeft();
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
	if (attached.hasTag("flesh"))
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