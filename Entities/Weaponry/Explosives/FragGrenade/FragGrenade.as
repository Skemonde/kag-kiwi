#include "MetroBoomin"
#include "KIWI_Hitters.as";
#include "Hitters.as";
#include "MakeBangEffect.as";
#include "MakeExplodeParticles.as";
#include "CExplosion"
#include "ActivationThrowCommon"
#include "KIWI_Locales"

void onInit(CBlob@ this)
{
	this.setInventoryName(Names::frag_grenade);
	//this.getCurrentScript().tickFrequency = 8;
	this.set_bool("map_damage_raycast", true);
	
	this.Tag("projectile");
	
	this.Tag("map_damage_dirt");
	
	this.Tag("dont deactivate");
	
	this.set_f32("explosion blob radius", 40);
	
	//this.Tag("no activating from inventory");
	
	this.Tag("ammo");
	
	this.Tag("activatable");
	
	this.set_string("custom_explosion_sound", "handgrenade_blast");
	this.set_u8("custom_hitter", HittersKIWI::handgren);
	
	this.maxQuantity = 1;

	Activate@ func = @onActivate;
	this.set("activate handle", @func);

	this.addCommandID("activate client");
	this.addCommandID("activate");
	
	if (XORRandom(1024)>16) return;
	CSprite@ sprite = this.getSprite();
	Vec2f sprite_dims = Vec2f(sprite.getFrameWidth(), sprite.getFrameHeight());
	sprite.ReloadSprite("cool_FragGrenade", sprite_dims.x, sprite_dims.y);
	this.SetInventoryIcon("cool_FragGrenade", 0, sprite_dims);
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

// custom callback
void onActivate(CBitStream@ params)
{
	if (!isServer()) return;

	u16 this_id;
	if (!params.saferead_u16(this_id)) return;
	
	CBlob@ this = getBlobByNetworkID(this_id);
	if (this is null) return;
	
	if (this.isInInventory()||this.exists("death_date")) return;
	
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	if(point is null) return;
	
	CBlob@ holder = point.getOccupied();
	if(holder is null) return;

	this.set_u16("death_timer", 4); //3-5 seconds PLEASE Don't make it more than 999 seconds >_<
	
	this.SendCommand(this.getCommandID("activate client"));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
    if(cmd == this.getCommandID("activate client"))
    {
		bool flip;
		
    	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
        if(point is null) return;
    	CBlob@ holder = point.getOccupied();

        if(holder !is null && this !is null)
        {
			flip = holder.isFacingLeft();
		}
		
        if(isClient())
        {
			makeGibParticle(
				this.getSprite().getFilename().find("cool")<0?"SafetyRing.png":"cool_SafetyRing.png",											// file name
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

	this.set_f32("map_damage_radius", 32);
	this.set_f32("map_damage_ratio", 1.00f);
	this.set_f32("explosion blob radius", 40);
	this.set_string("custom_explosion_sound", "bombita_explode");
	
	if (isServer()||true)
	{
		if (!this.exists("custom_explosion_pos")) this.set_Vec2f("custom_explosion_pos", this.getPosition());
		MakeItBoom(this, this.get_f32("explosion blob radius"), 32.0f);
	}
	
	kiwiExplosionEffects(this);
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