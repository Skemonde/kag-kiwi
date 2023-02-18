#include "Explosion.as";
#include "HittersKIWI.as";
#include "Hitters.as";
#include "MakeBangEffect.as";
#include "MakeExplodeParticles.as";

void onInit(CBlob@ this)
{
	//this.getCurrentScript().tickFrequency = 8;
	this.set_bool("map_damage_raycast", true);
	
	this.Tag("projectile");
	
	this.Tag("map_damage_dirt");
	
	this.set_string("custom_explosion_sound", "handgrenade_blast");
	this.set_u8("custom_hitter", HittersKIWI::boom);
	
	this.maxQuantity = 1;
}

void onTick(CBlob@ this)
{
	if (false)//this.exists("death_date"))
	{
		for(int i = 0; i < 8; ++i) {
		CParticle@ p = ParticleAnimated(
		"kiwi_fire.png",                   		// file name
		this.getPosition() + Vec2f(0,-3) + Vec2f(-XORRandom(Maths::Floor(this.getVelocity().getLength())), 0).RotateBy(-this.getVelocity().getAngleDegrees()),       // position
		Vec2f((XORRandom(60)-30)*0.01, 0),      // velocity
		0,                              		// rotation
		1.0f,                               	// scale
		3,                                  	// ticks per frame
		(XORRandom(3)+1)*-0.03f,                // gravity
		true);
		if (p !is null) {
			//p.setRenderStyle(RenderStyle::additive);
			p.Z=3+XORRandom(30)*0.01;
			p.growth = 0.015;
			p.damage = 1;
		}
		}
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (!solid)
	{
		if (this.exists("death_date")) {
			if (blob.getName() == "helm") {
				this.Tag("demined");
				this.setVelocity(Vec2f_zero);
				blob.setVelocity(Vec2f_zero);
				blob.getSprite().ResetTransform();
				blob.setPosition(this.getPosition());
				this.set_u16("the_one_who_activated_me", blob.getNetworkID());
				this.getSprite().SetRelativeZ(-10);
			}
		}
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
	
	if(this.hasTag("demined")) {
		CBlob@ minesweeper = this.exists("the_one_who_activated_me") ? getBlobByNetworkID(this.get_u16("the_one_who_activated_me")) : null;
		if (minesweeper !is null && minesweeper.isOverlapping(this)) {
			minesweeper.AddForceAtPosition(Vec2f(XORRandom(80)-40, -400), this.getPosition() + Vec2f(XORRandom(100)-50, 5));
			minesweeper.server_SetTimeToDie(2);
			Sound::Play("DistantDynamite", this.getPosition(), 3.0, 3.0f + XORRandom(2)*0.1);
			MakeExplodeParticles(this, Vec2f_zero, Vec2f_zero);
			//MakeBangEffect(this, "pufff", 1, false, Vec2f_zero);
			return;
		}
	}

	f32 random = XORRandom(32);
	f32 modifier = 1;

	this.set_f32("map_damage_radius", 32);
	this.set_f32("map_damage_ratio", 0.5f);
	
	//Explode(this, 48.0f + random, 5.0f);
	
	if (isServer())
	{
		Explode(this, 32.0f, 15.0f);
		//for (int i = 0; i < 10 * modifier; i++) 
		//{
		//	//Vec2f dir = Vec2f(1,0).RotateBy(360/10*i);
		//	//
		//	//LinearExplosion(this, dir, 32, 32, 2, 200.10f, HittersKIWI::boom);
		//	
		//}
	}
	
	if (isClient())
	{
		Vec2f pos = this.getPosition();
		CMap@ map = getMap();
		
		MakeBangEffect(this, "kaboom", 4.0);
		Sound::Play("handgrenade_blast2", this.getPosition(), 2, 1.0f + XORRandom(2)*0.1);
		u8 particle_amount = 6;
		for (int i = 0; i < particle_amount; i++)
		{
			MakeExplodeParticles(this, Vec2f( XORRandom(64) - 32, XORRandom(64) - 32), getRandomVelocity(360/particle_amount*i, XORRandom(220) * 0.01f, 90));
		}
		
		this.Tag("exploded");
	}
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	this.getSprite().ResetTransform();
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint @detachedPoint )
{
	if (this.exists("death_date")) Sound::Play("GrenadeThrow", this.getPosition(), 2.0, 1.0f + XORRandom(3)*0.1);
}