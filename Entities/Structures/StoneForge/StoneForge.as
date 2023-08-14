
#include "Descriptions.as";
#include "CheckSpam.as";

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");
	
	getMap().server_SetTile(this.getPosition(), CMap::tile_castle_back);
	
	this.set_u32("last_smelting", 0);
}

void smeltOreFromInventory(CBlob@ this)
{
	if (this.get_u32("last_smelting")>getGameTime()) return;
	
	const u16 SMELTING_INTERVAL = 20;
	const u8 INGOT_PRICE = 10;
	u8 smelting_multiplier = 1;
	u32 ore_count = this.getBlobCount("mat_stone");
	if (ore_count<INGOT_PRICE*smelting_multiplier) return;
	
	if (isClient())
	{
		this.getSprite().PlaySound("ProduceSound.ogg");
		this.getSprite().PlaySound("BombMake.ogg");
	}
	CBlob@ steel = server_CreateBlob("mat_steel", -1, this.getPosition());
	if (steel !is null && isServer()) {
		steel.server_SetQuantity(smelting_multiplier);
	}
	
	this.TakeBlob("mat_stone", INGOT_PRICE*smelting_multiplier);
	
	this.set_u32("last_smelting", getGameTime()+SMELTING_INTERVAL);
}

void onTick(CBlob@ this)
{
	smeltOreFromInventory(this);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{

	this.set_Vec2f("shop offset", Vec2f(2,0));

	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
	if (blob is null) return;
	if (blob.getName()=="mat_stone") {
		if (isServer())
		{
			this.server_PutInInventory(blob);
		}
	}
}

bool isInventoryAccessible( CBlob@ this, CBlob@ forBlob )
{
	CBlob@ carried = forBlob.getCarriedBlob();
	if (carried is null) return false;
	return carried.getName()=="mat_stone";
}