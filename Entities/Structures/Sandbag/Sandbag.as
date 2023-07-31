//#include "MapFlags"
#include "Hitters"
#include "HittersKIWI"
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
	
	//this.getCurrentScript().runFlags |= Script::tick_not_attached;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (damage > 0) {
		makeGibParticle("GenericGibs", worldPoint, getRandomVelocity((this.getPosition() - worldPoint).getAngle(), 1.0f + damage, 90.0f) + Vec2f(0.0f, -2.0f), Gibs::soil, XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);
		this.getSprite().PlaySound("destroy_dirt", Maths::Min(1.25f, Maths::Max(0.5f, damage)));
	}
	if (customData==Hitters::builder) {
		damage=this.getInitialHealth()*2/8;
	}
	return gunfireHitter(customData)?damage/3:damage;
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return true;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
    return true;
}