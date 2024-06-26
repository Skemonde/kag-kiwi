#include "SteelCrusherCommon"

void onInit(CBlob@ this)
{
	//this.set_TileType("background tile", CMap::tile_castle_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	this.getSprite().getConsts().accurateLighting = false;

	this.Tag("builder always hit");
	
	getMap().server_SetTile(this.getPosition(), CMap::tile_castle_back);
	
	this.set_u32("last_produce", 0);
	
	this.addCommandID("property_sync");
}

void produceSteelOnTick(CBlob@ this)
{
	const bool FLIP = this.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	if (this.get_u32("last_produce")>getGameTime()||!getRules().isMatchRunning()) return;
	
	const u16 PRODUCING_INTERVAL = getProducingInterval();
	u8 smelting_multiplier = 1;
	
	if (isServer()) {
		CBlob@ steel = server_CreateBlob("mat_steel", -1, this.getPosition()-Vec2f(1*FLIP_FACTOR, 0)*8);
		if (steel !is null) {
			steel.server_SetQuantity(smelting_multiplier);
		}
		this.set_u32("last_produce", getGameTime()+PRODUCING_INTERVAL);
		this.Sync("last_produce", true);
	}
	
}

void onTick(CBlob@ this)
{
	produceSteelOnTick(this);
}

// KAG's CBlob.Sync() is nonfunctional shit
void server_Sync(CBlob@ this)
{
	if (isServer())
	{
		CBitStream stream;
		stream.write_u32(this.get_u32("last_produce"));
		
		this.SendCommand(this.getCommandID("property_sync"), stream);
	}
}
void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("property_sync"))
	{
		if (isClient())
		{
			u32 quantity = params.read_u32();
			this.set_u32("last_produce", quantity);
		}
	}
}