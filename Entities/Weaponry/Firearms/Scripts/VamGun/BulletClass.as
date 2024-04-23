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
#include "WhatSHouldProjHit"

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
	f32 InitialRange;
    
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
		InitialRange= Range;
		Pierces  	= vars.B_PENETRATION;
			
        //Ricochet 	= (XORRandom(100) < vars.RICOCHET_CHANCE);
		Ricochet = false;
        
        //Sound Vars
        FleshHitSound  = vars.S_FLESH_HIT;
        ObjectHitSound = vars.S_OBJECT_HIT;
        
        //Sprite Vars
        //Texture = vars.BULLET_SPRITE+".png";
		Texture = "f2456f00.png";
		if (vars.BULLET_SPRITE=="cluster")
			Texture = "2252aa09.png";
		else if (vars.BULLET_SPRITE=="tank")
			Texture = "3a6d9c40.png";
		else if (vars.BULLET_SPRITE=="mantis_bullet")
			Texture = "bullet_ruhm.png";
		
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
		//x and y are switched due to poor render logic
		SpriteSize = Vec2f(8, 16);
		f32 sprite_min_x_rate = 1.25f;
		f32 sprite_maz_x_rate = 3;
		//SpriteSize = Vec2f(138, 240);
		if (vars.B_SPEED != 0 && vars.B_SPEED < 30)
			SpriteSize = Vec2f(SpriteSize.x, SpriteSize.y*sprite_min_x_rate);
		else
			SpriteSize = Vec2f(SpriteSize.x*1.0f*(DamageType==HittersKIWI::atr?1.5f:1), Maths::Clamp(SpriteSize.y*(vars.B_SPEED/13), SpriteSize.y*sprite_min_x_rate, SpriteSize.y*sprite_maz_x_rate));
        
		
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
		
		CBlob@ gunBlob = getBlobByNetworkID(gunBlobID);
		if (gunBlob !is null) {
			int AltFire = gunBlob.get_u8("override_alt_fire");
			if(AltFire == AltFire::Unequip)AltFire = vars.ALT_FIRE;
			
			if (AltFire == AltFire::LaserPointer) {
				Range		= vars.RANGE*2;
				InitialRange= Range;
			}
		}

        //@gunBlob   = gun;
        lastDelta = 0;
		
		/* 
		CBlob@ hoomanShooter = getBlobByNetworkID(hoomanBlobID);
		if (hoomanShooter !is null) {
			CBlob@[] blobsAround;
			getMap().getBlobsInRadius(hoomanShooter.getPosition(), 12.0f, @blobsAround);
			for (int counter = 0; counter<blobsAround.size(); ++counter) {
				CBlob@ blob = blobsAround[counter];
				u16 blobID = blob.getNetworkID();
				if (blob.getName()=="sandbag" || blob.hasTag("vehicle")) {
					TargetsPierced.push_back(blobID);
					//break;
				}
			}
		}
		 */
        
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
		if((CurrentPos-StartingPos).Length()>=InitialRange) return true;
		
		if(Range<=0) return true;
		
		if((RenderPos-StartingPos).Length()>SpriteSize.y/40)
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
		Range -= Speed;
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
		
		//Vec2f dir = Vec2f(1, 0).RotateBy(-(curPos - prevPos).Angle());
		bool hooman_is_player = hoomanShooter.hasTag("flesh");
		bool default_start_pos = !gunBlob.hasTag("firearm")||gunBlob.hasTag("cannon");
		bool far_enough = (hoomanShooter.getPosition()-curPos).Length()>SpriteSize.y*4;
		bool shooter_faces_left = hoomanShooter.isFacingLeft();
		Vec2f shoulder_world = hoomanShooter.get_Vec2f("sholder_join_world")+dir*3;
		bool can_fly = default_start_pos||far_enough;
		Vec2f b_start_pos = can_fly?prevPos-dir*Speed*2:(hooman_is_player?shoulder_world:hoomanShooter.getPosition());
		if (!hoomanShooter.isAttachedTo(gunBlob)&&!can_fly)
			b_start_pos += hoomanShooter.getPosition()-gunBlob.getPosition();
		f32 ray_len = default_start_pos||far_enough?(Speed*3):(SpriteSize.y*4);
		
        HitInfo@[] list;
        if(map.getHitInfosFromRay(b_start_pos, -(curPos - prevPos).Angle(), ray_len, hoomanShooter, @list))
        {
			//if (!endBullet)
			
			//if(getBlobByNetworkID(hoomanBlobID) is null) {
			//	@hoomanShooter = getBlobByNetworkID(getRules().get_u16("gunfire_handle"));
			//	if (hoomanShooter is null) return;
			//}			
			
			if (!endBullet)
            for(int a = 0; a < list.length(); a++)
            {
                breakLoop = false;
                HitInfo@ hit = list[a];
                Vec2f hitpos = hit.hitpos;
                CBlob@ blob = @hit.blob;
				bool doExplosion = false;
				bool healthPierce = false;
				//healthPierce = Damage>=100;
                
				if (blob !is null) // blob
                {
                    int hash = blob.getName().getHash();
					f32 blob_full_health = blob.getInitialHealth()*2;
					f32 wood_blob_hits = blob_full_health/5;
					f32 stone_blob_hits = blob_full_health/12;
					healthPierce = (Damage/10)>blob.getHealth()*2;
                    
					switch(hash)
                    {
                        /* case 213968596://Wooden_door
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
                        case 1051619956://warboat_door
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
                        break; */

                        //case 804095823://platform
                        case 804095824://NOT a platform
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
                            if(TargetsPierced.find(blob.getNetworkID()) > -1) continue;
                            
							if (!shouldRaycastHit(blob, -(curPos - prevPos).Angle(), FacingLeft, TeamNum, DamageType, hitpos, StartingPos)) continue;
                            	
							bool frend_team = blob.getTeamNum() == TeamNum;
							
                            CurrentPos = hitpos;
							if (true){//!blob.hasTag("steel")) {
								if(!blob.hasTag("invincible"))
								{
									doExplosion = true;
									if(isServer())
									{
										CPlayer@ p = hoomanShooter.getPlayer();
										int coins = 0;
										//if (!vars.EXPLOSIVE||true)
										f32 old_health = blob.getHealth()*2;
										
										f32 damage_to_recieve = vars.EXPLOSIVE?(vars.EXPL_DAMAGE*(Maths::Max(0.33f, Range/InitialRange))):(Damage/10)*((frend_team&&!(blob.hasTag("dummy")||blob.hasTag("scenary"))&&DamageType!=HittersKIWI::cos_will)?0:1);
										damage_to_recieve = DamageType==HittersKIWI::usar&&blob.hasTag("flesh")?(damage_to_recieve*(1.0f+(CurrentPos-StartingPos).Length()/200)):damage_to_recieve;
										damage_to_recieve = DamageType==HittersKIWI::cos_will&&frend_team&&blob.hasTag("flesh")?(blob.getInitialHealth()):damage_to_recieve;
										//print("Health before bullet "+blob.getHealth());
										f32 health_before = blob.getHealth();
										hoomanShooter.server_Hit(blob, CurrentPos, Vec2f(0, 0)+KB.RotateByDegrees(-angle),
											damage_to_recieve, DamageType);
										//print("		Health after bullet "+blob.getHealth());
										f32 health_after = blob.getHealth();
										
										f32 true_damage = health_before-health_after;
										
										healthPierce = true_damage>health_before||blob.hasTag("scenary")||blob.hasTag("no bullet affecting");
										bool get_damage_reduction = !(blob.hasTag("dummy")||blob.hasTag("scenary")||blob.hasTag("no bullet affecting"));
										
										if (healthPierce&&get_damage_reduction)
											Damage-=true_damage;
										Damage = Maths::Max(1, Damage);
										
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
								if(Damage <= 0 || Pierces <= 0 || blob.hasTag("non_pierceable") || (blob.getCarriedBlob()!is null && blob.getCarriedBlob().hasTag("shield")))
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
                    if(breakLoop)//So we can break while inside the switch
                    {
						if (vars.EXPLOSIVE && doExplosion) {
						} else {
							endBullet = true;
							if (blob !is null && !blob.hasTag("flesh")) {
								string bullet_hit_name = vars.BULLET_SPRITE+"_hit.png";
								if (!CFileMatcher(bullet_hit_name).hasMatch())
									bullet_hit_name = "smg_bullet_hit.png";
								CParticle@ b_hit = ParticleAnimated(bullet_hit_name, hitpos, Vec2f_zero, (StartingPos - hitpos).getAngleDegrees()+(XORRandom(2)*180), 1.0f, 2, 0, true);
								if (b_hit !is null) {
									b_hit.deadeffect = -1;
									b_hit.Z = 1500;
								}
							}
							break;
						}
                    }
                }
                //else
				//TODO: make bullets ricochet from steel things
                if ((blob is null || steelHit)&&!endBullet) {
                    TileType tile = map.getTile(hitpos).type;
					
					bool super_damage = Damage>200;
					bool hitting_solid = map.hasTileFlag(map.getTileOffset(hitpos), Tile::SOLID);
					bool needs_checking = map.isTileGround(tile)||isTileSteel(tile, true);
					bool can_hit_steel = needs_checking&&(super_damage||XORRandom(100)<Maths::Max(1, 0.5f*Damage));
                    
					{
						
						if (isTilePiercable(hitpos, vars)) {
							map.server_DestroyTile(hitpos, 1.0f);
							++TilesPierced;
						} else if (super_damage||!map.isTileGroundStuff(tile)||true) {
							if ((can_hit_steel||!needs_checking) && hitting_solid) {
								doHitTile(hitpos, super_damage?100:(needs_checking?1:Maths::Max(1, Maths::Floor(Damage/15))));
								if (!v_fastrender) {
									if (map.isTileWood(tile))
										makeGibParticle("GenericGibs", hitpos, getRandomVelocity((StartingPos - hitpos).getAngle(), 1.0f + Damage/8, 90.0f) + Vec2f(0.0f, -2.0f), 1, XORRandom(8), Vec2f(8, 8), 2.0f, 0, "", 0);
									else if (map.isTileCastle(tile))
										makeGibParticle("GenericGibs", hitpos, getRandomVelocity((StartingPos - hitpos).getAngle(), 1.0f + Damage/8, 90.0f) + Vec2f(0.0f, -2.0f), 2, 4+XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);									
								}
								//print("tile id "+tile);
								if (tile==203) {
									//print("hellow mapper?");
									//getMap().server_SetTile(hitpos, CMap::tile_wood_back);
								}
								if (Damage==1000)
									DestroyTilesInRadius(hitpos);
								endBullet = true;
							} else if (isTileSteel(tile, true)) {
								//print("hit "+hitpos+", tile "+map.getAlignedWorldPos(hitpos));
								sparks(hitpos, -angle, Damage/5/10, 30);
							}
							//break;
						} else
							endBullet = true;
							
						//if (TilesPierced > 1)
						//	endBullet = true;
						
						//leftover from tries of making accurate tile piercing
						//++steps_between_speed;
						//if (max_steps <= steps_between_speed)
						//	endBullet = true;
							
						if (!endBullet) {
							//hitOnRay(map, hitpos+dir*(map.tilesize), hitpos+dir*(map.tilesize+4));
						}
						
						//CurrentPos = hitpos;
						//endBullet = true;
						doExplosion = true;
						
						
						if (map.isTileWood(tile)&&false) {
							const f32 angle = StartingAimPos * (FacingLeft ? 1 : 1);
							Vec2f dir = Vec2f((FacingLeft ? -1 : 1), 0.0f).RotateBy(angle);
							CurrentPos = getMap().getAlignedWorldPos(hitpos)+dir*12;
							//StartingPos = CurrentPos;
							endBullet = false;
						}
                    }
					
					endBullet = true;
					
					if(!endBullet && /* !map.isTileWood(tile) && !map.isTileGround(tile) &&  */
						!vars.EXPLOSIVE &&
						hitting_solid
						)
					{
						Vec2f tile_aligned = map.getAlignedWorldPos(hitpos);
						f32 new_angle = (hitpos-tile_aligned).getAngle();
						
						const bool flip = hitpos.x > tile_aligned.x;
						const f32 flip_factor = flip ? -1 : 1;
						Vec2f dir = Vec2f(flip_factor, 0).RotateBy(new_angle);
						
                        CurrentPos = tile_aligned-dir*8;
						StartingAimPos = -new_angle*0.5;
                        
						/* 
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
						sparks(hitpos, -angle, Damage/5/10, 30);
                        
                        f32 dotProduct = (2*(Direction.x * FaceVector.x + Direction.y * FaceVector.y));
                        Vec2f RicochetV = ((FaceVector*dotProduct)-Direction);
                        StartingAimPos = RicochetV.getAngle();
                        
                        CurrentPos = prevPos; */
                    }
                    
                    if(!isServer()){
                        Sound::Play(ObjectHitSound, hitpos, 1.5f);
                    }
                }
				if (vars.EXPLOSIVE && doExplosion) {
					//print(""+(Range/InitialRange));
					ExplosionAtPos(
						CurrentPos,
						map,
						vars.EXPL_RADIUS,
						vars.EXPL_DAMAGE*(Maths::Max(0.33f, Range/InitialRange)),
						vars.EXPL_MAP_RADIUS,
						vars.EXPL_MAP_DAMAGE,
						vars.EXPL_RAYCAST,
						vars.EXPL_TEAMKILL,
						hoomanShooter,
						vars.B_HITTER
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
		if (vars.B_HITTER == HittersKIWI::atr &&
			(map.isTileWood(tile) || map.isTileCastle(tile)))
			return true;
		
		//if (map.isTileWood(tile))
		//	return true;
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
        const f32 x = lerp(LastPos.x, CurrentPos.x, blend);//Thanks to goldenGuy for finding this and telling me
        const f32 y = lerp(LastPos.y, CurrentPos.y, blend);
        Vec2f newPos = Vec2f(x,y);
        
        LastPos.x = x;
        LastPos.y = y;
        //End

		f32 angle = Vec2f(CurrentPos.x-newPos.x, CurrentPos.y-newPos.y).getAngleDegrees();//Sets the angle
		
		FirearmVars@ vars;
		gunBlob.get("firearm_vars", @vars);
		Vec2f RenderSize = SpriteSize/2;
		
		if (vars !is null) {
			if (vars.BULLET_SPRITE=="tank")
				RenderSize*=1.3f;
		}
		
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

