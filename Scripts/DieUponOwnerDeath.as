//skript by skemond <3
#define SERVER_ONLY

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 20;
}

void onTick(CBlob@ this)
{
	CPlayer@ owner = this.getDamageOwnerPlayer();
	if (owner is null) {
		return;
	} 
	CBlob@ owner_blob = owner.getBlob();
	if (owner_blob is null) {
		this.server_Die();
		return;
	} else if (owner_blob.hasTag("dead"))
		this.server_Die();
}