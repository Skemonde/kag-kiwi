#include "DummyCommon"
#include "ParticleSparks"
#include "CustomBlocks"
#include "ExplosionAtPos"
#include "MakeExplodeParticles"

void onInit(CMap@ this)
{
	this.legacyTileMinimap = false;
	this.MakeMiniMap();
	u16[] steel_tiles;
	//adding tiles we need for function
	steel_tiles.push_back(CMap::tile_steel_1x1);
	steel_tiles.push_back(CMap::tile_steel_3x1_left);
	steel_tiles.push_back(CMap::tile_steel_3x1_mid);
	steel_tiles.push_back(CMap::tile_steel_3x1_right);
	steel_tiles.push_back(CMap::tile_steel_1x3_top);
	steel_tiles.push_back(CMap::tile_steel_1x3_mid);
	steel_tiles.push_back(CMap::tile_steel_1x3_bot);
	steel_tiles.push_back(CMap::tile_steel_3x3_topleft);
	steel_tiles.push_back(CMap::tile_steel_3x3_topmid);
	steel_tiles.push_back(CMap::tile_steel_3x3_topright);
	steel_tiles.push_back(CMap::tile_steel_3x3_midleft);
	steel_tiles.push_back(CMap::tile_steel_3x3_midmid);
	steel_tiles.push_back(CMap::tile_steel_3x3_midright);
	steel_tiles.push_back(CMap::tile_steel_3x3_botleft);
	steel_tiles.push_back(CMap::tile_steel_3x3_botmid);
	steel_tiles.push_back(CMap::tile_steel_3x3_botright);
	steel_tiles.push_back(CMap::tile_steel_tshape_0);
	steel_tiles.push_back(CMap::tile_steel_tshape_90);
	steel_tiles.push_back(CMap::tile_steel_tshape_180);
	steel_tiles.push_back(CMap::tile_steel_tshape_270);
	steel_tiles.push_back(CMap::tile_steel_corner_2s_0);
	steel_tiles.push_back(CMap::tile_steel_corner_2s_90);
	steel_tiles.push_back(CMap::tile_steel_corner_2s_180);
	steel_tiles.push_back(CMap::tile_steel_corner_2s_270);
	steel_tiles.push_back(CMap::tile_steel_3corners_0);
	steel_tiles.push_back(CMap::tile_steel_3corners_90);
	steel_tiles.push_back(CMap::tile_steel_3corners_180);
	steel_tiles.push_back(CMap::tile_steel_3corners_270);
	steel_tiles.push_back(CMap::tile_steel_2corners_m);
	steel_tiles.push_back(CMap::tile_steel_2corners);
	steel_tiles.push_back(CMap::tile_steel_corner_1s_0);
	steel_tiles.push_back(CMap::tile_steel_corner_1s_90);
	steel_tiles.push_back(CMap::tile_steel_corner_1s_180);
	steel_tiles.push_back(CMap::tile_steel_corner_1s_270);
	steel_tiles.push_back(CMap::tile_steel_corner_1s_m_0);
	steel_tiles.push_back(CMap::tile_steel_corner_1s_m_90);
	steel_tiles.push_back(CMap::tile_steel_corner_1s_m_180);
	steel_tiles.push_back(CMap::tile_steel_corner_1s_m_270);
	steel_tiles.push_back(CMap::tile_steel_corner_0s_0);
	steel_tiles.push_back(CMap::tile_steel_corner_0s_90);
	steel_tiles.push_back(CMap::tile_steel_corner_0s_180);
	steel_tiles.push_back(CMap::tile_steel_corner_0s_270);
	steel_tiles.push_back(CMap::tile_steel_cross);
	steel_tiles.push_back(CMap::tile_steel_2corners_0s_0);
	steel_tiles.push_back(CMap::tile_steel_2corners_0s_90);
	steel_tiles.push_back(CMap::tile_steel_2corners_0s_180);
	steel_tiles.push_back(CMap::tile_steel_2corners_0s_270);
	this.set("steel_tiles", steel_tiles);
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
	tiles.push_back(CMap::tile_steel_2corners_0s_0);
	tiles.push_back(CMap::tile_steel_2corners_0s_90);
	tiles.push_back(CMap::tile_steel_2corners_0s_180);
	tiles.push_back(CMap::tile_steel_2corners_0s_270);

	if(map.getTile(index).type > 261 || true)
	{
		switch(oldTileType)
		{
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
				OnTileUpdate(false, true, map, pos, tiles);
				return CMap::tile_steel_d0;
				
			case CMap::tile_steel_d0:
			case CMap::tile_steel_d1:
			case CMap::tile_steel_d2:
			case CMap::tile_steel_d3:
			case CMap::tile_steel_d4:
			case CMap::tile_steel_d5:
			case CMap::tile_steel_d6:
				return oldTileType+1;
			case CMap::tile_steel_d7:
				return CMap::tile_empty;
			
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
			
			case 200:
			case 201:
			case 202:
			case 203:
				print("hello mapper");
				return CMap::tile_wood_back;
			
			case CMap::tile_tnt:
				setTile(index, CMap::tile_empty); //goes before explosion so the explosion (or other explosions) doesn't hit it another time
				ExplosionAtPos(pos,	map, 64, 20, 64, 0.4f, true, true);
				MakeParticles(pos);
				return CMap::tile_empty;;
		}
	}
	return map.getTile(index).type;
}

