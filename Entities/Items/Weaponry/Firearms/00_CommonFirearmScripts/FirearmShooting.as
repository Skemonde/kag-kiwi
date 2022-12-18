// Script by Skemonde
// I will use royal "we" in code comments :P
// 
// holy shit amogus ඞ
#include "FirearmVars.as";
#include "Logging.as";
#include "getAimAngle.as";
#include "MakeBangEffect.as";
#include "drawProgressBar.as";


const f32 reloadangle = 14;

void onInit( CBlob@ this )
{
	FirearmVars@ vars;
	this.get("firearm_vars", @vars);
	
    AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
    if (ap !is null)
    {
        ap.SetKeysToTake( key_action1 | key_action2 | key_action3);
    }
	
	//	basically our firearms have three different modes of fire
	//	
	//	first is when a firearm does each shot after a command (LMB)
	//	second one is when the firearm shoots when LMB is pressed
	//	and the last one is when the firearm does a certain amount of shots (you cannot stop the firearm shooting till burst ends) after a command (LMB) - this one seems similar to a first one but it's actually not
	
	if (vars.BURST == 1)
		// if the firearm is not capable of making more than a single shot in its burst we give it a specific Tag
		// that's why we said semi-automatic is not like burst-shooting firearms
		this.Tag("semi_autimatic");
	else if (vars.BURST == 0)
		//this one is funny
		this.Tag("full_auto");
	else
		//i love NT but you won't get auto-burst-shooting firearms >:(
		this.Tag("burst_shooting");

	
	CSprite@ sprite = this.getSprite();
	
	CSpriteLayer@ flash = sprite.addSpriteLayer("muzzle_flash",
		this.exists("CustomMuzzleFlash") ? (this.get_string("CustomMuzzleFlash").empty() ? "blank_flash" : this.get_string("CustomMuzzleFlash")) : "flash_bullet", 16, 16, this.getTeamNum(), 0);
	
	if (flash !is null)
	{
		Animation@ anim = flash.addAnimation("default", 1, false);
		int[] frames = {0, 1, 2, 3, 4, 5, 6, 7};
		anim.AddFrames(frames);
		flash.SetRelativeZ(500.0f);
		// for bazookas we want to have fancy flash from their back end
		flash.SetFacingLeft(this.hasTag("CustomMuzzleLeft"));
		//flash.setRenderStyle(RenderStyle::additive);
		flash.SetVisible(false);
	}
	
	
	u8 col = XORRandom(2);
	string laser_color;
	switch(col)
	{
	case 0: laser_color = "Red"; break;
	case 1: laser_color = "Green"; break;
	}
	
	CSpriteLayer@ laser = sprite.addSpriteLayer("laser", "Laser_" + laser_color, 1, 1);
	
	if(laser !is null)
	{
		Animation@ anim = laser.addAnimation("default", 0, false);
		anim.AddFrame(0);
		laser.SetRelativeZ(-1.0f);
		laser.SetVisible(false);
		laser.setRenderStyle(RenderStyle::outline);
	}

	// shoot command Init
    this.addCommandID("shoot");
	// reload command Init
    this.addCommandID("reload");
	// second action command Init
    this.addCommandID("action2");
	
	// item you have is dangerous y'know?
	this.Tag("firearm");
	
	// interval Init
    this.set_u16("interval", 0);
	this.set_u8("clickReload", 0);
	// we set specific amount of available shots from the firearm Init
	this.set_u16("clip", vars.CLIP);
	// shotcount Init
	this.set_u8("shotcount", 0);
	// this variable for empty case particles we make during reload of such firearms like a revolver or a mulsti-shot GL
	this.set_u8("shots_made_before_reloading", 0);
	// starts a firearm reloading
	this.set_bool("beginReload", false);
	// determines if the firearm is in a reloading phase
	this.set_bool("doReload", false);
	// for testing in localhost
	this.set_bool("cheaty", false);
	// no comments
	this.set_Vec2f("gun_trans", Vec2f_zero);
	// no comments
	this.set_Vec2f("gun_trans_from_carrier", Vec2f_zero);
	// no comments
	this.set_bool("aiming", false);
	
	this.set_f32("reload_ending_time", 0);
	this.set_f32("cycle_time", 0);
}

