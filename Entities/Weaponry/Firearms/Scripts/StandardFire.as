#include "BulletCase"
#include "MakeBangEffect"
#include "GunStandard"
#include "KIWI_Locales"
#include "FirearmVars"

//i genuinely sowwy for mixing actual comments with a commented code >///<

const uint8 NO_AMMO_INTERVAL = 5;
u8 reloadCMD, setClipCMD;
 
const Vec2f trench_aim = Vec2f(2, -3);

void onInit(CBlob@ this) 
{
	CSprite@ sprite = this.getSprite();
	
	FirearmVars@ vars;
	this.get("firearm_vars", @vars);
	if (vars is null) {
		warn("Firearm vars is null! at line 21 of StandardFire.as");
		return;
	}
	
    reloadCMD = this.addCommandID("reload");
    this.addCommandID("set_clip");
    this.addCommandID("finish_shooting");
    this.addCommandID("cycle_animation");
    this.addCommandID("load_animation");
    this.addCommandID("reload_animation");
    this.addCommandID("make_clipgib");
    this.addCommandID("dryshot_animation");

	//Sprites
    this.set_string("SpriteBullet", vars.BULLET_SPRITE);
    this.set_string("SpriteFade", vars.FADE_SPRITE);

	this.set_bool("beginReload", false);
	this.set_bool("doReload", false);
	this.set_u8("actionInterval", 0);
    this.set_u8("rounds_left_in_burst",0);
    this.set_u8("total",0);
    this.set_u8("clip",0);
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
}

