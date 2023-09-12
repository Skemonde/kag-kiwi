#include "KIWI_Players&Teams"
#include "KIWI_RespawnSystem"
#include "RulesCore"

void onInit(CBlob@ this)
{
	this.Tag("bullet_hits");
	this.Tag("stone");
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
	shape.checkCollisionsAgain;
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
	if (blob is null) return;
	CPlayer@ player = blob.getPlayer();
	if (player is null) return;
	string player_name = player.getUsername();
	
	
	KIWICore@ core;
	getRules().get("core", @core);
	if (core is null) return;
	
	KIWIPlayerInfo@ info = core.getKIWIInfoFromPlayer(player);
	if (info is null) return;
	
	string player_hat = getRules().get_string(player_name+"hat_name");
	
	if (player_hat.empty()) {
		getRules().set_string(player_name+"hat_name", this.getName());
		getRules().set_bool(player_name + "helm", true);
		//blob.getSprite().RemoveSpriteLayer("hat");
		//blob.getSprite().RemoveSpriteLayer("head");
		blob.SendCommand(blob.getCommandID("set head to update"));
		this.server_Die();
	}
	
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