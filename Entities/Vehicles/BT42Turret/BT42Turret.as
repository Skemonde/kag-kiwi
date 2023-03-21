#include "FirearmVars"
#include "MakeBangEffect"
#include "GetItemAmount"

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
	AttachmentPoint@ pipo = this.getAttachments().getAttachmentPointByName("AMOGUS");
	this.set_Vec2f("pilot_offset", pipo.offset);
	this.set_Vec2f("initial_pilot_offset", pipo.offset);
	
	// converting
	this.set_u8("interval", 0);
	this.Tag("tank");
	this.Tag("vehicle");
	this.Tag("convert on sit");
	this.set_bool("facingLeft", false);
	this.set_bool("turning", true);
	this.addCommandID("play_shoot_sound");
	
	FirearmVars vars = FirearmVars();
	vars.BUL_PER_SHOT				= 1;
	vars.B_SPREAD					= 0;
	
	vars.B_GRAV						= Vec2f(0, 0.033);
	vars.B_DAMAGE					= 2;
	vars.B_HITTER					= HittersKIWI::bullet_hmg;
	vars.B_TTL_TICKS				= 100;
	vars.B_KB						= Vec2f_zero;
	vars.B_SPEED					= 20;
	vars.B_PENETRATION				= 0;
	vars.FIRE_SOUND					= "anime_bang.ogg";
	vars.FIRE_PITCH					= 1.0f;
	vars.CART_SPRITE				= "empty_tank_shell.png";
	vars.ONOMATOPOEIA				= "";
	vars.AMMO_TYPE					= "tankshells";
	vars.BULLET_SPRITE				= "BulletGauss.png";
	//vars.FADE_SPRITE				= "CoalFade";
	vars.RICOCHET_CHANCE 			= 0;
	//EXPLOSIVE LOGIC
	vars.EXPLOSIVE					= true;
	vars.EXPL_RADIUS 				= 48;
	vars.EXPL_DAMAGE 				= 255;
	vars.EXPL_MAP_RADIUS 			= vars.EXPL_RADIUS;
	vars.EXPL_MAP_DAMAGE 			= 0.4;
	vars.EXPL_RAYCAST 				= true;
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
	
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("AMOGUS");
	Vec2f p_offset = this.get_Vec2f("initial_pilot_offset");
	CBlob@ tank = getBlobByNetworkID(this.get_u16("tank_id"));
	CSpriteLayer@ cannon = sprite.getSpriteLayer("cannon");
	//tag turning defines if the turret can even turn
	//and if it cannot we reset cannon's transform and make it face the direction the tank's facing
	if (tank !is null && !this.get_bool("turning")) {
		facingLeft = tank.isFacingLeft();
		cannon.ResetTransform();
	}
	
	if (!this.hasTag("pilotInside"))
		this.set_Vec2f("pilot_offset", Vec2f(p_offset.x, p_offset.y));
	
	f32 angle = 0;
	this.set_bool("facingLeft", facingLeft);
	if (ap !is null)
	{
		ap.offset = this.get_Vec2f("pilot_offset")
			//point offset depends of turret blob facing direction
			//previously we found facing direction of cannon and we invert it if the turret blob was made facing left due to the hull
			//the turret is attached to
			+(this.isFacingLeft()
			?(facingLeft ? Vec2f_zero : Vec2f(tank_hatch_offset,0))
			:(facingLeft ? Vec2f(tank_hatch_offset,0) : Vec2f_zero));
		ap.SetKeysToTake(key_action1);
		CBlob@ pilot = ap.getOccupied();
		if (pilot !is null)
		{
			cannon.ResetTransform();
			//if pilot and tank are present and we can turn we turn
			if (tank !is null && this.get_bool("turning"))
			{
				Vec2f mousePos = pilot.getAimPos();
				if (mousePos.x < tank.getPosition().x)
				{
					facingLeft = true;
				}
				else if (mousePos.x > tank.getPosition().x)
				{
					facingLeft = false;
				}
			}
			pilot.SetFacingLeft(facingLeft);
			CBlob@ carried = pilot.getCarriedBlob();
			if (carried !is null) {
				carried.SetFacingLeft(facingLeft);
				//carried.getSprite().SetZ(2000);
			}
			pilot.getSprite().SetRelativeZ(-60);
			pilot.setAngleDegrees(vehicle_angle);
			angle = getAimAngle(this, pilot);
			//print("X cord: "+pilot.getAimPos().x/8);
		}
		else
		{
			return;
		}
		this.set_bool("facingLeft", facingLeft);
		
		const bool flip = this.get_bool("facingLeft");
		const f32 flip_factor = flip ? -1 : 1;
		const u16 angle_flip_factor = flip ? 180 : 0;
		
		const f32 clampedAngle = (Maths::Clamp(angle, -30, 10) * flip_factor);
		
		if (pilot !is null) {
			this.set_f32("gun_angle", clampedAngle);
			u8 interval = this.get_u8("interval");
			
			if (ap.isKeyPressed(key_action3) && !pilot.hasTag("isInVehicle")) {
				this.Tag("pilotInside");
				this.set_u32("last_visit", getGameTime());
			} else
			if (ap.isKeyPressed(key_up) && this.hasTag("pilotInside")) {
				this.set_Vec2f("pilot_offset", Vec2f(p_offset.x, p_offset.y));
				pilot.Untag("isInVehicle");
				this.Untag("pilotInside");
			}
			if(this.hasTag("pilotInside")) {
				this.set_Vec2f("pilot_offset", Vec2f(p_offset.x, p_offset.y+Maths::Min(17,getGameTime()-this.get_u32("last_visit"))/17*16));
				if (Maths::Min(17,getGameTime()-this.get_u32("last_visit"))/17 == 1 && !pilot.hasTag("isInVehicle")) {
					pilot.Tag("isInVehicle");
					Sound::Play("GetInVehicle.ogg", pilot.getPosition());
					print("pilot's safe C:");
				}
			}
			
			Vec2f muzzle = Vec2f(30 * flip_factor, 1.5).RotateBy( clampedAngle+this.getAngleDegrees(), Vec2f(10 * flip_factor, 0.5) );
			this.set_Vec2f("muzzle_pos", muzzle);
			if (interval > 0) {
				interval--;
			}
			else if (interval == 0)
			{
				if ((pilot !is null && ap.isKeyPressed(key_action1))||GetItemAmount(this, vars.AMMO_TYPE)>0)
				{
					if (isServer()) {
						shootGun(this.getNetworkID(), clampedAngle+this.getAngleDegrees(), pilot.getNetworkID(), this.getPosition() + muzzle);
						CBitStream params;
						params.write_Vec2f(muzzle);
						this.SendCommand(this.getCommandID("play_shoot_sound"),params);
						interval = 30;
						if (XORRandom(100)<100)
							this.TakeBlob(vars.AMMO_TYPE, 1);
						if (tank !is null) {
							f32 mass = tank.getMass();
							//adding a bit of force for an epic physics effect
							tank.AddForceAtPosition(Vec2f(-3*flip_factor, -mass/4+(30-Maths::Abs(clampedAngle))*(-mass/256)).RotateBy(vehicle_angle), tank.getPosition() + Vec2f(100*flip_factor, 5));
						}
					}
					//SetScreenFlash( 128, 0, 0, 0 );
					ShakeScreen( 9*3, 2, this.getPosition() );
				}
			}
			
			this.set_u8("interval", interval);
			this.Sync("interval", true);
		}
		cannon.RotateBy(clampedAngle, Vec2f(8 * flip_factor, 0.5));
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if(cmd == this.getCommandID("play_shoot_sound")) 
	{
		Vec2f muzzle = params.read_Vec2f();
		this.getSprite().PlaySound("long_range_mortar_shot", 1, 0.60f + XORRandom(21)*0.01);
		MakeBangEffect(this, "foom", 1.5f, false, Vec2f((XORRandom(10)-5) * 0.1, -(3/2)), muzzle + Vec2f(XORRandom(11)-5,-XORRandom(4)-1));
	}
}

