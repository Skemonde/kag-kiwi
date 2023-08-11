//Main classes for bullets
#include "BulletCase"
#include "BulletParticle"
#include "KIWI_Hitters"
#include "FirearmVars"
#include "Explosion"
#include "ExplosionAtPos"
#include "MakeExplodeParticles"
#include "ParticleSparks"
#include "CustomBlocks"

const SColor trueWhite = SColor(255,255,255,255);
Driver@ PDriver = getDriver();
const int ScreenX = getDriver().getScreenWidth();
const int ScreenY = getDriver().getScreenWidth();


class BulletObj
{
	u16 hoomanBlobID;
	u16 gunBlobID;

    BulletFade@ Fade;

    Vec2f TrueVelocity;
    Vec2f CurrentPos;
    Vec2f StartingPos;
    Vec2f BulletGrav;
    Vec2f RenderPos;
    Vec2f OldPos;
    Vec2f LastPos;
    Vec2f Gravity;
    Vec2f KB;

    f32 StartingAimPos;
    f32 lastDelta;
	f32 Range;
    
    f32 Damage;
    u8 DamageType;
    
    u16[] TargetsPierced;
    u8 Pierces;
    bool Ricochet;

    u8 TeamNum;
    u8 Speed;
	u8 TilesPierced = 0;

    string FleshHitSound;
    string ObjectHitSound;

    string Texture = "";
    Vec2f SpriteSize;
    

    u8 TimeLeft;

