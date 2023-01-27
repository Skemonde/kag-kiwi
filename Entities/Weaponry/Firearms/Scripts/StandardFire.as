#include "GunStandard.as";
#include "MakeBangEffect.as";
#include "BulletCase.as";
#include "KIWI_Locales.as";

const uint8 NO_AMMO_INTERVAL = 5;
u8 reloadCMD, setClipCMD;
 
const Vec2f trench_aim = Vec2f(2, -3);
const f32 reload_angle = 65;

void onInit(CBlob@ this) 
{
	CSprite@ sprite = this.getSprite();
    reloadCMD = this.addCommandID("reload");
    this.addCommandID("set_clip");
	//todo: gun names from locales file
	string gun_name = this.getName();
	this.setInventoryName(Names::smg);

    //Only initialise variables here that things outside of the gun need to access smh
    this.set_u8("clip", CLIP);
    this.set_u8("total", TOTAL);
	this.set_u8("clip_size", CLIP);
	this.set_string("ammo_blob", AMMO_TYPE);
	
	this.set_Vec2f("muzzle_offset", MUZZLE_OFFSET);
	this.set_Vec2f("sprite_translation", SPRITE_TRANSLATION);

	this.set_u8("spread"       ,B_SPREAD);
	this.set_u8("TTL"          ,B_TTL);
	this.set_Vec2f("KB"        ,B_KB);
	this.set_Vec2f("grav"      ,B_GRAV);
	this.set_u8("spread"       ,B_SPREAD);
    this.set_bool("uniform_spread",UNIFORM_SPREAD);
    
	this.set_u8("b_count"      ,BUL_PER_SHOT);
	this.set_u8("speed"        ,B_SPEED);
    this.set_u8("random_speed" ,B_SPEED_RANDOM);
    this.set_u8("ricochet"     ,RICOCHET_CHANCE);
    this.set_u8("interval"     ,FIRE_INTERVAL);
    
	this.set_f32("damage"      ,B_DAMAGE);
    this.set_u8("damage_type"  ,DMG_TYPE);
	this.set_u16("coins_flesh" ,B_F_COINS);
	this.set_u16("coins_object",B_O_COINS);
	this.set_string("sound"    ,FIRE_SOUND);
	this.set_string("text_sound"    ,ONOMATOPOEIA);
    
    this.set_u8("pierces"      ,PIERCES);
    
    this.set_bool("self_ejecting",SELF_EJECTING);
    this.set_string("cart_sprite",CART_SPRITE);
	this.Tag(C_TAG);

    //Sounds
	this.set_string("flesh_hit_sound" ,S_FLESH_HIT);
	this.set_string("object_hit_sound",S_OBJECT_HIT);
	//Sprites
    this.set_string("SpriteBullet",BULLET_SPRITE);
    this.set_string("SpriteFade",FADE_SPRITE);

	this.set_bool("beginReload", false);
	this.set_bool("doReload", false);
	this.set_u8("actionInterval", 0);
    this.set_u8("rounds_left_in_burst",0);
	this.set_Vec2f("gun_trans_from_carrier", Vec2f_zero);
    
	this.Tag("gun");
    this.Tag("firearm");
    
    this.set_u8("stored_carts",0);
    
    
    AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
    this.set_Vec2f("original_offset",point.offset);
    
    CRules @rules = getRules();

    if (isClient())
	{
		if (BULLET_SPRITE != ""){

			Vertex[]@ bullet_vertex;
			rules.get(BULLET_SPRITE, @bullet_vertex);

			if (bullet_vertex is null)
			{
				Vertex[] vert;
				rules.set(BULLET_SPRITE, @vert);
			}

			// #blamekag
			if (!rules.exists("VertexBook"))
			{
				string[] book;
				rules.set("VertexBook", @book);
				book.push_back(BULLET_SPRITE);
			}
			else
			{
				string[]@ book;
				rules.get("VertexBook", @book);
				book.push_back(BULLET_SPRITE);
			}
		}
		
		if(FADE_SPRITE != ""){
			Vertex[]@ fade_vertex;
			rules.get(FADE_SPRITE, @fade_vertex);

			if (fade_vertex is null)
			{
				Vertex[] vert;
				rules.set(FADE_SPRITE, @vert);
			}

			// #blamekag
			if (!rules.exists("VertexBook"))
			{
				string[] book;
				rules.set("VertexBook", @book);
				book.push_back(FADE_SPRITE);
			}
			else
			{
				string[]@ book;
				rules.get("VertexBook", @book);
				book.push_back(FADE_SPRITE);
			}
		}
	}
	AddIconToken("$progress_bar$", "Entities/Special/CTF/FlagProgressBar.png", Vec2f(30, 8), 0);
	
	CSpriteLayer@ laser_flash = sprite.addSpriteLayer("laser_flash", "laser_flash.png", 18, 11, 0, 0);
	
	if (laser_flash !is null)
	{
		Animation@ anim = laser_flash.addAnimation("default", 1, true);
		int[] frames = {0, 1};
		anim.AddFrames(frames);
		laser_flash.SetRelativeZ(500.0f);
		laser_flash.setRenderStyle(RenderStyle::additive);
		laser_flash.SetVisible(false);
	}
}

