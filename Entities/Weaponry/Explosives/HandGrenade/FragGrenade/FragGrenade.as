#include "Explosion.as";
#include "KIWI_Hitters.as";
#include "Hitters.as";
#include "MakeBangEffect.as";
#include "MakeExplodeParticles.as";
#include "CExplosion"

void onInit(CBlob@ this)
{
	//this.getCurrentScript().tickFrequency = 8;
	this.set_bool("map_damage_raycast", true);
	
	this.Tag("projectile");
	
	this.Tag("map_damage_dirt");
	
	this.Tag("dont deactivate");
	
	this.set_f32("explosion blob radius", 64);
	
	//this.Tag("no activating from inventory");
	
	this.Tag("ammo");
	
	this.set_string("custom_explosion_sound", "handgrenade_blast");
	this.set_u8("custom_hitter", HittersKIWI::handgren);
	
	this.maxQuantity = 1;
}

void onTick(CBlob@ this)
{
	if (this.exists("death_date")) {
		if (this.hasScript("SetDamageToCarrier.as"))
			this.RemoveScript("SetDamageToCarrier.as");
		this.setAngleDegrees(0);
		
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
	}
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
		if (this.isInInventory()||this.exists("death_date")) return;
    	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
        if(point is null) return;
    	CBlob@ holder = point.getOccupied();

        if(holder !is null && this !is null)
        {
			this.set_u16("death_timer", 4); //3-5 seconds PLEASE Don't make it more than 999 seconds >_<
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
	return blob.isCollidable()&&blob.getName()!="helm";
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
	//AddToProcessor(this.getDamageOwnerPlayer().getBlob().getNetworkID(), 1);
	//this.Tag("exploded");
	//return;

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

	this.set_f32("map_damage_radius", 16);
	this.set_f32("map_damage_ratio", 0.75f);
	
	//Explode(this, 48.0f + random, 5.0f);
	
	if (isServer()||true)
	{
		Explode(this, 64, 16.0f);
	}
	
	if (isServer())
	for (int idx = 0; idx < 3; ++idx) {
		CBlob@ flare = server_CreateBlob("napalm", this.getTeamNum(), this.getPosition()+Vec2f(0, -6));
		if (flare is null) continue;
		flare.set_f32("particle_scale", 1.5f);
		flare.setVelocity(getRandomVelocity(90, (8+XORRandom(14)), 10));
		flare.SetDamageOwnerPlayer(this.getDamageOwnerPlayer());
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

void onRender( CSprite@ this )
{
	return;
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	if (!blob.exists("death_date")) return;
	if (blob.get_u32("death_date")-getGameTime()>5) return;
	if (getGameTime()%30>15) return;
	
	const f32 SCALEX = getDriver().getResolutionScaleFactor();
	const f32 ZOOM = getCamera().targetDistance * SCALEX;
	
	Vec2f screen_pos = blob.getInterpolatedScreenPos();
	f32 radius = blob.get_f32("explosion blob radius");
	f32 rendered_diameter = 2*radius/256*ZOOM;
	
	GUI::DrawIcon("white_circle.png", 0, Vec2f(1,1)*256, screen_pos-Vec2f(1,1)*256*rendered_diameter, rendered_diameter, 0);
}