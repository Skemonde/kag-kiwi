// TrapBlock.as

#include "Hitters.as";
#include "MapFlags.as";

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-80);
	this.getShape().SetRotationsAllowed(false);
	this.getSprite().getConsts().accurateLighting = false;

	this.Tag("place norotate");
	this.Tag("non_pierceable");
	this.Tag("bullet_hits");
	this.Tag("blocks sword");
	this.Tag("blocks water");
	this.Tag("vehicle");
	this.Tag("collides_everything");

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return true;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	CBlob@ host = getBlobByNetworkID(this.get_u16("owner_blob_id"));
	if (host is null) return damage;
	
	hitterBlob.server_Hit(host, worldPoint, velocity, damage, customData);
	
	return 0;
}