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
	sprite.getConsts().accurateLighting = false;
	
	FirearmVars@ vars;
	this.get("firearm_vars", @vars);
	if (vars is null) {
		warn("Firearm vars is null! at line 21 of StandardFire.as");
		return;
	}
	//0 is unacceptable >:[
	vars.FIRE_INTERVAL = Maths::Max(vars.FIRE_INTERVAL,1);
	vars.BURST_INTERVAL = Maths::Max(vars.BURST_INTERVAL,1);
	//set the vars so we don't lose the change
	this.set("firearm_vars", @vars);
	
	CSpriteLayer@ flash = null;
	if (!vars.FLASH_SPRITE.empty())
		@flash = sprite.addSpriteLayer("m_flash", vars.FLASH_SPRITE, 16, 16, this.getTeamNum(), 0);
	
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
	
	this.addCommandID("cycle_animation");
	this.addCommandID("load_animation");
	this.addCommandID("reload_animation");
	this.addCommandID("dryshot_animation");
	
	this.addCommandID("make_clipgib");
	
	this.addCommandID("fire_beginning");
	this.addCommandID("fire_ending");

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
	Animation@ reload_anime = sprite.getAnimation("reload");
	if (reload_anime !is null) {
		reload_anime.time = vars.RELOAD_TIME/reload_anime.getFramesCount();
	}
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
	//since it's a point from center we need to use flip_factor for x
	Vec2f shoulder_joint = Vec2f(3*flip_factor, -3);
	//it's a spriet offset so we don't need flip_factor here
	shoulder_joint -= sprite_offset;
	shoulder_joint += Vec2f(this.get_Vec2f("gun_trans_from_carrier").x * flip_factor, this.get_Vec2f("gun_trans_from_carrier").y);
	this.set_Vec2f("shoulder", shoulder_joint);
		
	sprite.ResetTransform();
	this.setAngleDegrees(0);
	
	Vec2f gun_translation = this.get_Vec2f("gun_trans");
	
    if(isServer() && (getGameTime()) % 30 == 0){
		this.Sync("clip", true);
		this.Sync("total", true);
	}
	int clip = this.get_u8("clip");
	
	if (this.isAttached()) 
    {
		this.getCurrentScript().runFlags &= ~(Script::tick_not_sleeping); 					   		
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
        CBlob@ holder = point.getOccupied();
		this.Sync("actionInterval", true);
		this.Sync("doReload", true);
		uint8 actionInterval = this.get_u8("actionInterval");
		bool gets_burst_penalty = vars.FIRE_AUTOMATIC && !this.hasTag("NoAccuracyBonus") && clip > 0;
		bool burst_cooldown = this.hasTag("pshh") && gets_burst_penalty;
		bool reloading = this.get_bool("doReload") || this.get_bool("beginReload");
		//TODO: it doesn't happen during action interval that is set when the gun stopped shooting a burst
		bool do_recoil = this.get_bool("make_recoil") && !(burst_cooldown || reloading);
		//do_recoil = false;

		//no flip_factor here because it's taken into account during passing params to a TranslateBy method
		gun_translation = Vec2f(vars.SPRITE_TRANSLATION.x, vars.SPRITE_TRANSLATION.y)
						+ Vec2f(-this.get_Vec2f("gun_trans_from_carrier").x, this.get_Vec2f("gun_trans_from_carrier").y);
		//this sets how far should it go
		Vec2f knockback = Vec2f(-3, 0);
		//multiplying it by percentage action interval
		knockback.x *= 1.0f*actionInterval/vars.FIRE_INTERVAL;
		//adding knockback if the gun plays recoil animation
		if (do_recoil) {
			gun_translation += knockback;
		}
		// changing gun postion when DOWN is pressed (and being hold)
        bool previousTrenchAim = this.hasTag("trench_aim");
        if(holder.isKeyPressed(key_down) && !this.get_bool("doReload")){
			// "aiming" style wield
			gun_translation += trench_aim;
			this.Tag("trench_aim");
        } else {
			// normal wield
			this.Untag("trench_aim");
        }
        /* if(isServer()) {
			if(previousTrenchAim != this.hasTag("trench_aim")){
				this.server_DetachFrom(holder);
				holder.server_Pickup(this);
			}
        } */
		this.set_Vec2f("gun_trans", gun_translation);
        
        if (holder !is null && !holder.hasTag("parachute"))
        {
			// defines how far should a gun jump upon fire
			f32 recoil_angle = (Maths::Tan(50)*(64-sprite.getFrameWidth()))*-1;
			// multiply it by percentage so it goes down slooowly like a snail
			recoil_angle *= 1.0f*actionInterval/vars.FIRE_INTERVAL;
			f32 aimangle = getAimAngle(this,holder), sprite_angle = 0;
			// these angles are only for sprite so they don't affect shooting
			sprite_angle = this.get_bool("doReload") ? (flip ? 0-vars.RELOAD_ANGLE : 0+vars.RELOAD_ANGLE) : aimangle;
			// make_recoil is set to false once actionInterval reaches 0 so recoil animation is stops
			sprite_angle = do_recoil ? (flip ? aimangle+recoil_angle : aimangle-recoil_angle) : sprite_angle;
			holder.set_f32("gunangle", sprite_angle);
			this.set_f32("gunangle", sprite_angle);
			sprite.TranslateBy(Vec2f((gun_translation.x + sprite_offset.x)* flip_factor, gun_translation.y + sprite_offset.y));
			
			u16 shot_count = this.get_u16("shotcount");
			if (shot_count > 2)
				knockback = Vec2f(knockback.x, 0 + XORRandom(Maths::Min(knockback.y, shot_count)) - knockback.y/2);
			else
				knockback = Vec2f(knockback.x, 0);
			knockback.RotateBy(aimangle+(this.isFacingLeft() ? 180 : 0), Vec2f(0, 0) ); //this rotates vector
			//if (this.get_bool("make_recoil"))
			//	sprite.TranslateBy(knockback); //this modifies sprite with our knockback vector
			
			sprite.RotateBy(sprite_angle, shoulder_joint);
			
			CSpriteLayer@ flash = sprite.getSpriteLayer("m_flash");
			if (flash !is null)
			{
				flash.ResetTransform();
				//todo offset taken from carrier and normilize trench_aim offset
				//the trash thing is flash rotates with a sprite and it doesn't need a flip_factor
				//BUT offset which around we rotate the offset of the flash is just a point so it does require it :<
				Vec2f trenchy_for_flash = previousTrenchAim?Vec2f(-trench_aim.x, trench_aim.y):Vec2f_zero;
				Vec2f trenchy_rotoff = -(previousTrenchAim?Vec2f(-trench_aim.x*flip_factor, trench_aim.y):Vec2f_zero);
				//and the same for gun_trans_from_carrier
				Vec2f gtfc_for_flash = Vec2f(this.get_Vec2f("gun_trans_from_carrier").x, this.get_Vec2f("gun_trans_from_carrier").y);
				Vec2f gtfc_rotoff = -Vec2f(this.get_Vec2f("gun_trans_from_carrier").x * flip_factor, this.get_Vec2f("gun_trans_from_carrier").y);
				//muzzle
				Vec2f muzzle = vars.MUZZLE_OFFSET;
				Vec2f muzzle_rotoff = -Vec2f(vars.MUZZLE_OFFSET.x*flip_factor,vars.MUZZLE_OFFSET.y);
				
				Vec2f fromBarrel = muzzle+trenchy_for_flash+gtfc_for_flash+sprite_offset;
				f32 rotate_rnd = 0;
				flash.RotateBy(aimangle+XORRandom(rotate_rnd*2)-rotate_rnd, muzzle_rotoff+trenchy_rotoff+gtfc_rotoff+shoulder_joint);
				flash.SetOffset(fromBarrel);
			}
			
	        // fire + reload
	        if(holder.isMyPlayer() || (holder.isBot() && isServer()))	
	        {
				CControls@ controls = holder.getControls();
				
				if (actionInterval <= 0) 
				if(controls !is null) 
				{
					// cheat code for testing :D
					if (controls.isKeyJustPressed(KEY_KEY_J))
					{
						if (isServer()) {
							this.set_u8("clip", -1);
							this.Sync("clip", true);
						}
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
					this.set_bool("make_recoil", false);
					// doesn't shoot if has buttons or menus
					this.Untag("pshh");
					//it's made before shooting so it's sets to false if we actually shoot
					sprite.SetEmitSoundPaused(true);
					if (!(getHUD().hasButtons() || getHUD().hasMenus()) && shooting)
					{
						if(clip > 0) 
						{
							actionInterval = vars.FIRE_INTERVAL;
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
							
							Vec2f fromBarrel = Vec2f(0, vars.MUZZLE_OFFSET.y-vars.SPRITE_TRANSLATION.y);
							if (this.exists("bullet_blob"))
								fromBarrel.x = -vars.MUZZLE_OFFSET.x*flip_factor;
							fromBarrel = fromBarrel.RotateBy(aimangle);
							this.set_Vec2f("fromBarrel", fromBarrel);
							
							if (shot_count < 1)
								this.SendCommand(this.getCommandID("fire_beginning"));
							shootGun(this.getNetworkID(), aimangle, holder.getNetworkID(), sprite.getWorldTranslation() + fromBarrel);
							//controls.setMousePosition(controls.getMouseScreenPos() + Vec2f(1, -20));
							if (!vars.CART_SPRITE.empty() && vars.SELF_EJECTING) {
								MakeEmptyShellParticle(this, vars.CART_SPRITE, 1, Vec2f(-69, -69), holder);
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
					this.SendCommand(this.getCommandID("fire_ending"));
					//print("nulify");
					//set overheat interval for automatic guns that gain accuracy bonus on 2-3 first shots if clip isn't empty
					if (gets_burst_penalty)
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
	Vec2f startPos = this.getPosition() + Vec2f(-this.get_Vec2f("shoulder").x,this.get_Vec2f("shoulder").y) + (this.hasTag("trench_aim") ? Vec2f(0,trench_aim.y) : Vec2f_zero) + Vec2f(0, this.getSprite().getOffset().y);
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