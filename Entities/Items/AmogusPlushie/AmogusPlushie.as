#include "Hitters.as";
#include "Knocked.as";

void onInit(CBlob@ this)
{
    this.server_setTeamNum(XORRandom(6));

	this.Tag("ignore fall");
	this.Tag("sussy");
	this.set_u32("next attack", 0);
	if (!this.exists("color")) this.set_u8("color", XORRandom(12));

	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action1);
	}
	
	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		Animation@ anim = sprite.getAnimation("default");
		if (anim !is null)
		{
			sprite.animation.frame = this.get_u8("color");
		}
	}
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1 )
{
    if (blob !is null && this.get_u8("color") == 0 && (blob.hasTag("sussy") || blob.hasTag("player")))
    {
		if (XORRandom(4) == 2) Sound::Play("amoamogus2", this.getPosition(), 1.4f, 1.1f + (XORRandom(4)-2)*0.01);
	}
	if (solid) {
		this.getSprite().PlaySound("launcher_boing"+(XORRandom(2)), this.getVelocity().Length()/20, 1);
	}
}

void onTick(CBlob@ this)
{	
	if (this.getTickSinceCreated() == XORRandom(5) && !this.hasTag("no_more_sound"))
	{
		Sound::Play("amoamogus1", this.getPosition(), 1.9f, 1.0f + XORRandom(2)-1);
		this.Tag("no_more_sound");
	}
	if (this.isAttached())
	{
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		CBlob@ holder = point.getOccupied();
		
		if (holder is null) return;

		if (getKnocked(holder) <= 0)
		{
			if (holder.isKeyPressed(key_action1) || point.isKeyPressed(key_action1))
			{
				if (this.get_u32("next attack") > getGameTime()) return;
			
				if (isClient())
				{
					Sound::Play("amoamogus0", this.getPosition(), 0.4f, 1.1f + (XORRandom(4)-2)*0.01);
				}
				
				this.set_u32("next attack", getGameTime() + 4 + XORRandom(10));
			}
		}
	}
}

void onDetach(CBlob@ this,CBlob@ detached,AttachmentPoint@ attachedPoint)
{
	Sound::Play("amoamogus1", this.getPosition(), 1.9f, 1.0f + XORRandom(2)-1);
	detached.Untag("noLMB");
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	this.getSprite().ResetTransform();
	attached.Tag("noLMB");
}
