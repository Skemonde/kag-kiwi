
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
		tile_bgsteelbeam = 288,
		tile_lightabsorber = 287
	};
};

//tiles
const SColor color_bgsteelbeam(255, 46, 33, 53);
const SColor color_lightabsorber(255, 30, 30, 19);

//blobs

void HandleCustomTile(CMap@ map, int offset, SColor pixel)
{
	//change this in your mod
	Vec2f pos = map.getTileWorldPosition(offset);
	//tiles
	if (pixel == color_bgsteelbeam) {
		map.server_SetTile(pos, CMap::tile_bgsteelbeam);
		map.AddTileFlag(offset, Tile::BACKGROUND | Tile::WATER_PASSES | Tile::LIGHT_PASSES);
		map.RemoveTileFlag(offset, Tile::LIGHT_SOURCE | Tile::SOLID | Tile::COLLISION);
		map.SetTileSupport(offset, 100);
	} else if (pixel == color_lightabsorber) {
		map.server_SetTile(pos, CMap::tile_lightabsorber);
		map.AddTileFlag(offset, Tile::BACKGROUND | Tile::WATER_PASSES);
		map.RemoveTileFlag(offset, Tile::LIGHT_SOURCE | Tile::SOLID | Tile::COLLISION | Tile::LIGHT_PASSES);
		map.SetTileSupport(offset, 100);
	}
}

bool isTileBGSteelBeam(u16 tile)
{
    return (tile == CMap::tile_bgsteelbeam);
}