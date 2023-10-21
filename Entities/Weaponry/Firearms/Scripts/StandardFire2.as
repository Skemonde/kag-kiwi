#include "BulletCase"
#include "MakeBangEffect"
#include "GunStandard"
#include "KIWI_Locales"
#include "FirearmVars"
#include "Hitters"
#include "SocialStatus"
#include "Help"
#include "Knocked"

const uint8 NO_AMMO_INTERVAL = 10;
u8 reloadCMD, setClipCMD;

bool canSendGunCommands(CBlob@ blob)
{
	if (blob is null) return false;
	CPlayer@ player = blob.getPlayer();
	if (player is null) return false;
	
	return (blob.isMyPlayer() || (isClient() && (player.isBot()||blob.hasTag("bot")))) && !isKnocked(blob);
}

void onInit(CBlob@ this) 
{
	this.Tag("firearm");
	
	AttachmentPoint@ pickup_point = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (pickup_point is null) return;
	this.set_Vec2f("pickup_default_offset", pickup_point.offset);
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	AttachmentPoint@ point = blob.getAttachments().getAttachmentPointByName("PICKUP");
	CBlob@ holder = point.getOccupied();
	@holder = getHolder(blob, holder);
}

CBlob@ getHolder(CBlob@ this, CBlob@ holder)
{
	//print("was called");
	if (true) {
		//print("holder is null");
		CBlob@ tripod = getBlobByNetworkID(this.get_u16("tripod_id"));
		if (tripod !is null) {
			//print("tripod is ok");
			CBlob@ gunner = getBlobByNetworkID(tripod.get_u16("gunner_id"));
			if (gunner !is null && gunner.isAttachedTo(tripod) && this.isAttachedTo(tripod)) {
				
				return gunner;
				//print("gunner is ok");
			}
		} //else print("tripod is NOT ok");
		//print("gothere1");
		if (holder !is null && holder.getPlayer() is null) {
			//print("gothere2");
			//print("tripod id"+this.get_u16("tripod_id"));
			if (tripod !is null) {
				//print("tripod isn't null!");
				AttachmentPoint@ gunner_seat = tripod.getAttachments().getAttachmentPointByName("MACHINEGUNNER");
				if (gunner_seat !is null) {
					//print("gunner_seat isn't null!");
					@holder = gunner_seat.getOccupied();
					if (holder !is null) {
						//print("holder "+holder.getName());
						return holder;
					}
				}
			}
		}
		return holder;
	}
	return null;
}

void onTick(CBlob@ this) 
{
	const bool FLIP = this.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	FirearmVars@ vars;
	if (!this.get("firearm_vars", @vars)) return;
	AttachmentPoint@ pickup_point = this.getAttachments().getAttachmentPointByName("PICKUP");
	const Vec2f PICKUP_DEFAULT_OFFSET = this.get_Vec2f("pickup_default_offset");
	
	if (pickup_point is null) {
		error("Pickup point is null in a firearm!");
		return;
	}
	
	
	CBlob@ holder = pickup_point.getOccupied();
	if (holder is null) return;
	
	const f32 GUN_ANGLE = getAimAngle(this, holder)-90*FLIP_FACTOR;
	pickup_point.offset = Vec2f()+PICKUP_DEFAULT_OFFSET+Vec2f(-10, 0).RotateBy(GUN_ANGLE*FLIP_FACTOR, Vec2f());
	
	this.setAngleDegrees(GUN_ANGLE);
}

void onRender(CSprite@ this)
{
	const f32 SCALEX = getDriver().getResolutionScaleFactor();
	const f32 ZOOM = getCamera().targetDistance * SCALEX;
	
	FirearmVars@ vars;
	this.getBlob().get("firearm_vars", @vars);
}