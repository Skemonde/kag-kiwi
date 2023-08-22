
/**
 *	Template for modders - add custom blocks by
 *		putting this file in your mod with custom
 *		logic for creating tiles in HandleCustomTile.
 *
 * 		Don't forget to check your colours don't overlap!
 *
 *		Note: don't modify this file directly, do it in a mod!
 */
const int filewidth = 16;

namespace CMap
{
	enum CustomTiles
	{
		//pick tile indices from here - indices > 256 are advised.
		tile_lightabsorber 			= 287,
			
		tile_bgsteelbeam 			= 288,
		
		tile_tnt					= 321,
			
		tile_window					= 320,
		tile_window_top				= tile_window+filewidth,
		tile_window_mid				= tile_window_top+filewidth,
		tile_window_bot				= tile_window_mid+filewidth,
			
		tile_framed_stone_top		= tile_window_top+1,
		tile_framed_stone_mid		= tile_framed_stone_top+filewidth,
		tile_framed_stone_bot		= tile_framed_stone_mid+filewidth,
			
		tile_shoji_top				= tile_framed_stone_top+1,
		tile_shoji_mid				= tile_shoji_top+filewidth,
		tile_shoji_bot				= tile_shoji_mid+filewidth,
		//	
		//	
		//steel tiles	
		tile_steel_1x1				= tile_window_bot+filewidth,
		//
		tile_steel_3x1_left			= tile_steel_1x1+1,
		tile_steel_3x1_mid			= tile_steel_1x1+2,
		tile_steel_3x1_right		= tile_steel_1x1+3,
		//
		tile_steel_1x3_top			= tile_steel_1x1+filewidth,
		tile_steel_1x3_mid			= tile_steel_1x1+filewidth*2,
		tile_steel_1x3_bot			= tile_steel_1x1+filewidth*3,
		//
		tile_steel_3x3_topleft		= tile_steel_1x3_top+1,
		tile_steel_3x3_topmid		= tile_steel_1x3_top+2,
		tile_steel_3x3_topright		= tile_steel_1x3_top+3,
		tile_steel_3x3_midleft		= tile_steel_3x3_topleft+filewidth*1,
		tile_steel_3x3_midmid		= tile_steel_3x3_midleft+1,
		tile_steel_3x3_midright		= tile_steel_3x3_midleft+2,
		tile_steel_3x3_botleft		= tile_steel_3x3_topleft+filewidth*2,
		tile_steel_3x3_botmid		= tile_steel_3x3_botleft+1,
		tile_steel_3x3_botright		= tile_steel_3x3_botleft+2,
		//
		tile_steel_tshape_0			= tile_steel_3x1_right+5,
		tile_steel_tshape_90		= tile_steel_tshape_0+1,
		tile_steel_tshape_180		= tile_steel_tshape_90+filewidth,
		tile_steel_tshape_270		= tile_steel_tshape_0+filewidth,
		//
		tile_steel_corner_2s_0		= tile_steel_3x1_right+1,
		tile_steel_corner_2s_90		= tile_steel_corner_2s_0+3,
		tile_steel_corner_2s_180	= tile_steel_corner_2s_90+filewidth*3,
		tile_steel_corner_2s_270	= tile_steel_corner_2s_0+filewidth*3,
		//3 corners is 3 corners
		tile_steel_3corners_0		= tile_steel_tshape_270+filewidth,
		tile_steel_3corners_90		= tile_steel_3corners_0+1,
		tile_steel_3corners_180		= tile_steel_3corners_90+filewidth,
		tile_steel_3corners_270		= tile_steel_3corners_0+filewidth,
		//no comments
		tile_steel_2corners_m		= tile_steel_tshape_90+1,
		tile_steel_2corners			= tile_steel_2corners_m+filewidth,
		//like t-shaped one but with no side
		tile_steel_2corners_0s_0	= tile_steel_2corners_m+1,
		tile_steel_2corners_0s_90	= tile_steel_2corners_0s_0+1,
		tile_steel_2corners_0s_180	= tile_steel_2corners_0s_90+filewidth,
		tile_steel_2corners_0s_270	= tile_steel_2corners_0s_0+filewidth,
		//1s stands for 1 side + 1 corner
		tile_steel_corner_1s_0		= tile_steel_corner_2s_0+1,
		tile_steel_corner_1s_90		= tile_steel_corner_1s_0+filewidth+2,
		tile_steel_corner_1s_180	= tile_steel_corner_1s_90+filewidth*2-1,
		tile_steel_corner_1s_270	= tile_steel_corner_1s_180-filewidth-2,
		//1s stands for 1 side + 1 corner AND MIRRORED
		tile_steel_corner_1s_m_0	= tile_steel_corner_1s_0+1,
		tile_steel_corner_1s_m_90	= tile_steel_corner_1s_90+filewidth,
		tile_steel_corner_1s_m_180	= tile_steel_corner_1s_180-1,
		tile_steel_corner_1s_m_270	= tile_steel_corner_1s_270-filewidth,
		//1s stands for 0 sides + 1 corner
		tile_steel_corner_0s_0		= tile_steel_corner_2s_0+filewidth+1,
		tile_steel_corner_0s_90		= tile_steel_corner_0s_0+1,
		tile_steel_corner_0s_180	= tile_steel_corner_0s_90+filewidth,
		tile_steel_corner_0s_270	= tile_steel_corner_0s_0+filewidth,
		//cross is cross
		tile_steel_cross			= tile_steel_2corners+filewidth,
		//damaged steel tiles
		tile_steel_d0				= tile_steel_1x3_bot+filewidth,
		tile_steel_d1				= tile_steel_d0+1,
		tile_steel_d2				= tile_steel_d1+1,
		tile_steel_d3				= tile_steel_d2+1,
		tile_steel_d4				= tile_steel_d3+1,
		tile_steel_d5				= tile_steel_d4+1,
		tile_steel_d6				= tile_steel_d5+1,
		tile_steel_d7				= tile_steel_d6+1,
	};
};

