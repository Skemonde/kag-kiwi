#include "CustomBlocks"

void onInit(CBlob@ this)
{
	this.set_Vec2f("snap offset", Vec2f(0, -4));
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	if (!isStatic) return;
	
	if (getNet().isServer())
	{
		dictionary harvest;
		harvest.set('mat_steel', 1);
		this.set('harvest', harvest);
	}
		
	CMap@ map = getMap();
	
	for (int y = 0; y<this.getShape().getHeight(); y+=map.tilesize)
	{
		map.server_SetTile(this.getPosition()+Vec2f(0,-8+y), CMap::tile_bgsteelbeam);
	}
}