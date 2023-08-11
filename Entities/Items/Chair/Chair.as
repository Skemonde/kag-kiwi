
#include "Hitters.as"
#include "KIWI_Hitters.as"

void onInit(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	sprite.SetRelativeZ(-20.0f);
	CSpriteLayer@ back = sprite.addSpriteLayer("back", sprite.getFilename(), 13, 16);
	if (back !is null)
	{
		back.SetRelativeZ(-20.1f);
		back.SetOffset(sprite.getOffset());
		back.SetFrameIndex(1);
	}

	this.Tag("furniture");
	this.Tag("usable by anyone");
	this.set_f32("pickup_priority", 8.00f); // The lower, the higher priority
	this.set_u8("hurtoncollide hitter", HittersKIWI::chair);

	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PILOT");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_up);
	}
}

void onTick(CSprite@ this)
{
	//this.SetZ(0);

	CSpriteLayer@ back = this.getSpriteLayer("back");
	if (back !is null)
	{	
		//back.SetRelativeZ(-0.1f);
	}
}

void onTick(CBlob@ this)
{
	AttachmentPoint@ ap2 = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (isServer() && ap2 !is null && ap2.getOccupied() !is null && ap2.getOccupied().isAttached()) this.server_DetachFrom(ap2.getOccupied());
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PILOT");
	if (ap !is null)
	{
		if (ap.isKeyJustPressed(key_up))
		{
			if (isServer())
			{
				CBlob@ pilot = ap.getOccupied();
				if (pilot !is null)  pilot.server_DetachFrom(this);
			}
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
    return this.getVelocity().Length() > 0.6f && (blob.getShape().isStatic() || (blob.hasTag("player") && blob.getTeamNum() != this.getTeamNum())) || blob.hasTag("furniture");
}
