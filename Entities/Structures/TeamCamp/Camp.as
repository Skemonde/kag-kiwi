#include "KIWI_Locales.as";

void onInit(CBlob@ this)
{
	//this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.setInventoryName("Delver's Camp");
	this.Tag("spawn");
	this.getCurrentScript().tickFrequency = 60;
	this.set_bool("pickup", true);
	
	this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 9, Vec2f(8, 8));
	this.SetMinimapRenderAlways(true);
}

bool canPickup(CBlob@ blob)
{
	return blob.hasTag("firearm") || blob.hasTag("material");
}

void onTick(CBlob@ this)
{
	PickupOverlap(this);
}

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	blob.getSprite().PlaySound("/PutInInventory.ogg");
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