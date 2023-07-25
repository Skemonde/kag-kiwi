#define SERVER_ONLY

void onTick(CBlob@ this)
{
	CMap@ map = getMap();
	CCamera@ camera = getCamera();
	CPlayer@ player = this.getPlayer();
	if (this.getPosition().x >= map.tilemapwidth*map.tilesize-map.tilesize) {
		Vec2f endPos = Vec2f(map.tilesize*3, this.getPosition().y);
		this.setPosition(endPos);
		if (camera !is null && player !is null && player.isMyPlayer())
			camera.setPosition(endPos);
	} else if (this.getPosition().x <= map.tilesize) {
		Vec2f endPos = Vec2f(map.tilemapwidth*map.tilesize-map.tilesize*3, this.getPosition().y);
		this.setPosition(endPos);
		if (camera !is null && player !is null && player.isMyPlayer())
			camera.setPosition(endPos);
	}
}