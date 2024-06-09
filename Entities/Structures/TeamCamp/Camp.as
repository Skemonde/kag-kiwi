#include "KIWI_Locales"
#include "StandardControlsCommon"

void onInit(CBlob@ this)
{
	//this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.setInventoryName("Delver's Camp");
	this.Tag("spawn");
	
	this.Tag("storingButton");
	this.Tag("takingItemButton");
	this.Tag("replenishButton");
	//this.Tag("remote_storage");
	
	this.getCurrentScript().tickFrequency = 60;
	this.set_bool("pickup", true);
	
	this.set_Vec2f("travel button pos", Vec2f(-this.getWidth()/2, this.getHeight()/2)/4);
}

bool isInRadius(CBlob@ this, CBlob @caller)
{
	return (this.getPosition() - caller.getPosition()).Length() < this.getRadius();
}

bool canPickup(CBlob@ blob)
{
	return blob.hasTag("firearm") || blob.hasTag("material");
}

void onTick(CBlob@ this)
{
	this.SetMinimapRenderAlways(false);
	this.SetMinimapVars("kiwi_minimap_icons.png", 6, Vec2f(1, 0.5f)*16);
	this.SetMinimapOutsideBehaviour(CBlob::minimap_arrow);
	
	PickupOverlap(this);
}

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	blob.getSprite().PlaySound("/PutInInventory.ogg");
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return this.getTeamNum()==forBlob.getTeamNum();
}

void PickupOverlap(CBlob@ this)
{
	if (getNet().isServer() && this.get_bool("pickup"))
	{
		if (this.getInventory().isFull()) return;
		Vec2f tl, br;
		this.getShape().getBoundingRect(tl, br);
		CBlob@[] blobs;
		this.getMap().getBlobsInBox(tl, br, @blobs);
		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ blob = blobs[i];
			if (!blob.isAttached() && blob.isOnGround() && canPickup(blob))
			{
				this.server_PutInInventory(blob);
			}
		}
	}
}