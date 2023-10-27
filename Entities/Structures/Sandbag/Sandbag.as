//#include "MapFlags"
#include "Hitters"
#include "KIWI_Hitters"
#include "GenericGibsEnum"

void onInit(CBlob@ this)
{
	//this.getShape().SetRotationsAllowed(false);
	this.getSprite().getConsts().accurateLighting = false;
	this.getSprite().SetZ(30); //foreground
	this.server_setTeamNum(-1); //allow anyone to break them

	this.Tag("builder always hit");
	this.Tag("bullet_hits");
	this.Tag("non_pierceable");
	this.Tag("blocks sword");
	this.Tag("heavy weight");
	
	this.set_f32("hand angle offset", 90);
	
	//this.getCurrentScript().runFlags |= Script::tick_not_attached;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (damage > 0) {
		makeGibParticle("GenericGibs", worldPoint, getRandomVelocity((this.getPosition() - worldPoint).getAngle(), 1.0f + damage/10, 90.0f) + Vec2f(0.0f, -2.0f), Gibs::soil, XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);
		//this.getSprite().PlaySound("SandbagPlace", Maths::Min(1.25f, Maths::Max(0.5f, damage)));
		Sound::Play("SandbagPlace.ogg", this.getPosition(), 1.0f);
	}
	if (customData==Hitters::builder||customData==Hitters::drill) {
		damage=this.getInitialHealth()*2/8;
	}
	if (customData==Hitters::flying) {
		damage=this.getInitialHealth();
	}
	return gunfireHitter(customData)?damage/3:damage;
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	this.setAngleDegrees(0);
}

bool canBePutInInventory( CBlob@ this, CBlob@ inventoryBlob )
{
	return !inventoryBlob.hasTag("player");
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return true;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
    return true;
}

void onDie( CBlob@ this )
{
	if (!isServer()) return;
	
	CBlob@ dirt = server_CreateBlob("dirtpile", -1, this.getPosition());
	if (dirt is null) return;
	dirt.server_SetQuantity(3);
}