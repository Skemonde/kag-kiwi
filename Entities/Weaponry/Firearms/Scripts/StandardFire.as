#include "BulletCase"
#include "MakeBangEffect"
#include "GunStandard"
#include "KIWI_Locales"
#include "FirearmVars"
#include "Hitters"
#include "SocialStatus"
#include "Help"
#include "Knocked"

//i genuinely sowwy for mixing actual comments with a commented code >///<

const uint8 NO_AMMO_INTERVAL = 10;
u8 reloadCMD, setClipCMD;

bool canSendGunCommands(CBlob@ blob)
{
	if (blob is null) return false;
	CPlayer@ player = blob.getPlayer();
	if (player is null) return false;
	
	return (blob.isMyPlayer() || (isClient() && (player.isBot()||blob.hasTag("bot")))) && !isKnocked(blob);
}

void onInit(CBlob@ this) 
{
	CSprite@ sprite = this.getSprite();
	sprite.getConsts().accurateLighting = false;
	//this.AddScript("Metal.as");
	//this.RemoveScript("IgnoreDamage.as");
	this.set_f32("pickup_priority", 1.00f);
	this.server_SetHealth(20);
	
	FirearmVars@ vars;
	this.get("firearm_vars", @vars);
	if (vars is null) {
		warn("Firearm vars is null! at line 21 of StandardFire.as");
		return;
	}
	if (vars.RANGE>500)
		this.set_f32("scope_zoom", Maths::Min(1400, vars.RANGE)*0.0003);
	this.Tag(vars.C_TAG);
	
	CSpriteLayer@ pixel = sprite.addSpriteLayer("pixel", "blue_pixel", 1, 1, this.getTeamNum(), 0);
	if (pixel !is null)
		pixel.SetVisible(false);
	CSpriteLayer@ flash = null;
	if (vars.FLASH_SPRITE=="from_bullet")
		@flash = sprite.addSpriteLayer("m_flash", "flash_"+vars.BULLET_SPRITE, 32, 32, this.getTeamNum(), 0);
	else if (!vars.FLASH_SPRITE.empty())
		@flash = sprite.addSpriteLayer("m_flash", vars.FLASH_SPRITE, 32, 32, this.getTeamNum(), 0);
	
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
	
    reloadCMD = this.addCommandID("reload");
	this.addCommandID("set_clip");
	
	this.addCommandID("sync_action_interval");
	this.addCommandID("sync_gun_state");
    
    this.addCommandID("toggle_shooting");
    this.addCommandID("change_altfire");
    this.addCommandID("change_shotsintime");
    this.set_bool("shooting",false);
    this.addCommandID("start_reload");
    this.addCommandID("cancel_reload");
    this.addCommandID("make_slash");
    this.set_u8("override_alt_fire",AltFire::Unequip);

	//Sprites
    this.set_string("SpriteBullet", vars.BULLET_SPRITE+".png");
    this.set_string("SpriteFade", vars.FADE_SPRITE);

	this.set_bool("beginReload", false);
	this.set_bool("doReload", false);
	this.set_u8("actionInterval", 0);
    this.set_u8("oldactionInterval", 0);
    this.set_u8("rounds_left_in_burst",0);
    this.set_u8("total",0);
    this.set_u8("clip",0);
	this.set_u8("gun_state", NONE);
	this.set_Vec2f("gun_trans_from_carrier", Vec2f_zero);
	this.set_u16("target_id", 0);
	this.set_s32("shots_in_time", 0);
    
	this.Tag("gun");
    this.Tag("firearm");
    this.Tag("hopperable");
    
    this.set_u8("stored_carts",0);
	
	sprite.SetEmitSound(vars.FIRE_SOUND);
    sprite.SetEmitSoundSpeed(1);
	sprite.SetEmitSoundVolume(1);
	sprite.SetEmitSoundPaused(true);
    
    AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
    this.set_Vec2f("original_offset",point.offset);
    
	AddIconToken("$progress_bar$", "Entities/Special/CTF/FlagProgressBar.png", Vec2f(30, 8), 0);
	Animation@ reload_anime = sprite.getAnimation("reload");
	if (reload_anime !is null) {
		reload_anime.time = vars.RELOAD_TIME/reload_anime.getFramesCount();
	}
	
	//if (vars !is null)
	//	SetHelp(this, "help use", "", "This gun uses "+"$"+vars.AMMO_TYPE[0]+"$ as ammo.");
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	AttachmentPoint@ point = blob.getAttachments().getAttachmentPointByName("PICKUP");
	CBlob@ holder = point.getOccupied();
	@holder = getHolder(blob, holder);
	
	if (!this.isOnScreen()) {
		this.SetVisible(false);
		return;
	}
	
	if (holder is null) {
		this.SetEmitSoundPaused(true);
		this.SetVisible(true);
	}
	else
	{
		this.SetVisible(!holder.hasTag("isInVehicle"));
	}
	if (holder !is null && canUseTheGun(holder, blob)) return; //engi doesn't operate cool guns :<
	//conts
	const Vec2f SPRITE_OFFSET = this.getOffset();
	const bool FLIP = blob.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	const u8 TEAM_NUM = blob.getTeamNum();
	//vars
	FirearmVars@ vars;
	if (!(blob.get("firearm_vars", @vars)))return;
	//0 is unacceptable >:[
	vars.FIRE_INTERVAL = Maths::Max(vars.FIRE_INTERVAL,1);
	vars.BURST_INTERVAL = Maths::Max(vars.BURST_INTERVAL,1);
	vars.ALTFIRE_INTERVAL = blob.get_u8("override_altfire_interval")>0?blob.get_u8("override_altfire_interval"):vars.ALTFIRE_INTERVAL;
	
	
	//states
	bool firing = blob.get_u8("gun_state")==FIRING;
	bool altfiring = blob.get_u8("gun_state")==ALTFIRING;
	bool burstfiring = blob.get_u8("gun_state")==BURSTFIRING;
	bool reloading = blob.get_u8("gun_state")==RELOADING;
	bool cooling = blob.get_u8("gun_state")==COOLING;
	bool being_ready = blob.get_u8("gun_state")==NONE;
	bool kickbacking = blob.get_u8("gun_state")==KICKBACK;
	//necessary vars for animation
	Vec2f shoulder_joint = blob.get_Vec2f("shoulder");
	Vec2f gun_translation = blob.get_Vec2f("gun_trans");
	u8 clip = blob.get_u8("clip");
	bool gets_burst_penalty = vars.FIRE_AUTOMATIC && vars.COOLING_INTERVAL > 0 && clip > 0;
	bool burst_cooldown = cooling && gets_burst_penalty;
	u16 shot_count = blob.get_u16("shotcount");
	u8 actionInterval = blob.get_u8("actionInterval");
	f32 angle = blob.get_f32("gunangle");
	f32 actual_angle = angle;
	// defines how far should a gun jump upon fire
	f32 recoil_angle = (Maths::Tan(50)*(64-this.getFrameWidth()))*-1;
	if (!blob.isAttached())
		angle = 0;
	Vec2f muzzleOffsetSprite = Vec2f(16,-1)+Vec2f(-gun_translation.x+vars.MUZZLE_OFFSET.x, gun_translation.y+vars.MUZZLE_OFFSET.y);
	Vec2f muzzleOffsetSpriteRotoff = -Vec2f(muzzleOffsetSprite.x*FLIP_FACTOR, muzzleOffsetSprite.y);
	blob.set_Vec2f("muzzleOffsetSprite", muzzleOffsetSprite);
	blob.set_Vec2f("muzzleOffsetSpriteRotoff", muzzleOffsetSpriteRotoff);
	//attachment type
	int AltFire = blob.get_u8("override_alt_fire");
	if(AltFire == AltFire::Unequip) //in case override value is 0 we use altfire type from vars
		AltFire = vars.ALT_FIRE;
	//attachment offets
	Vec2f bayo_offset = Vec2f(-3.5,4.5);
	Vec2f laser_offset = Vec2f(5.0f, 2.0f);
	Vec2f tracer_offset = Vec2f(-13.0f, -0.0f);
	Vec2f nader_offset = Vec2f(2.5,6.5);
	
	//makes looped sound only when the gun is shooting
	if (blob.hasTag("looped_sound"))
		this.SetEmitSoundPaused(!(firing||altfiring));
	this.SetEmitSoundSpeed(vars.FIRE_PITCH);
	
	bool do_recoil = blob.get_bool("make_recoil") && !(burst_cooldown || reloading);
	do_recoil = (kickbacking || firing || burstfiring || altfiring);
	
	f32 fire_interval_mod = Maths::Min(vars.FIRE_INTERVAL, 10)/vars.FIRE_INTERVAL;
	//let it go to 255 so it stops after reaching that point
	u8 cappedInterval = Maths::Max(-1, actionInterval-Maths::Max(0, -25+vars.FIRE_INTERVAL));
	if (actionInterval < 2) {
		// plays a cycle sound when actionInterval is reaching 0 that means when you hear a cycle sound you may shoot the exact same moment
        if(isClient()){
            if(firing){
                this.PlaySound(vars.CYCLE_SOUND,1.0f,float(100*vars.CYCLE_PITCH-pitch_range+XORRandom(pitch_range*2))*0.01f);
            }
			if(firing || burstfiring) {
				if(!vars.CART_SPRITE.empty() && actionInterval < 1) {
					if(vars.SELF_EJECTING){
						if (!v_fastrender&&holder !is null)
							MakeEmptyShellParticle(blob, vars.CART_SPRITE, 1, Vec2f(-69, -69), blob);
					} else {
						blob.add_u8("stored_carts",1);
					}
				}
			}
			if(altfiring) {
				switch (AltFire) {
					case AltFire::Bayonet:{
						this.PlaySound("SwordSheath",1.0f,float(100*vars.CYCLE_PITCH-pitch_range+XORRandom(pitch_range*2))*0.01f);
					break;}
					case AltFire::UnderbarrelNader:{
						this.PlaySound("grenade_launcher_load",1.0f,float(100*vars.CYCLE_PITCH-pitch_range+XORRandom(pitch_range*2))*0.01f);
						if (actionInterval < 1)
							MakeEmptyShellParticle(blob, "GrenadeCase.png", 1, Vec2f(-69, -69), blob);
					break;}
				}
			}
        }
	}
	
	//this sets how far should it go
	Vec2f knockback = Vec2f(-3, 0);
	if (vars.MELEE) {
		knockback.x = 0;
	}
	if (altfiring) {
		switch (AltFire) {
			case AltFire::Bayonet:{
				knockback.x = 4;
			break;}
		}
	}
	if (do_recoil) {
		u8 max_interval = -1;
		if (firing && vars.FIRE_INTERVAL > 1)
			max_interval =  Maths::Max(vars.FIRE_INTERVAL, 3);
		if (altfiring && vars.ALTFIRE_INTERVAL > 1)
			max_interval = vars.ALTFIRE_INTERVAL;
		if (burstfiring && vars.BURST_INTERVAL > 1)
			max_interval = vars.BURST_INTERVAL*5;
		if (kickbacking)
			max_interval = 30;
			
		//multiplying it by percentage action interval
		u32 time_from_last_shot = actionInterval;//max_interval-(getGameTime()-blob.get_u32("last_shot_time"));
		knockback.x *= 1.0f*time_from_last_shot/max_interval*(max_interval==255?0:1);
		recoil_angle *= 1.0f*time_from_last_shot/max_interval*(max_interval==255?0:1);
		//adding knockback if the gun plays recoil animation
		gun_translation += knockback;
		bayo_offset -= knockback;
		nader_offset -= knockback;
	}
	//attachment rotation offset are calculated after all additions
	Vec2f bayo_offset_rotoff = -Vec2f(bayo_offset.x*FLIP_FACTOR, bayo_offset.y);
	Vec2f laser_offset_rotoff = -Vec2f(laser_offset.x*FLIP_FACTOR, laser_offset.y);
	Vec2f tracer_offset_rotoff = -Vec2f(tracer_offset.x*FLIP_FACTOR, tracer_offset.y);
	Vec2f nader_offset_rotoff = -Vec2f(nader_offset.x*FLIP_FACTOR, nader_offset.y);
	
	//print("state "+blob.get_u8("gun_state"));
	if (blob.isAttached()) {
		if (reloading) {
			this.SetAnimation("reload");
		} else if (firing || burstfiring) {
			//fire animations blinks for 2-3 frames
			if (firing && actionInterval>(vars.FIRE_INTERVAL-Maths::Min(3, vars.FIRE_INTERVAL)) || burstfiring && actionInterval>(vars.BURST_INTERVAL-2)) {
				this.SetAnimation("fire");
			}
			//after that it's wield animation IF cycle animation isn't played
			else {
				if (!this.isAnimation("cycle"))
					this.SetAnimation("wield"); //default if is in hands
			}
			
			Animation@ cycle_anim = this.getAnimation("cycle");
			
			//only sets a cycle animation if the animation is valid (has more than 1 frames)
			//it's needed for a fire animation with light casting on gun
			if (cycle_anim !is null && cycle_anim.getFramesCount()>1 && firing && actionInterval < 6)
				this.SetAnimation("cycle");
		} else {
			this.SetAnimation("wield"); //default if is in hands
		}
		
		
	} else {
		this.SetAnimation("default");
	}
	angle = reloading ? (FLIP ? 0-vars.RELOAD_ANGLE : 0+vars.RELOAD_ANGLE) : angle;
	angle = do_recoil ? (FLIP ? angle+recoil_angle : angle-recoil_angle) : angle;
	
	int carts = blob.get_u8("stored_carts");
	f32 wield_angle = 90;
	f32 non_aligned_gun_angle = 90;
	Vec2f non_aligned_gun_offset = Vec2f(-10.5f, 5);
	if ((carts % 2 == 1 || blob.getName()=="shovel")&&isClient()&&false) {
		wield_angle *= -1;
		wield_angle += 45;
		non_aligned_gun_angle *= -1;
		non_aligned_gun_angle += 45;
		non_aligned_gun_offset.x += 3;
		non_aligned_gun_offset.y += -8;
	}
	non_aligned_gun_offset = Vec2f(non_aligned_gun_offset.x*FLIP_FACTOR, non_aligned_gun_offset.y);
	
	f32 knife_angle = vars.MELEE ? (FLIP ? angle+wield_angle : angle-wield_angle) : angle;
	if (vars.MELEE)
		angle = knife_angle;
	//we set a property so holder can use it later
	blob.set_f32("gunSpriteAngle", angle);
	//as we made all the angle calculations we apply them to the sprite itself
	this.ResetTransform();
	if (vars.MELEE)
		this.RotateBy(non_aligned_gun_angle*FLIP_FACTOR, Vec2f());
	this.TranslateBy(Vec2f((gun_translation.x)* FLIP_FACTOR, gun_translation.y));
	if (vars.MELEE)
		this.TranslateBy(non_aligned_gun_offset);
	this.RotateBy(angle, shoulder_joint);
	
	//modifying all the layers with the gathered and calculated data
	CSpriteLayer@ pixel = this.getSpriteLayer("pixel");
	if (pixel !is null) {
		pixel.ResetTransform();
		pixel.SetOffset(muzzleOffsetSprite+SPRITE_OFFSET);
		pixel.RotateBy(angle, muzzleOffsetSpriteRotoff+shoulder_joint);
		pixel.SetRelativeZ(2000);
		//use it to debug muzzle pos
		pixel.SetVisible(g_debug>1);
	}
	
	CSpriteLayer@ flash = this.getSpriteLayer("m_flash");
	if (flash !is null)
	{
		flash.ResetTransform();
		flash.ScaleBy(1.4f, 1.4f);
		
		f32 rotate_rnd = 0;
		f32 speed = 8;
		f32 jumping_value = (getGameTime()%speed)/(speed/2);
		
		//we don't change flash with any kickbacks so it's init right here
		Vec2f flash_offset = Vec2f(-flash.getFrameWidth()+0.5+Maths::Floor(flash.getFrameWidth()/16)*5, -0.5*(FLIP?1:2));//don't ask me why this is a thing... i guess it's because of the scale tho...(i scale flash by 1.4f)
		Vec2f flash_offset_rotoff = -Vec2f(flash_offset.x*FLIP_FACTOR, flash_offset.y);
		
		//we use unchanged angle so it doesn't look jumpy
		flash.RotateBy(actual_angle+jumping_value, muzzleOffsetSpriteRotoff+flash_offset_rotoff+shoulder_joint);
		//cannot add sprite_offset directily into muzzleOffsetSprite because it was already taken into account in shoulder_joint
		flash.SetOffset(muzzleOffsetSprite+flash_offset+SPRITE_OFFSET);
	}
	
	//handling attachment sprites
	CSpriteLayer@ bayo = this.getSpriteLayer("bayo");
	if(bayo !is null) {
		bayo.SetVisible(false);
	}
	CSpriteLayer@ nader = this.getSpriteLayer("nader");
	if(nader !is null) {
		nader.SetVisible(false);
	}
	CSpriteLayer@ laser = this.getSpriteLayer("laser");
	if(laser !is null) {
		laser.SetVisible(false);
	}
	
	switch (AltFire) {
		case AltFire::Bayonet: {
			if(bayo !is null) {
				bayo.ResetTransform();
				bayo.SetOffset(muzzleOffsetSprite+bayo_offset+SPRITE_OFFSET);
				bayo.RotateBy(angle, muzzleOffsetSpriteRotoff+bayo_offset_rotoff+shoulder_joint);
				bayo.SetRelativeZ(-2);
				bayo.SetVisible(this.isVisible());
			} else {
				@bayo = this.addSpriteLayer("bayo", blob.hasTag("basic_gun")?"att_bayonet":"att_m9", 16, 8, TEAM_NUM, 0);
			}
            CSpriteLayer@ stab = this.getSpriteLayer("stab_flash");
            if(stab != null){
                stab.ResetTransform();//we don't change flash with any kickbacks so it's init right here
				stab.ScaleBy(1.4f, 1.4f);
				Vec2f stab_offset = bayo_offset + Vec2f(-14, -4-0.5*(FLIP?1:2));
				Vec2f stab_offset_rotoff = -Vec2f(stab_offset.x*FLIP_FACTOR, stab_offset.y);
				
				//we use unchanged angle so it doesn't look jumpy
				stab.RotateBy(angle, muzzleOffsetSpriteRotoff+stab_offset_rotoff+shoulder_joint);
				//cannot add sprite_offset directily into muzzleOffsetSprite because it was already taken into account in shoulder_joint
				stab.SetOffset(muzzleOffsetSprite+stab_offset+SPRITE_OFFSET);
				if (!altfiring)
					stab.SetVisible(false);
				else
					stab.SetVisible(true);
            } else {
				@stab = this.addSpriteLayer("stab_flash", "flash_knoife32.png", 32, 32, TEAM_NUM, 0);
				if(stab != null){
					Animation@ stabbo = stab.addAnimation("stab", 1, false);
					int[] frames = {0, 1, 2, 3, 4, 5, 6, 7};
					stabbo.AddFrames(frames);
					stab.SetAnimation("stab");
				}
            }
			break;
		}
		case AltFire::UnderbarrelNader: {
			if(nader !is null) {
				nader.ResetTransform();
				nader.SetOffset(muzzleOffsetSprite+nader_offset+SPRITE_OFFSET);
				nader.RotateBy(angle, muzzleOffsetSpriteRotoff+nader_offset_rotoff+shoulder_joint);
				nader.SetRelativeZ(-2);
				nader.SetVisible(this.isVisible());
			} else {
				@nader = this.addSpriteLayer("nader", "att_underbarrelnader", 16, 8, TEAM_NUM, 0);
			}
			break;
		}
		case AltFire::LaserPointer: {
			CSpriteLayer@ laser = this.getSpriteLayer("laser");	
			if(laser is null)
			{
				@laser = this.addSpriteLayer("laser", "Laserpointer_Ray.png", 32, 1);
				Animation@ anim = laser.addAnimation("default", 0, false);
				anim.AddFrame(0);
				laser.SetVisible(true);
			} else {
				Vec2f hitPos;
				f32 laser_length;
				f32 range = vars.RANGE;
				Vec2f dir = Vec2f(FLIP_FACTOR, 0.0f).RotateBy(angle);
				Vec2f startPos = blob.getPosition()+laser_offset_rotoff*-1+Vec2f(0,-2.5);
				startPos = this.getWorldTranslation()+blob.get_Vec2f("fromBarrel")+(Vec2f(laser_offset_rotoff.x, laser_offset_rotoff.y+1)*-1).RotateBy(actual_angle);
				//startPos.RotateBy(actual_angle, blob.getPosition()+laser_offset_rotoff+Vec2f(0,-2.5)*-1+shoulder_joint);
				blob.set_Vec2f("for_render", startPos);
				Vec2f weak_point = getDriver().getScreenPosFromWorldPos(startPos);
				GUI::DrawRectangle(weak_point-Vec2f(2,2), weak_point+Vec2f(2,2), SColor(255, 0, 255, 0));
				Vec2f endPos = startPos + dir * range;
				//endPos = getControls().getMouseWorldPos();
				
				//bool mapHit = getMap().rayCastSolid(startPos, endPos, hitPos);
				 
				HitInfo@[] hitInfos;
				bool blobHit = getMap().getHitInfosFromRay(startPos, actual_angle+ANGLE_FLIP_FACTOR, vars.RANGE, blob, @hitInfos);
				for (int index = 0; index < hitInfos.size(); ++index) {
					HitInfo@ hit = hitInfos[index];
					CBlob@ target = @hit.blob;
					if (target !is null && rayHits(target, holder, actual_angle)) {
						hitPos = hit.hitpos;
						break;
					}
					else
						hitPos = hit.hitpos;
				}
				
				laser_length = Maths::Min(80, (hitPos - startPos).Length());
				
				laser.ResetTransform();
				laser.setRenderStyle(RenderStyle::light);
				laser.SetRelativeZ(-0.1f);
				laser.SetOffset(muzzleOffsetSprite+laser_offset+SPRITE_OFFSET);
				laser.ScaleBy(Vec2f(laser_length / 32.0f, 1.0f));
				laser.TranslateBy(Vec2f(laser_length / 2-3, 0.0f)*FLIP_FACTOR);
				laser.RotateBy(angle, muzzleOffsetSpriteRotoff+laser_offset_rotoff+shoulder_joint);
				bool laser_visible = this.isVisible()&&blob.isAttached()&&!reloading&&!firing&&blob.get_bool("laser_on");
				laser.SetVisible(laser_visible);
				CBlob@ light = getBlobByNetworkID(blob.get_u16("remote_netid"));
				if (light !is null)
				{
					if (laser_visible) {
						light.setPosition(hitPos+Vec2f(0, -1));
					}
					else {
						light.setPosition(Vec2f(0, getMap().tilemapheight*8));
					}
				}
			}
			break;
		}
	}
	
	for (int bullet_index = 0; bullet_index<vars.BUL_PER_SHOT; ++bullet_index) {
		CSpriteLayer@ tracer = this.getSpriteLayer("tracer" + bullet_index);
		if (tracer !is null && isClient()) {
			u8 display_time = 2;
			if (vars.FIRE_INTERVAL>1)
				display_time = 3;
			tracer.SetVisible(blob.get_u32("last_shot_time")+display_time>getGameTime());
			tracer.ResetTransform();
			tracer.SetRelativeZ(-10);
			tracer.SetOffset(muzzleOffsetSprite+tracer_offset+SPRITE_OFFSET);
			f32 length = blob.get_f32("bullet_length"+bullet_index);
			tracer.ScaleBy(length, Maths::Clamp(vars.B_DAMAGE/15,0.8, 3));
			tracer.TranslateBy(Vec2f((length*16.0f-this.getFrameWidth()/2-10)*FLIP_FACTOR,0.0f));
			tracer.RotateBy(blob.get_f32("bullet_angle"+bullet_index), muzzleOffsetSpriteRotoff+tracer_offset_rotoff+shoulder_joint);
		}		
	}
}