bool isTileSteel(u16 tile_type, bool damaged_tiles_too=false) {
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
	//adding damaged too if it's necessary
	if (damaged_tiles_too) {
		tiles.push_back(CMap::tile_steel_d0);
		tiles.push_back(CMap::tile_steel_d1);
		tiles.push_back(CMap::tile_steel_d2);
		tiles.push_back(CMap::tile_steel_d3);
		tiles.push_back(CMap::tile_steel_d4);
		tiles.push_back(CMap::tile_steel_d5);
		tiles.push_back(CMap::tile_steel_d6);
		tiles.push_back(CMap::tile_steel_d7);
	}
	
	for (int counter = 0; counter < tiles.size(); ++counter) {
		if (tile_type==tiles[counter]) {
			return true;
		}
	}
	return false;
}

bool isTileDamagedSteel(u16 tile_type) {
	return tile_type>=CMap::tile_steel_d0&&tile_type<=CMap::tile_steel_d7;
}

//tiles
const SColor color_bgsteelbeam(255, 46, 33, 53);
const SColor color_lightabsorber(255, 30, 30, 19);
const SColor color_window(255, 132, 162, 207);
const SColor color_framed_stone(255, 60, 40, 24);
const SColor color_shoji(255, 150, 136, 102);
const SColor color_steel(255, 197, 206, 221);
const SColor color_tnt(255, 142, 42, 9);

//blobs

void HandleCustomTile(CMap@ map, int offset, SColor pixel)
{
	//change this in your mod
	Vec2f pos = map.getTileWorldPosition(offset);
	//tiles
	if (pixel == color_bgsteelbeam) {
		map.server_SetTile(pos, CMap::tile_bgsteelbeam);
	} else if (pixel == color_lightabsorber) {
		map.server_SetTile(pos, CMap::tile_lightabsorber);
	} else if (pixel == color_window) {
		map.server_SetTile(pos, CMap::tile_window);
	} else if (pixel == color_framed_stone) {
		map.server_SetTile(pos, CMap::tile_framed_stone_top);
	} else if (pixel == color_shoji) {
		map.server_SetTile(pos, CMap::tile_shoji_top);
	} else if (pixel == color_steel) {
		map.server_SetTile(pos, CMap::tile_steel_1x1);
	} else if (pixel == color_tnt) {
		map.server_SetTile(pos, CMap::tile_tnt);
	}
}

bool isTileBGSteelBeam(u16 tile)
{
    return (tile == CMap::tile_bgsteelbeam);
}

bool isTileWindow(u16 tile)
{
	return 	tile == CMap::tile_window ||
			tile == CMap::tile_window_top ||
			tile == CMap::tile_window_mid ||
			tile == CMap::tile_window_bot;
}
bool isTileSteelBeam(u16 tile)
{
	return tile == CMap::tile_bgsteelbeam;
}