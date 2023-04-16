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
			
			case CMap::tile_framed_stone_top:
			case CMap::tile_framed_stone_mid:
			case CMap::tile_framed_stone_bot:
				return CMap::tile_castle_back;
			case CMap::tile_window:
			case CMap::tile_window_top:
			case CMap::tile_window_mid:
			case CMap::tile_window_bot:
			
			case CMap::tile_shoji_top:
			case CMap::tile_shoji_mid:
			case CMap::tile_shoji_bot:
				return CMap::tile_empty;
		}
	}
	return map.getTile(index).type;
}

void onSetTile(CMap@ map, u32 index, TileType tile_new, TileType tile_old)
{
	Vec2f pos = map.getTileWorldPosition(index);
	if (isClient() || (isClient() && isServer())) {
		switch(tile_old)
		{
			
			case CMap::tile_bgsteelbeam:
					Sound::Play("clang1", pos, 1.0f, (90+XORRandom(21))*0.01f);
					break;
			case CMap::tile_framed_stone_top:
			case CMap::tile_framed_stone_mid:
			case CMap::tile_framed_stone_bot:
					Sound::Play("rock_hit2", pos, 1.0f, (90+XORRandom(21))*0.01f);
					break;
			case CMap::tile_window:
			case CMap::tile_window_top:
			case CMap::tile_window_mid:
			case CMap::tile_window_bot:
					Sound::Play("GlassBreak1", pos, 3.0f, (90+XORRandom(21))*0.01f);
					break;
			case CMap::tile_shoji_top:
			case CMap::tile_shoji_mid:
			case CMap::tile_shoji_bot:
					Sound::Play("branches1", pos, 3.0f, (90+XORRandom(21))*0.01f);
					break;
		}
	}
	
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
			
			map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES | Tile::LIGHT_SOURCE | Tile::FLAMMABLE);
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
			
			map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES | Tile::FLAMMABLE);
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
			//adding tiles we need for function
			tiles.push_back(CMap::tile_shoji_top);				//for default tile
			tiles.push_back(CMap::tile_shoji_top);				//for top tile
			tiles.push_back(CMap::tile_shoji_mid);				//for middle tile
			tiles.push_back(CMap::tile_shoji_bot);				//for bottom tile
			OnVerticalTileUpdate(true, true, map, pos, tiles);
			
			map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES | Tile::FLAMMABLE);
			map.RemoveTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_SOURCE);
			map.SetTileSupport(index, 10);
			if (isClient() || (isClient() && isServer()))
				Sound::Play("branches1.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
			break;
		}
		case CMap::tile_steel_1x1:
		case CMap::tile_steel_3x1_left:
		case CMap::tile_steel_3x1_mid:
		case CMap::tile_steel_3x1_right:
		case CMap::tile_steel_1x3_top:
		case CMap::tile_steel_1x3_mid:
		case CMap::tile_steel_1x3_bot:
		case CMap::tile_steel_3x3_topleft:
		case CMap::tile_steel_3x3_topmid:
		case CMap::tile_steel_3x3_topright:
		case CMap::tile_steel_3x3_midleft:
		case CMap::tile_steel_3x3_midmid:
		case CMap::tile_steel_3x3_midright:
		case CMap::tile_steel_3x3_botleft:
		case CMap::tile_steel_3x3_botmid:
		case CMap::tile_steel_3x3_botright:
		case CMap::tile_steel_tshape_0:
		case CMap::tile_steel_tshape_90:
		case CMap::tile_steel_tshape_180:
		case CMap::tile_steel_tshape_270:
		case CMap::tile_steel_corner_2s_0:
		case CMap::tile_steel_corner_2s_90:
		case CMap::tile_steel_corner_2s_180:
		case CMap::tile_steel_corner_2s_270:
		case CMap::tile_steel_3corners_0:
		case CMap::tile_steel_3corners_90:
		case CMap::tile_steel_3corners_180:
		case CMap::tile_steel_3corners_270:
		case CMap::tile_steel_2corners_m:
		case CMap::tile_steel_2corners:
		case CMap::tile_steel_corner_1s_0:
		case CMap::tile_steel_corner_1s_90:
		case CMap::tile_steel_corner_1s_180:
		case CMap::tile_steel_corner_1s_270:
		case CMap::tile_steel_corner_1s_m_0:
		case CMap::tile_steel_corner_1s_m_90:
		case CMap::tile_steel_corner_1s_m_180:
		case CMap::tile_steel_corner_1s_m_270:
		case CMap::tile_steel_corner_0s_0:
		case CMap::tile_steel_corner_0s_90:
		case CMap::tile_steel_corner_0s_180:
		case CMap::tile_steel_corner_0s_270:
		case CMap::tile_steel_cross:
		{
			u16[] tiles;
			//adding tiles we need for function
			tiles.push_back(CMap::tile_steel_1x1);
			tiles.push_back(CMap::tile_steel_3x1_left);
			tiles.push_back(CMap::tile_steel_3x1_mid);
			tiles.push_back(CMap::tile_steel_3x1_right);
			tiles.push_back(CMap::tile_steel_1x3_top);
			tiles.push_back(CMap::tile_steel_1x3_mid);
			tiles.push_back(CMap::tile_steel_1x3_bot);
			tiles.push_back(CMap::tile_steel_3x3_topleft);
			tiles.push_back(CMap::tile_steel_3x3_topmid);
			tiles.push_back(CMap::tile_steel_3x3_topright);
			tiles.push_back(CMap::tile_steel_3x3_midleft);
			tiles.push_back(CMap::tile_steel_3x3_midmid);
			tiles.push_back(CMap::tile_steel_3x3_midright);
			tiles.push_back(CMap::tile_steel_3x3_botleft);
			tiles.push_back(CMap::tile_steel_3x3_botmid);
			tiles.push_back(CMap::tile_steel_3x3_botright);
			tiles.push_back(CMap::tile_steel_tshape_0);
			tiles.push_back(CMap::tile_steel_tshape_90);
			tiles.push_back(CMap::tile_steel_tshape_180);
			tiles.push_back(CMap::tile_steel_tshape_270);
			tiles.push_back(CMap::tile_steel_corner_2s_0);
			tiles.push_back(CMap::tile_steel_corner_2s_90);
			tiles.push_back(CMap::tile_steel_corner_2s_180);
			tiles.push_back(CMap::tile_steel_corner_2s_270);
			tiles.push_back(CMap::tile_steel_3corners_0);
			tiles.push_back(CMap::tile_steel_3corners_90);
			tiles.push_back(CMap::tile_steel_3corners_180);
			tiles.push_back(CMap::tile_steel_3corners_270);
			tiles.push_back(CMap::tile_steel_2corners_m);
			tiles.push_back(CMap::tile_steel_2corners);
			tiles.push_back(CMap::tile_steel_corner_1s_0);
			tiles.push_back(CMap::tile_steel_corner_1s_90);
			tiles.push_back(CMap::tile_steel_corner_1s_180);
			tiles.push_back(CMap::tile_steel_corner_1s_270);
			tiles.push_back(CMap::tile_steel_corner_1s_m_0);
			tiles.push_back(CMap::tile_steel_corner_1s_m_90);
			tiles.push_back(CMap::tile_steel_corner_1s_m_180);
			tiles.push_back(CMap::tile_steel_corner_1s_m_270);
			tiles.push_back(CMap::tile_steel_corner_0s_0);
			tiles.push_back(CMap::tile_steel_corner_0s_90);
			tiles.push_back(CMap::tile_steel_corner_0s_180);
			tiles.push_back(CMap::tile_steel_corner_0s_270);
			tiles.push_back(CMap::tile_steel_cross);
			OnTileUpdate(true, true, map, pos, tiles);
			
			map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
			map.RemoveTileFlag(index, Tile::LIGHT_SOURCE | Tile::BACKGROUND | Tile::WATER_PASSES | Tile::LIGHT_PASSES);
			map.SetTileSupport(index, 10);
			break;
		}
	}
}