void onTick(CBlob@ this) 
{	
	CSprite@ sprite = this.getSprite();
	const Vec2f sprite_offset = sprite.getOffset();
	
	FirearmVars@ vars;
	this.get("firearm_vars", @vars);
	if (vars is null) {
		warn("Firearm vars is null! at line 122 of StandardFire.as");
		return;
	}
	
	onRender(sprite);
		
	const bool flip = this.isFacingLeft();
	const f32 flip_factor = flip ? -1 : 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	const Vec2f shoulder_joint = Vec2f((3 - sprite_offset.x) * flip_factor, -3 - sprite_offset.y)
		+ Vec2f(this.get_Vec2f("gun_trans_from_carrier").x * flip_factor, this.get_Vec2f("gun_trans_from_carrier").y);
	this.set_Vec2f("shoulder", shoulder_joint);
		
	sprite.ResetTransform();
	this.setAngleDegrees(0);
	
	Vec2f gun_translation = this.get_Vec2f("gun_trans");
	
    if(isServer() && (getGameTime()) % 30 == 0){
		this.Sync("clip", true);
		this.Sync("total", true);
	}
	
	if (this.isAttached()) 
    {
		this.getCurrentScript().runFlags &= ~(Script::tick_not_sleeping); 					   		
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");	   		
        CBlob@ holder = point.getOccupied();

		//changing gun postion when DOWN is pressed (and being hold)
        bool previousTrenchAim = this.hasTag("trench_aim");
        if(holder.isKeyPressed(key_down) && !this.get_bool("doReload")){
			// "aiming" gun wield
			this.set_Vec2f("gun_trans", (Vec2f(vars.SPRITE_TRANSLATION.x, vars.SPRITE_TRANSLATION.y) + trench_aim
				+ Vec2f(-this.get_Vec2f("gun_trans_from_carrier").x, this.get_Vec2f("gun_trans_from_carrier").y)));
			this.Tag("trench_aim");
        } else {
			// normal gun wield
			this.set_Vec2f("gun_trans", (Vec2f(vars.SPRITE_TRANSLATION.x, vars.SPRITE_TRANSLATION.y)
				+ Vec2f(-this.get_Vec2f("gun_trans_from_carrier").x, this.get_Vec2f("gun_trans_from_carrier").y)));
			this.Untag("trench_aim");
        }
        if(isServer()) {
			if(previousTrenchAim != this.hasTag("trench_aim")){
				this.server_DetachFrom(holder);
				holder.server_Pickup(this);
			}
        }
        
        if (holder !is null && !holder.hasTag("parachute")) 
        {
			// defines how far should a gun jump upon fire
			f32 recoil_angle = (Maths::Tan(50)*(64-sprite.getFrameWidth()))*-1;
			f32 aimangle = getAimAngle(this,holder), sprite_angle = 0;
			// these angles are only for sprite so they don't affect shooting
			sprite_angle = this.get_bool("doReload") ? (flip ? 0-vars.RELOAD_ANGLE : 0+vars.RELOAD_ANGLE) : aimangle;
			sprite_angle = this.get_bool("make_recoil") ? (flip ? aimangle+recoil_angle : aimangle-recoil_angle) : sprite_angle;
			holder.set_f32("gunangle", sprite_angle);
			this.set_f32("gunangle", sprite_angle);
			sprite.TranslateBy(Vec2f((gun_translation.x + sprite_offset.x)* flip_factor, gun_translation.y));
			
			u16 shot_count = this.get_u16("shotcount");
			Vec2f knockback = Vec2f(-5, 0); //this sets how far should it go (with a random Y)
			if (shot_count > 2)
				knockback = Vec2f(knockback.x, 0 + XORRandom(Maths::Min(knockback.y, shot_count)) - knockback.y/2);
			else
				knockback = Vec2f(knockback.x, 0);
			knockback.RotateBy(aimangle+(this.isFacingLeft() ? 180 : 0), Vec2f(0, 0) ); //this rotates vector
			//if (this.get_bool("make_recoil"))
			//	sprite.TranslateBy(knockback); //this modifies sprite with our knockback vector
			
			sprite.RotateBy(sprite_angle, shoulder_joint);
			this.set_bool("make_recoil", false);
			
	        // fire + reload
	        if(holder.isMyPlayer() || (holder.isBot() && isServer()))	
	        {
				//print(aimvector + " | " + aimangle);
	        	//check for clip amount error
				//why do we need it though...
				int clip = this.get_u8("clip");
	        	
				CControls@ controls = holder.getControls();

				uint8 actionInterval = this.get_u8("actionInterval");
				
				if (actionInterval <= 0) 
				if(controls !is null) 
				{
					// cheat code for testing :D
					if (controls.isKeyJustPressed(KEY_KEY_J))
					{
						this.set_u8("clip", -1);
						Sound::Play("LoseM16", this.getPosition(), 1.0, 1.0f + (XORRandom(10)-5)*0.01);
					}
					
					if((controls.isKeyJustPressed(KEY_KEY_R) ||
						(clip < 1 && (vars.FIRE_AUTOMATIC && holder.isKeyPressed(key_action1)) && this.get_u8("clickReload")>=3)) &&
						!this.get_bool("beginReload") &&
                        !this.get_bool("doReload"))
					{
						if (canReload(this,holder)) {
							this.set_bool("beginReload", true);
						} else {
							Sound::Play("NoAmmo", this.getPosition(), 1.0, 1.0f + (XORRandom(10)-5)*0.01);
						}
					}
				}
				
                if (holder.isKeyPressed(key_action1))
                {
                    if(vars.RELOAD_HANDFED_ROUNDS > 0 && this.get_bool("doReload") && clip > 0){ //We can cancel out of reloading if we're a handfed gun
                        this.set_bool("doReload", false);
						this.SendCommand(this.getCommandID("reload_animation"));
                        actionInterval = 0;
                    }
                }
				
				bool shooting = (holder.isKeyJustPressed(key_action1) || (vars.FIRE_AUTOMATIC && holder.isKeyPressed(key_action1)) || this.get_u8("rounds_left_in_burst") > 0);
				
				if (actionInterval > 0) 
				{
					this.set_f32("perc", 1.0f*actionInterval / vars.RELOAD_TIME);
					actionInterval--;			
				}
				else if(this.get_bool("beginReload"))
				{
                    actionInterval = vars.RELOAD_TIME;
                    this.set_bool("beginReload", false);
                    this.set_bool("doReload", true);
					//sound only plays when we load whole clip at once
					//it's either reloading by X rounds a time and this X = CLIP or reloading full magazine (RHR variable = 0)
					//it's made so when rifle reloads by 5 (it's capacity) instead of full clip reload gun actually plays load sound
                    if((vars.RELOAD_HANDFED_ROUNDS <= 0 || vars.RELOAD_HANDFED_ROUNDS == vars.CLIP) && vars.LOAD_SOUND != "")
						this.SendCommand(this.getCommandID("load_animation"));
                    
                    if(vars.EMPTY_RELOAD)
                    if(isServer()){
                        this.set_u8("clip",0);
                        CBitStream params;
                        params.write_u8(this.get_u8("clip"));
                        params.write_u8(this.get_u8("total"));
                        this.SendCommand(this.getCommandID("set_clip"),params);
                    }
                    
                    if(vars.CART_SPRITE != ""){
                        int carts = this.get_u8("stored_carts");
                        if(carts > 0){
                            
                            f32 oAngle = aimangle;
                            if(holder.isFacingLeft())oAngle = (oAngle % 360) + 180;
                            
                            Vec2f fromBarrel = Vec2f((holder.isFacingLeft() ? -1 : 1),0);
                            fromBarrel = fromBarrel.RotateBy(aimangle);
                            fromBarrel *= 7;
                            
							MakeEmptyShellParticle(this, vars.CART_SPRITE, carts);
                            
                            this.set_u8("stored_carts",0);
                        }
                    }
                    
                    if(vars.CLIP_SPRITE != ""){
						this.SendCommand(this.getCommandID("make_clipgib"));
                    }
				} 
				else if(this.get_bool("doReload")) 
				{
                    if(vars.RELOAD_HANDFED_ROUNDS > 0){
						bool special_reload = vars.RELOAD_HANDFED_ROUNDS == vars.CLIP;
                        if(canReload(this,holder)){
                            reload(this, holder);
							//same here if reloading by X where X isn't equal to CLIP we play sound otherwise we don't because we did eariler
                            if(vars.LOAD_SOUND != "" && !special_reload)
								this.SendCommand(this.getCommandID("load_animation"));
                            actionInterval = vars.RELOAD_TIME;
							if (special_reload) actionInterval = 0;
                        } else {
                            this.SendCommand(this.getCommandID("reload_animation"));
                            this.set_bool("doReload", false);
                        }
                    } else {
                        reload(this, holder);
                        this.SendCommand(this.getCommandID("reload_animation"));
                        this.set_bool("doReload", false);
                    }
				}
				else {
					// this one is epic. It plays a cycle sound only when actionInterval is 0 that means when you hear a cycle sound you may shoot the exact same moment
					this.SendCommand(this.getCommandID("cycle_animation"));
					// doesn't shoot if has buttons or menus
					this.Untag("pshh");
					if (!(getHUD().hasButtons() || getHUD().hasMenus()) && shooting)
					{
						if(clip > 0) 
						{
							actionInterval = Maths::Max(vars.FIRE_INTERVAL,1); //0 is unacceptable >:[
							if(vars.BURST > 1){
								int burst_rounds = this.get_u8("rounds_left_in_burst");
								if(burst_rounds > 1){
									this.sub_u8("rounds_left_in_burst",1);
									actionInterval = vars.BURST_INTERVAL;
								} else 
								if(burst_rounds == 1){
									this.sub_u8("rounds_left_in_burst",1);
								} else {
									this.set_u8("rounds_left_in_burst",vars.BURST-1);
									actionInterval = vars.BURST_INTERVAL;
								}
							}
							
							Vec2f fromBarrel = Vec2f(flip_factor*vars.MUZZLE_OFFSET.x,vars.MUZZLE_OFFSET.y);
							fromBarrel = fromBarrel.RotateBy(aimangle);
							this.set_Vec2f("fromBarrel", fromBarrel);
							
							shootGun(this.getNetworkID(), aimangle, holder.getNetworkID(), sprite.getWorldTranslation() + fromBarrel);
							if (!vars.CART_SPRITE.empty() && vars.SELF_EJECTING) {
								MakeEmptyShellParticle(this, vars.CART_SPRITE, 1, Vec2f(-69, -69), this);
							}
						}
						else
						{
							this.set_u8("rounds_left_in_burst",0);
							actionInterval = NO_AMMO_INTERVAL;
							this.SendCommand(this.getCommandID("dryshot_animation"));
							//print("hey?");
						}
					}
				}
				//THIS BS DOESN'T WORK AT ALL AT SERVER WTAF?
				//now it kinda does..
				
				//gun stops shooging and plays the animation only when we were shooting and released button or if we're out of ammo
				if ((holder.isKeyJustReleased(key_action1) && !shooting && shot_count > 0 || clip < 1) && !this.hasTag("pshh"))
                {
					//nulify shotcount
					this.SendCommand(this.getCommandID("finish_shooting"));
					//print("nulify");
					//set overheat interval for automatic guns that gain accuracy bonus on 2-3 first shots if clip isn't empty
					if (vars.FIRE_AUTOMATIC && !this.hasTag("NoAccuracyBonus") && clip > 0)
						actionInterval = 15;
				}
				this.set_u8("actionInterval", actionInterval);	
			}
		}
    } 
    else 
    {
		this.getCurrentScript().runFlags |= Script::tick_not_sleeping; 
    }
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
		
		//f32 percentage = 1.0f - float(returncount) / float(return_time);
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
	
	const bool flip = holder.isFacingLeft();
	const f32 flip_factor = flip ? -1 : 1;
	this.set_Vec2f("gun_pos", (Vec2f(this.get_Vec2f("shoulder").x, vars.SPRITE_TRANSLATION.y - vars.MUZZLE_OFFSET.y)));
	Vec2f endPos = holder.getAimPos();
	Vec2f startPos = this.getPosition() + Vec2f(-this.get_Vec2f("shoulder").x,this.get_Vec2f("shoulder").y) + (this.hasTag("trench_aim") ? Vec2f(0,trench_aim.y) : Vec2f_zero) + Vec2f(-vars.MUZZLE_OFFSET.x/2*flip_factor, vars.MUZZLE_OFFSET.y+this.getSprite().getOffset().y);
 	Vec2f aimvector = endPos - startPos;
	if(endPos.x < startPos.x)
		aimvector = startPos - endPos;
	
	Vec2f hitPos;
	
	HitInfo@[] hitInfos;
	bool mapHit = getMap().rayCastSolid(startPos, endPos, hitPos);
	f32 length = (hitPos - startPos).Length();
	bool blobHit = getMap().getHitInfosFromRay(startPos, -aimvector.Angle(), length, this, @hitInfos);
	
    return -aimvector.Angle();
}