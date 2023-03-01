// киви

#include "BasePNGLoader.as";
#include "MinimapHook.as";
#include "addCharacterToBlob.as";
#include "Edward.as";

namespace KIWI_colors
{
	enum color
	{
		armory = 0xff4c565d,
		zombie_portal = 0xffb575f9,
		camp = 0xff5b6bf6,
		edward = 0xffc02020,
		campfire = 0xffdf7126,
		mercury_lamp = 0xffe0e050,
		cave_door = 0xff4d1f11,
		
		nothing = 0xffffffff
	};
}

class KIWIPNGLoader : PNGLoader
{
	KIWIPNGLoader()
	{
		super();
	}
	
	void handlePixel(const SColor &in pixel, int offset) override
	{
		PNGLoader::handlePixel(pixel, offset);
		int map_center_x = map.tilemapwidth/2,
			struct_pos_x = map.getTileWorldPosition(offset).x/8,
			repub = 0,
			soviet = 1,
			//first half of map with this color will be blue and the left one will colored red
			team_colored = struct_pos_x < map_center_x ? repub : soviet,
			elven = 2,
			undead = 3,
			neutral = -1;
			
		CBlob@ blob_to_spawn = null;
			
		switch (pixel.color)
		{
			case KIWI_colors::armory:
				spawnBlob(map, "armory", offset, team_colored, true, Vec2f(0, 0));
				autotile(offset); break;
			
			case KIWI_colors::zombie_portal:
				spawnBlob(map, "zombieportal", offset, undead, true, Vec2f(-4, -4));
				autotile(offset); break;
				
			case KIWI_colors::camp:
				spawnBlob(map, "camp", offset, soviet, true, Vec2f(-4, 0));	
				autotile(offset); break;
				
			case KIWI_colors::edward:
				spawnBlob(map, "ed", offset, elven, false, Vec2f(-4, -4));
				autotile(offset); break;
				
			case KIWI_colors::campfire:
				spawnBlob(map, "campfire", offset, neutral, true, Vec2f(-4, 0));
				autotile(offset); break;
				
			case KIWI_colors::mercury_lamp:
				spawnBlob(map, "mercurylamp", offset, neutral, true, Vec2f(0, 0));
				autotile(offset); break;
				
			case KIWI_colors::cave_door:
				spawnBlob(map, "cavedoor", offset, elven, true, Vec2f(-4, -4));
				autotile(offset); break;
		};
	}
};

bool LoadMap(CMap@ map, const string& in fileName)
{
	KIWIPNGLoader loader();

	MiniMap::Initialise();

	return loader.loadMap(map, fileName);
}