void onTick( CBlob@ this )
{	
	CSprite@ sprite = this.getSprite();
	const Vec2f sprite_offset = sprite.getOffset();
		
	const bool flip = this.isFacingLeft();
	const f32 flip_factor = flip ? -1 : 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	const Vec2f shoulder_joint = Vec2f((3 - sprite_offset.x) * flip_factor, -3 - sprite_offset.y)
		+ Vec2f(this.get_Vec2f("gun_trans_from_carrier").x * flip_factor, this.get_Vec2f("gun_trans_from_carrier").y);
	FirearmVars@ vars;
	this.get("firearm_vars", @vars);
	
    if (this.isAttached())
    {
		//this.getCurrentScript().runFlags &= ~(Script::tick_not_sleeping); 					   		
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");	   		
        CBlob@ holder = point.getOccupied();												   
        if (holder is null) { return; }
		u8 interval = this.get_u16("interval");

        CShape@ shape = this.getShape();
		CSpriteLayer@ flash = sprite.getSpriteLayer("muzzle_flash");
		Vec2f pos = this.getPosition();
		
		// angle stuff
		f32 aimangle;
		if (true) //!this.hasTag("we_shootin")
		{
			aimangle = getAimAngle(this,holder)*flip_factor;
			if (this.get_bool("doReload") || this.get_bool("beginReload")) aimangle = flip ? (reloadangle) : -reloadangle;
			if (this.exists("ClampedAimangle")) aimangle = Maths::Clamp(aimangle, -this.get_f32("ClampedAimangle"), this.get_f32("ClampedAimangle"));
			this.set_f32("aimangle", aimangle);
		}
		else
			aimangle = this.get_f32("aimangle");
		
		// offset stuff
		Vec2f gun_translation = this.get_Vec2f("gun_trans");
		Vec2f muzzle_offset = Vec2f(-(Maths::Abs(vars.MUZZLE_OFFSET.x) + gun_translation.x), (vars.MUZZLE_OFFSET.y + gun_translation.y));
		muzzle_offset.RotateBy( -aimangle * flip_factor, Vec2f() );
		this.set_Vec2f("muzzle_offset", muzzle_offset);
		
		
		
		
		
		
		
		
		
		
		
		Vec2f hitPos;
		f32 laser_length;
		f32 range = 800;
		//Vec2f offset = Vec2f(laser_offset.x * flip_factor, laser_offset.y);
		//Vec2f offset = Vec2f(laser_offset.x, laser_offset.y);
		
		//AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");	   		
        //CBlob@ holder = point.getOccupied();												   
        //if (holder is null) { return; }
		
		//f32 angle =	this.get_f32("aimangle");
		//offset.RotateBy( -angle, Vec2f(0, 0) );
		//startPos += offset.RotateBy(angle, Vec2f(3 * flip_factor, -3));
		//startPos = Vec2f(startPos.x + offset.x/4 * flip_factor, startPos.y + offset.y);
		
		CSpriteLayer@ laser = this.getSprite().getSpriteLayer("laser");
		
		if (laser !is null)
		{
			//if (getGameTime() % 3 == 0 || getGameTime() % 4 == 0) laser.setRenderStyle(RenderStyle::outline);
			//else laser.setRenderStyle(RenderStyle::light);
			laser.ResetTransform();
			//laser.RotateBy(aimangle, Vec2f(3 * flip_factor, -3));
			//Vec2f laser_offset = Vec2f(-(Maths::Abs(vars.MUZZLE_OFFSET.x) + vars.GUN_TRANS.x - 7), (vars.MUZZLE_OFFSET.y + vars.GUN_TRANS.y));
			Vec2f laser_offset = Vec2f((vars.MUZZLE_OFFSET.x - vars.GUN_TRANS.x + 8), (vars.MUZZLE_OFFSET.y + vars.GUN_TRANS.y + 0.5));
			laser_offset.RotateBy( -aimangle * flip_factor );
			laser.SetOffset(laser_offset);
			
			Vec2f dir = Vec2f(flip_factor, 0.0f).RotateBy( -aimangle * flip_factor );
			Vec2f startPos = this.getPosition() +
				Vec2f((vars.MUZZLE_OFFSET.x - vars.GUN_TRANS.x + 8), (vars.MUZZLE_OFFSET.y + vars.GUN_TRANS.y)).RotateBy( -aimangle * flip_factor );
			Vec2f endPos = startPos + (dir * range);
			
			bool mapHit = getMap().rayCastSolid(startPos, endPos, hitPos);
			laser_length = (hitPos - startPos).Length();
			//laser_length += -24;
			
			laser.ScaleBy(Vec2f(-(laser_length), 1.0f));
			laser.TranslateBy(Vec2f((laser_length)*flip_factor/2, 0.0f));
			laser.RotateBy( aimangle, Vec2f(3 * flip_factor, -3) );
			//laser.SetVisible(true);
		}
		
		
		
		
		
		
		
		
		
		
		

        // rotate towards mouse cursor
        sprite.ResetTransform();
		sprite.TranslateBy(Vec2f((gun_translation.x + sprite_offset.x)* flip_factor, gun_translation.y - sprite_offset.y));
        sprite.RotateBy(aimangle, shoulder_joint);
		
		
		
		if (getGameTime() % 15 == 0) this.set_u8("clickReload", 0);
		
		if (flash !is null)
		{
			flash.ResetTransform();
			flash.RotateBy(aimangle, shoulder_joint);
			flash.SetOffset(muzzle_offset);
			
			//muzzle offset testing thing
			//flash.SetFrameIndex(1);
		}
        
		//checking if gun is in reloading state
		u16 magazine = vars.MAG;
		if (this.get_bool("beginReload"))
		{
			// start reload sequence
			if (isServer())
			{
				interval = vars.RELOAD;
				this.set_bool("beginReload", false);
			
				if (HasAmmo(this) && this.get_u16("clip") < magazine) 
				{
					this.set_bool("doReload", true);
					this.set_f32("RStartTime", getGameTime());
				}
			//}
			//if (isClient())
			//{
				sprite.SetAnimation("reload");
				if (HasAmmo(this) && this.get_u16("clip") < magazine) 
				{
					if (!this.hasTag("ReloadByOneRound"))
						playReloadSound(this);
					if(this.hasTag("EmptyMagazineParticle"))
						MakeEmptyMagazineParticle(this);
				}
				else
				{
					playReloadingEndingSound(this);
				}
			}
		}
		else if (this.get_bool("doReload"))
		{
			drawProgressBar(this, 0.5f);
			if (isServer())
			{
				if (this.hasTag("ReloadByOneRound"))
				{
					if (HasAmmo(this) && this.get_u16("clip") < magazine)
					{
						if (interval == 0)
						{
							this.set_bool("doReload", false);
							Reload(this, holder);
						}
					}
					else
						this.set_bool("doReload", false);
				}
				else
					if (holder.isMyPlayer() || (isServer() && holder.getBrain() !is null && holder.getBrain().isActive()))
					{
						if (interval == 0) Reload(this, holder);
					}
			}
			if (isClient())
			{
				if (this.hasTag("ReloadByOneRound"))
					if (HasAmmo(this) && this.get_u16("clip") <= magazine)
						if (interval == 0)
							playReloadSound(this);
			}
		}
		else
		{
			sprite.SetAnimation("default");
		}

		bool reloading = this.get_bool("doReload") || this.get_bool("beginReload");
        // sbooting a firearm
        //if (holder.isMyPlayer())
        //if (holder !is null)
		{
			u16 shot_count = this.get_u8("shotcount");
			u16 shots_skipped_before_next_burst = 8;
			
			if (this.get_f32("reload_ending_time") <= getGameTime() && this.get_f32("reload_ending_time") != 0)
			{
				Sound::Play(this.exists("CustomReloadingEnding") ? this.get_string("CustomReloadingEnding") : "Rechamber", this.getPosition(),
					1.0f, vars.RELOAD_ENDING_SOUND_PITCH + (XORRandom(10)-5)*0.01);
				this.set_f32("reload_ending_time", 0);
			}
			if (this.get_f32("cycle_time") <= getGameTime() && this.get_f32("cycle_time") != 0 && this.exists("CustomCycleSound"))
			{
				Sound::Play(this.get_string("CustomCycleSound"), this.getPosition(),
					1.0f, vars.CYCLE_SOUND_PITCH + (XORRandom(10)-5)*0.01);
				this.set_f32("cycle_time", 0);
			}
			
			// this decrements interval each tick if holder do actualy wield a gun
			if (interval > 0)
				interval--;
			
			if (!reloading)
			{
				// we check for an elapsed interval
				if (interval == 0)
				{
					// we track amount of shots in a firearm burst to stop gun shooting after specific amount of made shots
					// this is not applied to full auto firearms
					if (shot_count < vars.BURST || this.hasTag("full_auto"))
					{
						if (point.isKeyPressed(key_action1) || this.hasTag("we_shootin"))
						{
							if (this.hasTag("burst_shooting"))
							{
								if (this.get_u16("clip") >= vars.BURST)
									this.Tag("we_shootin");
							}
							
							// only allows burst shooting guns do it when they have the tag
							if ((this.hasTag("burst_shooting") && this.hasTag("we_shootin"))
								|| (!this.hasTag("burst_shooting") && point.isKeyPressed(key_action1))
								//this is for burstshooting firearms that are out of ammo
								//we mean we let them send "shoot" command to get click sound and FX
								|| this.get_u16("clip") == 0)
							{
								Shoot( this, aimangle, shot_count);
								// this is set to x+1 to preventing 0 interval that is insane trust me
								interval = (vars.FIRE_INTERVAL + 1) * (this.hasTag("burst_shooting") ? 0 : 1);
								++shot_count;
							}
						}
					}
					// transfering shot count to a next tick
					this.set_u8("shotcount", shot_count);
					
					if (shot_count >= vars.BURST && this.hasTag("burst_shooting"))
					{
						this.Untag("we_shootin");
						holder.setKeyPressed(key_action1, false);
					}
				}
			} else
				// so we don't continue shooting a burst after reloading
				this.Untag("we_shootin");
			
			// transfering interval to a next tick
			this.set_u16("interval", interval);
			
			// if a firearm has stopped shooting we set interval value to 10x normal to prevent burst spamming for getting better accuracy for each shot
			// this is not aplied to firearms what shoot each shot by your command since they don't have bonus accuracy :P
			if(!this.hasTag("semi_autimatic")
				&& shot_count != 0
				&& !reloading
				&& !this.hasTag("NoBurstPenalty")
				&&
				((!point.isKeyPressed(key_action1) && this.hasTag("full_auto"))
				|| (!this.hasTag("we_shootin") && this.hasTag("burst_shooting"))))
			{
				this.set_u16("interval", 2 * shots_skipped_before_next_burst * (this.hasTag("full_auto") ? 2 : 1));
				Sound::Play("steam", this.getPosition(), 1.0, 1.0f + (XORRandom(10)-5)*0.01);
			}
		}
		if (!point.isKeyPressed(key_action1) && !this.hasTag("we_shootin"))
		{
			this.set_u8("shotcount", 0);
		}
		
		//changing gun postion when SPACE is pressed (and hold)
		if (point.isKeyPressed(key_action3))
		{
			this.set_Vec2f("gun_trans", Vec2f(vars.GUN_TRANS.x + 2, vars.GUN_TRANS.y - 3)
				+ Vec2f(-this.get_Vec2f("gun_trans_from_carrier").x, this.get_Vec2f("gun_trans_from_carrier").y));
			this.set_bool("aiming", true);
		}
		else
		{
			this.set_Vec2f("gun_trans", vars.GUN_TRANS
				+ Vec2f(-this.get_Vec2f("gun_trans_from_carrier").x, this.get_Vec2f("gun_trans_from_carrier").y));
			this.set_bool("aiming", false);
		}
		
		CControls@ controls = holder.getControls();
		//if (isServer() && isClient())
		{
			// cheat code for testing :D
			if (controls.isKeyJustPressed(KEY_KEY_J))
			{
				this.set_u16("clip", 999);
				Sound::Play("LoseM16", this.getPosition(), 1.0, 1.0f + (XORRandom(10)-5)*0.01);
			}
			//another cheat code for testing C:
			if (controls.isKeyJustPressed(KEY_KEY_K))
			{
				this.set_bool("cheaty", !this.get_bool("cheaty"));
				Sound::Play(this.get_bool("cheaty") ? "ScopeFocus" : "Remove", this.getPosition(), 3.0, 1.0f + (XORRandom(10)-5)*0.01);
			}
		}
		
		if (controls !is null && controls.isKeyJustPressed(KEY_KEY_R))
		{
			if (!this.get_bool("beginReload")
				&& !this.get_bool("doReload")
				&& this.get_u16("clip") < vars.MAG)
			{
				if (HasAmmo(this)) this.set_bool("beginReload", true);
				 else
				{
					sprite.PlaySound("noammo", 1.0f, 1.0f);
				}
			}
				
			if (this.hasTag("EmptyCaseDuringReload")) MakeEmptyShellParticle( this );
			this.set_u8("shots_made_before_reloading", 0);
		}
    }
    else
    {
		this.getSprite().ResetTransform();
		CSpriteLayer@ laser = this.getSprite().getSpriteLayer("laser");
		
		if (laser !is null)
		{
			laser.SetVisible(false);
		}
		//this.getSprite().TranslateBy(Vec2f(0,0));
		//this.getCurrentScript().runFlags |= Script::tick_not_sleeping;
    }
}

