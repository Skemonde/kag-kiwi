#include "GunStandard.as";
#include "MakeBangEffect.as";
#include "BulletCase.as";

const uint8 NO_AMMO_INTERVAL = 5;
u8 reloadCMD, setClipCMD;
 

void onInit(CBlob@ this) 
{
    reloadCMD = this.addCommandID("reload");
    this.addCommandID("set_clip");

    //Only initialise variables here that things outside of the gun need to access smh
    this.set_u8("clip", CLIP);
    this.set_u8("total", TOTAL);
	this.set_u8("clip_size", CLIP);

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
    
	this.set_f32("damage"      ,B_DAMAGE);
    this.set_u8("damage_type"  ,DMG_TYPE);
	this.set_u16("coins_flesh" ,B_F_COINS);
	this.set_u16("coins_object",B_O_COINS);
	this.set_string("sound"    ,FIRE_SOUND);
    
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
}

void onTick(CBlob@ this) 
{	
    if(isServer() && (getGameTime()+this.getNetworkID()) % 30 == 0){
		this.Sync("clip",true);
		this.Sync("total",true);
	}
	
	if (this.isAttached()) 
    {
		this.getCurrentScript().runFlags &= ~(Script::tick_not_sleeping); 					   		
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");	   		
        CBlob@ holder = point.getOccupied();	

        bool previousTrenchAim = this.hasTag("trench_aim");
        if(holder.isKeyPressed(key_down) && !this.get_bool("doReload")){
            point.offset = this.get_Vec2f("original_offset")+Vec2f(-5,3);
            this.Tag("trench_aim");
        } else {
            point.offset = this.get_Vec2f("original_offset");
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
	        
			Vec2f aimvector = holder.getAimPos() - this.getPosition();
			f32 aimangle = getAimAngle(this,holder);

	        // fire + reload
	        if(holder.isMyPlayer() || (holder.isBot() && isServer()))	
	        {
				//print(aimvector + " | " + aimangle);
	        	//check for clip amount error
				int clip = this.get_u8("clip");
				if(clip > CLIP) 
				{
					this.set_u8("clip", 0);
					clip = 0;
				}
	        	
				CControls@ controls = holder.getControls();

				uint8 actionInterval = this.get_u8("actionInterval");
				
				if (actionInterval <= 0) 
				if(controls !is null) 
				{
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
                    }
                }
                
				if (actionInterval > 0) 
				{
					actionInterval--;			
				} 
				else if(this.get_bool("beginReload"))
				{
                    actionInterval = RELOAD_TIME;
                    this.set_bool("beginReload", false);
                    this.set_bool("doReload", true);
                    if(RELOAD_HANDFED_ROUNDS <= 0 && LOAD_SOUND != "")sprite.PlaySound(LOAD_SOUND,1.0f,float(90+XORRandom(21))*0.01f);
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
							this.set_f32("aimangle", aimangle);
                            if(holder.isFacingLeft())oAngle = (oAngle % 360) + 180;
                            
                            Vec2f fromBarrel = Vec2f((holder.isFacingLeft() ? -1 : 1),0);
                            fromBarrel = fromBarrel.RotateBy(aimangle);
                            fromBarrel *= 7;
                            
                            for(int c = 0;c < carts;c++)ParticleCase2(CART_SPRITE,sprite.getWorldTranslation() + fromBarrel,oAngle);
                            
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
                        if(canReload(this,holder)){
                            reload(this, holder);
                            if(LOAD_SOUND != "")sprite.PlaySound(LOAD_SOUND,1.0f,float(90+XORRandom(21))*0.01f);
                            actionInterval = RELOAD_TIME;
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
				else if (holder.isKeyJustPressed(key_action1) || (FIRE_AUTOMATIC && holder.isKeyPressed(key_action1)) || this.get_u8("rounds_left_in_burst") > 0)
				{
                    if(this.isInWater()) 
					{
						sprite.PlaySound("EmptyClip.ogg",1.0f,float(90+XORRandom(21))*0.01f);
						actionInterval = NO_AMMO_INTERVAL;
                        this.set_u8("rounds_left_in_burst",0);
					}				
					else if(clip > 0) 
					{
						actionInterval = FIRE_INTERVAL;
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
                        
						Vec2f fromBarrel = Vec2f((holder.isFacingLeft() ? -1 : 1)*MUZZLE_OFFSET.x,MUZZLE_OFFSET.y);
						fromBarrel = fromBarrel.RotateBy(aimangle);
                        
                        shootGun(this.getNetworkID(), aimangle, holder.getNetworkID(),sprite.getWorldTranslation() + fromBarrel);
                        
                        MakeBangEffect(this, ONOMATOPOEIA, 1.0f, false, Vec2f((XORRandom(10)-5) * 0.1, -(3/2)), fromBarrel + Vec2f(XORRandom(11)-5,-XORRandom(4)-1));
					}
					else
					{
                        this.set_u8("rounds_left_in_burst",0);
						actionInterval = NO_AMMO_INTERVAL;
                        sprite.PlaySound("DryShot.ogg",1.0f,float(90+XORRandom(21))*0.01f);
                        MakeBangEffect(this, "click");
					}
				}

				this.set_u8("actionInterval", actionInterval);	
			}
			sprite.ResetTransform();
			this.setAngleDegrees(0);
			if(this.get_bool("doReload")){
				//if(holder.isFacingLeft())sprite.RotateBy( 45-60.0f*(f32(this.get_u8("actionInterval"))/f32(RELOAD_TIME)),  Vec2f(-3,3));
				//else sprite.RotateBy( 315+60.0f*(f32(this.get_u8("actionInterval"))/f32(RELOAD_TIME)),  Vec2f(3,3));
                
                if(holder.isFacingLeft())sprite.RotateBy( 45-60.0f,  Vec2f(-3,1));
				else sprite.RotateBy( 315+60.0f,  Vec2f(3,1));
			} else {
				sprite.RotateBy( aimangle, holder.isFacingLeft() ? Vec2f(-3,1) : Vec2f(3,1) );
			}

		}
    } 
    else 
    {
		this.getCurrentScript().runFlags |= Script::tick_not_sleeping; 
    }	
}

f32 getAimAngle( CBlob@ this, CBlob@ holder )
{
 	Vec2f aimvector = holder.getAimPos() - this.getPosition();//TODO this is a duplicate
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