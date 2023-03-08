
/**
 *	Template for modders - add custom blocks by
 *		putting this file in your mod with custom
 *		logic for creating tiles in HandleCustomTile.
 *
 * 		Don't forget to check your colours don't overlap!
 *
 *		Note: don't modify this file directly, do it in a mod!
 */

namespace CMap
{
	enum CustomTiles
	{
		//pick tile indices from here - indices > 256 are advised.
		tile_lightabsorber 		= 287,
		tile_bgsteelbeam 		= 288,
		tile_window				= 304,
		tile_window_top			= 305,
		tile_window_mid			= 306,
		tile_window_bot			= 307,
		tile_framed_stone_top	= 308,
		tile_framed_stone_mid	= 309,
		tile_framed_stone_bot	= 310,
		tile_shoji_top			= 311,
		tile_shoji_mid			= 312,
		tile_shoji_bot			= 313
	};
};

//tiles
const SColor color_bgsteelbeam(255, 46, 33, 53);
const SColor color_lightabsorber(255, 30, 30, 19);
const SColor color_window(255, 132, 162, 207);
const SColor color_framed_stone(255, 60, 40, 24);
const SColor color_shoji(255, 150, 136, 102);

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
	}
}

bool isTileBGSteelBeam(u16 tile)
{
    return (tile == CMap::tile_bgsteelbeam);
}