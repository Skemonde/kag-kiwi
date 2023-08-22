//#include "MapFlags"
#include "Hitters"
#include "KIWI_Hitters"
#include "GenericGibsEnum"

void onInit(CBlob@ this)
{
	//this.getShape().SetRotationsAllowed(false);
	this.getSprite().getConsts().accurateLighting = false;
	this.getSprite().SetZ(30); //foreground
	//this.server_setTeamNum(-1); //allow anyone to break them

	this.Tag("builder always hit");
	this.Tag("heavy weight");
	this.Tag("no force from flying");
	
	//this.getCurrentScript().runFlags |= Script::tick_not_attached;
}

bool canBePutInInventory( CBlob@ this, CBlob@ inventoryBlob )
{
	return !inventoryBlob.hasTag("player");
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	this.setVelocity(Vec2f());
	return damage;
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return blob.hasTag("vehicle")&&blob.getTeamNum()!=this.getTeamNum()||blob.getName()==this.getName();
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
    return byBlob.getTeamNum()==this.getTeamNum();
}