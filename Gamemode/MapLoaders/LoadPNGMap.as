// loads a classic KAG .PNG map

#include "BasePNGLoader.as";
#include "MinimapHook.as";

namespace KIWI_colors
{
	enum color
	{
		armory = 0xFF4c565d
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
		switch (pixel.color)
		{
			case KIWI_colors::armory:
				spawnBlob(map, "armory", offset, 255, true, Vec2f(0, -28));
				autotile(offset);
				break;
		};
	}
};

bool LoadMap(CMap@ map, const string& in fileName)
{
	KIWIPNGLoader loader();

	MiniMap::Initialise();

	return loader.loadMap(map, fileName);
}
