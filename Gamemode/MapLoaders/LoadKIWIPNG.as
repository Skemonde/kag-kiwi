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
		int map_x_center = map.tilemapwidth/2;
		int neutral = -1,
			team_colored = getSpawnPosition(map, offset).x < map_x_center ? 0 : 1,
			repub = 0,
			soviet = 1,
			elven = 2,
			undead = 3;
			
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
				spawnBlob(map, "camp", offset, team_colored, true, Vec2f(-4, 0));
				autotile(offset); break;
				
			case KIWI_colors::edward:
				spawnBlob(map, "ed", offset, elven, false, Vec2f(-4, -4));
				autotile(offset); break;
				
			case KIWI_colors::campfire:
				spawnBlob(map, "campfire", offset, neutral, true, Vec2f(-4, 0));
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