s32 CountAmmo(CBlob@ this, string ammoBlob)
{
	//count how much ammo is in the holder's inventory
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (point !is null)
	{
		CBlob@ holder = point.getOccupied();
		if (holder !is null)
		{
			CInventory@ inv = holder.getInventory();
			if (inv !is null)
			{
				FirearmVars@ vars;
				this.get("firearm_vars", @vars);
				const string ammo = ammoBlob.empty() ? vars !is null ? vars.AMMO : ammoBlob : ammoBlob;

				return inv.getCount(ammo);
			}
		}
	}

	return 0;
}

void playReloadSound (CBlob@ this)
{
	if(!isClient()) return;
	FirearmVars@ vars;
	this.get("firearm_vars", @vars);
	
	Sound::Play(vars.RELOAD_SOUND, this.getPosition(), 1.0f, vars.RELOAD_SOUND_PITCH);
}

const bool HasAmmo(CBlob@ this)
{
	if (this.exists("ammoBlob")) return CountAmmo(this, this.get_string("ammoBlob")) > 0;
	else return CountAmmo(this, "") > 0;
}

void Shoot( CBlob@ this, const f32 aimangle, u16 shot_count)
{
	CBitStream params;
	params.write_Vec2f( this.getPosition() );
	params.write_f32( aimangle );
	params.write_u16( shot_count );
	this.SendCommand( this.getCommandID("shoot"), params );
}

