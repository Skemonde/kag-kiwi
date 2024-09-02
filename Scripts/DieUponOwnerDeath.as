//skript by skemond <3
#define SERVER_ONLY

//#include "KIWI_RulesCore"
//#include "KIWI_Players&Teams"

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint) 
{
	if (!attached.hasTag("player")) return;
	CPlayer@ player = attached.getPlayer();
	if (player is null) return;
	
	this.set_u16("item_owner_id", player.getNetworkID());
}
/* 
void onInit(CBlob@ this)
{
	//this.getCurrentScript().tickFrequency = 28;
}

void onTick(CBlob@ this)
{	
	return;
	CPlayer@ owner = this.getDamageOwnerPlayer();
	if (owner is null) {
		this.server_Die();
		return;
	}
	
	CBlob@ owner_blob = owner.getBlob();
	if (owner_blob is null) {
		this.server_Die();
	} else if (owner_blob.hasTag("dead") || owner_blob.getTickSinceCreated() < 1)
		this.server_Die();
}
 */