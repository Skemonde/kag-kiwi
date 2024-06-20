#include "FirearmVars"
#include "MakeBangEffect"
#include "Skemlib"
#include "BulletCase"
#include "TanksCommon"

void onInit( CBlob@ this )
{
	this.Tag("bullet_hits");
	this.Tag("turret");
	this.Tag("vehicle");
	this.Tag("non_pierceable");
	
	{
		CBlob@ blob = server_CreateBlob("firsttankcannon");
		if (blob !is null)
		{
			blob.server_setTeamNum(this.getTeamNum());
			//blob.setInventoryName(this.getInventoryName() + "'s Turret");
			//blob.getShape().getConsts().collideWhenAttached = true;
			blob.getSprite().SetRelativeZ(40);
			this.server_AttachTo(blob, "GUNPOINT");
			this.set_u16("cannon_id", blob.getNetworkID());
			blob.set_u16("storage_id", this.get_u16("mothertank_id"));
			blob.set_u16("turret_id", this.getNetworkID());
		}
	}
	
	AttachmentPoint@ gunner = this.getAttachments().getAttachmentPointByName("TURRET_GUNNER");
	if (gunner !is null)
	{
		gunner.SetKeysToTake(key_left | key_right | key_up | key_down);
		// pilot.SetMouseTaken(true);
	}
	this.set_Vec2f("initial_pilot_offset", Vec2f(-2, -13));
	this.getSprite().SetZ(-3);
	
	CSpriteLayer@ front_plate = this.getSprite().addSpriteLayer("front_plate", "FirstTankTurret.png", 40, 20, this.getTeamNum(), 0);
	if (front_plate !is null) {
		front_plate.SetFrame(1);
		front_plate.SetRelativeZ(10);
		front_plate.SetOffset(Vec2f(0,-8));
	}
}

void GayAssLogic(CBlob@ this)
{
	if (this.getTickSinceCreated()>2&&false) return;
	
	CBlob@ tank = getBlobByNetworkID(this.get_u16("mothertank_id"));
	if (tank is null) return;
	this.SetFacingLeft(tank.isFacingLeft());
	CBlob@ cannon = getBlobByNetworkID(this.get_u16("cannon_id"));
	if (cannon is null) return;
	cannon.set_Vec2f("gun_trans_from_carrier", Vec2f(-5, 0));
	cannon.SetFacingLeft(this.isFacingLeft());
	cannon.getSprite().SetZ(-30);
}

void onTick( CBlob@ this )
{
	GayAssLogic(this);
	ReadPlayerMoves(this);
}

void ReadPlayerMoves(CBlob@ this)
{	
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("TURRET_GUNNER");
	if (ap is null) return;
	
	CBlob@ pilot = ap.getOccupied();
	if (pilot is null) return;
	pilot.SetFacingLeft(this.isFacingLeft());
	pilot.setAngleDegrees(this.getAngleDegrees());
	ap.offsetZ= 1;
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
	CBlob@ cannon = getBlobByNetworkID(this.get_u16("cannon_id"));
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
		attachedPoint.offsetZ=-40.3f;
	}
	if (!attached.hasTag("player")) return;
	this.set_u16("gunner_id", attached.getNetworkID());
	attached.Tag("isInVehicle");
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