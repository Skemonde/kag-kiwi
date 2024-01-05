//#define SERVER_ONLY

#include "FirearmVars"
#include "KIWI_RespawnSystem"
#include "KIWI_Players&Teams"

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 12;
	this.getCurrentScript().removeIfTag = "dead";
	
	this.addCommandID("give picking up tag");
}

bool EngiPickup(CBlob@ this, CBlob@ item)
{
	if (this is null || item is null) return false;
	CBlob@ carried = this.getCarriedBlob();
	//if (carried is null) return false;
	
	if (this.getBlobCount("masonhammer")<1) return false;
	
	return item.hasScript("MaterialStandard.as")&&!item.hasTag("ammo");
}

bool SoldiPickup(CBlob@ this)
{
	if (this.getName()!="soldat") return false;
	return false;
}

void Take(CBlob@ this, CBlob@ blob)
{
	CRules@ rules = getRules();
	CPlayer@ player = this.getPlayer();
	const string blobName = blob.getName();
	if (this is null || rules is null || blob is null) return;
	CBlob@ carried = this.getCarriedBlob();
	bool canPutInInventory = true;
	
	//KIWIRespawn spawns();
	//KIWICore core(rules, spawns);
	
	if (!this.isAttached() && !blob.hasTag("no pickup"))
	{
		// if it's bot autopickup is always active
		if (player is null)
			canPutInInventory = true;
		else {
			canPutInInventory = rules.get_bool(player.getUsername() + "autopickup");
			
			KIWICore@ core;
			getRules().get("core", @core);
			if (core is null) return;
			
			KIWIPlayerInfo@ info = cast < KIWIPlayerInfo@ > (core.getInfoFromPlayer(player));
			if (info is null) return;
			canPutInInventory = info.auto_pickup;
		}
		if (!canPutInInventory) return;
		
		CBlob@[] blob_touched;
		getMap().getBlobsInRadius(blob.getPosition(), 4, @blob_touched);
		//not actually touched but yeah
		for (int idx = 0; idx < blob_touched.size(); ++idx) {
			CBlob@ touched = blob_touched[idx];
			if (touched is null) continue;
			
			if (touched.getName()=="advancedconveyor" && Maths::Abs(blob.getVelocity().x)>0.3f) return;
		}
		
		if ((this.getDamageOwnerPlayer() is blob.getPlayer()) || getGameTime() > blob.get_u32("autopick time"))
		{
			bool add = false;
			if (!blob.hasTag("no auto pickup") && (blob.hasTag("ammo") || blob.hasTag("material") || EngiPickup(this, blob))) //only add ammo if we have something that can use it, or if same ammo exists in inventory.
			{
				add = false;
				//array
				CBlob@[] items;
				//adding held item to array
				if (carried != null)
				{
					items.push_back(carried);
				}
				//adding items from inventory to array
				CInventory@ inv = this.getInventory();
				for (int i = 0; i < inv.getItemsCount(); i++)
				{
					CBlob@ item = inv.getItem(i);
					items.push_back(item);
				}
				//checking for all items in the array if we have a match with the item on a floor
				for (int i = 0; i < items.size(); i++)
				{
					CBlob@ item = items[i];
					FirearmVars@ vars;
					item.get("firearm_vars", @vars);
	
					// adds blob only if one of inventory items is the same as the blob AND/OR if blob is the same as the ammotype string of the item(gun)
					if ((vars !is null && vars.AMMO_TYPE.find(blob.getName())>-1) || item.getName() == blob.getName())
					{
						add = true;
						break;
					}
				}
				if (EngiPickup(this, blob))
					add = true;
			}
			
			if (!add) return;
			
			//all this fuckery allows to check if the blob would take space we need for a carried blob
			Vec2f blob_old_pos = blob.getPosition();
			
			s32 blob_id = -1;
			if (carried !is null && this.isMyPlayer())
				blob_id = carried.getNetworkID();
			
			//tagging so gun doesn't stop reloading
			SendTagCommand(this, blob_id);
			
			//if inventory is full to the brim
			if (!this.server_PutInInventory(blob)) {
				SendTagCommand(this, blob_id);
				return;
			}
			
			//if we managed to put a blob in our inventory but then we can't store our carried - pulling that blob back
			if (carried !is null) {
				if (!this.server_PutInInventory(carried)) {
					this.server_PutOutInventory(blob);
					blob.setPosition(blob_old_pos);
				} else {
					this.server_Pickup(carried);
				}
			}
			//not keeping this tag
			SendTagCommand(this, blob_id);
		}
	}
}

bool SendTagCommand(CBlob@ this, s32 blob_id)
{
	if (blob_id < 0) return false;
	CBitStream params;
	params.write_u16(blob_id);
	
	this.SendCommand(this.getCommandID("give picking up tag"), params);
	
	return true;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null || blob.getShape().vellen > 1.0f)
	{
		return;
	}
	
	Take(this, blob);
}

void onTick(CBlob@ this)
{
	CBlob@[] overlapping;

	if (this.getOverlapping(@overlapping))
	{
		for (uint i = 0; i < overlapping.length; i++)
		{
			CBlob@ blob = overlapping[i];
			{
				if (blob.getShape().vellen > 1.0f)
				{
					continue;
				}

				Take(this, blob);
			}
		}
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if(cmd == this.getCommandID("give picking up tag"))
	{
		u16 blob_id; if (!params.saferead_u16(blob_id)) return;
		//if (isServer()) return;
		CBlob@ blob = getBlobByNetworkID(blob_id);
		
		if (blob.hasTag("quick_detach"))
			blob.Untag("quick_detach");
		else
			blob.Tag("quick_detach");
	}
}

// make ignore collision time a lot longer for auto-pickup stuff
void IgnoreCollisionLonger(CBlob@ this, CBlob@ blob)
{
	if (this.hasTag("dead"))
	{
		return;
	}

	const string blobName = blob.getName();
	bool addCooldown = false;

	if (addCooldown)
	{
		blob.set_u32("autopick time", getGameTime() +  getTicksASecond() * 7);
		blob.SetDamageOwnerPlayer(blob.getPlayer());
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	IgnoreCollisionLonger(this, detached);
}

void onRemoveFromInventory(CBlob@ this, CBlob@ blob)
{
	IgnoreCollisionLonger(this, blob);
}