void onRender(CSprite@ this)
{
	if (this is null) return;
	CBlob@ blob = this.getBlob();
	const bool flip = blob.get_bool("facingLeft");
	const f32 flip_factor = flip ? -1 : 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	FirearmVars@ vars;
	blob.get("firearm_vars", @vars);
	
	CSpriteLayer@ turret = this.getSpriteLayer("turret");
	CSpriteLayer@ cannon = this.getSpriteLayer("cannon");
	CSpriteLayer@ hatchet = this.getSpriteLayer("hatchet");
	turret.SetFacingLeft(blob.get_bool("facingLeft"));
	cannon.SetFacingLeft(blob.get_bool("facingLeft"));
	cannon.SetOffset(Vec2f(-20, 1.5));
	cannon.SetOffset(cannon.getOffset()
		+Vec2f(float(blob.get_u8("interval")/5),0).RotateBy(-blob.get_f32("gun_angle") * flip_factor));
	hatchet.SetFacingLeft(blob.get_bool("facingLeft"));
	hatchet.SetOffset(Vec2f(3.5,-6.5));
	hatchet.ResetTransform();
	hatchet.RotateBy(-120*flip_factor, Vec2f(6*flip_factor,0));
	if (blob.hasTag("pilotInside"))
		hatchet.RotateBy(Maths::Min(20,getGameTime()-blob.get_u32("last_visit"))/20*120*flip_factor, Vec2f(6*flip_factor,0));
	
	Vec2f pos = blob.getInterpolatedScreenPos();
	AttachmentPoint@ ap = blob.getAttachments().getAttachmentPointByName("AMOGUS");
	if (ap !is null) {
		CBlob@ pilot = ap.getOccupied();
		if (pilot is getLocalPlayerBlob() && pilot.isMyPlayer()) {
			GUI::SetFont("smallest");
			GUI::DrawTextCentered("Gun angle: "+formatFloat(Maths::Round(-blob.get_f32("gun_angle")*flip_factor), "", 0, 0), Vec2f(pos.x, pos.y + 80 + Maths::Sin(getGameTime() / 10.0f) * 10.0f), SColor(0xfffffcf0));
			GUI::SetFont("menu");
			Vec2f muzzle = blob.get_Vec2f("muzzle_pos") + blob.getPosition();
			Vec2f tracer = getDriver().getScreenPosFromWorldPos(muzzle);
			Vec2f CurrentPos = tracer;
			const f32 scalex = getDriver().getResolutionScaleFactor();
			const f32 zoom = getCamera().targetDistance * scalex;
			if (vars !is null) {
				for (int counter = 0; counter < 20*zoom*4; ++counter) {
					const f32 angle = blob.get_f32("gun_angle");
					Vec2f dir = Vec2f((flip ? -1 : 1), 0.0f).RotateBy(angle);
					CurrentPos += ((dir * vars.B_SPEED) - (-vars.B_GRAV * vars.B_SPEED/zoom/1.88 * counter));
					GUI::DrawRectangle(CurrentPos, CurrentPos + Vec2f(4, 4), SColor(255, 0, 255, 0));
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

f32 getAimAngle( CBlob@ this, CBlob@ holder, Vec2f muzzle_offset = Vec2f(-69, -69) )
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
		// условие...
		(muzzle_offset == Vec2f(-69, -69)
			// ...верно?
			? Vec2f(flip_factor*this.get_Vec2f("gun_trans").x*0,
				(this.get_Vec2f("gun_trans").y))//+vars.MUZZLE_OFFSET.y))
			// если нет, то используем параметр, который получили при вызове функции
			: muzzle_offset);
	
	// вращаем конец ствола пушки вокруг плеча персонажа через угол между курсором и этим самым плечом
	// но из-за этого не выходит избежать погрешности, пуля отходит от направления, но это едва заметно :P
	// получи пушку "uzi" и убедись, как здорово работает эта формула!!
	Vec2f pos = this.getPosition() + muzzle_offset.RotateBy(
	constrainAngle(angle_flip_factor-((holder.getAimPos() - holder.getPosition()).Angle())), shoulder_joint);
	
 	Vec2f aimvector = holder.getAimPos() - pos;
	f32 angle = aimvector.Angle() + this.getAngleDegrees();
    return constrainAngle(angle_flip_factor-(angle+flip_factor))*flip_factor;
}

f32 constrainAngle(f32 x)
{
	x = (x + 180) % 360;
	if (x < 0) x += 360;
	return x - 180;
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
		detached.Untag("isInVehicle");
		this.Untag("pilotInside");
		if (detached.hasTag("flesh"))
			detached.AddForce(Vec2f(0.0f, -4.0)*detached.getMass());
	}
}