CBlob@ getHolder(CBlob@ this, CBlob@ holder)
{
	//print("was called");
	if (true) {
		//print("holder is null");
		CBlob@ tripod = getBlobByNetworkID(this.get_u16("tripod_id"));
		if (tripod !is null) {
			//print("tripod is ok");
			CBlob@ gunner = getBlobByNetworkID(tripod.get_u16("gunner_id"));
			if (gunner !is null && gunner.isAttachedTo(tripod) && this.isAttachedTo(tripod)) {
				
				return gunner;
				//print("gunner is ok");
			}
		} //else print("tripod is NOT ok");
		//print("gothere1");
		if (holder !is null && holder.getPlayer() is null) {
			//print("gothere2");
			//print("tripod id"+this.get_u16("tripod_id"));
			if (tripod !is null) {
				//print("tripod isn't null!");
				AttachmentPoint@ gunner_seat = tripod.getAttachments().getAttachmentPointByName("MACHINEGUNNER");
				if (gunner_seat !is null) {
					//print("gunner_seat isn't null!");
					@holder = gunner_seat.getOccupied();
					if (holder !is null) {
						//print("holder "+holder.getName());
						return holder;
					}
				}
			}
		}
		return holder;
	}
	return null;
}

void onTick(CBlob@ this) 
{	
	CSprite@ sprite = this.getSprite();
	const Vec2f SPRITE_OFFSET = sprite.getOffset();
	bool being_used_indirectly = getBlobByNetworkID(this.get_u16("tripod_id")) !is null && this.isAttachedTo(getBlobByNetworkID(this.get_u16("tripod_id")));
	
	FirearmVars@ vars;
	this.get("firearm_vars", @vars);
	if (vars is null) {
		warn("Firearm vars is null! at line 122 of StandardFire.as");
		return;
	}
	bool can_decrease_shots = true;
	//0 is unacceptable >:[
	vars.FIRE_INTERVAL = Maths::Max(vars.FIRE_INTERVAL,1);
	vars.BURST_INTERVAL = Maths::Max(vars.BURST_INTERVAL,1);
	vars.ALTFIRE_INTERVAL = this.get_u8("override_altfire_interval")>0?this.get_u8("override_altfire_interval"):vars.ALTFIRE_INTERVAL;
		
	const bool flip = this.isFacingLeft();
	const f32 flip_factor = flip ? -1 : 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	//since it's a point from center we need to use flip_factor for x
	Vec2f shoulder_joint = Vec2f(3*flip_factor, -3);
	//it's a spriet offset so we don't need flip_factor here
	shoulder_joint -= SPRITE_OFFSET;
	shoulder_joint += Vec2f(this.get_Vec2f("gun_trans_from_carrier").x * flip_factor, this.get_Vec2f("gun_trans_from_carrier").y);
	if (being_used_indirectly)
		shoulder_joint = Vec2f(-3*flip_factor,4);
	this.set_Vec2f("shoulder", shoulder_joint);
	
	Vec2f gun_translation = this.get_Vec2f("gun_trans");
	
	//idk how to make it right way :<
	if (vars.MELEE) {
		this.set_u8("clip", -1);
	}
	u8 clip = this.get_u8("clip");
	bool clip_empty = clip<1;
	
	//no flip_factor here because it's taken into account during passing params to a TranslateBy method
	gun_translation = Vec2f(-this.get_Vec2f("gun_trans_from_carrier").x, this.get_Vec2f("gun_trans_from_carrier").y)
					+ Vec2f(vars.SPRITE_TRANSLATION.x, vars.SPRITE_TRANSLATION.y)
					;
	if (!this.isAttached())
		gun_translation = Vec2f_zero;
	
	if (this.isAttached()) 
    {
		this.setAngleDegrees(0);
		//this.getCurrentScript().runFlags &= ~(Script::tick_not_sleeping); 					   		
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
        CBlob@ holder = point.getOccupied();
		@holder = getHolder(this, holder);
		CPlayer@ player = holder.getPlayer();
		if (player is null) return;
		
		bool gets_burst_penalty = vars.FIRE_AUTOMATIC && vars.COOLING_INTERVAL > 0 && !clip_empty;
		bool burst_cooldown = this.hasTag("pshh") && gets_burst_penalty;
		//states
		bool firing = this.get_u8("gun_state")==FIRING;
		bool altfiring = this.get_u8("gun_state")==ALTFIRING;
		bool burstfiring = this.get_u8("gun_state")==BURSTFIRING;
		bool reloading = this.get_u8("gun_state")==RELOADING;
		bool cooling = this.get_u8("gun_state")==COOLING;
		bool being_ready = this.get_u8("gun_state")==NONE;	
		bool kickbacking = this.get_u8("gun_state")==KICKBACK;
		
		if (point !is null) {
			if (this.get_u8("rounds_left_in_burst") > 0 || burstfiring) {
				point.SetKeysToTake(key_inventory | key_pickup | key_action3 | key_action1);
			} else {
				point.SetKeysToTake(0);
			}
		}
		
		u16 shot_count = this.get_u16("shotcount");
		u8 sprite_actionInterval = this.get_u8("actionInterval");
		//TODO: it doesn't happen during action interval that is set when the gun stopped shooting a burst
		bool do_recoil = this.get_bool("make_recoil") && !(burst_cooldown || reloading);
				
		// changing gun postion when DOWN is pressed (and being hold)
        bool previousTrenchAim = this.hasTag("trench_aim");
		bool player_crouching = gunCrouching(holder);
		bool can_aim_gun = !vars.MELEE && !(vars.TRENCH_AIM == 0);
		bool constant_aiming = vars.TRENCH_AIM == 1;
		
        if((((player_crouching && can_aim_gun) && !reloading) || constant_aiming) && !being_used_indirectly){
			// "aiming" style wield
			gun_translation += trench_aim;
			this.Tag("trench_aim");
        } else {
			// normal wield
			this.Untag("trench_aim");
        }
        
        if (holder !is null)
        {
			if(canUseTheGun(holder, this)) return; //engi doesn't operate cool guns :<
			//if(holder.isAttached()) return; //no shooting/reloading while in vehicle :< (sprite isn't visible too)
			
			f32 aimangle = getAimAngle(this,holder), sprite_angle = 0;
			f32 upper_line = 90;
			f32 lower_line = 90;
			if (this.getName()=="hmg"&&false)
				aimangle = Maths::Clamp(aimangle, flip?360-lower_line:upper_line, flip?360-upper_line:lower_line);
			if (flip)
				aimangle+=90;
			else
				aimangle-=90;
				
			//print("gun angle "+aimangle);
			this.set_f32("gunangle", aimangle);
			
			//if (isKnocked(holder)) return;
			
            if(canSendGunCommands(holder)){
                if (getHUD().hasButtons())
					this.set_u32("last_menus_time", getGameTime());
                if (holder.isKeyPressed(key_action1) && false){ //disabled due to a problem
                    if(vars.RELOAD_HANDFED_ROUNDS > 0 && this.get_bool("doReload") && !clip_empty && this.get_u8("actionInterval") > 5){ //We can cancel out of reloading if we're a handfed gun
                        this.SendCommand(this.getCommandID("cancel_reload"));
                    }
                }
            
                //clientside only
                CControls@ controls = holder.getControls();
            
                if(controls !is null) 
                {
                    // cheat code for testing :D
                    if (controls.isKeyJustPressed(KEY_KEY_J) && (holder.getPlayer() !is null && IsCool(holder.getPlayer().getUsername())))
                    {
                        if (clip != 255) {
                            this.set_u8("clip", -1);
                            Sound::Play("PowerUp", this.getPosition(), 3.0, 1.0f + (XORRandom(10)-5)*0.01);
                        }
                        else {
                            this.set_u8("clip", 0);
                            Sound::Play("PowerDown", this.getPosition(), 3.0, 1.0f + (XORRandom(10)-5)*0.01);
                        }
						CBitStream params;
						params.write_u8(this.get_u8("clip"));
						params.write_u8(this.get_u8("total"));
						this.SendCommand(this.getCommandID("set_clip"),params);
                    }
                    
                    if((controls.isKeyJustPressed(KEY_KEY_R) ||
						(isClient() && (holder.hasTag("bot") || player.isBot()) && clip_empty && this.get_u8("clickReload")>=1) ||
                        (clip_empty && (vars.FIRE_AUTOMATIC && holder.isKeyPressed(key_action1)) && this.get_u8("clickReload")>=3)) &&
                        being_ready &&
						!holder.isAttached() &&
                        this.get_u8("rounds_left_in_burst") <= 0){
                        
                        if (canReload(this,holder)) {
                            startReload(this,vars.RELOAD_TIME);
                        } else if (controls.isKeyJustPressed(KEY_KEY_R) && !vars.MELEE && sprite_actionInterval<1 && clip < vars.CLIP){
							if (isClient()) {
								sprite.PlaySound("NoAmmo",1.0f,float(100*vars.FIRE_PITCH-pitch_range+XORRandom(pitch_range*2))*0.01f);
								if (!v_fastrender)
									MakeBangEffect(this, "ammo");
							}
							this.set_u8("actionInterval", NO_AMMO_INTERVAL);
                        }
                    }
                }
            }
            
            bool shooting = this.get_bool("shooting");
            if(canSendGunCommands(holder)){
                if(!(getHUD().hasButtons() && getHUD().hasMenus())){
				
					bool using_melee_semiauto = vars.MELEE && holder.isKeyJustPressed(key_action2);
					bool using_melee_auto = vars.FIRE_AUTOMATIC && vars.MELEE && holder.isKeyPressed(key_action2);
					
					bool using_gun_semiauto = holder.isKeyJustPressed(key_action1);
					bool using_gun_auto = vars.FIRE_AUTOMATIC && holder.isKeyPressed(key_action1);
					
					bool user_presses_shoot_key = using_melee_semiauto || using_melee_auto || using_gun_semiauto || using_gun_auto;
					
					bool still_shooting_burst = this.get_u8("rounds_left_in_burst") > 0;
					
					bool gun_is_old_enough = this.getTickSinceCreated()>vars.RELOAD_TIME;
					
					bool wait_after_menus_close = this.get_u32("last_menus_time")+5<getGameTime();
					
                    bool checkShooting = (user_presses_shoot_key || still_shooting_burst) && gun_is_old_enough && wait_after_menus_close;
                    
					if(this.get_bool("shooting") != checkShooting){
                        shooting = checkShooting;
                        this.set_bool("shooting",checkShooting);
                        CBitStream params;
                        params.write_bool(checkShooting); //shooting status
                        this.SendCommand(this.getCommandID("toggle_shooting"),params);
                    }
                }
            }
            
            if (this.get_u8("actionInterval") > 0) 
            {
                this.set_f32("perc", 1.0f*this.get_u8("actionInterval") / vars.RELOAD_TIME);
                this.sub_u8("actionInterval",1);               
            }
            else if(this.get_bool("doReload")) 
            {
                bool finishedReloading = true;
                bool special_reload = vars.RELOAD_HANDFED_ROUNDS == vars.CLIP;
                
                if(vars.RELOAD_HANDFED_ROUNDS > 0){
                    if(canReload(this,holder)){
                        if(canSendGunCommands(holder)){
                            reload(this, holder);
                            
							if (!special_reload)
								startReload(this,(clip<1?1.15f:1)*vars.RELOAD_TIME);
                        }
                        
                        finishedReloading = false;
                    }
                } else {
                    if(canSendGunCommands(holder))reload(this, holder);
                }
                
                if(finishedReloading){
                    if(isClient()){
                        if(vars.RELOAD_SOUND != "")
                            sprite.PlaySound(vars.RELOAD_SOUND,1.0f,float(100*vars.RELOAD_PITCH-pitch_range+XORRandom(pitch_range*2))*0.01f);
                        this.set_u8("clickReload", 0);
                    }
                    this.set_u8("actionInterval", NO_AMMO_INTERVAL); //small interval after each reload
					this.set_u8("gun_state", NONE);
                    this.set_bool("doReload", false);
                }
            } else {
				this.set_u8("gun_state", NONE);
				//after the gun shoots a burst it does apply a burstinterval after the last round so animation for empty cases works properly
				//and then after the interval is expired fireinterval is added
				//P.S. empty cases go off when interval is almost expired so it's important to make the intervals the same so ejecting is consistent
				if (burstfiring && this.get_u8("rounds_left_in_burst")<1) {
					this.set_u8("actionInterval", vars.FIRE_INTERVAL);
					this.set_u8("gun_state", KICKBACK);
				}
                if(shooting)
                {
					if ((vars.BULLET=="blobconsuming"&&!findAmmo(holder, vars).empty()||vars.BULLET!="blobconsuming")) {
						if(!clip_empty) 
						{
							if(vars.BURST > 1){
								int burst_rounds = this.get_u8("rounds_left_in_burst");
								
								if(burst_rounds >= 1){
									this.sub_u8("rounds_left_in_burst",1);
								} else
								//this one makes gun shoot the burst by setting the amount of shots in a burst
								//it shouldn't work if we're already firing a burst tho
								if (this.get_u8("gun_state")==NONE && this.get_u8("actionInterval")<1 && !vars.ONOMATOPOEIA.empty()) {
									this.set_u8("rounds_left_in_burst",vars.BURST-1);
									MakeBangEffect(this, "brrrap", 1.0f, false, Vec2f((XORRandom(10)-5) * 0.1, -(3/2)), this.get_Vec2f("fromBarrel") + Vec2f(XORRandom(11)-5,-XORRandom(4)-1));
								}
								this.set_u8("gun_state", BURSTFIRING);
								this.set_u8("actionInterval", vars.BURST_INTERVAL);
							} else {
								this.set_u8("gun_state", FIRING);
								f32 shots_in_time = 1.0f*this.get_s32("shots_in_time")/7;
								this.set_u8("actionInterval", (this.getName()=="hmg"?Maths::Max(1, vars.FIRE_INTERVAL-shots_in_time):vars.FIRE_INTERVAL));
								//this.set_u8("actionInterval", vars.FIRE_INTERVAL);
							}
							
							Vec2f fromBarrel = Vec2f(0, vars.MUZZLE_OFFSET.y);
							if (this.exists("bullet_blob")||!vars.BULLET.empty())
								fromBarrel.x = (vars.MUZZLE_OFFSET.x)*-flip_factor;
							fromBarrel = fromBarrel.RotateBy(aimangle);
							this.set_Vec2f("fromBarrel", fromBarrel);
							
							if(isClient()){
								if(shot_count < 1){
									if (!vars.FIRE_START_SOUND.empty())
										sprite.PlaySound(vars.FIRE_START_SOUND,1.0f,float(100*1.0f-pitch_range+XORRandom(pitch_range*2))*0.01f);
								}
							}
							
							if (!vars.MELEE) {
								if(canSendGunCommands(holder)) {
									shootGun(this.getNetworkID(), aimangle, holder.getNetworkID(), sprite.getWorldTranslation() + fromBarrel);
									bool burst_happening = this.get_u8("rounds_left_in_burst")>0&&clip>0;
									
									//recoil
									f32 recoil_value = -1.0f*vars.FIRE_INTERVAL;
									if (vars.RECOIL != 0) {
										recoil_value = vars.RECOIL;
										if (isFullscreen())
											recoil_value *= 4;
									}
									recoil_value/=2;
									if (vars.BURST>1)
										recoil_value*=3;
									
									if (holder.isMyPlayer()) {
										if (!burst_happening)
										if (getRules().get_bool("cursor_recoil_enabled")) {
											getControls().setMousePosition(getControls().getMouseScreenPos() + Vec2f(isFullscreen()?0:5, recoil_value));
											ShakeScreen(Maths::Min(vars.B_DAMAGE * 1.5f, 150), 8, this.getPosition());
										}
										can_decrease_shots = false;
									}
									CBitStream shots;
									shots.Clear();
									shots.write_s32(10);
									this.SendCommand(this.getCommandID("change_shotsintime"), shots);
								}
							} else if (canSendGunCommands(holder)&&(getGameTime()-this.get_u32("last_slash")>5)) {
								CBitStream params;
								params.write_netid(holder.getNetworkID());
								params.write_f32(aimangle);
								params.write_Vec2f(holder.getPosition()+holder.getVelocity());
								params.write_f32(vars.B_SPREAD);
								params.write_f32(vars.RANGE);
								//if (canSendGunCommands(holder))
									this.SendCommand(this.getCommandID("make_slash"),params);
								//print("sending slash command");
								
								CSpriteLayer@ flash = sprite.getSpriteLayer("m_flash");
								if (flash !is null) {
									flash.SetFrameIndex(0);
									flash.SetVisible(true);
								}
								sprite.PlaySound("Slash",1.0f,float(100*vars.FIRE_PITCH-pitch_range+XORRandom(pitch_range*2))*0.01f);
								this.set_u32("last_slash", getGameTime());
							}
						}
						else
						{
							this.set_u8("rounds_left_in_burst",0);
							this.set_u8("actionInterval", NO_AMMO_INTERVAL);
							this.set_u8("gun_state", NONE);
							
							if(isClient()){
								f32 default_pitch = 110;
								default_pitch -= (vars.B_DAMAGE);
								sprite.PlaySound("DryShot.ogg",1.0f,float(default_pitch-pitch_range+XORRandom(pitch_range*2))*0.01f);
								this.add_u8("clickReload", 1);
								if (!v_fastrender)
									MakeBangEffect(this, "click");
							}
						}
					}
					else {
						
						if (isClient()) {
							sprite.PlaySound("NoAmmo",1.0f,float(100*vars.FIRE_PITCH-pitch_range+XORRandom(pitch_range*2))*0.01f);
							if (!v_fastrender)
								MakeBangEffect(this, "ammo");
						}
						this.set_u8("actionInterval", NO_AMMO_INTERVAL);
					}
                } else {                    
					int AltFire = this.get_u8("override_alt_fire");
                    if(AltFire == AltFire::Unequip)AltFire = vars.ALT_FIRE;
					
                    if(holder.isKeyPressed(key_action2)&&!holder.isAttached()){
                        
                        switch(AltFire){
                        
                            case AltFire::Bayonet:{	
								this.set_u8("actionInterval", vars.ALTFIRE_INTERVAL);
								this.set_u8("gun_state", ALTFIRING);
                                
								if(isClient()){
									//print("hellow from script");
									CSpriteLayer@ stab = sprite.getSpriteLayer("stab_flash");
									if (stab !is null) stab.SetFrameIndex(0);
									CBitStream params;
									params.write_netid(holder.getNetworkID());
									params.write_f32(aimangle);
									params.write_Vec2f(holder.getPosition()+holder.getVelocity());
									params.write_f32(32);
									params.write_f32(5*getMap().tilesize);
									if (holder.isMyPlayer())
										this.SendCommand(this.getCommandID("make_slash"),params);
                                
									sprite.PlaySound("Slash",1.0f,float(100*vars.FIRE_PITCH-pitch_range+XORRandom(pitch_range*2))*0.01f);
                                }
                            break;}
							
							case AltFire::UnderbarrelNader:{
								if (GetItemAmount(holder, "froggy")>0) {
									this.set_u8("actionInterval", vars.ALTFIRE_INTERVAL);
									this.set_u8("gun_state", ALTFIRING);
									
									Vec2f fromBarrel = this.get_Vec2f("fromBarrel");
									Vec2f grenade_offset = Vec2f(XORRandom(11)-5,-XORRandom(4)-1)
										+ Vec2f(this.getSprite().getFrameWidth()+8, 0).RotateBy(this.get_f32("gunSpriteAngle")+(this.isFacingLeft()?180:0));
									if(isServer()&&!holder.hasTag("bot"))
										holder.TakeBlob("froggy", 1);
									if(canSendGunCommands(holder))
										shootGun(this.getNetworkID(), aimangle, holder.getNetworkID(), holder.getPosition(), true);
								}
								else {
									this.set_u8("actionInterval", NO_AMMO_INTERVAL);
									
									if (isClient())
										sprite.PlaySound("NoAmmo",1.0f,float(100*vars.FIRE_PITCH-pitch_range+XORRandom(pitch_range*2))*0.01f);
										
									if (!v_fastrender)
										MakeBangEffect(this, "ammo");
								}
							break;}
                        
                            default:{ //Unequip
							break; // doesn't work as intended :<
                                if(isServer()){
                                    if(this.canBePutInInventory(holder)){
                                        holder.DropCarried();
                                        holder.server_PutInInventory(this);
                                    }
                                }
                            break;}
                        }
                    }                
                }
            }
            
            //gun stops shooting and plays the animation only when we were shooting and released button or if we're out of ammo
            if ((holder.isKeyJustReleased(key_action1) && shot_count > 0 || clip_empty) && !cooling && vars.BURST < 2)
            {
                this.set_u16("shotcount", 0);//nulify shotcount
                /* 
                if(isClient()){
                    if (this.get_u8("clip") > 0 && !vars.FIRE_END_SOUND.empty())
                        sprite.PlaySound(vars.FIRE_END_SOUND,1.0f,float(100*1.0f-pitch_range+XORRandom(pitch_range*2))*0.01f);
                }
                
                //set overheat interval for automatic guns that gain accuracy bonus on 2-3 first shots if clip isn't empty
                if (gets_burst_penalty) {
                    this.set_u8("actionInterval", vars.COOLING_INTERVAL);
					this.set_u8("gun_state", COOLING); //Prevent spam click on accuracy-lossy smgs
				} */
            }
          
            if(this.isMyPlayer()){
                if(this.get_u8("oldactionInterval") < this.get_u8("actionInterval")){
                    CBitStream params;
                    params.write_u8(this.get_u8("actionInterval"));
                    this.SendCommand(this.getCommandID("sync_action_interval"), params);
                }
                this.set_u8("oldactionInterval",this.get_u8("actionInterval"));
            }            
		}
		//if (holder.isMyPlayer()&&can_decrease_shots) {
		if (isServer()&&(getGameTime()-this.get_u32("last_shot_time"))>10) {
			//sending the command from local client
			CBitStream shots;
			shots.Clear();
			shots.write_s32(-(getGameTime()-this.get_u32("last_shot_time")));
			this.SendCommand(this.getCommandID("change_shotsintime"), shots);
		}
    }
    else 
    {
		//this.getCurrentScript().runFlags |= Script::tick_not_sleeping; 
    }
	
	this.set_Vec2f("gun_trans", gun_translation);
	local_SyncGunState(this);
}

