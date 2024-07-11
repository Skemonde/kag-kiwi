#include "Hitters.as";
#include "MetroBoomin";

void onInit(CBlob@ this)
{
	this.Tag("explosive");
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	switch (customData)
	{
		case Hitters::sword:
			damage = 0;
			break;
	}
	
	return damage;
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	this.setAngleDegrees(0);
}

void onTick(CBlob@ this)
{
	if (this.hasTag("DoExplode")||this.isAttached()) return;
	
	if (this.getVelocity().Length()>1.5) {
		this.setAngleDegrees(-this.getVelocity().Angle()-90);
		this.set_f32("bomb angle", -this.getVelocity().Angle());
	}
	else if (this.isAttached())	{
		this.set_f32("bomb angle", this.getAngleDegrees());
	}
}

// void onCollision(CBlob@ this, CBlob@ blob, bool solid)
// {
	// print("hit");
	
	// return this.getTeamNum() != blob.getTeamNum() && blob.hasTag("building");
// }

// bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
// {
	// return this.getTeamNum() != blob.getTeamNum() && blob.hasTag("building");
// }