
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

void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
	if (blob is null) return;
	CPlayer@ player = blob.getPlayer();
	if (player is null) return;
	string player_name = player.getUsername();
	if (!getRules().get_bool(player_name + "helm")) {
		getRules().set_bool(player_name + "helm", true);
		getRules().set_string(player_name + "hat_name", this.getName());
		//this updates hat layer :P
		blob.getSprite().RemoveSpriteLayer("hat");
		blob.getSprite().RemoveSpriteLayer("head");
		this.server_Die();
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