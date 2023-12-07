
#include "Descriptions.as";
#include "CheckSpam.as";

const u16 SMELTING_INTERVAL = 3;
const u8 INGOT_PRICE = 30;

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
	u32 time_from_last_smelting = getGameTime()-this.get_u32("last_smelting");
	if (time_from_last_smelting<SMELTING_INTERVAL) return;
	
	const u8 SMELTING_MULTIPLIER = 1;
	u32 ore_count = this.get_u32("ore_amount");
	if (ore_count<INGOT_PRICE*SMELTING_MULTIPLIER) return;
	
	if (isClient())
	{
		this.getSprite().PlaySound("ProduceSound.ogg");
		this.getSprite().PlaySound("BombMake.ogg");
	}
	if (isServer()) {
		CBlob@ steel = server_CreateBlob("mat_steel", -1, this.getPosition());
		steel.server_SetQuantity(SMELTING_MULTIPLIER);
	}
	
	//this.TakeBlob("mat_stone", INGOT_PRICE*SMELTING_MULTIPLIER);
	this.sub_u32("ore_amount", INGOT_PRICE*SMELTING_MULTIPLIER);
	
	if (isServer())
		this.set_u32("last_smelting", getGameTime());
	this.Sync("last_smelting", true);
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

void onAddToInventory( CBlob@ this, CBlob@ blob )
{
	if (blob is null) return;
	if (blob.getName()=="mat_stone") {
		if (isServer())
		{
			//this.server_PutInInventory(blob);
			this.add_u32("ore_amount", blob.getQuantity());
			blob.server_Die();
		}
		this.Sync("ore_amount", true);
	}
}

bool isInventoryAccessible( CBlob@ this, CBlob@ forBlob )
{
	return false;
	/* 
	CBlob@ carried = forBlob.getCarriedBlob();
	if (carried is null) return false;
	return carried.getName()=="mat_stone";
	 */
}