void onRender(CSprite@ this)
{
	return;
	const f32 SCALEX = getDriver().getResolutionScaleFactor();
	const f32 ZOOM = getCamera().targetDistance * SCALEX;
	
	FirearmVars@ vars;
	this.getBlob().get("firearm_vars", @vars);
	if (vars is null) {
		warn("Firearm vars is null! at line 396 of StandardFire.as");
		return;
	}
	if (isClient()||true) {
		CBlob@ blob = this.getBlob();
		//renders only when a gun's reloading and if the gun is attached	
		
		Vec2f render_point = getDriver().getScreenPosFromWorldPos(blob.get_Vec2f("for_render"));
		if (g_debug>0)
			GUI::DrawRectangle(render_point - Vec2f(2, 2), render_point + Vec2f(2, 2), SColor(255, 0, 0, 255));
		
		CBlob@ target = getBlobByNetworkID(blob.get_u16("target_id"));
		if (target !is null) {
			Vec2f target_pos = target.getPosition();
			target_pos = getDriver().getScreenPosFromWorldPos(target_pos);
			
			GUI::DrawIcon("TargetCross.png", 0, Vec2f(32, 32), target_pos-Vec2f(32,32)*ZOOM, ZOOM);
		}
		
		bool altfiring = blob.get_u8("gun_state")==ALTFIRING;
		bool reloading = blob.get_u8("gun_state")==RELOADING;
		
		if (!(altfiring || reloading)||(vars.RELOAD_HANDFED_ROUNDS>0&&blob.get_u8("clip")==vars.CLIP&&reloading)) return;
		
		AttachmentPoint@ point = blob.getAttachments().getAttachmentPointByName("PICKUP");	   		
		CBlob@ holder = point.getOccupied();
		if (holder is null) return;
		CPlayer@ player = holder.getPlayer();
		if ((player is null || (player !is null && !player.isMyPlayer())) && !holder.hasTag("bot")) return;
		
		Vec2f pos2d =  holder.getInterpolatedScreenPos() + Vec2f(0.0f, (-blob.getHeight() - 20.0f) * ZOOM);
		Vec2f pos = pos2d + Vec2f(-30.0f, -40.0f);
		Vec2f dimension = Vec2f(60.0f - 8.0f, 8.0f);
			
		GUI::DrawIconByName("$progress_bar$", pos);
		
		f32 percentage = 1.0f*blob.get_u8("actionInterval") / vars.RELOAD_TIME;
		if (altfiring)
			percentage = 1.0f*blob.get_u8("actionInterval") / vars.ALTFIRE_INTERVAL;
		Vec2f bar = Vec2f(pos.x + (dimension.x * percentage), pos.y + dimension.y);
		
		GUI::DrawRectangle(pos + Vec2f(4, 4), bar + Vec2f(4, 4), SColor(255, 59, 20, 6));
		GUI::DrawRectangle(pos + Vec2f(6, 6), bar + Vec2f(2, 4), SColor(255, 148, 27, 27));
		GUI::DrawRectangle(pos + Vec2f(6, 6), bar + Vec2f(2, 2), SColor(255, 183, 51, 51));
	}
}