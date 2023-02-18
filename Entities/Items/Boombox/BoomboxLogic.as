#include "Tunes.as";

void onInit(CBlob@ this)
{
	this.addCommandID("insert_tape");
	this.set_u32("tune", tunes.length-1);
}

void onTick(CBlob@ this)
{
	if (this.get_u32("tune") >= tunes.length-1)
		this.Untag("playing");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBlob@ carried = caller.getCarriedBlob();
	if (carried !is null && carried.getName() == "tape") {
		u16 carried_netid = carried.getNetworkID();
		CBitStream params;
		params.write_u16(carried_netid);
		
		caller.CreateGenericButton("$tape$", Vec2f(0,0), this, this.getCommandID("insert_tape"), "Insert a Tape!", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("insert_tape")) {
		CBlob@ carried = getBlobByNetworkID(params.read_u16());
		if(carried !is null){
			u32 tune_num = carried.get_u32("customData");
			this.set_u32("tune", tune_num);
			carried.server_Die();
			
			if (this.get_u32("tune") < tunes.length-1) {
				this.Tag("playing");
				this.getSprite().SetEmitSound(tunes[this.get_u32("tune")]);
				this.getSprite().SetEmitSoundPaused(false);
			}
			else {
				this.getSprite().SetEmitSoundPaused(true);
			}
		}
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint) 
{
	this.setAngleDegrees(0);
}

bool canBePutInInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	return false;
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return !(blob.hasTag("player") || blob.hasTag("vehicle"));
}