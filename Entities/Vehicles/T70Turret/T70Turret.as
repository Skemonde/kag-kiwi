#include "FirearmVars"
#include "MakeBangEffect"
#include "Skemlib"
#include "BulletCase"
#include "TanksCommon"

void onInit( CBlob@ this )
{
	this.Tag("turret");
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
}

void onTick( CBlob@ this )
{
	AttachmentPoint@ gunner = this.getAttachments().getAttachmentPointByName("AMOGUS");
	if (gunner is null) return;
	CBlob@ gunner_blob = gunner.getOccupied();
	if (gunner_blob is null) return;
	this.SetFacingLeft(gunner_blob.isFacingLeft());
	gunner_blob.setAngleDegrees(this.getAngleDegrees());
	CBlob@ gun = getBlobByNetworkID(this.get_u16("mg_id"));
	if (gun is null) return;
	gun.SetFacingLeft(gunner_blob.isFacingLeft());
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
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