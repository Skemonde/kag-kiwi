#include "KIWI_Players&Teams"
#include "KIWI_RespawnSystem"
//#include "KIWI_Locales"
#include "RulesCore"
#include "EquipmentCommon"

void onInit(CBlob@ this)
{
	//this.setInventoryName(Names::combat_helmet);
	this.Tag("bullet_hits");
	//this.Tag("no bullet affecting");
	this.Tag("crate pickup");
	//this.Tag("material");
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @ap)
{
	this.setAngleDegrees(0);
	this.getSprite().ResetTransform();
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{
	CShape@ shape = this.getShape();
	if (shape is null) return;
	shape.checkCollisionsAgain = true;
}

void onThisAddToInventory( CBlob@ this, CBlob@ inventoryBlob )
{
	PutHatOn(this, inventoryBlob, true);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (this.getTickSinceCreated()<30) return;
	
	PutHatOn(this, blob);
	
	if (!solid)
	{
		//return;
	}

	u16 sound_num = XORRandom(2) + 1;
	const f32 vellen = this.getOldVelocity().Length();
	if (vellen > 1.7f && (blob !is null && (blob.getShape().isStatic() && blob.isCollidable() || blob.getName() == this.getName()) || blob is null))
	{
		Sound::Play("GrenadeDrop" + sound_num, this.getPosition(), 0.4, 1.0f + XORRandom(2)*0.1);
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return !(blob.hasTag("player") || blob.hasTag("vehicle"));
}