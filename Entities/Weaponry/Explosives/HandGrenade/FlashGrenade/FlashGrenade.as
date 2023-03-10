#include "Hitters.as";
#include "Knocked.as";
#include "Explosion.as";
#include "MakeBangEffect.as";

const f32 max_range = 256.00f;

void onInit(CBlob@ this)
{
	this.Tag("projectile");
	this.maxQuantity = 1;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (!solid)
	{
		return;
	}

	u16 sound_num = XORRandom(2) + 1;
	const f32 vellen = this.getOldVelocity().Length();
	if (vellen > 1.7f)
	{
		Sound::Play("GrenadeDrop" + sound_num, this.getPosition(), 0.4, 1.0f + XORRandom(2)*0.1);
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
			this.set_u16("death_timer", 3); //3-5 seconds PLEASE Don't make it more than 999 seconds >_<
			
			CSprite@ sprite = this.getSprite();
			if (sprite !is null)
			{
				Animation@ anim = sprite.getAnimation("default");
				if (anim !is null)
				{
					sprite.animation.frame = 1;
				}
			}
			flip = holder.isFacingLeft();
           }
		
		makeGibParticle(
			"SafetyPlate",											// file name
			this.getPosition(),                 					// position
			Vec2f(-2 * (flip ? -1: 1), -5),											// velocity
			0,                              						// column
			0,                                  					// row
			Vec2f(5, 5),                      						// frame size
			1.0f,                               					// scale?
			0,                                  					// ?
			"handgrenade_ring",                    		  				// sound
			this.getTeamNum()										// team number
		);
		
		this.getSprite().PlaySound("GrenadePut", 1.0f, 1.0f);
    }
}

void onDie(CBlob@ this)
{
	CBlob@[] blobs;
	if (this.getMap().getBlobsInRadius(this.getPosition(), max_range, @blobs))
	{
		for (int i = 0; i < blobs.length; i++)
		{
			CBlob@ blob = blobs[i];
			if (!blob.hasTag("player")) continue;
			
			if (!this.getMap().rayCastSolidNoBlobs(blob.getPosition(), this.getPosition()))
			{
				f32 dist = (blob.getPosition() - this.getPosition()).getLength();
				f32 factor = 1.00f - Maths::Pow(dist / max_range, 2);
			
			
				if (blob is getLocalPlayerBlob())
				{					
					if (isClient())
					{
						SetScreenFlash(255, 255, 255, 255, 30 * factor);
						Sound::Play("Flashbang", this.getPosition(), 2.0, 1.0f + XORRandom(2)*0.1);
					}
				}
				else
				{
					SetDazzled(blob, 250 * factor);
					blob.Tag("force_knock");
				}
			}
			else Sound::Play("dry_hit", this.getPosition(), 3.0, 1.5f + XORRandom(2)*0.1);
		}
	}
	
	//for (int i = 0; i < 4; ++i)
	{
		CBlob@ light = server_CreateBlob("flashyflash", this.getTeamNum(), this.getPosition());
	}
	MakeBangEffect(this, "pufff", 1, false, Vec2f_zero);
	for (u8 i = 1; i <= 5; ++i) ParticleAnimated("SmallSteam", this.getPosition(), Vec2f(0,0), float(XORRandom(360)), 1.0f + XORRandom(100) * 0.01f, 2 + XORRandom(4), XORRandom(100) * -0.00005f, true);
	
	//Explode(this, 0.01f, 0.00f);
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	if (inventoryBlob is null) return;

	CInventory@ inv = inventoryBlob.getInventory();

	if (inv is null) return;

	this.doTickScripts = true;
	inv.doTickScripts = true;
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	this.getSprite().ResetTransform();
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint @detachedPoint )
{
	if (this.exists("death_date")) Sound::Play("GrenadeThrow", this.getPosition(), 2.0, 1.0f + XORRandom(3)*0.1);
}
