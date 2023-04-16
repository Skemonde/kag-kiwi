#include "BulletCase"
#include "MakeBangEffect"
#include "GunStandard"
#include "KIWI_Locales"
#include "FirearmVars"
#include "Hitters"

//i genuinely sowwy for mixing actual comments with a commented code >///<

const uint8 NO_AMMO_INTERVAL = 5;
u8 reloadCMD, setClipCMD;
 
const Vec2f trench_aim = Vec2f(2, -3);

enum GunState
{
	NONE = 0,
	RELOADING, //no comments
	FIRING, //interval between main action
	ALTFIRING, //interval between RMB action
	BURSTFIRING, //interval between shots in a burst
	COOLING //penalty after a burst
};

void onInit(CBlob@ this) 
{
	CSprite@ sprite = this.getSprite();
	sprite.getConsts().accurateLighting = false;
	
	FirearmVars@ vars;
	this.get("firearm_vars", @vars);
	if (vars is null) {
		warn("Firearm vars is null! at line 21 of StandardFire.as");
		return;
	}
	
	if (this.getName()=="combatknife") {
		this.set_u8("clip", -1);
	}
	
	CSpriteLayer@ pixel = sprite.addSpriteLayer("pixel", "blue_pixel", 1, 1, this.getTeamNum(), 0);
	CSpriteLayer@ flash = null;
	if (!vars.FLASH_SPRITE.empty())
		@flash = sprite.addSpriteLayer("m_flash", vars.FLASH_SPRITE, 32, 32, this.getTeamNum(), 0);
	
	if (flash !is null)
	{
		Animation@ anim = flash.addAnimation("default", 1, false);
		int[] frames = {0, 1, 2, 3, 4, 5, 6, 7};
		anim.AddFrames(frames);
		flash.SetRelativeZ(500.0f);
		flash.ScaleBy(Vec2f(1.4f, 1.4f));
		// for bazookas we want to have fancy flash from their back end
		flash.SetFacingLeft(this.hasTag("CustomMuzzleLeft"));
		//flash.setRenderStyle(RenderStyle::additive);
		flash.SetVisible(false);
	}
	
    reloadCMD = this.addCommandID("reload");
	this.addCommandID("set_clip");
	
	this.addCommandID("sync_action_interval");
    
    this.addCommandID("toggle_shooting");
    this.set_bool("shooting",false);
    this.addCommandID("start_reload");
    this.addCommandID("cancel_reload");
    this.addCommandID("make_slash");
    this.set_u8("override_alt_fire",AltFire::Unequip);

	//Sprites
    this.set_string("SpriteBullet", vars.BULLET_SPRITE);
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
    
	this.Tag("gun");
    this.Tag("firearm");
    
    this.set_u8("stored_carts",0);
	
	sprite.SetEmitSound(vars.FIRE_SOUND);
    sprite.SetEmitSoundSpeed(1);
	sprite.SetEmitSoundVolume(1);
	sprite.SetEmitSoundPaused(true);
    
    AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
    this.set_Vec2f("original_offset",point.offset);
    
    CRules @rules = getRules();

    if (isClient())
	{
		if (vars.BULLET_SPRITE != ""){

			Vertex[]@ bullet_vertex;
			rules.get(vars.BULLET_SPRITE, @bullet_vertex);

			if (bullet_vertex is null)
			{
				Vertex[] vert;
				rules.set(vars.BULLET_SPRITE, @vert);
			}

			// #blamekag
			if (!rules.exists("VertexBook"))
			{
				string[] book;
				rules.set("VertexBook", @book);
				book.push_back(vars.BULLET_SPRITE);
			}
			else
			{
				string[]@ book;
				rules.get("VertexBook", @book);
				book.push_back(vars.BULLET_SPRITE);
			}
		}
		
		if(vars.FADE_SPRITE != ""){
			Vertex[]@ fade_vertex;
			rules.get(vars.FADE_SPRITE, @fade_vertex);

			if (fade_vertex is null)
			{
				Vertex[] vert;
				rules.set(vars.FADE_SPRITE, @vert);
			}

			// #blamekag
			if (!rules.exists("VertexBook"))
			{
				string[] book;
				rules.set("VertexBook", @book);
				book.push_back(vars.FADE_SPRITE);
			}
			else
			{
				string[]@ book;
				rules.get("VertexBook", @book);
				book.push_back(vars.FADE_SPRITE);
			}
		}
	}
	AddIconToken("$progress_bar$", "Entities/Special/CTF/FlagProgressBar.png", Vec2f(30, 8), 0);
	Animation@ reload_anime = sprite.getAnimation("reload");
	if (reload_anime !is null) {
		reload_anime.time = vars.RELOAD_TIME/reload_anime.getFramesCount();
	}
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	//conts
	const Vec2f SPRITE_OFFSET = this.getOffset();
	const bool FLIP = blob.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	const u8 TEAM_NUM = blob.getTeamNum();
	//vars
	FirearmVars@ vars;
	if (!(blob.get("firearm_vars", @vars)))return;
	
	
	//states
	bool firing = blob.get_u8("gun_state")==FIRING;
	bool altfiring = blob.get_u8("gun_state")==ALTFIRING;
	bool burstfiring = blob.get_u8("gun_state")==BURSTFIRING;
	bool reloading = blob.get_u8("gun_state")==RELOADING;
	bool cooling = blob.get_u8("gun_state")==COOLING;
	bool being_ready = blob.get_u8("gun_state")==NONE;	
	//necessary vars for animation
	Vec2f shoulder_joint = blob.get_Vec2f("shoulder");
	Vec2f gun_translation = blob.get_Vec2f("gun_trans");
	u8 clip = blob.get_u8("clip");
	bool gets_burst_penalty = vars.FIRE_AUTOMATIC && !blob.hasTag("NoAccuracyBonus") && clip > 0;
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
	//attachment type
	int AltFire = blob.get_u8("override_alt_fire");
	if(AltFire == AltFire::Unequip)AltFire = vars.ALT_FIRE;
	//attachment offets
	Vec2f bayo_offset = Vec2f(-3.5,4.5);
	Vec2f nader_offset = Vec2f(2.5,6.5);
	
	bool do_recoil = blob.get_bool("make_recoil") && !(burst_cooldown || reloading);
	do_recoil = (firing || burstfiring || altfiring);
	
	if (actionInterval < 2) {
		// plays a cycle sound when actionInterval is reaching 0 that means when you hear a cycle sound you may shoot the exact same moment
        if(isClient()){
            if(firing){
                this.PlaySound(vars.CYCLE_SOUND,1.0f,float(100*vars.CYCLE_PITCH-pitch_range+XORRandom(pitch_range*2))*0.01f);
            }
			if(altfiring) {
				switch (AltFire) {
					case AltFire::Bayonet:{
						this.PlaySound("SwordSheath",1.0f,float(100*vars.CYCLE_PITCH-pitch_range+XORRandom(pitch_range*2))*0.01f);
					break;}
					case AltFire::UnderbarrelNader:{
						this.PlaySound("grenade_launcher_load",1.0f,float(100*vars.CYCLE_PITCH-pitch_range+XORRandom(pitch_range*2))*0.01f);
					break;}
				}
			}
        }
	}
	
	//this sets how far should it go
	Vec2f knockback = Vec2f(-3, 0);
	if (blob.getName()=="combatknife") {
		knockback.x = 7;
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
			max_interval = vars.FIRE_INTERVAL;
		else if (altfiring && 30 > 1)
			max_interval = 30;
		else if (burstfiring && vars.BURST_INTERVAL > 1)
			max_interval = vars.BURST_INTERVAL*5;
		//multiplying it by percentage action interval
		knockback.x *= 1.0f*actionInterval/max_interval;
		recoil_angle *= 1.0f*actionInterval/max_interval;
		//adding knockback if the gun plays recoil animation
		gun_translation += knockback;
		bayo_offset -= knockback;
		nader_offset -= knockback;
	}
	//attachment rotation offset are calculated after all additions
	Vec2f bayo_offset_rotoff = -Vec2f(bayo_offset.x*FLIP_FACTOR, bayo_offset.y);
	Vec2f nader_offset_rotoff = -Vec2f(nader_offset.x*FLIP_FACTOR, nader_offset.y);
	
	//print("state "+blob.get_u8("gun_state"));
	if (blob.isAttached()) {
		if (reloading) {
			this.SetAnimation("reload");
		} else if (firing || burstfiring) {
			this.SetAnimation("fire");
		} else {
			this.SetAnimation("wield"); //default if is in hands
		}
		
		
	}  else {
		this.SetAnimation("default");
	}
	angle = reloading ? (FLIP ? 0-vars.RELOAD_ANGLE : 0+vars.RELOAD_ANGLE) : angle;
	angle = do_recoil ? (FLIP ? angle+recoil_angle : angle-recoil_angle) : angle;
	//we set a property so holder can use it later
	blob.set_f32("gunSpriteAngle", angle);
	//as we made all the angle calculations we apply them to the sprite itself
	this.ResetTransform();
	this.TranslateBy(Vec2f((gun_translation.x)* FLIP_FACTOR, gun_translation.y));			
	this.RotateBy(angle, shoulder_joint);
	
	//modifying all the layers with the gathered and calculated data
	CSpriteLayer@ pixel = this.getSpriteLayer("pixel");
	if (pixel !is null) {
		pixel.ResetTransform();
		pixel.SetOffset(muzzleOffsetSprite+SPRITE_OFFSET);
		pixel.RotateBy(angle, muzzleOffsetSpriteRotoff+shoulder_joint);
		pixel.SetRelativeZ(2000);
		//use it to debug muzzle pos
		pixel.SetVisible(false);
	}
	
	CSpriteLayer@ flash = this.getSpriteLayer("m_flash");
	if (flash !is null)
	{
		flash.ResetTransform();
		
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
	switch (AltFire) {
		case AltFire::Bayonet: {
			CSpriteLayer@ bayo = this.getSpriteLayer("bayo");
			if(bayo !is null) {
				bayo.ResetTransform();
				bayo.SetOffset(muzzleOffsetSprite+bayo_offset+SPRITE_OFFSET);
				bayo.RotateBy(angle, muzzleOffsetSpriteRotoff+bayo_offset_rotoff+shoulder_joint);
				bayo.SetRelativeZ(-2);
				bayo.SetVisible(true);
			} else {
				@bayo = this.addSpriteLayer("bayo", "att_bayonet", 16, 8, TEAM_NUM, 0);
			}
            CSpriteLayer@ stab = this.getSpriteLayer("stab_flash");
            if(stab != null){
                //stab.SetFrameIndex(0);
                stab.ResetTransform();//we don't change flash with any kickbacks so it's init right here
				Vec2f stab_offset = bayo_offset + Vec2f(-2, -8-0.5*(FLIP?1:2));
				Vec2f stab_offset_rotoff = -Vec2f(stab_offset.x*FLIP_FACTOR, stab_offset.y);
				
				//we use unchanged angle so it doesn't look jumpy
				stab.RotateBy(actual_angle, muzzleOffsetSpriteRotoff+stab_offset_rotoff+shoulder_joint);
				//cannot add sprite_offset directily into muzzleOffsetSprite because it was already taken into account in shoulder_joint
				stab.SetOffset(muzzleOffsetSprite+stab_offset+SPRITE_OFFSET);
				stab.SetVisible(true);
            } else {
				@stab = this.addSpriteLayer("stab_flash", "flash_knoife.png", 16, 16, TEAM_NUM, 0);
				if(stab != null){
					Animation@ stabbo = stab.addAnimation("stab", 1, false);
					int[] frames = {0, 1, 2, 3, 4, 5, 6, 7};
					stabbo.AddFrames(frames);
					stab.SetAnimation("stab");
					stab.ScaleBy(Vec2f(1.4f, 1.4f));
				}
            }
			break;
		}
		case AltFire::UnderbarrelNader: {
			CSpriteLayer@ nader = this.getSpriteLayer("nader");
			if(nader !is null) {
				nader.ResetTransform();
				nader.SetOffset(muzzleOffsetSprite+nader_offset+SPRITE_OFFSET);
				nader.RotateBy(angle, muzzleOffsetSpriteRotoff+nader_offset_rotoff+shoulder_joint);
				nader.SetRelativeZ(-2);
				nader.SetVisible(true);
			} else {
				@nader = this.addSpriteLayer("nader", "att_underbarrelnader", 16, 8, TEAM_NUM, 0);
			}
			break;
		}
	}
}

void onTick(CBlob@ this) 
{	
	CSprite@ sprite = this.getSprite();
	const Vec2f SPRITE_OFFSET = sprite.getOffset();
	
	FirearmVars@ vars;
	this.get("firearm_vars", @vars);
	if (vars is null) {
		warn("Firearm vars is null! at line 122 of StandardFire.as");
		return;
	}
	//0 is unacceptable >:[
	vars.FIRE_INTERVAL = Maths::Max(vars.FIRE_INTERVAL,1);
	vars.BURST_INTERVAL = Maths::Max(vars.BURST_INTERVAL,1);
		
	const bool flip = this.isFacingLeft();
	const f32 flip_factor = flip ? -1 : 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	//since it's a point from center we need to use flip_factor for x
	Vec2f shoulder_joint = Vec2f(3*flip_factor, -3);
	//it's a spriet offset so we don't need flip_factor here
	shoulder_joint -= SPRITE_OFFSET;
	shoulder_joint += Vec2f(this.get_Vec2f("gun_trans_from_carrier").x * flip_factor, this.get_Vec2f("gun_trans_from_carrier").y);
	this.set_Vec2f("shoulder", shoulder_joint);
	
	this.setAngleDegrees(0);
	
	Vec2f gun_translation = this.get_Vec2f("gun_trans");
	
	u8 clip = this.get_u8("clip");
	
	//no flip_factor here because it's taken into account during passing params to a TranslateBy method
	gun_translation = Vec2f(-this.get_Vec2f("gun_trans_from_carrier").x, this.get_Vec2f("gun_trans_from_carrier").y)
					+ Vec2f(vars.SPRITE_TRANSLATION.x, vars.SPRITE_TRANSLATION.y)
					;
	if (!this.isAttached())
		gun_translation = Vec2f_zero;
	
	if (this.isAttached()) 
    {
		this.getCurrentScript().runFlags &= ~(Script::tick_not_sleeping); 					   		
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
        CBlob@ holder = point.getOccupied();
		if (point !is null) {
			if (this.get_u8("rounds_left_in_burst") > 0) {
				point.SetKeysToTake(key_inventory | key_pickup | key_action3);
			} else {
				point.SetKeysToTake(0);
			}
		}
		bool gets_burst_penalty = vars.FIRE_AUTOMATIC && !this.hasTag("NoAccuracyBonus") && clip > 0;
		bool burst_cooldown = this.hasTag("pshh") && gets_burst_penalty;
		bool reloading = this.get_bool("doReload");
		bool cooling = this.get_u8("gun_state")==COOLING;
		u16 shot_count = this.get_u16("shotcount");
		u8 sprite_actionInterval = this.get_u8("actionInterval");
		//TODO: it doesn't happen during action interval that is set when the gun stopped shooting a burst
		bool do_recoil = this.get_bool("make_recoil") && !(burst_cooldown || reloading);
				
		// changing gun postion when DOWN is pressed (and being hold)
        bool previousTrenchAim = this.hasTag("trench_aim");
        if(holder.isKeyPressed(key_down) && !reloading){
			// "aiming" style wield
			gun_translation += trench_aim;
			this.Tag("trench_aim");
        } else {
			// normal wield
			this.Untag("trench_aim");
        }
        
        if (holder !is null && !holder.hasTag("parachute"))
        {
			f32 aimangle = getAimAngle(this,holder), sprite_angle = 0;
			this.set_f32("gunangle", aimangle);
			
            if(holder.isMyPlayer()){
                
                if (holder.isKeyPressed(key_action1)){
                    if(vars.RELOAD_HANDFED_ROUNDS > 0 && this.get_bool("doReload") && clip > 0){ //We can cancel out of reloading if we're a handfed gun
                        this.SendCommand(this.getCommandID("cancel_reload"));
                        this.SendCommand(this.getCommandID("reload_animation"));
                    }
                }
            
                //clientside only
                CControls@ controls = holder.getControls();
            
                if(controls !is null) 
                {
                    // cheat code for testing :D
                    if (controls.isKeyJustPressed(KEY_KEY_J))
                    {
                        //todo: make it send a command so it runs on server
                        
                        if (clip != 255) {
                            this.set_u8("clip", -1);
                            Sound::Play("PowerUp", this.getPosition(), 1.0, 1.0f + (XORRandom(10)-5)*0.01);
                        }
                        else {
                            this.set_u8("clip", 0);
                            Sound::Play("PowerDown", this.getPosition(), 1.0, 1.0f + (XORRandom(10)-5)*0.01);
                        }
                    }
                    
                    if((controls.isKeyJustPressed(KEY_KEY_R) ||
                        (clip < 1 && (vars.FIRE_AUTOMATIC && holder.isKeyPressed(key_action1)) && this.get_u8("clickReload")>=3)) &&
                        !reloading &&
                        this.get_u8("rounds_left_in_burst") <= 0){
                        
                        if (canReload(this,holder)) {
                            startReload(this,vars.RELOAD_TIME);
                        } else {
                            Sound::Play("NoAmmo", this.getPosition(), 1.0, 1.0f + (XORRandom(10)-5)*0.01);
                        }
                    }
                }
            }
            
            bool shooting = this.get_bool("shooting");
            if(holder.isMyPlayer() || (isServer() && holder.isBot())){
                if(!getHUD().hasButtons() && !getHUD().hasMenus()){
                    bool checkShooting = (holder.isKeyJustPressed(key_action1) || (vars.FIRE_AUTOMATIC && holder.isKeyPressed(key_action1)) || this.get_u8("rounds_left_in_burst") > 0);
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
                        if(holder.isMyPlayer()){
                            reload(this, holder);
                            
							if (!special_reload)
								startReload(this,vars.RELOAD_TIME);
                        }
                        
                        finishedReloading = false;
                    }
                } else {
                    if(holder.isMyPlayer())reload(this, holder);
                }
                
                if(finishedReloading){
                    if(isClient()){
                        if(vars.RELOAD_SOUND != "" && this.get_u8("clip") == vars.CLIP)
                            sprite.PlaySound(vars.RELOAD_SOUND,1.0f,float(100*vars.RELOAD_PITCH-pitch_range+XORRandom(pitch_range*2))*0.01f);
                        this.set_u8("clickReload", 0);
                    }
                    this.set_u8("actionInterval", NO_AMMO_INTERVAL); //small interval after each reload
					this.set_u8("gun_state", NONE);
                    this.set_bool("doReload", false);
                }
            } else {
                this.set_u8("gun_state", NONE);
                //it's made before shooting so it's sets to false if we actually shoot
                sprite.SetEmitSoundPaused(true);
                if(shooting)
                {
                    if(clip > 0) 
                    {
                        this.set_u8("actionInterval", vars.FIRE_INTERVAL);
						this.set_u8("gun_state", FIRING);
                        if(vars.BURST > 1){
                            int burst_rounds = this.get_u8("rounds_left_in_burst");
                            if(burst_rounds > 1){
                                this.sub_u8("rounds_left_in_burst",1);
                                this.set_u8("actionInterval", vars.BURST_INTERVAL);
								this.set_u8("gun_state", BURSTFIRING);
                            } else 
                            if(burst_rounds == 1){
                                this.sub_u8("rounds_left_in_burst",1);
                            } else {
                                this.set_u8("rounds_left_in_burst",vars.BURST-1);
                                this.set_u8("actionInterval",vars.BURST_INTERVAL);
								this.set_u8("gun_state", BURSTFIRING);
                            }
                        }
                        
                        Vec2f fromBarrel = Vec2f(0, vars.MUZZLE_OFFSET.y+vars.SPRITE_TRANSLATION.y);
                        if (this.exists("bullet_blob"))
                            fromBarrel.x = -vars.MUZZLE_OFFSET.x*flip_factor;
                        fromBarrel = fromBarrel.RotateBy(aimangle);
                        this.set_Vec2f("fromBarrel", fromBarrel);
                        
                        if(isClient()){
                            if(shot_count < 1){
                                if (!vars.FIRE_START_SOUND.empty())
                                    sprite.PlaySound(vars.FIRE_START_SOUND,1.0f,float(100*1.0f-pitch_range+XORRandom(pitch_range*2))*0.01f);
                            }
                        }
                        
                        if(holder.isMyPlayer() || (isServer() && holder.isBot()))
							shootGun(this.getNetworkID(), aimangle, holder.getNetworkID(), sprite.getWorldTranslation() + fromBarrel);
                    }
                    else
                    {
                        this.set_u8("rounds_left_in_burst",0);
                        this.set_u8("actionInterval", NO_AMMO_INTERVAL);
						this.set_u8("gun_state", NONE);
                        
                        if(isClient()){
                            f32 default_pitch = 110;
                            default_pitch -= 10*(vars.B_DAMAGE);
                            sprite.PlaySound("DryShot.ogg",1.0f,float(default_pitch-pitch_range+XORRandom(pitch_range*2))*0.01f);
                            this.add_u8("clickReload", 1);
                            MakeBangEffect(this, "click");
                        }
                    }
                } else {
                    int AltFire = this.get_u8("override_alt_fire");
                    if(AltFire == AltFire::Unequip)AltFire = vars.ALT_FIRE;
					
                    if(holder.isKeyPressed(key_action2)){
                        
                        switch(AltFire){
                        
                            case AltFire::Bayonet:{	
								this.set_u8("actionInterval",30);
								this.set_u8("gun_state", ALTFIRING);
                                
								if(isClient()){
									CSpriteLayer@ stab = sprite.getSpriteLayer("stab_flash");
									if (stab !is null) stab.SetFrameIndex(0);
									CBitStream params;
									params.write_netid(holder.getNetworkID());
									params.write_f32(aimangle);
									params.write_Vec2f(holder.getPosition()+holder.getVelocity());
									this.SendCommand(this.getCommandID("make_slash"),params);
                                
									sprite.PlaySound("Slash",1.0f,float(100*vars.FIRE_PITCH-pitch_range+XORRandom(pitch_range*2))*0.01f);
                                }
                            break;}
							
							case AltFire::UnderbarrelNader:{
								if (GetItemAmount(holder, "grenades")>0) {
									this.set_u8("actionInterval",30);
									this.set_u8("gun_state", ALTFIRING);
									
									Vec2f fromBarrel = this.get_Vec2f("fromBarrel");
									if(isServer())
										holder.TakeBlob("grenades", 1);
									if(holder.isMyPlayer() || (isServer() && holder.isBot()))
										shootGun(this.getNetworkID(), aimangle, holder.getNetworkID(), sprite.getWorldTranslation() + fromBarrel, true);
								}
							break;}
                        
                            default:{ //Unequip
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
            if ((holder.isKeyJustReleased(key_action1) && !shooting && shot_count > 0 || clip < 1) && !cooling)
            {
                this.set_u16("shotcount", 0);//nulify shotcount
                //this.Tag("pshh");
                
                if(isClient()){
                    sprite.SetEmitSoundPaused(true);
                    if (this.get_u8("clip") > 0 && !vars.FIRE_END_SOUND.empty())
                        sprite.PlaySound(vars.FIRE_END_SOUND,1.0f,float(100*1.0f-pitch_range+XORRandom(pitch_range*2))*0.01f);
                }
                
                //set overheat interval for automatic guns that gain accuracy bonus on 2-3 first shots if clip isn't empty
                if (gets_burst_penalty) {
                    this.set_u8("actionInterval",15);
					this.set_u8("gun_state", COOLING); //Prevent spam click on accuracy-lossy smgs
				}
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
    } 
    else 
    {
		this.getCurrentScript().runFlags |= Script::tick_not_sleeping; 
    }
	this.set_Vec2f("gun_trans", gun_translation);
}

void onRender(CSprite@ this)
{
	FirearmVars@ vars;
	this.getBlob().get("firearm_vars", @vars);
	if (vars is null) {
		warn("Firearm vars is null! at line 396 of StandardFire.as");
		return;
	}
	if (isClient()) {
		CBlob@ blob = this.getBlob();
		//renders only when a gun's reloading and if the gun is attached
		if (!blob.get_bool("doReload") || blob.get_u8("clip") == vars.CLIP || !blob.isAttached()) return;
		
		AttachmentPoint@ point = blob.getAttachments().getAttachmentPointByName("PICKUP");	   		
		CBlob@ holder = point.getOccupied();
		if (holder is null) return;
		
		const f32 scalex = getDriver().getResolutionScaleFactor();
		const f32 zoom = getCamera().targetDistance * scalex;
		Vec2f pos2d =  holder.getInterpolatedScreenPos() + Vec2f(0.0f, (-blob.getHeight() - 20.0f) * zoom);
		Vec2f pos = pos2d + Vec2f(-30.0f, -40.0f);
		Vec2f dimension = Vec2f(60.0f - 8.0f, 8.0f);
			
		GUI::DrawIconByName("$progress_bar$", pos);
		
		f32 percentage = blob.get_f32("perc");
		Vec2f bar = Vec2f(pos.x + (dimension.x * percentage), pos.y + dimension.y);
		
		GUI::DrawRectangle(pos + Vec2f(4, 4), bar + Vec2f(4, 4), SColor(255, 59, 20, 6));
		GUI::DrawRectangle(pos + Vec2f(6, 6), bar + Vec2f(2, 4), SColor(255, 148, 27, 27));
		GUI::DrawRectangle(pos + Vec2f(6, 6), bar + Vec2f(2, 2), SColor(255, 183, 51, 51));
	}
}

f32 getAimAngle( CBlob@ this, CBlob@ holder )
{
	FirearmVars@ vars;
	this.get("firearm_vars", @vars);
	CSprite@ sprite = this.getSprite();
	const Vec2f SPRITE_OFFSET = sprite.getOffset();
	
	const bool flip = holder.isFacingLeft();
	const f32 flip_factor = flip ? -1 : 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	this.set_Vec2f("gun_pos", (Vec2f(this.get_Vec2f("shoulder").x, vars.SPRITE_TRANSLATION.y - vars.MUZZLE_OFFSET.y)));
	Vec2f endPos = holder.getAimPos();
	Vec2f startPos = this.getPosition() + Vec2f(-this.get_Vec2f("shoulder").x,this.get_Vec2f("shoulder").y) + (this.hasTag("trench_aim") ? Vec2f(0,trench_aim.y) : Vec2f_zero) + Vec2f(-SPRITE_OFFSET.x, SPRITE_OFFSET.y);
 	Vec2f aimvector = endPos - startPos;
	
	Vec2f hitPos;
	
	HitInfo@[] hitInfos;
	bool mapHit = getMap().rayCastSolid(startPos, endPos, hitPos);
	f32 length = (hitPos - startPos).Length();
	bool blobHit = getMap().getHitInfosFromRay(startPos, -aimvector.Angle(), length, this, @hitInfos);
	
    return -aimvector.Angle()+angle_flip_factor;
}

f32 constrainAngle(f32 x)
{
	x = (x + 180) % 360;
	if (x < 0) x += 360;
	return x - 180;
}