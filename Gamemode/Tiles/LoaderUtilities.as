#include "DummyCommon"
#include "ParticleSparks"
#include "CustomBlocks"

void onInit(CMap@ this)
{
	this.legacyTileMinimap = false;
	this.MakeMiniMap();
}

bool onMapTileCollapse(CMap@ map, u32 offset)
{
	return true;
	if(map.getTile(offset).type > 255 && map.getTile(offset).type < 262)
	{
		CBlob@ blob = getBlobByNetworkID(server_getDummyGridNetworkID(offset));
		if(blob !is null)
		{
			blob.server_Die();
		}
	}
	return true;
}

TileType server_onTileHit(CMap@ map, f32 damage, u32 index, TileType oldTileType)
{
	if(map.getTile(index).type > 261)
	{
		switch(oldTileType)
		{
			case CMap::tile_bgsteelbeam:
				//return CMap::tile_empty;
				return CMap::tile_castle_back;
		}
	}
	return map.getTile(index).type;
}

void onSetTile(CMap@ map, u32 index, TileType tile_new, TileType tile_old)
{
	/* if(tile_new > 255)
	{
		map.SetTileSupport(index, 10);

		switch(tile_new)
		{
			case Dummy::SOLID:
			case Dummy::OBSTRUCTOR:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				break;
			case Dummy::BACKGROUND:
			case Dummy::OBSTRUCTOR_BACKGROUND:
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES);
				break;
			case Dummy::LADDER:
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::LADDER | Tile::WATER_PASSES);
				break;
			case Dummy::PLATFORM:
				map.AddTileFlag(index, Tile::PLATFORM);
				break;
		}
	} */

	switch(tile_new)
	{		
		case CMap::tile_bgsteelbeam:
		{
			map.AddTileFlag(index, Tile::BACKGROUND | Tile::WATER_PASSES | Tile::LIGHT_PASSES);
			map.RemoveTileFlag(index, Tile::LIGHT_SOURCE | Tile::SOLID | Tile::COLLISION);
			map.SetTileSupport(index, 100);
			break;
		}
		case CMap::tile_lightabsorber:
		{
			map.AddTileFlag(index, Tile::BACKGROUND | Tile::WATER_PASSES);
			map.RemoveTileFlag(index, Tile::LIGHT_SOURCE | Tile::SOLID | Tile::COLLISION | Tile::LIGHT_PASSES);
			map.SetTileSupport(index, 100);
			break;
		}
	}
}