void setTile(u32 index, uint16 tile) {
	getMap().SetTile(index, tile);
}

void OnTileUpdate(bool updateThis, bool updateOthers, CMap@ map, Vec2f pos, uint16[] tiles)
{
	u32 index = map.getTileOffset(pos);
	
	u16
		tile_1x1 					= tiles[0],
		tile_3x1_left 				= tiles[1],
		tile_3x1_mid				= tiles[2],
		tile_3x1_right				= tiles[3],
		tile_1x3_top				= tiles[4],
		tile_1x3_mid				= tiles[5],
		tile_1x3_bot				= tiles[6],
		tile_3x3_topleft			= tiles[7],
		tile_3x3_topmid				= tiles[8],
		tile_3x3_topright			= tiles[9],
		tile_3x3_midleft			= tiles[10],
		tile_3x3_midmid				= tiles[11],
		tile_3x3_midright			= tiles[12],
		tile_3x3_botleft			= tiles[13],
		tile_3x3_botmid				= tiles[14],
		tile_3x3_botright			= tiles[15],
		tile_tshape_0				= tiles[16],
		tile_tshape_90				= tiles[17],
		tile_tshape_180				= tiles[18],
		tile_tshape_270				= tiles[19],
		tile_corner_2s_0			= tiles[20],
		tile_corner_2s_90			= tiles[21],
		tile_corner_2s_180			= tiles[22],
		tile_corner_2s_270			= tiles[23],
		tile_3corners_0				= tiles[24],
		tile_3corners_90			= tiles[25],
		tile_3corners_180			= tiles[26],
		tile_3corners_270			= tiles[27],
		tile_2corners_m				= tiles[28],
		tile_2corners				= tiles[29],
		tile_corner_1s_0			= tiles[30],
		tile_corner_1s_90			= tiles[31],
		tile_corner_1s_180			= tiles[32],
		tile_corner_1s_270			= tiles[33],
		tile_corner_1s_m_0			= tiles[34],
		tile_corner_1s_m_90			= tiles[35],
		tile_corner_1s_m_180		= tiles[36],
		tile_corner_1s_m_270		= tiles[37],
		tile_corner_0s_0			= tiles[38],
		tile_corner_0s_90			= tiles[39],
		tile_corner_0s_180			= tiles[40],
		tile_corner_0s_270			= tiles[41],
		tile_cross					= tiles[42];
	
	int autotile_id = 0;
	bool TopNeighbour = (map.getTile(pos-Vec2f(0.0f, map.tilesize)).type >= tiles[0] && map.getTile(pos-Vec2f(0.0f, map.tilesize)).type <= tiles[tiles.length-1]) ? true : false;
	bool BotNeighbour = (map.getTile(pos+Vec2f(0.0f, map.tilesize)).type >= tiles[0] && map.getTile(pos+Vec2f(0.0f, map.tilesize)).type <= tiles[tiles.length-1]) ? true : false;
	bool LeftNeighbour = (map.getTile(pos-Vec2f(map.tilesize, 0.0f)).type >= tiles[0] && map.getTile(pos-Vec2f(0.0f, map.tilesize)).type <= tiles[tiles.length-1]) ? true : false;
	bool RightNeighbour = (map.getTile(pos+Vec2f(map.tilesize, 0.0f)).type >= tiles[0] && map.getTile(pos+Vec2f(0.0f, map.tilesize)).type <= tiles[tiles.length-1]) ? true : false;
	bool TopleftNeighbour = (map.getTile(pos-Vec2f(map.tilesize, map.tilesize)).type >= tiles[0] && map.getTile(pos-Vec2f(map.tilesize, map.tilesize)).type <= tiles[tiles.length-1]) ? true : false;
	bool ToprightNeighbour = (map.getTile(pos+Vec2f(map.tilesize, -map.tilesize)).type >= tiles[0] && map.getTile(pos+Vec2f(map.tilesize, -map.tilesize)).type <= tiles[tiles.length-1]) ? true : false;
	bool BotleftNeighbour = (map.getTile(pos+Vec2f(-map.tilesize, map.tilesize)).type >= tiles[0] && map.getTile(pos+Vec2f(-map.tilesize, map.tilesize)).type <= tiles[tiles.length-1]) ? true : false;
	bool BotrightNeighbour = (map.getTile(pos+Vec2f(map.tilesize, map.tilesize)).type >= tiles[0] && map.getTile(pos+Vec2f(map.tilesize, map.tilesize)).type <= tiles[tiles.length-1]) ? true : false;
	
	if (TopleftNeighbour) 	autotile_id += 1;
    if (TopNeighbour) 			autotile_id += 2;
	if (ToprightNeighbour) 	autotile_id += 4;
    if (LeftNeighbour) 			autotile_id += 8;
    if (RightNeighbour) 		autotile_id += 16;
	if (BotleftNeighbour) 	autotile_id += 32;
    if (BotNeighbour) 			autotile_id += 64;
	if (BotrightNeighbour) 	autotile_id += 128;
	
	int tile_id = 0;
	
	if(updateThis)
	{
		switch (autotile_id)
		{
			case 0: 	setTile(index, tile_1x1); break;
			
			case 64:
			case 96:
			case 192:
			case 224:
						setTile(index, tile_1x3_top); break;
			case 66:
			case 98:
			case 194:
			case 226:
						setTile(index, tile_1x3_mid); break;
			case 2:
			case 7:
						setTile(index, tile_1x3_bot); break;
			case 8:
			case 9:
			case 41:
						setTile(index, tile_3x1_right); break;
			case 24:
			case 28:
			case 29:
						setTile(index, tile_3x1_mid); break;
			case 16:
			case 20:
			case 148:
						setTile(index, tile_3x1_left); break;
						
			
			case 249: 	setTile(index, tile_2corners); break;
			case 250: 	setTile(index, tile_tshape_180); break;
			case 104: 	setTile(index, tile_3x3_topright); break;
			case 248: 	setTile(index, tile_3x3_topmid); break;
			case 208:
			case 210:
				setTile(index, tile_3x3_topleft); break;
			case 11: 	setTile(index, tile_3x3_botright); break;
			case 31: 	setTile(index, tile_3x3_botmid); break;
			case 22: 	setTile(index, tile_3x3_botleft); break;
			
			case 127: 	setTile(index, tile_corner_0s_0); break;
			case 10: 	setTile(index, tile_corner_2s_180); break;
			case 18: 	setTile(index, tile_corner_2s_270); break;
			case 26: 	setTile(index, tile_tshape_180); break;
			case 90: 	setTile(index, tile_cross); break;
			default: 	setTile(index, tile_3x3_midmid); break;
		}
	}
	
	if(updateOthers)
	{
		if(TopNeighbour)
			OnTileUpdate(true, false, map, pos-Vec2f(0.0f, map.tilesize), tiles);
		if(BotNeighbour)
			OnTileUpdate(true, false, map, pos+Vec2f(0.0f, map.tilesize), tiles);
		if(LeftNeighbour)
			OnTileUpdate(true, false, map, pos-Vec2f(map.tilesize, 0.0f), tiles);
		if(RightNeighbour)
			OnTileUpdate(true, false, map, pos+Vec2f(map.tilesize, 0.0f), tiles);
		if(TopleftNeighbour)
			OnTileUpdate(true, false, map, pos-Vec2f(map.tilesize, map.tilesize), tiles);
		if(ToprightNeighbour)
			OnTileUpdate(true, false, map, pos+Vec2f(map.tilesize, -map.tilesize), tiles);
		if(BotleftNeighbour)
			OnTileUpdate(true, false, map, pos+Vec2f(-map.tilesize, map.tilesize), tiles);
		if(BotrightNeighbour)
			OnTileUpdate(true, false, map, pos+Vec2f(map.tilesize, map.tilesize), tiles);
	}
}

