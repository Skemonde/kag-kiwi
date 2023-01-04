#include "Explosion.as";
#include "HittersKIWI.as";
#include "Hitters.as";
#include "MakeBangEffect.as";

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 8;
	this.set_bool("map_damage_raycast", true);
	
	this.Tag("projectile");
	
	this.Tag("map_damage_dirt");
	
	this.set_string("custom_explosion_sound", "handgrenade_blast");
	
	this.maxQuantity = 1;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (!solid)
	{
		return;
	}

	//u16 sound_num = XORRandom(2) + 1;
	const f32 vellen = this.getOldVelocity().Length();
	if (vellen > 1.7f)
	{
		Sound::Play("BombBounce", this.getPosition(), 0.4, 1.0f + XORRandom(2)*0.1);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool flip;
	
    if(cmd == this.getCommandID("activate"))
    {
    	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
        if(point is null){return;}
    	CBlob@ holder = point.getOccupied();

        if(holder !is null && this !is null)
        {
			this.set_u16("death_timer", 4); //3-5 seconds PLEASE Don't make it more than 999 seconds >_<
			if(isClient())
			{
				CSprite@ sprite = this.getSprite();
				if (sprite !is null)
				{
					Animation@ anim = sprite.getAnimation("default");
					if (anim !is null)
					{
						sprite.animation.frame = 1;
					}
				}
			}
			flip = holder.isFacingLeft();
		}
		
        if(isClient())
        {
			makeGibParticle(
				"SafetyRing",											// file name
				this.getPosition(),                 					// position
				Vec2f(-2 * (flip ? -1: 1), -5),							// velocity
				0,                              						// column
				0,                                  					// row
				Vec2f(5, 5),                      						// frame size
				1.0f,                               					// scale?
				0,                                  					// ?
				"handgrenade_ring",                    		  			// sound
				this.getTeamNum()										// team number
			);
		
			this.getSprite().PlaySound("GrenadePut", 1.0f, 1.0f);
		}
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

void onDie(CBlob@ this)
{
	this.getSprite().SetEmitSoundPaused(true);
	DoExplosion(this);
}

void DoExplosion(CBlob@ this)
{
	//CRules@ rules = getRules();
	//if (!shouldExplode(this, rules))
	//{
	//	addToNextTick(this, rules, DoExplosion);
	//	return;
	//}

	if (this.hasTag("exploded")) return;

	f32 random = XORRandom(32);
	f32 modifier = 1;

	this.set_f32("map_damage_radius", (64.0f + random) * modifier);
	this.set_f32("map_damage_ratio", 0.10f);
	
	Explode(this, 48.0f + random, 5.0f);
	
	if (isServer())
	{
		for (int i = 0; i < 10 * modifier; i++) 
		{
			Vec2f dir = Vec2f(1,0).RotateBy(360/10*i);
			
			LinearExplosion(this, dir, 32, 32, 2, 0.10f, HittersKIWI::bullet_pistol);
			
			/*
			CBlob @blob = server_CreateBlob("shrapnel", this.getTeamNum(), this.getPosition()); // + Vec2f(16 - XORRandom(32), -10));
			blob.setVelocity(Vec2f(10-XORRandom(20), -XORRandom(15)));
			blob.SetDamageOwnerPlayer(this.getDamageOwnerPlayer()); 
			*/
		}
	}
	
	if (isClient())
	{

	
		Vec2f pos = this.getPosition();
		CMap@ map = getMap();
		
		MakeBangEffect(this, "kaboom", 4.0);
		for (int i = 0; i < 35; i++)
		{
			MakeParticle(this, Vec2f( XORRandom(64) - 32, XORRandom(64) - 32), getRandomVelocity(360/35*i, XORRandom(220) * 0.01f, 90));
		}
		
		this.Tag("exploded");
		//this.getSprite().Gib();
	}
}

void MakeParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	//ParticleAnimated(filename, this.getPosition() + pos, vel, float(XORRandom(360)), 0.5f + XORRandom(100) * 0.01f, 1 + XORRandom(4), XORRandom(100) * -0.00005f, true);
	ParticleAnimated(
	"explosion64.png",                   // file name
	this.getPosition() + pos,            // position
	vel,                         // velocity
	float(XORRandom(360)),                              // rotation
	0.5f + XORRandom(100) * 0.01f,                               // scale
	3,                                  // ticks per frame
	0.0f,                               // gravity
	true);
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	this.getSprite().ResetTransform();
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint @detachedPoint )
{
	if (this.exists("death_date")) Sound::Play("GrenadeThrow", this.getPosition(), 2.0, 1.0f + XORRandom(3)*0.1);
}