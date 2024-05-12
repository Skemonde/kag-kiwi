#include "Explosion.as";

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 3;
	//this.server_SetTimeToDie(5);
	
	this.set_string("custom_explosion_sound", "Molotov_Explode.ogg");
	
	this.Tag("projectile");
	this.Tag("map_damage_dirt");
	this.Tag("dont deactivate");
	this.Tag("crate pickup");
}

void onTick(CSprite@ this)
{
	if (!this.getBlob().exists("death_date")) return;
	ParticleAnimated("kiwi_fire_v2", this.getBlob().getPosition() + Vec2f(1 - XORRandom(3), -4), Vec2f(0, -1 - XORRandom(2)), 0, 1.0f, 2, 0.25f, false);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (!this.exists("death_date")) return;
	if (isServer())
	{
		if (solid || (blob !is null && blob.isCollidable()))
		{
			f32 vellen = this.getOldVelocity().Length();
			if (vellen > 3.0f)
			{
				this.server_Die();
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool flip;
	
    if(cmd == this.getCommandID("activate"))
    {
		if (this.isInInventory()||this.exists("death_date")) return;
    	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
        if(point is null) return;
    	CBlob@ holder = point.getOccupied();

        if(holder !is null && this !is null)
        {
			this.set_u16("death_timer", 7); //3-5 seconds PLEASE Don't make it more than 999 seconds >_<
			flip = holder.isFacingLeft();
		}
    }
}

void onDie(CBlob@ this)
{
	this.getSprite().SetEmitSoundPaused(true);
	DoExplosion(this);
}

void DoExplosion(CBlob@ this)
{	
	if (!this.hasTag("dead"))
	{
		Explode(this, 16.0f, 2.0f);
		
		if (isServer())
		{
			Vec2f vel = this.getOldVelocity();
			for (int i = 0; i < 9; i++)
			{
				CBlob@ blob = server_CreateBlob("napalm", -1, this.getPosition() + Vec2f(0, -8));
				//Vec2f nv = Vec2f((XORRandom(100) * 0.01f * vel.x * 1.30f), -(XORRandom(100) * 0.01f * 3.00f));
				f32 vel_factor = (vel.x>0?1:-1);
				Vec2f nv = Vec2f((XORRandom(11)),0).RotateBy(-90*vel_factor+(90-XORRandom(90)*vel_factor));
				
				blob.setVelocity(nv);
				blob.server_SetTimeToDie(2 + XORRandom(6));
			}
		}
		
		
		this.Tag("dead");
		this.getSprite().Gib();
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.isCollidable();
}

bool canBePutInInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	return !this.exists("death_date");
}