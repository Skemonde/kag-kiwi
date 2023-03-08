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
	Vec2f pos = map.getTileWorldPosition(index);
	if(map.getTile(index).type > 261)
	{
		switch(oldTileType)
		{
			case CMap::tile_bgsteelbeam:
				if (isClient() || (isClient() && isServer()))
					Sound::Play("clang1", pos, 1.0f, (90+XORRandom(21))*0.01f);
			case CMap::tile_framed_stone_top:
			case CMap::tile_framed_stone_mid:
			case CMap::tile_framed_stone_bot:
				if (isClient() || (isClient() && isServer()))
					Sound::Play("rock_hit2", pos, 1.0f, (90+XORRandom(21))*0.01f);
				return CMap::tile_castle_back;
			case CMap::tile_window:
			case CMap::tile_window_top:
			case CMap::tile_window_mid:
			case CMap::tile_window_bot:
				if (isClient() || (isClient() && isServer()))
					Sound::Play("GlassBreak1", pos, 3.0f, (90+XORRandom(21))*0.01f);
			case CMap::tile_shoji_top:
			case CMap::tile_shoji_mid:
			case CMap::tile_shoji_bot:
				if (isClient() || (isClient() && isServer()))
					Sound::Play("branches1", pos, 1.0f, (90+XORRandom(21))*0.01f);
				return CMap::tile_empty;
		}
	}
	return map.getTile(index).type;
}

void onSetTile(CMap@ map, u32 index, TileType tile_new, TileType tile_old)
{
	if(tile_new > 255)
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
	}

	switch(tile_new)
	{		
		case CMap::tile_bgsteelbeam:
		{
			map.AddTileFlag(index, Tile::BACKGROUND | Tile::WATER_PASSES | Tile::LIGHT_PASSES);
			map.RemoveTileFlag(index, Tile::LIGHT_SOURCE | Tile::SOLID | Tile::COLLISION);
			map.SetTileSupport(index, 10);
			break;
		}
		case CMap::tile_lightabsorber:
		{
			map.AddTileFlag(index, Tile::BACKGROUND | Tile::WATER_PASSES);
			map.RemoveTileFlag(index, Tile::LIGHT_SOURCE | Tile::SOLID | Tile::COLLISION | Tile::LIGHT_PASSES);
			map.SetTileSupport(index, -1);
			break;
		}
		case CMap::tile_window:
		case CMap::tile_window_top:
		case CMap::tile_window_mid:
		case CMap::tile_window_bot:
		{
			Vec2f pos = map.getTileWorldPosition(index);
			u16[] tiles;
			//adding tiles we need for function
			tiles.push_back(CMap::tile_window);					//for default tile
			tiles.push_back(CMap::tile_window_top);				//for top tile
			tiles.push_back(CMap::tile_window_mid);				//for middle tile
			tiles.push_back(CMap::tile_window_bot);				//for bottom tile
			OnVerticalTileUpdate(true, true, map, pos, tiles);
			
			map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES | Tile::LIGHT_SOURCE);
			map.RemoveTileFlag(index, Tile::SOLID | Tile::COLLISION);
			map.SetTileSupport(index, 10);
			if (isClient() || (isClient() && isServer()))
				Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
			break;
		}
		case CMap::tile_framed_stone_top:
		case CMap::tile_framed_stone_mid:
		case CMap::tile_framed_stone_bot:
		{
			Vec2f pos = map.getTileWorldPosition(index);
			u16[] tiles;
			//adding tiles we need for function
			tiles.push_back(CMap::tile_framed_stone_top);		//for default tile
			tiles.push_back(CMap::tile_framed_stone_top);		//for top tile
			tiles.push_back(CMap::tile_framed_stone_mid);		//for middle tile
			tiles.push_back(CMap::tile_framed_stone_bot);		//for bottom tile
			OnVerticalTileUpdate(true, true, map, pos, tiles);
			
			map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES);
			map.RemoveTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_SOURCE);
			map.SetTileSupport(index, 10);
			if (isClient() || (isClient() && isServer()))
				Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
			break;
		}
		case CMap::tile_shoji_top:
		case CMap::tile_shoji_mid:
		case CMap::tile_shoji_bot:
		{
			Vec2f pos = map.getTileWorldPosition(index);
			u16[] tiles;
			tiles.push_back(CMap::tile_shoji_top);
			for (int i = 0; i < 3; ++i) {
				tiles.push_back(CMap::tile_shoji_top+i);
			}
			OnVerticalTileUpdate(true, true, map, pos, tiles);
			map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES);
			map.RemoveTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_SOURCE);
			map.SetTileSupport(index, 10);
			if (isClient() || (isClient() && isServer()))
				Sound::Play("branches1.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
			break;
		}
	}
}

void OnVerticalTileUpdate(bool updateThis, bool updateOthers, CMap@ map, Vec2f pos, uint16[] tiles)
{
	u32 index = map.getTileOffset(pos);
	bool isTop = (map.getTile(pos-Vec2f(0.0f, 8.0f)).type >= tiles[0] && map.getTile(pos-Vec2f(0.0f, 8.0f)).type <= tiles[tiles.length-1]) ? true : false;
	bool isBot = (map.getTile(pos+Vec2f(0.0f, 8.0f)).type >= tiles[0] && map.getTile(pos+Vec2f(0.0f, 8.0f)).type <= tiles[tiles.length-1]) ? true : false;

	if(updateThis)
	{
		if(isTop && isBot) {
			map.SetTile(index, tiles[2]);
		} else if(isTop || isBot) {
			if(isTop && !isBot)
				map.SetTile(index, tiles[3]);
			if(!isTop && isBot)
				map.SetTile(index, tiles[1]);
		} else {
			map.SetTile(index, tiles[0]);
		}
	}
	if(updateOthers)
	{
		if(isTop)
			OnVerticalTileUpdate(true, false, map, pos-Vec2f(0.0f, 8.0f), tiles);
		if(isBot)
			OnVerticalTileUpdate(true, false, map, pos+Vec2f(0.0f, 8.0f), tiles);
	}
}