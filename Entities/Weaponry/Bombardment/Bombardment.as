#include "Explosion.as";
#include "Hitters.as";
#include "MakeMat.as";

f32 danger_radius = 256;

void onInit(CBlob@ this)
{
	this.getShape().SetGravityScale(0.0f);
	this.getShape().SetStatic(true);
	
	if (isClient())
	{
		CCamera@ cam = getCamera();
		if (cam !is null && (cam.getPosition()-this.getPosition()).Length()<danger_radius)
		{
			client_AddToChat("Artillery fires at your position", SColor(255, 255, 0, 0));
		}
	}
	
	this.set_u8("shots fired", 0);
	this.set_u8("shots spawned", 0);
	
	if (!this.exists("max shots fired")) this.set_u8("max shots fired", 10);
	if (!this.exists("delay between shells")) this.set_u32("delay between shells", 5);
	if (!this.exists("shell blob")) this.set_string("shell blob", "rocket");
	
	this.set_u32("next shot", getGameTime() + 150);
	this.set_u32("next spawn", getGameTime() + 150);
}

void onTick(CBlob@ this)
{
	const u8 shotsFired = this.get_u8("shots fired");
	const u8 maxShotsFired = this.get_u8("max shots fired");
	const u32 delay = this.get_u32("delay between shells");
	
	if (isClient() && getGameTime() >= this.get_u32("next shot") && shotsFired < maxShotsFired)
	{
		CCamera@ cam = getCamera();
		if (cam !is null && (cam.getPosition()-this.getPosition()).Length()<danger_radius)
		{
			//client_AddToChat("Artillery fires at your position", SColor(255, 255, 0, 0));
			Sound::Play("PatriotExplosion.ogg", cam.getPosition(), 1.00f, 0.50f+1.0f*XORRandom(300)/1000);
			ShakeScreen(20, 30, this.getPosition());
			this.set_u32("next shot", (getGameTime() + 20 + XORRandom(delay)));
		
			this.set_u8("shots fired", shotsFired + 1);
		}
	}
	
	if (isServer())
	{
		const u32 ticks = this.getTickSinceCreated();
		const u8 shotsSpawned = this.get_u8("shots spawned");
		
		if (ticks >= 150 + 300 && getGameTime() >= this.get_u32("next spawn"))
		{
			for (int idx = 0; idx < 5; ++idx) {
				f32 angle = 10 + XORRandom(30)/3;
				CMap@ map = getMap();
				int map_center_x = map.tilemapwidth/2;
				int struct_pos_x = this.getPosition().x/map.tilesize;
				f32 flipped = struct_pos_x>map_center_x?-1:1;
				
				CBlob@ b = server_CreateBlobNoInit(this.get_string("shell blob"));
				b.server_setTeamNum(250);
				b.setPosition(Vec2f(this.getPosition().x + (200 + 40*idx*2)*flipped, -400));
				b.setVelocity(Vec2f(0, 10).RotateBy(angle*flipped) * 20.00f);
				b.setAngleDegrees(angle);
				b.Init();
			}
			
			this.set_u8("shots spawned", shotsSpawned + 1);
			this.set_u32("next spawn", (getGameTime() + 20 + XORRandom(delay)));
		}
		
		if (shotsSpawned >= maxShotsFired)
		{
			this.server_Die();
		}
	}
}

void onDie(CBlob@ this)
{
}