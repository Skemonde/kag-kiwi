
#include "Hitters.as";
#include "MakeMat.as";
#include "ParticleSparks.as";
 
const u16 RESPAWN_TIME = 2 * getTicksASecond();
const f32 YIELD_PROBABILITY = 0.50f;

void onInit( CSprite@ sprite )
{
    sprite.SetZ(-50);
    sprite.SetFacingLeft(((sprite.getBlob().getNetworkID() % 13) % 2) == 0);
}

void onTick( CSprite@ sprite )
{
    if(isDepleted(sprite.getBlob()))
	    sprite.animation.frame = 1;
	else
	    sprite.animation.frame = 0;
}

void onInit( CBlob@ this )
{
    CShape@ shape = this.getShape();
	shape.SetStatic(true);
	shape.SetGravityScale(0.0f);
	
	this.set_u32("depleteRespawnTime", 0);
	this.set_f32("gib health", -5.0f);
	this.set_f32("death health", -5.0f);
	this.Tag("builder always hit");
	
	this.getCurrentScript().tickFrequency = 30;
}

void onTick( CBlob@ this )
{
    if(getNet().isServer())
	{
	    const u32 time = getGameTime();
		const u32 depleteRespawnTime = this.get_u32("depleteRespawnTime");
        const bool depleted = isDepleted(this);
		
		if (this.get_u32("last_hit")>getGameTime()-RESPAWN_TIME) return;
	    
		if(this.getHealth()<this.getInitialHealth())
		{
	        if(depleteRespawnTime == 0)
			{
	            this.set_u32("depleteRespawnTime", getGameTime() + RESPAWN_TIME);
			}
	        else if(time >= depleteRespawnTime)
			{
	            this.server_SetHealth(this.getHealth()+1);
				this.set_u32("depleteRespawnTime", 0);
			}
		}
	}
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
    if(damage <= 0.0f) return damage;
	
	if(isDepleted(this) || customData != Hitters::builder)
	{
	    if(getNet().isClient())
		{
			this.getSprite().PlaySound("/metal_stone.ogg");
			sparks(worldPoint, velocity.Angle(), damage);
		}
	    return 0.0f;
	}
	else if(getNet().isServer())
	{		
        this.Damage(damage, hitterBlob);
		
        bool yield_ore = (true) ? XORRandom(1024) / 1024.0f < (YIELD_PROBABILITY * 1.25) :
                                            XORRandom(1024) / 1024.0f <  YIELD_PROBABILITY;
		if  (yield_ore)
		{
		    MakeMat(hitterBlob, hitterBlob.getPosition(), "mat_steel", 1 * damage);
		}
		else
		{
		    MakeMat(hitterBlob, hitterBlob.getPosition(), "mat_stone", (30+(XORRandom(10))) * damage);
		}
	}
    return damage;
}

bool isDepleted( CBlob@ this )
{
    return this.getHealth() <= 0.0f;
}
