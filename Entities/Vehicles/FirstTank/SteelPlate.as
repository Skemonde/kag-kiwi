// TrapBlock.as

#include "Hitters.as";
#include "MapFlags.as";

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-80);
	this.getShape().SetRotationsAllowed(false);
	this.getSprite().getConsts().accurateLighting = false;
	
	this.getShape().getConsts().collideWhenAttached = true;
	this.getShape().getConsts().transports = true;

	this.Tag("place norotate");
	this.Tag("non_pierceable");
	this.Tag("bullet_hits");
	this.Tag("blocks sword");
	this.Tag("blocks water");
	this.Tag("vehicle");
	this.Tag("collides_everything");

	//this.getCurrentScript().runFlags |= Script::tick_not_attached;
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return false;
	
	CBlob@ host = getBlobByNetworkID(this.get_u16("owner_blob_id"));
	if (host is null) return false;
	
	return host.doesCollideWithBlob(blob);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null) return;
	CPlayer@ player = blob.getPlayer();
	if ((player is null || !player.isMyPlayer()) && blob.hasTag("player")) return;
	
	this.getShape().getConsts().transports = blob.getPosition().y<(this.getPosition().y-this.getHeight()/2);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	CBlob@ host = getBlobByNetworkID(this.get_u16("owner_blob_id"));
	if (host is null) return damage;
	
	f32 dmg_mod = 0.1f;
	
	if ((getGameTime()-host.get_u32("last_hit"))>1)
		hitterBlob.server_Hit(host, worldPoint, velocity, damage*dmg_mod, customData);
	else
	{
		//print("didn't hit host");
	}
	
	return 0;
}