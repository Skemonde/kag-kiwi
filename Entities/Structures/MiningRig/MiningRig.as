#include "MiningRigCommon"

void onInit(CBlob@ this)
{
	//this.set_TileType("background tile", CMap::tile_castle_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");
	
	getMap().server_SetTile(this.getPosition(), CMap::tile_castle_back);
	
	this.set_u32("last_produce", 0);
	
	this.addCommandID("property_sync");
}

void produceStoneOnTick(CBlob@ this)
{
	const bool FLIP = this.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	if (this.get_u32("last_produce")>getGameTime()||!this.hasTag("active")) return;
	
	const u16 PRODUCING_INTERVAL = getProducingInterval();
	const u8 PROD_MULTIPLIER = 10;
	
	if (isServer()&&this.get_u32("last_produce")!=0) {
		CBlob@ steel = server_CreateBlob("mat_stone", -1, this.getPosition()-Vec2f(1*FLIP_FACTOR, -2)*8);
		if (steel !is null) {
			steel.server_SetQuantity(PROD_MULTIPLIER);
		}
	}
	
	this.set_u32("last_produce", getGameTime()+PRODUCING_INTERVAL);
}

void checkIfCanMine(CBlob@ this)
{
	CMap@ map = getMap();
	Vec2f important_pos = this.getPosition()+Vec2f(-map.tilesize, 3.5f*map.tilesize);
	this.Untag("active");
	
	for (int pos_x = 0; pos_x<3*map.tilesize; pos_x+=map.tilesize) {
		TileType type = map.getTile(important_pos+Vec2f(pos_x,0)).type;
		if (map.isTileGroundStuff(type)) {
			this.Tag("active");
			break;
		}
	}
}

void onTick(CBlob@ this)
{
	produceStoneOnTick(this);
	
	checkIfCanMine(this);
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