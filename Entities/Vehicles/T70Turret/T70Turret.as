#include "FirearmVars"
#include "MakeBangEffect"
#include "Skemlib"
#include "BulletCase"
#include "TanksCommon"

void onInit( CBlob@ this )
{
	this.Tag("bullet_hits");
	this.Tag("turret");
	this.Tag("non_pierceable");
	if (getNet().isServer())
	{
		CBlob@ blob = server_CreateBlob("t70_cannon");
		if (blob !is null)
		{
			blob.server_setTeamNum(this.getTeamNum());
			//blob.setInventoryName(this.getInventoryName() + "'s Turret");
			//blob.getShape().getConsts().collideWhenAttached = true;
			blob.getSprite().SetRelativeZ(40);
			this.server_AttachTo(blob, "GUNPOINT");
			this.set_u16("mg_id", blob.getNetworkID());
			blob.set_u16("tripod_id", this.getNetworkID());
		}
	}
	AttachmentPoint@ gunner = this.getAttachments().getAttachmentPointByName("AMOGUS");
	if (gunner !is null)
	{
		gunner.SetKeysToTake(key_left | key_right | key_up | key_down);
		// pilot.SetMouseTaken(true);
	}
	this.set_Vec2f("initial_pilot_offset", Vec2f(-2, -13));
}

void GayAssLogic(CBlob@ this)
{
	if (this.getTickSinceCreated()>2) return;
	
	CBlob@ tank = getBlobByNetworkID(this.get_u16("mothertank_id"));
	if (tank is null) return;
	this.SetFacingLeft(tank.isFacingLeft());
	CBlob@ cannon = getBlobByNetworkID(this.get_u16("mg_id"));
	if (cannon is null) return;
	cannon.SetFacingLeft(this.isFacingLeft());
}

void onTick( CBlob@ this )
{
	GayAssLogic(this);
	ReadPlayerMoves(this);
	
	AttachmentPoint@ gunner = this.getAttachments().getAttachmentPointByName("AMOGUS");
	if (gunner is null) return;
	CBlob@ gun = getBlobByNetworkID(this.get_u16("mg_id"));
	if (gun is null) return;
	gun.setAngleDegrees(this.getAngleDegrees());
	CBlob@ gunner_blob = gunner.getOccupied();
	if (gunner_blob is null) return;
	this.SetFacingLeft(gunner_blob.isFacingLeft());
	gunner_blob.setAngleDegrees(this.getAngleDegrees());
	gun.SetFacingLeft(gunner_blob.isFacingLeft());
}

void ReadPlayerMoves(CBlob@ this)
{
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("AMOGUS");
	if (ap is null) return;
	ap.SetKeysToTake(key_left);
	
	Vec2f p_offset = this.get_Vec2f("initial_pilot_offset");
	if (!this.hasTag("pilotInside"))
		this.set_Vec2f("pilot_offset", Vec2f(p_offset.x, p_offset.y));
	ap.offset = this.get_Vec2f("pilot_offset");
	
	CBlob@ pilot = ap.getOccupied();
	if (pilot is null) return;
	
	bool enabled = true;
	
	if (enabled && ap.isKeyPressed(key_down) && !pilot.hasTag("isInVehicle") && getGameTime()-this.get_u32("last_visit")>17) {
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
		}
		ap.SetKeysToTake(key_action2);
	}
	
	AttachmentPoint@ pilot_pickup = pilot.getAttachments().getAttachmentPointByName("PICKUP");
	if (pilot_pickup is null) return;
	
	pilot_pickup.offsetZ = this.hasTag("pilotInside")?-10:30;
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	CBlob@ tank = getBlobByNetworkID(this.get_u16("mothertank_id"));
	if (tank is null) return 0;
	
	hitterBlob.server_Hit(tank, worldPoint, velocity, damage, customData);
	return 0;
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
	return;
	CPlayer@ localplayer = getLocalPlayer();
	if (localplayer is null) return;
	
	CSpriteLayer@ insignia = this.getSpriteLayer("insignia");
	
	if (insignia is null) {
		@insignia = getVehicleInsignia(this);
		insignia.SetOffset(Vec2f(6, 3));
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	if (this.isAttachedToPoint("SCHOOL_SHOOTER"))
		return true;
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

void onDie(CBlob@ this)
{
	CBlob@ cannon = getBlobByNetworkID(this.get_u16("mg_id"));
	if (cannon !is null)
		cannon.server_Die();		
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

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	if (attachedPoint.name=="GUNPOINT") {
		attachedPoint.offsetZ=0.3f;
	}
	if (!attached.hasTag("player")) return;
	this.set_u16("gunner_id", attached.getNetworkID());
}

void ResetPickupZ(CBlob@ pilot)
{
	AttachmentPoint@ pilot_pickup = pilot.getAttachments().getAttachmentPointByName("PICKUP");
	if (pilot_pickup is null) return;
	
	pilot_pickup.offsetZ = 0;
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{
	if (detached !is null)
	{
		if (detached.hasTag("flesh")) {
			detached.Untag("isInVehicle");
			this.Untag("pilotInside");
			detached.AddForce(Vec2f(0.0f, -4.0)*detached.getMass());
			ResetPickupZ(detached);
		}
	}
}