u16 getProducingInterval()
{
	return 14*5;
	return Maths::Max(60, 180.0f-Maths::Floor(getRules().get_u32("match_time")/getTicksASecond()/60)*2);
}

void checkIfCanMine(CBlob@ this)
{
	CMap@ map = getMap();
	Vec2f important_pos = this.getPosition()+Vec2f(-map.tilesize, 3.5f*map.tilesize);
	this.Untag("active");
	
	for (int pos_x = 0; pos_x<3*map.tilesize; pos_x+=map.tilesize) {
		TileType type = map.getTile(important_pos+Vec2f(pos_x,0)).type;
		if (map.isTileGroundStuff(type)) {
			this.Tag("active");
			break;
		}
	}
	//disabled for a test
	this.Tag("active");
}