//Main classes for bullets
#include "BulletCase"
#include "BulletParticle"
#include "HittersKIWI"
#include "FirearmVars"
#include "Explosion"
#include "ExplosionAtPos"
#include "MakeExplodeParticles"

const SColor trueWhite = SColor(255,255,255,255);
Driver@ PDriver = getDriver();
const int ScreenX = getDriver().getScreenWidth();
const int ScreenY = getDriver().getScreenWidth();


class BulletObj
{
    CBlob@ hoomanShooter;
    CBlob@ gunBlob;

    BulletFade@ Fade;

    Vec2f TrueVelocity;
    Vec2f CurrentPos;
    Vec2f BulletGrav;
    Vec2f RenderPos;
    Vec2f OldPos;
    Vec2f LastPos;
    Vec2f Gravity;
    Vec2f KB;

    f32 StartingAimPos;
    f32 lastDelta;
    
    f32 Damage;
    u8 DamageType;
    
    u16[] TargetsPierced;
    u8 Pierces;
    bool Ricochet;

    u8 TeamNum;
    u8 Speed;

    string FleshHitSound;
    string ObjectHitSound;

    string Texture = "";
    Vec2f SpriteSize;
    

    u8 TimeLeft;

    bool FacingLeft;


    
	BulletObj(CBlob@ humanBlob, CBlob@ gun, f32 angle, Vec2f pos)
	{
        CurrentPos = pos;
		FirearmVars@ vars;
		gun.get("firearm_vars", @vars);

        //Gun Vars
        BulletGrav	= vars.B_GRAV;
        Damage   	= vars.B_DAMAGE;
        DamageType	= vars.B_HITTER;
        TimeLeft 	= vars.B_TTL_TICKS;
        KB       	= vars.B_KB;
		if (vars.B_SPEED != 0)
			Speed	= vars.B_SPEED;
		else
			Speed	= 12*Damage+XORRandom(vars.B_SPEED_RANDOM+1);//vars.B_SPEED
        Pierces  	= vars.B_PENETRATION;
			
        Ricochet 	= (XORRandom(100) < vars.RICOCHET_CHANCE);
        
        //Sound Vars
        FleshHitSound  = vars.S_FLESH_HIT;
        ObjectHitSound = vars.S_OBJECT_HIT;
        
        //Sprite Vars
        Texture = vars.BULLET_SPRITE;
		if (vars.B_SPEED != 0)
			SpriteSize = Vec2f(16, 16);
		else
			SpriteSize = Vec2f(16, Maths::Clamp(16*Damage, 20, 64));
        
        //Misc Vars
        @hoomanShooter = humanBlob;
        FacingLeft = hoomanShooter.isFacingLeft();
        TeamNum  	= hoomanShooter.getTeamNum();
        StartingAimPos = angle;
        OldPos     = CurrentPos;
        LastPos    = CurrentPos;
		RenderPos  = CurrentPos;

        @gunBlob   = gun;
        lastDelta = 0;
        
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

    bool onFakeTick(CMap@ map)
    {
        //map.debugRaycasts = true;
        //Time to live check
        TimeLeft--;
        if(TimeLeft == 0)
        {
            return true;
        }
        //End
        FirearmVars@ vars;
		gunBlob.get("firearm_vars", @vars);
        

        //Angle check, some magic stuff
        OldPos = CurrentPos;
        Gravity -= BulletGrav;
		//Gravity = Vec2f(0,0);
        const f32 angle = StartingAimPos * (FacingLeft ? 1 : 1);
        Vec2f dir = Vec2f((FacingLeft ? -1 : 1), 0.0f).RotateBy(angle);
        CurrentPos = ((dir * Speed) - (Gravity * Speed)) + CurrentPos;
        TrueVelocity = CurrentPos - OldPos;
        //End

		bool steelHit = false;
        bool endBullet = false;
        bool breakLoop = false;
        HitInfo@[] list;
        if(map.getHitInfosFromRay(OldPos, -(CurrentPos - OldPos).Angle(), (OldPos - CurrentPos).Length(), hoomanShooter, @list))
        {
            for(int a = 0; a < list.length(); a++)
            {
                breakLoop = false;
                HitInfo@ hit = list[a];
                Vec2f hitpos = hit.hitpos;
                CBlob@ blob = @hit.blob;
				bool doExplosion = false;
                
				if (blob !is null) // blob
                {
                    int hash = blob.getName().getHash();
                    switch(hash)
                    {
                        case 1296319959://Stone_door
                        case 213968596://Wooden_door
                        case 916369496://Trapdoor
                        case -637068387://steelblock
                        {
                            if(blob.isCollidable())
                            {
                                CurrentPos = hitpos;
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
                                if((blob.hasTag("player") || blob.hasTag("flesh") || blob.hasTag("bullet_hits")) && blob.isCollidable())
                                {
									bool skip_bones = blob.hasTag("bones") && !(XORRandom(3)==0);
                                    if(blob.getTeamNum() == TeamNum
										//if commander offcier decides to kill an ally - no one shall stop them
										&& DamageType != HittersKIWI::cos_will
										//we always hit dummy
										&& !blob.hasTag("dummy")
										//only with a 33% chance we can hit a skeleton
										|| skip_bones
										//don't shoot NPCs <3
										|| blob.hasTag("migrant")){
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
												if (!vars.EXPLOSIVE)
													hoomanShooter.server_Hit(blob, CurrentPos, Vec2f(0, 0)+KB.RotateByDegrees(-angle), Damage, DamageType);
												else
													hoomanShooter.server_Hit(blob, CurrentPos, Vec2f(0, 0)+KB.RotateByDegrees(-angle), vars.EXPL_DAMAGE, HittersKIWI::boom);
												
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
										if(Pierces <= 0 || blob.hasTag("non_pierceable"))breakLoop = true;
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
							break;
						}
                    }
                }
                //else
				//TODO: make bullets ricochet from steel things
                if (blob is null || steelHit) { 
                    
                    if(Ricochet){
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
                        print("FaceVector"+FaceVector);
						if (!steelHit)
							Sound::Play("dirt_ricochet_" + XORRandom(4), hitpos, 0.91 + XORRandom(5)*0.1, 1.0f);
                        
                        f32 dotProduct = (2*(Direction.x * FaceVector.x + Direction.y * FaceVector.y));
                        Vec2f RicochetV = ((FaceVector*dotProduct)-Direction);
                        StartingAimPos = RicochetV.getAngle();
                        
                        CurrentPos = OldPos;
                        Ricochet = false;
                    } else {
                        CurrentPos = hitpos;
                        endBullet = true;
                        ParticleBullet(CurrentPos, TrueVelocity);
						doExplosion = true;
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
            }
        }

        if(endBullet == true)
        {
            TimeLeft = 1;
        }
       
        //End
		
		return false;
    }

    void onRender()//every bullet gets forced to join the queue in onRenders, so we use this to calc to position
    {   
        //Are we on the screen?
        const Vec2f xLast = PDriver.getScreenPosFromWorldPos(LastPos);
        const Vec2f xNew  = PDriver.getScreenPosFromWorldPos(CurrentPos);
        if(!(xNew.x > 0 && xNew.x < ScreenX))//Is our main position still on screen?
        {//No, so lets left if we just 'left'
            if(!(xLast.x > 0 && xLast.x < ScreenX))//Was our last position on screen?
            {//No
                if(Fade !is null)Fade.Front = CurrentPos;
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
		
        Vec2f TopLeft  = Vec2f(newPos.x - SpriteSize.x, newPos.y + SpriteSize.y);//New positions
        Vec2f TopRight = Vec2f(newPos.x - SpriteSize.x, newPos.y - SpriteSize.y);
        Vec2f BotLeft  = Vec2f(newPos.x + SpriteSize.x, newPos.y + SpriteSize.y);
        Vec2f BotRight = Vec2f(newPos.x + SpriteSize.x, newPos.y - SpriteSize.y);

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

	return !(velocity_angle > -90.0f && velocity_angle < 90.0f);
}

