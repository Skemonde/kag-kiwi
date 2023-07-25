#include "Hitters"
#include "CollideWithPlatform"

const u8 fire_density = 1;
const u8 time_to_die = 1;
void onInit(CBlob@ this)
{
	this.getShape().SetGravityScale(0.1f);
	this.server_SetTimeToDie(time_to_die);

	if(isServer())
	{
		this.getCurrentScript().tickFrequency = 15;
	}

	if(isClient())
	{
		this.getCurrentScript().tickFrequency = 2;
	}

	if(isClient())
	{
		this.getCurrentScript().runFlags |= Script::tick_onscreen;
	}
	this.SetLight(true);
	this.SetLightRadius(48.0f);
	this.SetLightColor(SColor(255, 255, 200, 50));
	//this.getSprite().ScaleBy(Vec2f(1.5f, 1.5f));
	//this.getSprite().setRenderStyle(RenderStyle::additive);
	this.setAngleDegrees(-this.getVelocity().getAngleDegrees());
    this.getSprite().getConsts().accurateLighting = true;
    //this.getSprite().SetVisible(false); 
}

void onInit(CSprite@ this)
{
	Animation@ anim = this.getAnimation("default");
	//print("time ="+anim.timer);
	anim.time = XORRandom(3)+3;
	
	for (int counter = 0; counter < fire_density; ++counter) {
		CSpriteLayer@ flame = this.addSpriteLayer("flame"+counter, "kiwi_fire.png", 8, 8);
		if (flame !is null)
		{
			flame.addAnimation("default", anim.time, false);
			int[] frames = { 0, 1, 2, 3, 4, 5, 6, 7, 8 };
			flame.animation.AddFrames(frames);
			flame.SetRelativeZ(10+3*counter);
			//flame.SetOffset(sprite_offset + Vec2f(29, -28));
		}
	}
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	
	Animation@ anim = this.getAnimation("default");
	if (anim !is null) {
		anim.time = blob.getTimeToDie()*23;
	}
	
	CBlob@[] flames;
	if (getBlobsByName("napalm", flames)) {
		f32 min_dist = 99999999;
		int index = 0;
		Vec2f pos_diff = Vec2f_zero;
		f32 angle = 0;
		for (int counter = 0; counter < flames.size(); ++counter) {
			min_dist = 7;
			//break;
			CBlob@ current = flames[counter];
			if (current !is null && !(current is blob)) {
				pos_diff = current.getPosition()-blob.getPosition();
				f32 current_dist = pos_diff.Length();
				angle = pos_diff.AngleDegrees();
				if (current_dist<min_dist) {
					min_dist = current_dist;
					index = counter;
				}
			}
		}
		CBlob@ neighbour = flames[index];
		for (int counter = 0; counter < fire_density; ++counter){
			CSpriteLayer@ flame = this.getSpriteLayer("flame"+counter);
			Animation@ anim = flame.getAnimation("default");
			if (anim !is null) {
				//anim.time = blob.getTimeToDie()*23-4;
			}
			if (flame !is null) {
				if (neighbour !is null) {
					//flame.SetOffset(pos_diff/fire_density*counter);
					flame.SetOffset(Vec2f(min_dist*1.2/(fire_density+1)*(counter+1),XORRandom(fire_density*2)-fire_density));
				} else {
					flame.SetOffset(Vec2f_zero);
				}
				//flame.ScaleBy(Vec2f(1.02f, 1.02f));
			}
		}
	}
}

void onTick(CBlob@ this)
{
	//so it doesn't change angle upon hitting a wall (looks awful)
	if (this.getVelocity().Length()>0.3&&!this.isInWater())
		this.setAngleDegrees(-this.getVelocity().getAngleDegrees());
		
	//this.getSprite().ScaleBy(Vec2f(1.09f, 1.09f));

	if (isServer() && this.getTickSinceCreated() > 5) 
	{
		Vec2f pos = this.getPosition();
		CMap@ map = getMap();
		
		Vec2f bpos = pos + Vec2f(map.tilesize, 0).RotateBy(this.getAngleDegrees());
		TileType t = map.getTile(bpos).type;
		if(map.isTileWood(t))
			getMap().server_setFireWorldspace(this.getPosition() + Vec2f(XORRandom(16) - 8, XORRandom(16) - 8), true);

	
		//map.server_setFireWorldspace(pos, true);
		
		for (int i = 0; i < 3; i++)
		{
			Vec2f bpos = pos + Vec2f(12 - XORRandom(24), XORRandom(8));
			TileType t = map.getTile(bpos).type;
			if (map.isTileGround(t) && t != CMap::tile_ground_d0 && (XORRandom(100) < 50 ? true : t != CMap::tile_ground_d1) || map.isTileWood(t))
			{
				map.server_DestroyTile(bpos, 1, this);
			}
			else
			{
				//map.server_setFireWorldspace(bpos, true);
			}
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.getShape().isStatic();
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (isServer())
	{
		if (solid)
		{
			Vec2f pos = this.getPosition();
			CMap@ map = getMap();

			for (int i = 0; i < 3; i++)
			{
				Vec2f bpos = pos + Vec2f(map.tilesize*i, 0).RotateBy(this.getAngleDegrees());
				TileType t = map.getTile(bpos).type;
				if (map.isTileGround(t) && t != CMap::tile_ground_d0 && (XORRandom(100) < 50 ? true : t != CMap::tile_ground_d1))
				{
					map.server_DestroyTile(bpos, 1, this);
				}
				{
					map.server_setFireWorldspace(bpos, true);
				}
			}
			this.server_Die();
		}
		if (this.isInWater())
		{
			if (isServer()) this.server_Die();
		}
		else if (blob !is null && blob.isCollidable())
		{
			if (this.getTeamNum() != blob.getTeamNum()) this.server_Hit(blob, this.getPosition(), Vec2f(0, 0), 0.50f, Hitters::fire, false);
			//napalm doesn't come through platform if it's facing the right side
			if (blob.getShape().isStatic() && CollidesWithPlatform(this, blob, this.getVelocity()))
				this.server_Die();
		}
	}
}
f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::water || customData == Hitters::water_stun)
	{
		if (isServer()) this.server_Die();
	}

	return damage;
}