void onTick(CBlob@ this) 
{	
	CSprite@ sprite = this.getSprite();
	const Vec2f sprite_offset = sprite.getOffset();
	
	CSpriteLayer@ laser = sprite.getSpriteLayer("laser_flash");
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
	
    if(isServer() && (getGameTime()+this.getNetworkID()) % 30 == 0){
		this.Sync("clip",true);
		this.Sync("total",true);
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
			this.set_Vec2f("gun_trans", (Vec2f(SPRITE_TRANSLATION.x, SPRITE_TRANSLATION.y) + trench_aim
				+ Vec2f(-this.get_Vec2f("gun_trans_from_carrier").x, this.get_Vec2f("gun_trans_from_carrier").y)));
			this.Tag("trench_aim");
        } else {
			// normal gun wield
			this.set_Vec2f("gun_trans", (Vec2f(SPRITE_TRANSLATION.x, SPRITE_TRANSLATION.y)
				+ Vec2f(-this.get_Vec2f("gun_trans_from_carrier").x, this.get_Vec2f("gun_trans_from_carrier").y)));
			this.Untag("trench_aim");
        }
        if(isServer())
        if(previousTrenchAim != this.hasTag("trench_aim")){
            this.server_DetachFrom(holder);
            holder.server_Pickup(this);
        }
        
        if (holder !is null && !holder.hasTag("parachute")) 
        { 
	        CSprite@ sprite = this.getSprite();
			
			//why doesn't it work?
			//int recoil_range = 10; // pixels
			//f32 recoil_angle = Maths::ATan(recoil_range/sprite.getFrameWidth());
			
			//don't ask about this formula...
			f32 recoil_angle = Maths::Tan(50)*(64-sprite.getFrameWidth())*-1;
	        
			Vec2f aimvector = holder.getAimPos() - this.getPosition();
			f32 aimangle = getAimAngle(this,holder), sprite_angle = 0;
			// these angles are only for sprite so they don't affect shooting
			sprite_angle = this.get_bool("doReload") ? (flip ? (45-reload_angle) : (315+reload_angle)) : aimangle;
			sprite_angle = this.get_bool("make_recoil") ? (flip ? aimangle+recoil_angle : aimangle-recoil_angle) : aimangle;
			this.set_bool("make_recoil", false);
			holder.set_f32("gunangle", sprite_angle);
			this.set_f32("gunangle", sprite_angle);
			sprite.TranslateBy(Vec2f((gun_translation.x + sprite_offset.x)* flip_factor, gun_translation.y - sprite_offset.y));
			sprite.RotateBy(sprite_angle, shoulder_joint);
			
			if (laser !is null)
			{
				laser.ResetTransform();
				//laser.RotateBy(aimangle, shoulder_joint);
				laser.SetOffset(Vec2f(MUZZLE_OFFSET.x*-2,MUZZLE_OFFSET.y).RotateBy(-aimangle* flip_factor, shoulder_joint));
				laser.SetVisible(false);
			}

	        // fire + reload
	        if(holder.isMyPlayer() || (holder.isBot() && isServer()))	
	        {
				//print(aimvector + " | " + aimangle);
	        	//check for clip amount error
				//why do we need it though...
				int clip = this.get_u8("clip");
				//if(clip > CLIP) 
				//{
				//	this.set_u8("clip", 0);
				//	clip = 0;
				//}
	        	
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
					//another cheat code for testing C:
					//if (controls.isKeyJustPressed(KEY_KEY_K))
					//{
					//	this.set_bool("cheaty", !this.get_bool("cheaty"));
					//	Sound::Play(this.get_bool("cheaty") ? "ScopeFocus" : "Remove", this.getPosition(), 3.0, 1.0f + (XORRandom(10)-5)*0.01);
					//}
					
					if(controls.isKeyJustPressed(KEY_KEY_R) &&
						!this.get_bool("beginReload") &&
                        !this.get_bool("doReload") &&
						canReload(this,holder)) 
					{
						this.set_bool("beginReload", true);				
					}
				}
				
                if (holder.isKeyPressed(key_action1))
                {
                    if(RELOAD_HANDFED_ROUNDS > 0 && this.get_bool("doReload") && clip > 0){ //We can cancel out of reloading if we're a handfed gun
                        this.set_bool("doReload", false);
                        actionInterval = 0;
						this.getSprite().SetAnimation("default");
                    }
                }
				if (actionInterval > 0) 
				{
					this.set_f32("perc", 1.0f*actionInterval / RELOAD_TIME);
					actionInterval--;			
				} 
				else if(this.get_bool("beginReload"))
				{
                    actionInterval = RELOAD_TIME;
                    this.set_bool("beginReload", false);
                    this.set_bool("doReload", true);
					//sound only plays when we load whole clip at once
					//it's either reloading by X rounds a time and this X = CLIP or reloading full magazine (RHR variable = 0)
					//it's made so when rifle reloads by 5 (it's capacity) instead of full clip reload gun actually plays load sound
                    if((RELOAD_HANDFED_ROUNDS <= 0 || RELOAD_HANDFED_ROUNDS == CLIP) && LOAD_SOUND != "")
						sprite.PlaySound(LOAD_SOUND,1.0f,float(90+XORRandom(21))*0.01f);
                    this.getSprite().SetAnimation("reload");
                    
                    if(EMPTY_RELOAD)
                    if(isServer()){
                        this.set_u8("clip",0);
                        CBitStream params;
                        params.write_u8(this.get_u8("clip"));
                        params.write_u8(this.get_u8("total"));
                        this.SendCommand(this.getCommandID("set_clip"),params);
                    }
                    
                    if(CART_SPRITE != ""){
                        int carts = this.get_u8("stored_carts");
                        if(carts > 0){
                            
                            f32 oAngle = aimangle;
                            if(holder.isFacingLeft())oAngle = (oAngle % 360) + 180;
                            
                            Vec2f fromBarrel = Vec2f((holder.isFacingLeft() ? -1 : 1),0);
                            fromBarrel = fromBarrel.RotateBy(aimangle);
                            fromBarrel *= 7;
                            
                            //for(int c = 0;c < carts;c++)ParticleCase2(CART_SPRITE,sprite.getWorldTranslation() + fromBarrel,oAngle);
							MakeEmptyShellParticle(this, CART_SPRITE, false, carts);
                            
                            this.set_u8("stored_carts",0);
                        }
                    }
                    
                    if(CLIP_SPRITE != ""){
                        makeGibParticle(CLIP_SPRITE,this.getPosition(),Vec2f((holder.isFacingLeft() ? -1 : 1),-1),0,0,Vec2f(8, 8),1.0f,0,"empty_magazine");
                    }
				} 
				else if(this.get_bool("doReload")) 
				{
                    if(RELOAD_HANDFED_ROUNDS > 0){
						bool special_reload = RELOAD_HANDFED_ROUNDS == CLIP;
                        if(canReload(this,holder)){
                            reload(this, holder);
							//same here if reloading by X where X isn't equal to CLIP we play sound otherwise we don't because we did eariler
                            if(LOAD_SOUND != "" && !special_reload)sprite.PlaySound(LOAD_SOUND,1.0f,float(90+XORRandom(21))*0.01f);
                            actionInterval = RELOAD_TIME;
							if (special_reload) actionInterval = 0;
                        } else {
                            if(RELOAD_SOUND != "")sprite.PlaySound(RELOAD_SOUND,1.0f,float(90+XORRandom(21))*0.01f);
                            this.set_bool("doReload", false);
                            this.getSprite().SetAnimation("default");
                        }
                    } else {
                        reload(this, holder);
                        if(RELOAD_SOUND != "")sprite.PlaySound(RELOAD_SOUND,1.0f,float(90+XORRandom(21))*0.01f);
                        this.set_bool("doReload", false);
                        this.getSprite().SetAnimation("default");
                    }
				}
				// doesn't shoot if has buttons or menus
				else if (!(getHUD().hasButtons() || getHUD().hasMenus()) && (holder.isKeyJustPressed(key_action1) || (FIRE_AUTOMATIC && holder.isKeyPressed(key_action1)) || this.get_u8("rounds_left_in_burst") > 0))
				{
					//we don't need this warzone shit :<
                    /* if(this.isInWater()) 
					{
						sprite.PlaySound("DryShot.ogg",1.0f,float(90+XORRandom(21))*0.01f);
						MakeBangEffect(this, "click");
						actionInterval = NO_AMMO_INTERVAL;
                        this.set_u8("rounds_left_in_burst",0);
					}		
					else*/ if(clip > 0) 
					{
						actionInterval = Maths::Max(FIRE_INTERVAL,1); //0 is unacceptable >:[
                        if(BURST > 1){
                            int burst_rounds = this.get_u8("rounds_left_in_burst");
                            if(burst_rounds > 1){
                                this.sub_u8("rounds_left_in_burst",1);
                                actionInterval = BURST_INTERVAL;
                            } else 
                            if(burst_rounds == 1){
                                this.sub_u8("rounds_left_in_burst",1);
                            } else {
                                this.set_u8("rounds_left_in_burst",BURST-1);
                                actionInterval = BURST_INTERVAL;
                            }
                        }
                        
						Vec2f fromBarrel = Vec2f(flip_factor*MUZZLE_OFFSET.x,MUZZLE_OFFSET.y);
						fromBarrel = fromBarrel.RotateBy(aimangle);
						this.set_Vec2f("fromBarrel", fromBarrel);
						
						
                        
						//if (!(this.getMap().rayCastSolidNoBlobs(this.getPosition() + fromBarrel, holder.getPosition())))
						//todo: this should allow shoot the gun but bullet shouldn't spawn at all
						{
							shootGun(this.getNetworkID(), aimangle, holder.getNetworkID(), sprite.getWorldTranslation() + fromBarrel);
							this.add_u16("shotcount", 1);
							//MakeBangEffect(this, ONOMATOPOEIA, 1.0f, false, Vec2f((XORRandom(10)-5) * 0.1, -(3/2)), fromBarrel + Vec2f(XORRandom(11)-5,-XORRandom(4)-1));
						}
					}
					else
					{
                        this.set_u8("rounds_left_in_burst",0);
						actionInterval = NO_AMMO_INTERVAL;
                        sprite.PlaySound("DryShot.ogg",1.0f,float(90+XORRandom(21))*0.01f);
                        MakeBangEffect(this, "click");
					}
				}
				else
				{
					//print("shotcount"+this.get_u16("shotcount"));
					// if gun doesn't shoot we set shootcount to zeroo
					this.set_u16("shotcount", 0);
				}
				//todo: spam check
				//if (holder.isKeyJustReleased(key_action1))
                //{
				//	actionInterval = 15;
				//	Sound::Play("steam", this.getPosition(), 1.0, 1.0f + (XORRandom(10)-5)*0.01);
				//}
				
				Vec2f hitPos;
				Vec2f dir = Vec2f((flip ? -1 : 1), 0.0f).RotateBy(aimangle);
				Vec2f startPos = this.getPosition();
				Vec2f endPos = startPos + dir * 300;
			
				HitInfo@[] hitInfos;
				bool mapHit = getMap().rayCastSolid(startPos, endPos, hitPos);
				f32 length = (hitPos - startPos).Length();
				bool blobHit = getMap().getHitInfosFromRay(startPos, aimangle + (flip ? 180.0f : 0.0f), length, this, @hitInfos);
			
				CBlob@ light = getBlobByNetworkID(this.get_u16("remote_netid"));
				if (light !is null)
				{
					light.setPosition(hitPos);
					this.set_Vec2f("startPos", startPos);
					this.set_Vec2f("hitPos", hitPos);
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

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	removeLight(this);
}

void onThisRemoveFromInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	//makeLight(this);
}

void makeLight(CBlob@ this)
{
	if (isServer())
	{
		CBlob@ blob = server_CreateBlobNoInit("laser_point");
		blob.set_u16("remote_netid", this.getNetworkID());
		blob.setPosition(this.getPosition());

		blob.Init();

		this.set_u16("remote_netid", blob.getNetworkID());
	}
}

void removeLight(CBlob@ this)
{
	CBlob@ light = getBlobByNetworkID(this.get_u16("remote_netid"));
	if (light !is null) light.server_Die();
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	//renders only when a gun's reloading and if the gun is attached
	if (!blob.get_bool("doReload") || blob.get_u8("clip") == CLIP || !blob.isAttached()) return;
	
	const f32 scalex = getDriver().getResolutionScaleFactor();
	const f32 zoom = getCamera().targetDistance * scalex;
	Vec2f pos2d =  blob.getInterpolatedScreenPos() + Vec2f(0.0f, (-blob.getHeight() - 20.0f) * zoom);
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

f32 getAimAngle( CBlob@ this, CBlob@ holder )
{
	const bool flip = holder.isFacingLeft();
	const f32 flip_factor = flip ? -1 : 1;
	this.set_Vec2f("gun_pos", (Vec2f(this.get_Vec2f("shoulder").x, SPRITE_TRANSLATION.y + MUZZLE_OFFSET.y)));
 	Vec2f aimvector = holder.getAimPos() - holder.getPosition() + this.get_Vec2f("gun_pos")
		//+ (flip ? Vec2f(8*flip_factor,0) : Vec2f_zero)
		+ (this.hasTag("trench_aim") ? Vec2f(0,-trench_aim.y) : Vec2f_zero);//TODO this is a duplicate
	//print("gun range should be " + aimvector.getLength());
    return holder.isFacingLeft() ? -aimvector.Angle()+180.0f : -aimvector.Angle();
}

f32 getAimAngle2(CBlob@ this, CBlob@ player)
{
	bool facing_left = this.isFacingLeft();
	
	Vec2f dir = player.getAimPos() - this.getPosition();
	f32 angle = dir.Angle();
	dir.Normalize();
	
	bool failed = true;

	if (player !is null)
	{
		Vec2f aim_vec = player.getPosition() - player.getAimPos();

		if (this.isAttached())
		{
			//print("hi");
			if (facing_left) { 
				aim_vec.x = -aim_vec.x; 
				angle = (-(aim_vec).getAngle() + 180.0f);
			}
			else
			{
				angle = (-(aim_vec).getAngle() + 180.0f);
			}
		}
		else
		{
			if ((!facing_left && aim_vec.x < 0) ||
			        (facing_left && aim_vec.x > 0))
			{
				if (aim_vec.x > 0) { aim_vec.x = -aim_vec.x; }

				angle = (-(aim_vec).getAngle() + 180.0f);
				//angle = Maths::Max(-90.0f, Maths::Min(angle, 50.0f));
			}
			else
			{
				this.SetFacingLeft(!facing_left);
			}
		}
	}

	return angle;
}