    bool FacingLeft;
	bool DrawBullet;

    
	BulletObj(u16 _hoomanBlobID, u16 _gunBlobID, f32 angle, Vec2f pos, u8 _TeamNum, bool _FacingLeft, FirearmVars@ vars)
	{
        StartingPos = pos;
        CurrentPos = pos;

        //Gun Vars
        BulletGrav	= vars.B_GRAV;
        Damage   	= vars.B_DAMAGE;
        DamageType	= vars.B_HITTER;
        KB       	= vars.B_KB;
		if (vars.B_SPEED != 0)
			Speed	= vars.B_SPEED;
		else
			Speed	= 12*Damage;//vars.B_SPEED
		Speed 	   += XORRandom(vars.B_SPEED_RANDOM+1);
        //TimeLeft 	= vars.B_TTL_TICKS;
        TimeLeft 	= vars.RANGE/Speed;
		Range		= vars.RANGE;
		Pierces  	= vars.B_PENETRATION;
			
        Ricochet 	= (XORRandom(100) < vars.RICOCHET_CHANCE);
        
        //Sound Vars
        FleshHitSound  = vars.S_FLESH_HIT;
        ObjectHitSound = vars.S_OBJECT_HIT;
        
        //Sprite Vars
        //Texture = vars.BULLET_SPRITE+".png";
		Texture = "high_res_18.png";
		
		CRules @rules = getRules();

		if (isClient())
		{
			if (Texture != ""){
	
				Vertex[]@ bullet_vertex;
				rules.get(Texture, @bullet_vertex);
	
				if (bullet_vertex is null)
				{
					Vertex[] vert;
					rules.set(Texture, @vert);
				}
	
				// #blamekag
				if (!rules.exists("VertexBook"))
				{
					string[] book;
					rules.set("VertexBook", @book);
					book.push_back(Texture);
				}
				else
				{
					string[]@ book;
					rules.get("VertexBook", @book);
					book.push_back(Texture);
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
		
			SpriteSize = Vec2f(16, 16);
		SpriteSize = Vec2f(138, 240);
		if (vars.B_SPEED != 0 && vars.B_SPEED < 30)
			SpriteSize = Vec2f(SpriteSize.x, SpriteSize.y);
		else
			SpriteSize = Vec2f(SpriteSize.x*1.3f, Maths::Clamp(SpriteSize.y*(vars.B_SPEED/13), SpriteSize.y*1.25f, SpriteSize.y*4));
        
		
        //Misc Vars
        //@hoomanShooter = humanBlob;
		//hoomanBlobID = humanBlob.getNetworkID();
        FacingLeft = _FacingLeft;
        TeamNum  	= _TeamNum;
        StartingAimPos = angle;
        OldPos     = CurrentPos;
        LastPos    = CurrentPos;
		RenderPos  = CurrentPos;
		DrawBullet = false;
		
		hoomanBlobID = _hoomanBlobID;
		gunBlobID = _gunBlobID;

        //@gunBlob   = gun;
        lastDelta = 0;
		
		CBlob@[] blobsAround;
		getMap().getBlobsInRadius(StartingPos, 8.0f, @blobsAround);
		for (int counter = 0; counter<blobsAround.size(); ++counter) {
			CBlob@ blob = blobsAround[counter];
			u16 blobID = blob.getNetworkID();
			if (blob.getName()=="sandbag") {
				TargetsPierced.push_back(blobID);
				break;
			}
		}
        
        //Fade
        if(!vars.FADE_SPRITE.empty() && !v_fastrender){
			string fadeTexture = vars.FADE_SPRITE;
			if(!fadeTexture.empty()){ //No point even giving ourselves a fade if it doesn't have a texture
				@Fade = BulletFade(CurrentPos);
				Fade.Texture = fadeTexture;
				bullet_holder.addFade(Fade);
			}
		}
	}

    void SetStartAimPos(Vec2f aimPos, bool isFacingLeft)
    {
        Vec2f aimvector = aimPos - CurrentPos;
        StartingAimPos = isFacingLeft ? -aimvector.Angle()+180.0f : -aimvector.Angle();
    }

	int steps_between_speed = 0;
	int max_steps = Maths::Floor(Speed/getMap().tilesize);
    bool onFakeTick(CMap@ map)
    {
        //map.debugRaycasts = true;
        //Time to live check
        //TimeLeft--;
        //if(TimeLeft == 0)
        //{
        //    return true;
        //}
		if((CurrentPos-StartingPos).Length()>=Range) return true;
		
		if((RenderPos-StartingPos).Length()>SpriteSize.x/20)
			DrawBullet = true;        

        //Angle check, some magic stuff
        OldPos = CurrentPos;
        Gravity -= BulletGrav;
		//Gravity = Vec2f(0,0);
        const f32 angle = StartingAimPos * (FacingLeft ? 1 : 1);
        Vec2f dir = Vec2f((FacingLeft ? -1 : 1), 0.0f).RotateBy(angle);
		steps_between_speed = 0;
        CurrentPos = ((dir * Speed) - (Gravity * Speed)) + CurrentPos;
        RenderPos = -((dir * Speed) - (Gravity * Speed)) + CurrentPos;
        TrueVelocity = CurrentPos - OldPos;
        //End

		//CCamera@ camera = getCamera();
		//camera.setPosition(CurrentPos);
		hitOnRay(map, OldPos, CurrentPos);
       
        //End
		
		return false;
    }
	
	void hitOnRay(CMap@ map, Vec2f prevPos, Vec2f curPos) {
		CBlob@ hoomanShooter = getBlobByNetworkID(hoomanBlobID);
		CBlob@ gunBlob = getBlobByNetworkID(gunBlobID);
		if (hoomanShooter is null || gunBlob is null) return;
        FirearmVars@ vars;
		gunBlob.get("firearm_vars", @vars);
		
		const f32 angle = StartingAimPos * (FacingLeft ? 1 : 1);
		Vec2f dir = Vec2f((FacingLeft ? -1 : 1), 0.0f).RotateBy(angle);
		
		bool steelHit = false;
        bool endBullet = false;
        bool breakLoop = false;
		
		if (map.getSectorAtPosition(curPos,"barrier")!is null) {
			endBullet = true;
		}
		
        HitInfo@[] list;
        if(map.getHitInfosFromRay(prevPos, -(curPos - prevPos).Angle(), (prevPos - curPos).Length(), hoomanShooter, @list))
        {
			if (!endBullet)
			
			//if(getBlobByNetworkID(hoomanBlobID) is null) {
			//	@hoomanShooter = getBlobByNetworkID(getRules().get_u16("gunfire_handle"));
			//	if (hoomanShooter is null) return;
			//}
			
            for(int a = 0; a < list.length(); a++)
            {
                breakLoop = false;
                HitInfo@ hit = list[a];
                Vec2f hitpos = hit.hitpos;
                CBlob@ blob = @hit.blob;
				bool doExplosion = false;
				bool healthPierce = false;
				healthPierce = Damage>=100;
                
				if (blob !is null) // blob
                {
                    int hash = blob.getName().getHash();
					f32 blob_full_health = blob.getInitialHealth()*2;
					f32 wood_blob_hits = blob_full_health/5;
					f32 stone_blob_hits = blob_full_health/12;
                    switch(hash)
                    {
                        case 213968596://Wooden_door
                        {
                            if(blob.isCollidable())
                            {
                                CurrentPos = hitpos;
								hoomanShooter.server_Hit(blob, CurrentPos, Vec2f_zero, wood_blob_hits, DamageType);
                                breakLoop = true;
                                Sound::Play(ObjectHitSound, hitpos, 1.5f);
								doExplosion = true;
                            }
                        }
                        break;
						
                        case 1296319959://Stone_door
                        case 916369496://Trapdoor
                        case -112615628://iron_door
                        {
                            if(blob.isCollidable())
                            {
                                CurrentPos = hitpos;
								hoomanShooter.server_Hit(blob, CurrentPos, Vec2f_zero, stone_blob_hits, DamageType);
                                breakLoop = true;
                                Sound::Play(ObjectHitSound, hitpos, 1.5f);
								doExplosion = true;
                            }
                        }
                        break;

                        case 804095823://platform
                        {
                            if(CollidesWithPlatform(blob,TrueVelocity))
                            {
                                CurrentPos = hitpos;
								hoomanShooter.server_Hit(blob, CurrentPos, Vec2f_zero, wood_blob_hits, DamageType);
                                breakLoop = true;
                                Sound::Play(ObjectHitSound, hitpos, 1.5f);
								doExplosion = true;
                            }
                        }
                        break;

                        default:
                        {
                            if(TargetsPierced.find(blob.getNetworkID()) <= -1){
                                //print(blob.getName() + '\n'+blob.getName().getHash()); //useful for debugging new tiles to hit
                                if((	blob.hasTag("builder always hit")
									|| 	blob.getTeamNum()==250
									|| 	blob.hasTag("door")
									|| 	blob.hasTag("bullet_hits"))
									|| 	blob.hasTag("player")
									|| 	blob.hasTag("flesh")
									|| 	blob.hasTag("npc")
									|| 	blob.hasTag("explosive"))
                                {
									bool skip_bones = blob.hasTag("bones") && !(XORRandom(3)==0);
                                    if(blob.getTeamNum() == TeamNum
										//if commander offcier decides to kill an ally - no one shall stop them
										&& DamageType != HittersKIWI::cos_will
										//only with a 33% chance we can hit a skeleton
										|| skip_bones
										//don't shoot NPCs <3
										//naah it's TC - KILL THEM ALL !!!
										//|| blob.hasTag("migrant")
										//pellets don't collide with deads
										|| blob.hasTag("dead") && vars.B_HITTER==HittersKIWI::pellet
										|| !blob.isCollidable()){
                                        continue;
                                    }
									
                                    CurrentPos = hitpos;
									if (true){//!blob.hasTag("steel")) {
										if(!blob.hasTag("invincible"))
										{
											doExplosion = true;
											if(isServer())
											{
												CPlayer@ p = hoomanShooter.getPlayer();
												int coins = 0;
												if (!vars.EXPLOSIVE||true)
													hoomanShooter.server_Hit(blob, CurrentPos, Vec2f(0, 0)+KB.RotateByDegrees(-angle),
														Damage/10+(vars.EXPLOSIVE?XORRandom(130)/10:0), DamageType);
												
												if(blob.hasTag("flesh"))
												{
													//flesh coins
													coins = vars.B_F_COINS;
												}
												else
												{
													//object coins
													coins = vars.B_O_COINS;
												}
	
												if(p !is null)
												{
													p.server_setCoins(p.getCoins() + coins);
												}
											}
											else
											{
												Sound::Play(FleshHitSound,  CurrentPos, 1.5f); 
											}
	
										}
										if (healthPierce)
											Pierces += 1;
										if(Pierces <= 0 || blob.hasTag("non_pierceable") || (blob.getCarriedBlob()!is null && blob.getCarriedBlob().hasTag("shield")))
										{
											breakLoop = true;
										}
										else {
											Pierces-=1;
											TargetsPierced.push_back(blob.getNetworkID());
										}
									} else {
										//steel hit
										steelHit = true;
									}
                                }
                            }
                        }
                    }
                    if(breakLoop)//So we can break while inside the switch
                    {
						if (vars.EXPLOSIVE && doExplosion) {
						} else {
							endBullet = true;
							//break;
						}
                    }
                }
                //else
				//TODO: make bullets ricochet from steel things
                if ((blob is null || steelHit)) {
                    TileType tile = map.getTile(hitpos).type;
					
                    if(Ricochet && !map.isTileWood(tile) && !map.isTileGround(tile) && !vars.EXPLOSIVE){
                        Vec2f tilepos = map.getTileWorldPosition(hit.tileOffset)+Vec2f(4,4);
						const bool flip = hitpos.x > tilepos.x;
						const f32 flip_factor = flip ? -1 : 1;
                        
                        Vec2f Direction = Vec2f(10,0);
                        Direction.RotateByDegrees(-StartingAimPos);
                        Vec2f FaceVector = Vec2f(1,0);
						f32 b_angle = (hitpos-tilepos).getAngleDegrees();
						if (hitpos.y<tilepos.y || hitpos.y>tilepos.y) {
							b_angle = 180 - b_angle;
						} else if (hitpos.x<tilepos.x) {
							b_angle *= -1;
						}
                        FaceVector.RotateByDegrees(Maths::Floor(((hitpos-tilepos).getAngleDegrees()+45.0f)/90.0f)*90);
                        //FaceVector.RotateByDegrees(b_angle);
                        FaceVector.Normalize();
                        //print("FaceVector"+FaceVector);
						if (!steelHit)
							Sound::Play("dirt_ricochet_" + XORRandom(4), hitpos, 0.91 + XORRandom(5)*0.1, 1.0f);
						//ParticleBullet(CurrentPos, TrueVelocity);
						sparks(CurrentPos, -angle, Damage/5, 30);
                        
                        f32 dotProduct = (2*(Direction.x * FaceVector.x + Direction.y * FaceVector.y));
                        Vec2f RicochetV = ((FaceVector*dotProduct)-Direction);
                        StartingAimPos = RicochetV.getAngle();
                        
                        CurrentPos = prevPos;
                        Ricochet = false;
                    } else {
						if (isTilePiercable(hitpos, vars)) {
							map.server_DestroyTile(hitpos, 1.0f);
							++TilesPierced;
						} else if (!map.isTileGroundStuff(tile)) {
							if ((isTileSteel(tile, true)&&XORRandom(100)<(Damage*0.75f)||!isTileSteel(tile, true))&&
								map.hasTileFlag(map.getTileOffset(hitpos), Tile::SOLID)) {
								doHitTile(hitpos, 1);
								if (!v_fastrender) {
									if (map.isTileWood(tile))
										makeGibParticle("GenericGibs", hitpos, getRandomVelocity((StartingPos - hitpos).getAngle(), 1.0f + Damage, 90.0f) + Vec2f(0.0f, -2.0f), 1, XORRandom(8), Vec2f(8, 8), 2.0f, 0, "", 0);
									else if (map.isTileCastle(tile))
										makeGibParticle("GenericGibs", hitpos, getRandomVelocity((StartingPos - hitpos).getAngle(), 1.0f + Damage, 90.0f) + Vec2f(0.0f, -2.0f), 2, 4+XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);									
								}
								//print("tile id "+tile);
								if (tile==203) {
									//print("hellow mapper?");
									//getMap().server_SetTile(hitpos, CMap::tile_wood_back);
								}
							}
							endBullet = true;
							//break;
						}
						//if (TilesPierced > 1)
						//	endBullet = true;
						
						//leftover from tries of making accurate tile piercing
						//++steps_between_speed;
						//if (max_steps <= steps_between_speed)
						//	endBullet = true;
							
						if (!endBullet) {
							//hitOnRay(map, hitpos+dir*(map.tilesize), hitpos+dir*(map.tilesize+4));
						}
						
						CurrentPos = hitpos;
						endBullet = true;
						doExplosion = true;
						
						
						if (map.isTileWood(tile)&&false) {
							const f32 angle = StartingAimPos * (FacingLeft ? 1 : 1);
							Vec2f dir = Vec2f((FacingLeft ? -1 : 1), 0.0f).RotateBy(angle);
							CurrentPos = getMap().getAlignedWorldPos(hitpos)+dir*12;
							//StartingPos = CurrentPos;
							endBullet = false;
						}
                    }
                    
                    if(!isServer()){
                        Sound::Play(ObjectHitSound, hitpos, 1.5f);
                    }
                }
				if (vars.EXPLOSIVE && doExplosion) {
					ExplosionAtPos(
						CurrentPos,
						map,
						vars.EXPL_RADIUS,
						vars.EXPL_DAMAGE,
						vars.EXPL_MAP_RADIUS,
						vars.EXPL_MAP_DAMAGE,
						vars.EXPL_RAYCAST,
						vars.EXPL_TEAMKILL,
						hoomanShooter
					);
					int particle_amount = Maths::Ceil(vars.EXPL_MAP_RADIUS/map.tilesize);
					for (int i = 0; i < particle_amount; i++)
					{
						MakeExplodeParticles(CurrentPos+Vec2f( XORRandom(64) - 32, XORRandom(64) - 32), getRandomVelocity(360/particle_amount*i, XORRandom(220) * 0.01f, 90));
					}
					endBullet = true;
				}
				
				if (endBullet && !v_fastrender && (blob is null || (blob !is null && !blob.hasTag("flesh")))) {
					string bullet_hit_name = vars.BULLET_SPRITE+"_hit.png";
					if (!CFileMatcher(bullet_hit_name).hasMatch())
						bullet_hit_name = "smg_bullet_hit.png";
					CParticle@ b_hit = ParticleAnimated(bullet_hit_name, hitpos, Vec2f_zero, (StartingPos - hitpos).getAngleDegrees()+(XORRandom(2)*180), 1.0f, 2, 0, true);
					if (b_hit !is null) {
						b_hit.deadeffect = -1;
						b_hit.Z = 1500;
					}
				}
            }
        }

        if(endBullet == true)
        {
            Range = 0;
			//TimeLeft = 0;
			//SpriteSize = Vec2f(1, 1);
        }
	}
	
	bool isTilePiercable(Vec2f world_pos, FirearmVars@ vars) {
		return false; // todo: make good piercing logic
		CMap@ map = getMap();
		TileType tile = map.getTile(world_pos).type;
		if (vars.B_HITTER == HittersKIWI::bullet_rifle &&
			(map.isTileWood(tile) || map.isTileCastle(tile)))
			return true;
		
		if (map.isTileWood(tile))
			return true;
		return false;
	}
	
	void doHitTile(Vec2f hitpos, f32 damage) {
		for (int times_we_hit_block = 0; times_we_hit_block < damage; ++times_we_hit_block)
			getMap().server_DestroyTile(hitpos, 1.0f);
	}

    void onRender()//every bullet gets forced to join the queue in onRenders, so we use this to calc to position
    {   
		CBlob@ gunBlob = getBlobByNetworkID(gunBlobID);
		if (gunBlob is null) return;
		if (!DrawBullet) return;
        //Are we on the screen?
        const Vec2f xLast = PDriver.getScreenPosFromWorldPos(LastPos);
        const Vec2f xNew  = PDriver.getScreenPosFromWorldPos(RenderPos);
        if(!(xNew.x > 0 && xNew.x < ScreenX))//Is our main position still on screen?
        {//No, so lets left if we just 'left'
            if(!(xLast.x > 0 && xLast.x < ScreenX))//Was our last position on screen?
            {//No
                if(Fade !is null)Fade.Front = RenderPos;
                return;
            }
        }

        //Lerp
        const float blend = 1 - Maths::Pow(0.5f, getRenderApproximateCorrectionFactor());//EEEE
        const f32 x = lerp(LastPos.x, RenderPos.x, blend);//Thanks to goldenGuy for finding this and telling me
        const f32 y = lerp(LastPos.y, RenderPos.y, blend);
        Vec2f newPos = Vec2f(x,y);
        
        LastPos.x = x;
        LastPos.y = y;
        //End

		f32 angle = Vec2f(RenderPos.x-newPos.x, RenderPos.y-newPos.y).getAngleDegrees();//Sets the angle
		
		FirearmVars@ vars;
		gunBlob.get("firearm_vars", @vars);
		Vec2f RenderSize = SpriteSize/15;
		
		if (vars !is null && vars.EXPLOSIVE)
			RenderSize*=2;
		
        Vec2f TopLeft  = Vec2f(newPos.x + RenderSize.x, newPos.y - RenderSize.y);//New positions
        Vec2f TopRight = Vec2f(newPos.x + RenderSize.x, newPos.y + RenderSize.y);
        Vec2f BotLeft  = Vec2f(newPos.x - RenderSize.x, newPos.y - RenderSize.y);
        Vec2f BotRight = Vec2f(newPos.x - RenderSize.x, newPos.y + RenderSize.y);

        angle = -((angle % 360) + 90);
		
		if(Fade !is null)Fade.Front = newPos;
        
        if(Texture.empty()) return; //No point in trying to render if we have no texture.

        BotLeft.RotateBy( angle,newPos);
        BotRight.RotateBy(angle,newPos);
        TopLeft.RotateBy( angle,newPos);
        TopRight.RotateBy(angle,newPos);   

        Vertex[]@ bullet_vertex;
        if(getRules().get(Texture, @bullet_vertex)){
			bullet_vertex.push_back(Vertex(TopLeft.x,  TopLeft.y,  0, 0, 0, trueWhite)); // top left
			bullet_vertex.push_back(Vertex(TopRight.x, TopRight.y, 0, 1, 0, trueWhite)); // top right
			bullet_vertex.push_back(Vertex(BotRight.x, BotRight.y, 0, 1, 1, trueWhite)); // bot right
			bullet_vertex.push_back(Vertex(BotLeft.x,  BotLeft.y,  0, 0, 1, trueWhite)); // bot left
		}
    }

    
}


class BulletHolder
{
    BulletObj[] bullets;
    BulletFade@[] fade;
    PrettyParticle@[] PParticles;
	BulletHolder(){}

    void FakeOnTick(CRules@ this)
    {
        CMap@ map = getMap();
        for(int a = 0; a < bullets.length(); a++)
        {
            BulletObj@ bullet = bullets[a];
            if(bullet.onFakeTick(map))
            {
                if(bullets[a].Fade !is null)bullets[a].Fade.Front = bullets[a].CurrentPos;
				bullets.removeAt(a);
            }
        }
        //print(bullets.length() + '');
         
        for(int a = 0; a < PParticles.length(); a++)
        {
            if(PParticles[a].ttl == 0)
            {
                PParticles.removeAt(a);
                continue;
            }
            PParticles[a].FakeTick();
        }
		
		for(int a = 0; a < fade.length(); a++)
        {
            if(fade[a].TimeLeft <= 0){
				fade.removeAt(a);
			}
        }
    }

    void addFade(BulletFade@ fadeToAdd)
    {   
        fade.push_back(fadeToAdd);
    }

    void addNewParticle(CParticle@ p,const u8 type)
    {
        PParticles.push_back(PrettyParticle(p,type));
    }
    
    void FillVertexBook()
    {
        for (int a = 0; a < bullets.length(); a++)
		{
			bullets[a].onRender();
		}
		for (int a = 0; a < fade.length(); a++)
		{
			fade[a].onRender();
		}
    }

    void AddNewObj(BulletObj@ this)
    {
        CMap@ map = getMap();
        this.onFakeTick(map);
        bullets.push_back(this);
    }
    
	void Clean()
	{
		bullets.clear();
	}

    int ArrayCount()
	{
		return bullets.length();
	}
}


const float lerp(float v0, float v1, float t)
{
	//return (1 - t) * v0 + t * v1; //Golden guys version of lerp
    return v0 + t * (v1 - v0); //vams version
}


const bool CollidesWithPlatform(CBlob@ blob, const Vec2f velocity)//Stolen from rock.as
{
	const f32 platform_angle = blob.getAngleDegrees();	
	Vec2f direction = Vec2f(0.0f, -1.0f);
	direction.RotateBy(platform_angle);
	const float velocity_angle = direction.AngleWith(velocity);

	return !(velocity_angle > -100.0f && velocity_angle < 100.0f);
}

