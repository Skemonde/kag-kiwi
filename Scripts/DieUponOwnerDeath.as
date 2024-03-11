//skript by skemond <3
#define SERVER_ONLY

#include "KIWI_RulesCore"
#include "KIWI_Players&Teams"

void onInit(CBlob@ this)
{
	//this.getCurrentScript().tickFrequency = 2;
}

void onTick(CBlob@ this)
{	
	CPlayer@ owner = this.getDamageOwnerPlayer();
	if (owner is null) {
		this.server_Die();
		return;
	}
	
	CBlob@ owner_blob = owner.getBlob();
	if (owner_blob is null) {
		this.server_Die();
	} else if (owner_blob.hasTag("dead"))
		this.server_Die();
}