void SecondAction( CBlob@ this, const f32 aimangle, CBlob@ holder)
{
	CBitStream params;
	params.write_Vec2f( this.getPosition() );
	params.write_f32( aimangle );
	params.write_netid( holder.getNetworkID() );
	this.SendCommand( this.getCommandID("action2"), params );
}

void Reload(CBlob@ this, CBlob@ holder) 
{
	CBitStream params;

	params.write_Vec2f(this.getPosition());
	params.write_netid(holder.getNetworkID());

	this.SendCommand(this.getCommandID("reload"), params);

	this.set_u8("clickReload", 0);
	this.set_u8("shotcount", 0);
}

void playReloadingEndingSound(CBlob@ this)
{
	FirearmVars@ vars;
	this.get("firearm_vars", @vars);
	
	//if (this.exists("CustomReloadingEnding"))
	{
		this.set_f32("reload_ending_time", getGameTime() + (this.hasTag("ReloadByOneRound") ? 10 : 0));
	}
}

void MakeEmptyShellParticle (CBlob@ this)
{
	FirearmVars@ vars;
	this.get("firearm_vars", @vars);
	
	const bool flip = this.isFacingLeft();
	const f32 flip_factor = flip ? -1: 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	u16 sound_rnd = XORRandom(2) + 1;
	
	u8 times_we_make_particle;
	if (!this.hasTag("EmptyCaseDuringReload")) times_we_make_particle = 1;
	else times_we_make_particle = Maths::Min(8, this.get_u8("shots_made_before_reloading")); //not going to make more than 8 empty cases a time
	bool amogus = this.hasTag("EmptyCaseDuringReload"); //i don't have enough imagination to come up with a better name than A M O G U S
	
	for (u8 i = 0; i < times_we_make_particle; ++i)
	{
		// particle of an empty round case
		makeGibParticle(
			//
			this.exists("CustomEmptyCase")						// file name
				? this.get_string("CustomEmptyCase")
				: "RoundCase",
			Vec2f(this.getPosition().x,this.getPosition().y)
				+ Vec2f((this.getSprite().getFrameWidth()*0.5 - this.get_Vec2f("gun_trans").x + this.getSprite().getOffset().x)*flip_factor,
				+ vars.MUZZLE_OFFSET.y + this.get_Vec2f("gun_trans").y + this.getSprite().getOffset().y)
				.RotateBy( angle_flip_factor + angle_flip_factor + this.get_f32("aimangle"), Vec2f()),  	// position   
			//
			Vec2f(													// velocity
				flip_factor *
				(-Maths::Abs(Maths::Min(vars.PROJ_DAMAGE, 5) + XORRandom(4))),
				amogus && this.get_u8("shots_made_before_reloading") != 1 ? 0 : -Maths::Min(vars.PROJ_DAMAGE, 5)) * (amogus ? (0.3 * (i + 1)) : 1),
			//
			0,                              						// column
			0,                                  					// row
			Vec2f(8, 8),                      						// frame size
			1.0f,                               					// scale?
			0,                                  					// ?
			"ShellDrop" + sound_rnd,                      			// sound
			this.getTeamNum()										// team number
		);
	}
}

