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

void onDie(CBlob@ this)
{
	if (this.hasTag("temp blob")) return;
	for (int idx = 0; idx < 2; ++idx) {
		makeGibParticle(
			"SteelDoorGibs.png",
			this.getPosition(), this.getVelocity() + getRandomVelocity(idx==0?0:180, 2 , 30),
			0, idx, Vec2f(9, 9),
			2.0f, 20, "BaseHitSound", this.getTeamNum()
		);
	}
}