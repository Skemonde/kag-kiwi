#include "KIWI_Locales.as";

void onInit(CBlob@ this)
{
	//this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.setInventoryName("Delver's Camp");
	this.Tag("spawn");
}

bool canPickup(CBlob@ blob)
{
	return blob.hasTag("firearm") || blob.hasTag("material");
}

void onTick(CBlob@ this)
{
	if (this.getInventory().isFull()) return;
	Vec2f size = Vec2f(this.getWidth()-20, this.getHeight()-24);

	CBlob@[] blobs;
	if (getMap().getBlobsInBox(this.getPosition() - size/2, this.getPosition() + size/2, @blobs))
	{
		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ blob = blobs[i];

			if ((canPickup(blob)) && !blob.isAttached())
			{
				if (isClient() && this.getInventory().canPutItem(blob)) blob.getSprite().PlaySound("/PutInInventory.ogg");
				if (isServer()) this.server_PutInInventory(blob);
			}
		}
	}
}