void OnVerticalTileUpdate(bool updateThis, bool updateOthers, CMap@ map, Vec2f pos, uint16[] tiles)
{
	u32 index = map.getTileOffset(pos);
	bool isTop = (map.getTile(pos-Vec2f(0.0f, 8.0f)).type >= tiles[0] && map.getTile(pos-Vec2f(0.0f, 8.0f)).type <= tiles[tiles.length-1]) ? true : false;
	bool isBot = (map.getTile(pos+Vec2f(0.0f, 8.0f)).type >= tiles[0] && map.getTile(pos+Vec2f(0.0f, 8.0f)).type <= tiles[tiles.length-1]) ? true : false;
	/* for (int counter = 0; counter < (tiles.length-1); ++counter) {
		if (map.getTile(pos-Vec2f(0.0f, map.tilesize)).type == tiles[counter]) {
			isTop = true; break;
		}
		else
			isTop = false;
	}
	for (int counter = 0; counter < (tiles.length-1); ++counter) {
		if (map.getTile(pos+Vec2f(0.0f, map.tilesize)).type == tiles[counter]) {
			isBot = true; break;
		}
		else
			isBot = false;
	}
	print("top "+isTop);
	print("bot "+isBot+"\n"); */

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
			OnVerticalTileUpdate(true, false, map, pos-Vec2f(0.0f, map.tilesize), tiles);
		if(isBot)
			OnVerticalTileUpdate(true, false, map, pos+Vec2f(0.0f, map.tilesize), tiles);
	}
}