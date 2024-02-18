#include "Tunes.as";

void onInit(CBlob@ this)
{
	this.addCommandID("insert_tape");
	this.set_u32("tune", tunes.length-1);
	this.Tag("bullet_hits");
	this.Tag("steel");
}

void onTick(CBlob@ this)
{
	if (this.get_u32("tune") >= tunes.length-1)
		this.Untag("playing");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBlob@ carried = caller.getCarriedBlob();
	if ((caller.getTeamNum() == this.getTeamNum() || this.getTeamNum() == 255)) {
		u16 carried_netid = 0;
		if (carried !is null)
			carried_netid = carried.getNetworkID();
		CBitStream params;
		params.write_u16(carried_netid);
		
		CButton@ b = caller.CreateGenericButton("$tape$", Vec2f(0,0), this, this.getCommandID("insert_tape"), "Insert a Tape!", params);
		if (b !is null)
			b.SetEnabled(!this.isAttached() && carried !is null && carried.getName() == "tape" && carried.get_u32("customData")!=this.get_u32("tune"));
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("insert_tape")) {
		CBlob@ carried = getBlobByNetworkID(params.read_u16());
		if(carried !is null){
			u32 tune_num = Maths::Min(tunes.length-1, carried.get_u32("customData"));
			u32 old_tune = this.get_u32("tune");
			
			this.set_u32("tune", tune_num);
			carried.server_Die();
			
			if (this.get_u32("tune") < tunes.length-1) {
				this.Tag("playing");
				this.getSprite().SetEmitSoundPaused(false);
			}
			else {
				this.getSprite().SetEmitSoundPaused(true);
			}
			
			if (old_tune < tunes.length-1 && isServer()) {
				CBlob@ prev_tape = server_CreateBlob("tape", this.getTeamNum(), this.getPosition()+Vec2f(0,-8));
				if (prev_tape !is null) {
					prev_tape.setVelocity(Vec2f(0,-4));
					prev_tape.set_u32("customData", old_tune);
				}
			}
		}
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint) 
{
	this.setAngleDegrees(0);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return this.isOverlapping(byBlob);
}

bool canBePutInInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	return true;
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return !(blob.hasTag("player") || blob.hasTag("vehicle"));
}