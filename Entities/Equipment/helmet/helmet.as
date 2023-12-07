#include "KIWI_Players&Teams"
#include "KIWI_RespawnSystem"
#include "RulesCore"
#include "EquipmentCommon"

void onInit(CBlob@ this)
{
	this.Tag("bullet_hits");
	this.Tag("stone");
	this.Tag("material");
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

void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
	//return;
	PutHatOn(this, blob);
	
	
	//KIWICore@ core;
	//getRules().get("core", @core);
	//if (core is null) return;
	
	//KIWIPlayerInfo@ info = core.getKIWIInfoFromPlayer(player);
	//if (info is null) return;
	
	
	
	//if (!getRules().get_bool(player_name + "helm")) {
	//	getRules().set_bool(player_name + "helm", true);
	//	getRules().set_string(player_name + "hat_name", this.getName());
	//	//this updates hat layer :P
	//	blob.getSprite().RemoveSpriteLayer("hat");
	//	blob.getSprite().RemoveSpriteLayer("head");
	//	this.server_Die();
	//}
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