void MakeEmptyMagazineParticle (CBlob@ this)
{
	FirearmVars@ vars;
	this.get("firearm_vars", @vars);
	
	const bool flip = this.isFacingLeft();
	const f32 flip_factor = flip ? -1: 1;
	
	u8 times_we_make_particle = 1;
	
	for (u8 i = 0; i < times_we_make_particle; ++i)
	{
		// particle of an empty gun's magazine
		makeGibParticle(
			//
			this.getName() + "_magazine",							// file name
			Vec2f(this.getPosition().x,this.getPosition().y)
				+ Vec2f((this.getSprite().getFrameWidth()*0.5 - this.get_Vec2f("gun_trans").x - this.getSprite().getOffset().x)*flip_factor,
				+ vars.MUZZLE_OFFSET.y - this.get_Vec2f("gun_trans").y - this.getSprite().getOffset().y)
				.RotateBy( flip_factor * reloadangle, Vec2f()),  	// position            					
			//
			Vec2f(													// velocity
				flip_factor * (2),                                  			
				-1),                                                			
			//                                                      			
			0,                              						// column
			0,                                  					// row
			Vec2f(8, 8),                      						// frame size
			1.0f,                               					// scale?
			0,                                  					// ?
			"empty_magazine",                      					// sound
			this.getTeamNum()										// team number
		);
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	Vec2f sprite_offset = this.getSprite().getOffset();
	const bool flip = this.isFacingLeft();
	const f32 flip_factor = flip ? -1: 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	const Vec2f shoulder_joint = Vec2f((3 - sprite_offset.x) * flip_factor, -3 - sprite_offset.y)
		+ Vec2f(this.get_Vec2f("gun_trans_from_carrier").x * flip_factor, this.get_Vec2f("gun_trans_from_carrier").y);
	
	FirearmVars@ vars;
	this.get("firearm_vars", @vars);
	const u16 modifier = 1; // how many rounds does the firearm use per shot???????/
	
	if (cmd == this.getCommandID("shoot"))
	{
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		if (point is null) return;

		CBlob@ holder = point.getOccupied();
		if (holder is null) return;
		
		if (this.get_u16("clip") < modifier)
		{
			if (this.get_u8("clickReload") == 0)
			{
				this.getSprite().PlaySound( "DryShot" ); // if we don't have rounds in a firearm clip firearm plays click sound
				MakeBangEffect(this, "click");
				this.set_u8("clickReload", 1);
			}
			return;
		}
		
		this.sub_u16("clip", 1 * modifier);
		this.add_u8("shots_made_before_reloading", 1);
		
		Vec2f pos = params.read_Vec2f();
		f32 angle = params.read_f32();
		//angle += -1*flip_factor;
		u16 shot_count = params.read_u16();
		bool auto = this.hasTag("full_auto");
		CSpriteLayer@ flash = this.getSprite().getSpriteLayer("muzzle_flash");
		
		u16 too_fast = 1;
		
		bool uncomfy_pose = holder.isKeyPressed(key_down) && point.isKeyPressed(key_action3);
		
		f32 inaccuracy_angle;
		if (auto && !this.hasTag("NoAccuracyBonus"))
		{
			if (shot_count < 2) inaccuracy_angle = 1;
			// if shooter has key DOWN pressed inaccuracy isn't that bad
			// it's halved i mean
			//
			else inaccuracy_angle = Maths::Min(vars.INACCURACY * (uncomfy_pose ? 0.5 : 1), Maths::Floor(shot_count * 3));
		}
		else inaccuracy_angle = vars.INACCURACY; // firearm skips those maths above if it's not a full auto one
		
		
		//angle = this.get_f32("aimangle");
		//f32 spread = XORRandom(inaccuracy_angle) * flip_factor - inaccuracy_angle / 2 * flip_factor;
		//f32 bullet_angle = angle + angle_flip_factor + spread;
		
		string effect_name = "bang";
		if (this.hasTag("semi_autimatic"))
			effect_name = "bang";
		else if (this.hasTag("full_auto"))
			effect_name = "ratta";
		else
			effect_name = "brrrap";
			
		if (this.exists("CustomShotFX"))
			effect_name = this.get_string("CustomShotFX");
			

		//Vec2f velocity(1,0);
		//f32 bullet_speed = vars.PROJ_SPEED + XORRandom(vars.PROJ_SPEED/8)-vars.PROJ_SPEED/16;
		Vec2f bullet_offset;
		
		for (u8 i = 0; i < vars.PROJ_AMOUNT; ++i)
		{
			if (isServer())
			{
				CBlob@ bullet_blob = server_CreateBlobNoInit( vars.PROJ_BLOB );
				if (bullet_blob !is null)
				{			
					Vec2f velocity(1,0);
					f32 spread = this.hasTag("UniformSpread")
						? (- inaccuracy_angle / 2 + inaccuracy_angle/(vars.PROJ_AMOUNT-1)*i)*flip_factor
						: XORRandom(inaccuracy_angle) * flip_factor - inaccuracy_angle / 2 * flip_factor;
					
					//angle stuff
					f32 bullet_angle = angle + angle_flip_factor + spread;
				
					//offset stuff
					bullet_offset = Vec2f(flip_factor*(Maths::Abs(vars.MUZZLE_OFFSET.x) + this.get_Vec2f("gun_trans").x), (vars.MUZZLE_OFFSET.y + this.get_Vec2f("gun_trans").y));
					bullet_offset.RotateBy( bullet_angle + angle_flip_factor, shoulder_joint );
					
					f32 random_speed = XORRandom(vars.PROJ_SPEED/4)-vars.PROJ_SPEED/8;
					
					f32 bullet_speed = vars.PROJ_SPEED + (this.hasTag("UniformSpeed") ? 0 : random_speed);
					//we want our bullet to go teh same direction it looks in right?
					velocity.RotateBy( bullet_angle );
					//we combine all velocity stuff together
					velocity = velocity * bullet_speed + this.getVelocity();
					
					//this one is pretty cool check you know... it makes bullet die and flash don't appear at all if muzzle is behind blocks !!!
					if (this.getMap().rayCastSolidNoBlobs(this.getPosition() + bullet_offset, holder.getPosition()))
					{
						bullet_blob.server_Die();
						break;
					}
					
					if (flash !is null)
					{
						if (((vars.FIRE_INTERVAL < too_fast && shot_count % 4 == 0) || vars.FIRE_INTERVAL >= too_fast) && (i == vars.PROJ_AMOUNT-1))
						{
							//Turn on muzzle flash
							flash.SetFrameIndex(0);
							flash.SetVisible(true);
						}
					}
					
					//assigning values to bullet blob
					bullet_blob.setPosition( this.getPosition() + bullet_offset );
					//this.set_Vec2f("laser_offset", this.getPosition() + offset);
					//this.set_f32("laser_angle", angle + angle_flip_factor);
					bullet_blob.setVelocity( velocity );
					bullet_blob.IgnoreCollisionWhileOverlapped( holder );
					bullet_blob.SetDamageOwnerPlayer( holder.getPlayer() );
					bullet_blob.server_setTeamNum( holder.getTeamNum() );
					
					//we do assign some values after Init to rewrite default ones blob got on Init ?_?
					bullet_blob.Init();
					bullet_blob.set_Vec2f("velocity_before_watur",  velocity );
					//we share 80 hearts of damage between our projectiles in this case
					bullet_blob.set_f32("damage", vars.PROJ_DAMAGE);
					bullet_blob.set_u8("hitter", vars.PROJ_HITTER);
					bullet_blob.set_bool("hit_dead_bodies", vars.PROJ_HITTER == HittersKIWI::bullet_hmg);
					bullet_blob.set_f32("range", vars.PROJ_RANGE);
					bullet_blob.set_Vec2f("start_pos", this.getPosition() + bullet_offset);
				}
			}
		}
		
		if ((this.hasTag("burst_shooting") && shot_count < 1) || !this.hasTag("burst_shooting"))
			if ((vars.FIRE_INTERVAL < 3 && shot_count % 2 == 0) || vars.FIRE_INTERVAL >= 3)
				MakeBangEffect(this, effect_name, 1, false, Vec2f((XORRandom(10)-5) * 0.1, -(3/2)), bullet_offset);
		// we play shooting sound when player is on close enough esle we play distant shot sound
		// good idea tho not very possible
		/*
		CBlob@[] blobs;
		if (this.getMap().getBlobsInRadius(this.getPosition(), 1337, @blobs))
		{
			for (int i = 0; i < blobs.length; i++)
			{
				CBlob@ blob = blobs[i];
				if (!blob.hasTag("player")) continue;
				
				f32 dist = (blob.getPosition() - this.getPosition()).getLength();
				if (isClient())
				{
					if (dist <= 500) this.getSprite().PlaySound( vars.FIRE_SOUND );
					else this.getSprite().PlaySound( "DistantShot" );
				}
			}
		}
		*/
		//this.getSprite().PlaySound( vars.FIRE_SOUND );
		
		// animation of gun kickback
		if (isClient())
		{
			Sound::Play(vars.FIRE_SOUND, this.getPosition(), 1.0, vars.FIRE_SOUND_PITCH + (XORRandom(10)-5)*0.01);
			this.set_f32("cycle_time", getGameTime() + vars.FIRE_INTERVAL*0.5);
			
			Vec2f knockback = vars.KICKBACK_FORCE; //this sets how far should it go (with a random Y)
			if (shot_count > 2) knockback = Vec2f(knockback.x, 0 + XORRandom(Maths::Min(knockback.y, shot_count)) - knockback.y/2);
			else knockback = Vec2f(knockback.x, 0);
			knockback.RotateBy(angle + (flip ? 180 : 0), Vec2f(0, 0) ); //this rotates vector
			
			u16 too_fast = 1; //ticks
			
			if ((vars.FIRE_INTERVAL < too_fast && shot_count % 2 == 0) || vars.FIRE_INTERVAL >= too_fast)
			{
				this.getSprite().TranslateBy(knockback); //this modifies sprite with our knockback vector
			
				if (flash !is null)
				{
					flash.TranslateBy(knockback);
				}
			}
		}
		
		if (!this.hasTag("EmptyCaseDuringReload")) MakeEmptyShellParticle( this );
	}
	else if (cmd == this.getCommandID("reload"))
	{
		if (isServer())
		{
			u32 magazine = vars.MAG;
	
			AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
			if (point is null) return;
	
			CBlob@ holder = point.getOccupied();
			if (holder is null) return;
	
			CInventory@ inv = holder.getInventory();
			if (inv !is null)
			{
				string ammoBlob;
				if (this.exists("ammoBlob")) ammoBlob = this.get_string("ammoBlob");
				else ammoBlob = "";
				
				const string ammo = ammoBlob.empty() ? vars !is null ? vars.AMMO : ammoBlob : ammoBlob;
				u32 count = inv.getItemsCount();
				for (u32 i = 0; i < count; i++)
				{
					CBlob@ item = inv.getItem(i);
					if (item !is null && item.getName() == ammo)
					{
						u32 clip = this.get_u16("clip");
						s32 quantity = item.getQuantity();
	
						if (clip >= magazine) 
						{
							playReloadingEndingSound(this);
							break;
						}
	
						// Determines what can have infinite ammunition
						const bool free_ammo = isServer() && isClient() && this.get_bool("cheaty");
	
						if (this.hasTag("ReloadByOneRound"))
						{
							//Shotgun reload
	
							if (quantity <= 1) item.server_Die();
							else item.server_SetQuantity(Maths::Max(quantity - (free_ammo ? 0 : 1), 0));
							quantity--;
	
							this.add_u16("clip", 1);
							if (clip < magazine || quantity == 1) this.set_bool("beginReload", true); //loop
							//else this.set_bool("beginReload", false);
	
							break;
						}
						else
						{
							//Normal reload
							s32 taken = Maths::Min(quantity, Maths::Clamp(magazine - clip, 0, magazine));
	
							item.server_SetQuantity(Maths::Max(quantity - (free_ammo ? 0 : taken), 0));
	
							this.add_u16("clip", taken);
						}
					}
				}
			}
			if (!this.hasTag("ReloadByOneRound"))
			{
				this.set_bool("doReload", false);
				playReloadingEndingSound(this);
			}
		}
	}
}

void onRender(CSprite@ sprite)
{
	CBlob@ blob = sprite.getBlob();
	FirearmVars@ vars;
	blob.get("firearm_vars", @vars);
	
	if (!blob.get_bool("doReload")) return;
	AddIconToken("$progress_bar$", "Entities/Special/CTF/FlagProgressBar.png", Vec2f(30, 8), 0);
	Vec2f pos = blob.getPosition() + Vec2f(-30.0f, -40.0f);
	Vec2f dimension = Vec2f(60.0f - 8.0f, 8.0f);
	f32 percentage = (getGameTime() - blob.get_f32("RStartTime"))/vars.RELOAD;
		
	//GUI::DrawIcon(
	//			"FlagProgressBar.png",
	//			0,
	//			Vec2f(30, 8),
	//			pos,
	//			1.0f);
	GUI::DrawIconByName("$progress_bar$", pos);
	
	Vec2f bar = Vec2f(pos.x + (dimension.x * percentage), pos.y + dimension.y);
	
	if (true)
	{
		GUI::DrawRectangle(pos + Vec2f(4, 4), bar + Vec2f(4, 4), SColor(255, 59, 20, 6));
		GUI::DrawRectangle(pos + Vec2f(6, 6), bar + Vec2f(2, 4), SColor(255, 148, 27, 27));
		GUI::DrawRectangle(pos + Vec2f(6, 6), bar + Vec2f(2, 2), SColor(255, 183, 51, 51));
	}
	else
	{
		GUI::DrawRectangle(pos + Vec2f(4, 4), bar + Vec2f(4, 4), SColor(255, 58, 63, 21));
		GUI::DrawRectangle(pos + Vec2f(6, 6), bar + Vec2f(2, 4), SColor(255, 99, 112, 95));
		GUI::DrawRectangle(pos + Vec2f(6, 6), bar + Vec2f(2, 2), SColor(255, 125, 139, 120));
	}
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	//Sound::Play("Rechamber", this.getPosition(), 1.0, 1.0 + (XORRandom(10)-5)*0.01);
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint @detachedPoint )
{
	this.set_bool("beginReload", false); // starts a firearm reloading
	this.set_bool("doReload", false); // determines if the firearm is in a reloading phase
	this.Untag("we_shootin");
}

/*
void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	this.getCurrentScript().runFlags &= ~Script::tick_not_sleeping;
	this.SetDamageOwnerPlayer( attached.getPlayer() );

	attached.server_setTeamNum( 1 );
	attached.getPlayer().server_setTeamNum(1);
	this.getSprite().PlaySound( "PickupM16.ogg" );
}

int lastTimePlayedSound = 0;
void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint @detachedPoint )
{
    CSprite@ sprite = this.getSprite();
    sprite.ResetTransform();
    sprite.animation.frame = 0;
    this.setAngleDegrees( getAimAngle(this,detached) );

    detached.server_setTeamNum( 0 );
    detached.getPlayer().server_setTeamNum(0);
    if (getGameTime() - lastTimePlayedSound > 30 )
    {
    	this.getSprite().PlaySound( "LoseM16.ogg" );
    	lastTimePlayedSound = getGameTime();
	}
}
*/