void MakeParticles(Vec2f pos)
{
	u8 particle_amount = 6;
	for (int i = 0; i < particle_amount; i++)
	{
		MakeExplodeParticles(pos+Vec2f( XORRandom(64) - 32, XORRandom(64) - 32), getRandomVelocity(360/particle_amount*i, XORRandom(220) * 0.01f, 90));
	}
}

void onSetTile(CMap@ map, u32 index, TileType tile_new, TileType tile_old)
{
	Vec2f pos = map.getTileWorldPosition(index);
	CBlob@ blob_handle;
	if (isClient()) {
		switch(tile_old)
		{
			case CMap::tile_bgsteelbeam:
					if (tile_new==CMap::tile_empty||
						tile_new==CMap::tile_ground_back||
						tile_new==CMap::tile_castle_back
						) {
						Sound::Play("clang1", pos, 1.0f, (90+XORRandom(21))*0.01f);
					}
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
		if (isTileSteel(tile_old, true)&&!isTileSteel(tile_new, false)) {
			Vec2f pos = map.getTileWorldPosition(index);											
																								
			Sound::Play("dig_stone.ogg", pos, 1.0f, 1.0f);
			makeGibParticle("GenericGibs", pos, getRandomVelocity(XORRandom(360), 1.0f, 90.0f) + Vec2f(0.0f, -2.0f), 9, 4+XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);
			sparks(pos, 1, 1);	
		}
	}
	if (isServer()) {
		switch(tile_old)
		{
			case 31: //last frame of damaged dirt
					@blob_handle = server_CreateBlob("dirtpile", -1, pos+Vec2f(1,1)*map.tilesize/2);
					if (blob_handle !is null) {
						blob_handle.server_SetQuantity(1);
					}
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
			tiles.push_back(CMap::tile_steel_2corners_0s_0);
			tiles.push_back(CMap::tile_steel_2corners_0s_90);
			tiles.push_back(CMap::tile_steel_2corners_0s_180);
			tiles.push_back(CMap::tile_steel_2corners_0s_270);
			
			OnTileUpdate(true, true, map, pos, tiles);
			
			if (isClient() || (isClient() && isServer()))
				Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
		}
		case CMap::tile_steel_d0:
		case CMap::tile_steel_d1:
		case CMap::tile_steel_d2:
		case CMap::tile_steel_d3:
		case CMap::tile_steel_d4:
		case CMap::tile_steel_d5:
		case CMap::tile_steel_d6:
		case CMap::tile_steel_d7:
		{	
			map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
			map.RemoveTileFlag(index, Tile::LIGHT_SOURCE | Tile::BACKGROUND | Tile::WATER_PASSES | Tile::LIGHT_PASSES);
			map.SetTileSupport(index, 10);
			break;
		}
		case CMap::tile_tnt:
		{
			map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::WATER_PASSES | Tile::LIGHT_PASSES);
			map.RemoveTileFlag(index, Tile::LIGHT_SOURCE | Tile::BACKGROUND);
			map.SetTileSupport(index, 0);
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
		tile_cross					= tiles[42],
		tile_2corners_0s_0			= tiles[43],
		tile_2corners_0s_90   		= tiles[44],
		tile_2corners_0s_180  		= tiles[45],
		tile_2corners_0s_270  		= tiles[46];
	
	int autotile_id = 0;
	bool TopNeighbour = false;
	for (int counter = 0; counter < tiles.size(); ++counter) {
		if (map.getTile(pos-Vec2f(0.0f, map.tilesize)).type==tiles[counter]) {
			TopNeighbour = true;
			//print("found top tile! the index of the tile is "+counter);
			break;
		}
	}
	bool BotNeighbour = false;
	for (int counter = 0; counter < tiles.size(); ++counter) {
		if (map.getTile(pos+Vec2f(0.0f, map.tilesize)).type==tiles[counter]) {
			BotNeighbour = true;
			//print("found bottom tile! the index of the tile is "+counter);
			break;
		}
	}
	bool LeftNeighbour = false;
	for (int counter = 0; counter < tiles.size(); ++counter) {
		if (map.getTile(pos-Vec2f(map.tilesize, 0.0f)).type==tiles[counter]) {
			LeftNeighbour = true;
			//print("found left tile! the index of the tile is "+counter);
			break;
		}
	}
	bool RightNeighbour = false;
	for (int counter = 0; counter < tiles.size(); ++counter) {
		if (map.getTile(pos+Vec2f(map.tilesize, 0.0f)).type==tiles[counter]) {
			RightNeighbour = true;
			//print("found right tile! the index of the tile is "+counter);
			break;
		}
	}
	
	bool TopleftNeighbour = false;
	for (int counter = 0; counter < tiles.size(); ++counter) {
		if (map.getTile(pos-Vec2f(map.tilesize, map.tilesize)).type==tiles[counter]) {
			TopleftNeighbour = true;
			//print("found TOP LEFT tile! the index of the tile is "+counter);
			break;
		}
	}
	bool ToprightNeighbour = false;
	for (int counter = 0; counter < tiles.size(); ++counter) {
		if (map.getTile(pos+Vec2f(map.tilesize, -map.tilesize)).type==tiles[counter]) {
			ToprightNeighbour = true;
			//print("found TOP RIGHT tile! the index of the tile is "+counter);
			break;
		}
	}
	bool BotleftNeighbour = false;
	for (int counter = 0; counter < tiles.size(); ++counter) {
		if (map.getTile(pos+Vec2f(-map.tilesize, map.tilesize)).type==tiles[counter]) {
			BotleftNeighbour = true;
			//print("found BOTTOM LEFT tile! the index of the tile is "+counter);
			break;
		}
	}
	bool BotrightNeighbour = false;
	for (int counter = 0; counter < tiles.size(); ++counter) {
		if (map.getTile(pos+Vec2f(map.tilesize, map.tilesize)).type==tiles[counter]) {
			BotrightNeighbour = true;
			//print("found BOTTOM RIGHT tile! the index of the tile is "+counter);
			break;
		}
	}
	
	if (TopleftNeighbour) 	autotile_id += 1;
    if (TopNeighbour) 			autotile_id += 2;
	if (ToprightNeighbour) 	autotile_id += 4;
    if (LeftNeighbour) 			autotile_id += 8;
    if (RightNeighbour) 		autotile_id += 16;
	if (BotleftNeighbour) 	autotile_id += 32;
    if (BotNeighbour) 			autotile_id += 64;
	if (BotrightNeighbour) 	autotile_id += 128;
	
	//print("autotile val "+autotile_id+"\n");
	
	int tile_id = tile_3x3_midmid;
	
	if(updateThis)
	{
		switch (autotile_id)
		{
			//
			//		0 . 0
			//		. t .
			//		0 . 0
			//
			// t means our current tile
			// dot means an empty tile or a tile that is 100% not an iron tile
			// zero means a tile that can be iron and it doesn't affect the look of the tile in the middle
			// amount of cases for 4 zeros is 16 
			//
			case 0:			// case  1
			case 1:         // case  2
			case 4:         // case  3
			case 5:         // case  4
			case 32:        // case  5
			case 33:        // case  6
			case 37:        // case  7
			case 36:        // case  8
			case 128:       // case  9
			case 129:       // case 10
			case 132:       // case 11
			case 133:       // case 12
			case 160:       // case 13
			case 161:       // case 14
			case 164:       // case 15
			case 165:       // case 16
						tile_id = tile_1x1; break;
			//
			//		0 . 0
			//		. t .
			//		0 c 0
			//
			// c stands for connection and means a tile that MUST be iron so our tile becomes the current one (top tile of a pillar in this case)
			// 16 again
			//
			case 64:		// case  1
			case 65:        // case  2
			case 68:        // case  3
			case 69:        // case  4
			case 96:        // case  5
			case 97:        // case  6
			case 100:       // case  7
			case 101:       // case  8
			case 192:       // case  9
			case 193:       // case 10
			case 196:       // case 11
			case 197:       // case 12
			case 224:       // case 13
			case 225:       // case 14
			case 228:       // case 15
			case 229:       // case 16
						tile_id = tile_1x3_top; break;
			//
			//		0 c 0
			//		. t .
			//		0 c 0
			//
			case 66:		// case  1
			case 67:        // case  2
			case 70:        // case  3
			case 71:        // case  4
			case 98:        // case  5
			case 99:        // case  6
			case 102:       // case  7
			case 103:       // case  8
			case 194:       // case  9
			case 195:       // case 10
			case 198:       // case 11
			case 199:       // case 12
			case 226:       // case 13
			case 227:       // case 14
			case 230:       // case 15
			case 231:		// case 16
						tile_id = tile_1x3_mid; break;
			//
			//		0 c 0
			//		. t .
			//		0 . 0
			//
			case 2:			// case  1
			case 3:			// case  2
			case 6:			// case  3
			case 7:			// case  4
			case 34:		// case  5
			case 35:		// case  6
			case 38:		// case  7
			case 39:		// case  8
			case 130:		// case  9
			case 131:		// case 10
			case 134:		// case 11
			case 135:		// case 12
			case 162:		// case 13
			case 163:		// case 14
			case 166:		// case 15
			case 167:		// case 16
						tile_id = tile_1x3_bot; break;
			//
			//		0 . 0
			//		. t c
			//		0 c .
			// corner tile 0 degrees looks like this
			// has 8 cases
			//
			case 80:		// case  1
			case 81:        // case  2
			case 84:        // case  3
			case 85:        // case  4
			case 112:       // case  5
			case 113:       // case  6
			case 116:       // case  7
			case 117:       // case  8
						tile_id = tile_corner_2s_0; break;
			//
			//		0 . 0
			//		c t .
			//		. c 0
			//
			case 72:		// case  1
			case 73:        // case  2
			case 76:        // case  3
			case 77:        // case  4
			case 200:       // case  5
			case 204:       // case  6
			case 205:       // case  7
			case 201:       // case  8
						tile_id = tile_corner_2s_90; break;
			//
			//		. c 0
			//		c t .
			//		0 . 0
			//
			case 10:		// case  1
			case 14:        // case  2
			case 42:        // case  3
			case 46:        // case  4
			case 138:       // case  5
			case 170:       // case  6
			case 174:       // case  7
			case 142:       // case  8
						tile_id = tile_corner_2s_180; break;
			//
			//		0 c .
			//		. t c
			//		0 . 0
			//
			case 18:		// case  1
			case 19:        // case  2
			case 50:        // case  3
			case 51:        // case  4
			case 147:       // case  5
			case 178:       // case  6
			case 179:       // case  7
			case 146:       // case  8
						tile_id = tile_corner_2s_270; break;
			//
			//		0 . 0
			//		c t .
			//		0 . 0
			//
			case 8:			// case  1
			case 9:         // case  2
			case 12:        // case  3
			case 13:        // case  4
			case 40:        // case  5
			case 41:        // case  6
			case 44:        // case  7
			case 45:        // case  8
			case 136:       // case  9
			case 137:       // case 10
			case 140:       // case 11
			case 141:       // case 12
			case 168:       // case 13
			case 169:       // case 14
			case 172:       // case 15
			case 173:       // case 16
						tile_id = tile_3x1_right; break;
			//
			//		0 . 0
			//		c t c
			//		0 . 0
			//
			case 24:		// case  1
			case 25:        // case  2
			case 28:        // case  3
			case 29:        // case  4
			case 56:        // case  5
			case 57:        // case  6
			case 60:        // case  7
			case 61:        // case  8
			case 152:       // case  9
			case 153:       // case 10
			case 156:       // case 11
			case 157:       // case 12
			case 184:       // case 13
			case 185:       // case 14
			case 188:       // case 15
			case 189:       // case 16
						tile_id = tile_3x1_mid; break;
			//
			//		0 . 0
			//		. t c
			//		0 . 0
			//
			case 16:		// case  1
			case 17:        // case  2
			case 20:        // case  3
			case 21:        // case  4
			case 48:        // case  5
			case 49:        // case  6
			case 52:        // case  7
			case 53:        // case  8
			case 144:       // case  9
			case 145:       // case 10
			case 148:       // case 11
			case 149:       // case 12
			case 176:       // case 13
			case 177:       // case 14
			case 180:       // case 15
			case 181:       // case 16
						tile_id = tile_3x1_left; break;
			//
			//		0 . 0
			//		c t c
			//		c c .
			//
			// 2 zeros mean 4 cases
			//
			case 120:
			case 121:
			case 124:
			case 125:
						tile_id = tile_corner_1s_0; break;
			//
			//		0 . 0
			//		c t c
			//		. c c
			//
			case 216:
			case 220:
			case 221:
			case 217:
						tile_id = tile_corner_1s_m_0; break;
			//
			//		c c 0
			//		c t .
			//		. c 0
			//
			case 75:
			case 79:
			case 203:
			case 207:
						tile_id = tile_corner_1s_90; break;
			//
			//		. c 0
			//		c t .
			//		c c 0
			//
			case 110:
			case 106:
			case 234:
			case 238:
						tile_id = tile_corner_1s_m_90; break;
			//
			//		. c c
			//		c t c
			//		0 . 0
			//
			case 30:
			case 62:
			case 158:
			case 190:
						tile_id = tile_corner_1s_180; break;
			//
			//		c c .
			//		c t c
			//		0 . 0
			//
			case 27:
			case 59:
			case 155:
			case 187:
						tile_id = tile_corner_1s_m_180; break;
			//
			//		0 c .
			//		. t c
			//		0 c c
			//
			case 210:
			case 211:
			case 242:
			case 243:
						tile_id = tile_corner_1s_270; break;
			//
			//		0 c c
			//		. t c
			//		0 c .
			//
			case 118:
			case 119:
			case 86:
			case 87:
						tile_id = tile_corner_1s_m_270; break;
			//
			//		. c c
			//		c t c
			//		c c .
			//
			// no zeros mean only 1 case
			//
			case 126:
						tile_id = tile_2corners; break;
			//
			//		c c .
			//		c t c
			//		. c c
			//
			case 219:
						tile_id = tile_2corners_m; break;
			//
			//		0 . 0
			//		c t c
			//		. c .
			//
			case 88:
			case 89:
			case 92:
			case 93:
						tile_id = tile_tshape_0; break;
			//
			//		. c 0
			//		c t .
			//		. c 0
			//
			case 74:
			case 78:
			case 202:
			case 206:
						tile_id = tile_tshape_90; break;
			//
			//		. c .
			//		c t c
			//		0 . 0
			//
			case 26:
			case 58:
			case 154:
			case 186:
						tile_id = tile_tshape_180; break;
			//
			//		0 c .
			//		. t c
			//		0 c .
			//
			case 82:
			case 83:
			case 114:
			case 115:
						tile_id = tile_tshape_270; break;
			//
			//		c c c
			//		c t c
			//		. c .
			//
			case 95:
						tile_id = tile_2corners_0s_0; break;
			//
			//		. c c
			//		c t c
			//		. c c
			//
			case 222:
						tile_id = tile_2corners_0s_90; break;
			//
			//		. c .
			//		c t c
			//		c c c
			//
			case 250:
						tile_id = tile_2corners_0s_180; break;
			//
			//		c c .
			//		c t c
			//		c c .
			//
			case 123:
						tile_id = tile_2corners_0s_270; break;
			//
			//		0 . 0
			//		c t .
			//		c c 0
			//
			case 104:		// case  1
			case 105:       // case  2
			case 108:       // case  3
			case 109:       // case  4
			case 232:       // case  5
			case 233:       // case  6
			case 236:       // case  7
			case 237:       // case  8
						tile_id = tile_3x3_topright; break;
			//
			//		0 . 0
			//		c t c
			//		c c c
			//
			case 248:
			case 249:
			case 252:
			case 253:
						tile_id = tile_3x3_topmid; break;
			//
			//		0 . 0
			//		. t c
			//		0 c c
			//
			case 208:		// case  1
			case 209:       // case  2
			case 212:       // case  3
			case 213:       // case  4
			case 240:       // case  5
			case 241:       // case  6
			case 244:       // case  7
			case 245:       // case  8
						tile_id = tile_3x3_topleft; break;
			//
			//		c c 0
			//		c t .
			//		c c 0
			//
			case 107:
			case 111:
			case 239:
			case 235:
						tile_id = tile_3x3_midright; break;
			//
			//		0 c c
			//		. t c
			//		0 c c
			//
			case 214:
			case 215:
			case 246:
			case 247:
						tile_id = tile_3x3_midleft; break;
			//
			//		c c 0
			//		c t .
			//		0 . 0
			//
			case 11:		// case  1
			case 43:        // case  2
			case 47:        // case  3
			case 139:       // case  4
			case 143:       // case  5
			case 175:       // case  6
			case 171:       // case  7
			case 15:        // case  8
						tile_id = tile_3x3_botright; break;
			//
			//		c c c
			//		c t c
			//		0 . 0
			//
			case 31:
			case 63:
			case 159:
			case 191:
						tile_id = tile_3x3_botmid; break;
			//
			//		0 c c
			//		. t c
			//		0 . 0
			//
			case 22:		// case  1
			case 23:        // case  2
			case 54:        // case  3
			case 55:        // case  4
			case 150:       // case  5
			case 151:       // case  6
			case 182:       // case  7
			case 183:       // case  8
						tile_id = tile_3x3_botleft; break;
			//
			//		. c .
			//		c t c
			//		. c c
			//
			case 218:
						tile_id = tile_3corners_0; break;
			//
			//		. c .
			//		c t c
			//		c c .
			//
			case 122:
						tile_id = tile_3corners_90; break;
			//
			//		c c .
			//		c t c
			//		. c .
			//
			case 91:
						tile_id = tile_3corners_180; break;
			//
			//		. c c
			//		c t c
			//		. c .
			//
			case 94:
						tile_id = tile_3corners_270; break;
			//
			//		c c c
			//		c t c
			//		c c .
			//
			case 127:
						tile_id = tile_corner_0s_0; break;
			//
			//		c c c
			//		c t c
			//		. c c
			//
			case 223:
						tile_id = tile_corner_0s_90; break;
			//
			//		. c c
			//		c t c
			//		c c c
			//
			case 254:
						tile_id = tile_corner_0s_180; break;
			//
			//		c c .
			//		c t c
			//		c c c
			//
			case 251:
						tile_id = tile_corner_0s_270; break;
			//
			//		. c .
			//		c t c
			//		. c .
			//
			case 90:
						tile_id = tile_cross; break;
			
			
			
			default: 	tile_id = tile_3x3_midmid; break;
		}
		setTile(index, tile_id);
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
			//return;
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