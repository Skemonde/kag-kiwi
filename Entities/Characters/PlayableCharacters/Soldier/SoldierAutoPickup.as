//#define SERVER_ONLY

#include "FirearmVars"
#include "KIWI_RespawnSystem"
#include "KIWI_Players&Teams"

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 12;
	this.getCurrentScript().removeIfTag = "dead";
}

bool EngiPickup(CBlob@ this, CBlob@ item)
{
	if (this is null || item is null) return false;
	CBlob@ carried = this.getCarriedBlob();
	//if (carried is null) return false;
	
	if (this.getBlobCount("masonhammer")<1) return false;
	
	return item.hasScript("MaterialStandard.as");
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
		
		if ((this.getDamageOwnerPlayer() is blob.getPlayer()) || getGameTime() > blob.get_u32("autopick time"))
		{
			bool add = false;
			if (blob.hasTag("ammo") || blob.hasTag("material") || EngiPickup(this, blob)) //only add ammo if we have something that can use it, or if same ammo exists in inventory.
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
			if (!this.server_PutInInventory(blob)) return;
			if (carried !is null) carried.Tag("quick_detach");
			if ((carried !is null && !this.server_PutInInventory(carried))) {
				this.server_PutOutInventory(blob);
				blob.setPosition(blob_old_pos);
			} else {
				this.server_Pickup(carried);
			}
		}
	}
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
