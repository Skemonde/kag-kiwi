#include "BulletTrails"
#include "BulletClass"
#include "BulletCase"
#include "MakeBangEffect"
#include "FirearmVars"

//todo
//u
//v
//vertex textures for bullets
//learn it 
//
//
//
//on join sync bullet count to the new person for each gun, or existing?

Random@ r = Random(12345);//amazing
//used to sync numbers between clients *assuming* they have run it the same amount of times 
//as everybody else
//(which they should UNLESS kag breaks with bad deltas or other weird net issues)
const int cursor_dimensions = 16;

BulletHolder@ bullet_holder = BulletHolder();
int FireGunID;

void onInit(CRules@ this)
{
    if (isClient())
	{
		
		if (!this.exists("VertexBook"))
		{
			// Client vertex book used to grab bullet texture to batch render
			string[] book;
			this.set("VertexBook", @book);
		}
		else
		{
			string[]@ book;
			this.get("VertexBook", @book);

			if (book is null)
			{
				string[] book;
				this.set("VertexBook", @book);
			}
		}
		
	}
    Render::addScript(Render::layer_postworld, "BulletMain", "SeeMeFlyyyy", 0.0f);
    Render::addScript(Render::layer_posthud, "BulletMain", "GUIStuff", 0.0f);
    
    Reset(this);
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void onTick(CRules@ this)
{
	bullet_holder.FakeOnTick(this);
}

void Reset(CRules@ this)
{
    r.Reset(12345);
    FireGunID     = this.addCommandID("fireGun");
}

void SeeMeFlyyyy(int id)//New onRender
{
    CRules@ rules = getRules();

    bullet_holder.FillVertexBook();

    string[]@ vertex_book;
    rules.get("VertexBook", @vertex_book);
    
    for (int a = vertex_book.length()-1; a >= 0; a--)
    {
        Vertex[]@ bulletVertex;
        string texture = vertex_book[a];
        rules.get(texture, @bulletVertex);

        // Sending empty vertex just eats performance because engine does not check :)
        if (bulletVertex.length() < 1) continue;

        Render::SetAlphaBlend(true);
        Render::RawQuads(texture, bulletVertex);
        Render::SetAlphaBlend(false);

        bulletVertex.clear();
    }
}


void GUIStuff(int id)//Second new render
{
    renderScreenpls();
}

SColor white = SColor(255,255,255,255);
SColor eatUrGreens = SColor(255,0,255,0);

#include "FindDigit.as";

void renderScreenpls()//GUI
{
    ///Bullet Ammo
    CBlob@ holder = getLocalPlayerBlob();           
    if(holder !is null) 
    {
        CBlob@ b = holder.getAttachments().getAttachmentPointByName("PICKUP").getOccupied(); 
        CPlayer@ p = holder.getPlayer(); //get player holding this

        if(b !is null && p !is null) 
        {
            if(b.exists("clip"))//make sure its a valid gun
            {
                if(p.isMyPlayer() && b.isAttached())
                {
					FirearmVars@ vars;
					b.get("firearm_vars", @vars);
					if (vars is null) {
						error("Firearm vars is null! at line 127 of BulletMain.as");
						return;
					}
                    Vec2f mouse_pos = getControls().getInterpMouseScreenPos();
                    Vec2f ammos_offset = Vec2f(0, -cursor_dimensions*2 + 7);
                    Vec2f digit = Vec2f(5, 7);
                    
                    uint8 clip = b.get_u8("clip");
                    uint8 clipsize = vars.CLIP;
                    uint8 total = vars.TOTAL;//get clip and ammo total for easy access later

                    Render::SetTransformScreenspace();
                    
                    u8 out_of_hundreds_offset, out_of_tens_offset, out_of_units_offset;
                    
                    if (clipsize > 99)
                    {
                        out_of_hundreds_offset = 12;
                        out_of_tens_offset = out_of_hundreds_offset + 8;
                        out_of_units_offset = out_of_tens_offset + 8;
                    }
                    else if (clipsize > 9)
                    {
                        out_of_tens_offset = 12;
                        out_of_units_offset = out_of_tens_offset + 8;
                    }
                    else
                    {
                        out_of_units_offset = 12;
                    }
                    
                    if (isClient())
                    {
                        // painting digits in cool colors :D
                        SColor UnitsCol, Col,
                            White = SColor(255,255,255,255),
                            Orang = SColor(255,255,200,0),
                            Red = SColor(255,255,0,0);
							
						string cursor_file = "AimCrossCircle.png";
						
                        if (clip <= (clipsize/2))
                        {
                            if (clip < 1) {
								//when clip doesn't have ammo AT ALL
								Col = Red;
								cursor_file = "AimCrossCircleRED.png";
							}
                            else {
								//when clip is only half-full or less
								Col = Orang;
								cursor_file = "AimCrossCircleORANG.png";
							}
                        }
                        else
                        {
                            Col = White;
                        }
						
						//managing a gun cursor
						if (getHUD().hasButtons() || getHUD().hasMenus())
						{
							getHUD().SetDefaultCursor();
						}
						else {
							getHUD().SetCursorImage(cursor_file, Vec2f(cursor_dimensions, cursor_dimensions));
							getHUD().SetCursorOffset(Vec2f(-20, -20));
						}
                        
                        Vertex[] current_digit_units;
                        
                        current_digit_units.push_back(Vertex(mouse_pos.x + ammos_offset.x - digit.x - 10,
                            mouse_pos.y + ammos_offset.y + digit.y, 1, 0, 1, Col)); //top left
                        current_digit_units.push_back(Vertex(mouse_pos.x + ammos_offset.x + digit.x - 10,
                            mouse_pos.y + ammos_offset.y + digit.y, 1, 1, 1, Col)); //top right
                        current_digit_units.push_back(Vertex(mouse_pos.x + ammos_offset.x + digit.x - 10,
                            mouse_pos.y + ammos_offset.y - digit.y, 1, 1, 0, Col)); //bot right
                        current_digit_units.push_back(Vertex(mouse_pos.x + ammos_offset.x - digit.x - 10,
                            mouse_pos.y + ammos_offset.y - digit.y, 1, 0, 0, Col)); //bot left
                        
                        Vertex[] current_digit_tens;
                        
                        current_digit_tens.push_back(Vertex(mouse_pos.x + ammos_offset.x - digit.x - 18,
                            mouse_pos.y + ammos_offset.y + digit.y, 1, 0, 1, Col)); //top left
                        current_digit_tens.push_back(Vertex(mouse_pos.x + ammos_offset.x + digit.x - 18,
                            mouse_pos.y + ammos_offset.y + digit.y, 1, 1, 1, Col)); //top right
                        current_digit_tens.push_back(Vertex(mouse_pos.x + ammos_offset.x + digit.x - 18,
                            mouse_pos.y + ammos_offset.y - digit.y, 1, 1, 0, Col)); //bot right
                        current_digit_tens.push_back(Vertex(mouse_pos.x + ammos_offset.x - digit.x - 18,
                            mouse_pos.y + ammos_offset.y - digit.y, 1, 0, 0, Col)); //bot left
                            
                        Vertex[] current_digit_hundreds;
                        
                        current_digit_hundreds.push_back(Vertex(mouse_pos.x + ammos_offset.x - digit.x - 26,
                            mouse_pos.y + ammos_offset.y + digit.y, 1, 0, 1, Col)); //top left
                        current_digit_hundreds.push_back(Vertex(mouse_pos.x + ammos_offset.x + digit.x - 26,
                            mouse_pos.y + ammos_offset.y + digit.y, 1, 1, 1, Col)); //top right
                        current_digit_hundreds.push_back(Vertex(mouse_pos.x + ammos_offset.x + digit.x - 26,
                            mouse_pos.y + ammos_offset.y - digit.y, 1, 1, 0, Col)); //bot right
                        current_digit_hundreds.push_back(Vertex(mouse_pos.x + ammos_offset.x - digit.x - 26,
                            mouse_pos.y + ammos_offset.y - digit.y, 1, 0, 0, Col)); //bot left
                            
                        Vertex[] char_slash;
                        
                        char_slash.push_back(Vertex(mouse_pos.x + ammos_offset.x - digit.x,
                            mouse_pos.y + ammos_offset.y + digit.y, 1, 0, 1, Col)); //top left
                        char_slash.push_back(Vertex(mouse_pos.x + ammos_offset.x + digit.x,
                            mouse_pos.y + ammos_offset.y + digit.y, 1, 1, 1, Col)); //top right
                        char_slash.push_back(Vertex(mouse_pos.x + ammos_offset.x + digit.x,
                            mouse_pos.y + ammos_offset.y - digit.y, 1, 1, 0, Col)); //bot right
                        char_slash.push_back(Vertex(mouse_pos.x + ammos_offset.x - digit.x,
                            mouse_pos.y + ammos_offset.y - digit.y, 1, 0, 0, Col)); //bot left
                            
                        Vertex[] out_of_hundreds;
                        
                        out_of_hundreds.push_back(Vertex(mouse_pos.x + ammos_offset.x - digit.x + out_of_hundreds_offset,
                            mouse_pos.y + ammos_offset.y + digit.y, 1, 0, 1, Col)); //top left
                        out_of_hundreds.push_back(Vertex(mouse_pos.x + ammos_offset.x + digit.x + out_of_hundreds_offset,
                            mouse_pos.y + ammos_offset.y + digit.y, 1, 1, 1, Col)); //top right
                        out_of_hundreds.push_back(Vertex(mouse_pos.x + ammos_offset.x + digit.x + out_of_hundreds_offset,
                            mouse_pos.y + ammos_offset.y - digit.y, 1, 1, 0, Col)); //bot right
                        out_of_hundreds.push_back(Vertex(mouse_pos.x + ammos_offset.x - digit.x + out_of_hundreds_offset,
                            mouse_pos.y + ammos_offset.y - digit.y, 1, 0, 0, Col)); //bot left
                            
                        Vertex[] out_of_tens;
                        
                        out_of_tens.push_back(Vertex(mouse_pos.x + ammos_offset.x - digit.x + out_of_tens_offset,
                            mouse_pos.y + ammos_offset.y + digit.y, 1, 0, 1, Col)); //top left
                        out_of_tens.push_back(Vertex(mouse_pos.x + ammos_offset.x + digit.x + out_of_tens_offset,
                            mouse_pos.y + ammos_offset.y + digit.y, 1, 1, 1, Col)); //top right
                        out_of_tens.push_back(Vertex(mouse_pos.x + ammos_offset.x + digit.x + out_of_tens_offset,
                            mouse_pos.y + ammos_offset.y - digit.y, 1, 1, 0, Col)); //bot right
                        out_of_tens.push_back(Vertex(mouse_pos.x + ammos_offset.x - digit.x + out_of_tens_offset,
                            mouse_pos.y + ammos_offset.y - digit.y, 1, 0, 0, Col)); //bot left
                            
                        Vertex[] out_of_units;
                        
                        out_of_units.push_back(Vertex(mouse_pos.x + ammos_offset.x - digit.x + out_of_units_offset,
                            mouse_pos.y + ammos_offset.y + digit.y, 1, 0, 1, Col)); //top left
                        out_of_units.push_back(Vertex(mouse_pos.x + ammos_offset.x + digit.x + out_of_units_offset,
                            mouse_pos.y + ammos_offset.y + digit.y, 1, 1, 1, Col)); //top right
                        out_of_units.push_back(Vertex(mouse_pos.x + ammos_offset.x + digit.x + out_of_units_offset,
                            mouse_pos.y + ammos_offset.y - digit.y, 1, 1, 0, Col)); //bot right
                        out_of_units.push_back(Vertex(mouse_pos.x + ammos_offset.x - digit.x + out_of_units_offset,
                            mouse_pos.y + ammos_offset.y - digit.y, 1, 0, 0, Col)); //bot left
                        
                        Render::RawQuads("digit" + FindDigit(clip, 0) + ".png", current_digit_units);
                        if (clip > 9) Render::RawQuads("digit" + FindDigit(clip, 1) + ".png", current_digit_tens);
                        if (clip > 99) Render::RawQuads("digit" + FindDigit(clip, 2) + ".png", current_digit_hundreds);
                        
                        Render::RawQuads("char_slash.png", char_slash);
                        
                        if (clipsize > 99) Render::RawQuads("digit" + FindDigit(clipsize, 2) + ".png", out_of_hundreds);
                        if (clipsize > 9) Render::RawQuads("digit" + FindDigit(clipsize, 1) + ".png", out_of_tens);
                        Render::RawQuads("digit" + FindDigit(clipsize, 0) + ".png", out_of_units);
                    }
                }
				else
					getHUD().SetDefaultCursor();
            }
        }   
    }
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params) {
	if(cmd == FireGunID)
    {
        CBlob@ hoomanBlob = getBlobByNetworkID(params.read_netid());
        CBlob@ gunBlob    = getBlobByNetworkID(params.read_netid());

        if(hoomanBlob !is null && gunBlob !is null)
        {
			FirearmVars@ vars;
			gunBlob.get("firearm_vars", @vars);
			if (vars is null) {
				warn("Firearm vars is null! at line 303 of BulletMain.as");
				return;
			}
			//print("what went wrong?");
			const bool flip = hoomanBlob.isFacingLeft();
			const f32 flip_factor = flip ? -1: 1;
			
            f32 angle = params.read_f32();
            const Vec2f pos = params.read_Vec2f();
            
            const u8 b_count = vars.BUL_PER_SHOT;
            f32 spread  = vars.B_SPREAD;
			u16 shot_count = gunBlob.get_u16("shotcount");
			
			if (b_count == 1 && (!gunBlob.hasTag("NoAccuracyBonus") && vars.FIRE_AUTOMATIC))
			{
				//print("shotcount in BulletMain.as "+shot_count);
				if (shot_count < 2) 
					spread = 1;
				else
					spread = Maths::Min(spread, Maths::Floor(shot_count * 3));
				//print("spread in BulletMain.as "+spread);
				//print("what went wrong? x2");
            }
			
			
            if(vars.UNIFORM_SPREAD && b_count == 1)
			{            
                for(u8 a = 0; a < b_count; a++)
                {
                    //f32 tempAngle = angle-spread+random_spacing*0.5f+random_spacing*a;
                    //tempAngle += r.NextRanged(2) != 0 ? -r.NextRanged(random_spacing*0.5f) : r.NextRanged(random_spacing*0.5f);
					//todo: make it work for both automatic and non-automatic guns
					f32 bulletAngle = (- spread / 2 + spread/Maths::Max(b_count-1, 1)*a)*flip_factor;
					bulletAngle += angle;
					
					if (!gunBlob.exists("bullet_blob")) {
						BulletObj@ bullet = BulletObj(hoomanBlob,gunBlob,bulletAngle,pos);
						bullet_holder.AddNewObj(bullet);
						//print("case 1 what went wrong? x3");
					}
					else if (isServer()){
						//print("case 1 created blob on server");
						bulletAngle += hoomanBlob.isFacingLeft() ? 180 : 0;
						CBlob@ bullet_blob = server_CreateBlobNoInit(gunBlob.get_string("bullet_blob"));
						if (bullet_blob !is null) {
							Vec2f velocity(1,0);
							velocity.RotateBy(bulletAngle);
							velocity *= vars.B_SPEED;
							
							bullet_blob.setPosition(pos);
							bullet_blob.setVelocity(velocity);
							bullet_blob.server_setTeamNum(hoomanBlob.getTeamNum());
							bullet_blob.IgnoreCollisionWhileOverlapped(hoomanBlob);
							bullet_blob.SetDamageOwnerPlayer(hoomanBlob.getPlayer());
						}
						//print("case 1 successfully created blob on server");
					}
                }
            } else {
                for(u8 a = 0; a < b_count; a++){
                    //f32 tempAngle = angle + (r.NextRanged(2) != 0 ? -r.NextRanged(spread) : r.NextRanged(spread));
					f32 bulletAngle = r.NextRanged(spread) * flip_factor - spread / 2 * flip_factor;
					bulletAngle += angle;
					
					if (!gunBlob.exists("bullet_blob")) {
						BulletObj@ bullet = BulletObj(hoomanBlob,gunBlob,bulletAngle,pos);
						bullet_holder.AddNewObj(bullet);
						//print("case 2 what went wrong? x3");
					}
					else if (isServer()){
						//print("case 2 created blob on server");
						bulletAngle += hoomanBlob.isFacingLeft() ? 180 : 0;
						CBlob@ bullet_blob = server_CreateBlobNoInit(gunBlob.get_string("bullet_blob"));
						if (bullet_blob !is null) {
							Vec2f velocity(1,0);
							velocity.RotateBy(bulletAngle);
							velocity *= vars.B_SPEED;
							
							bullet_blob.setPosition(pos);
							bullet_blob.setVelocity(velocity);
							bullet_blob.server_setTeamNum(hoomanBlob.getTeamNum());
							bullet_blob.IgnoreCollisionWhileOverlapped(hoomanBlob);
							bullet_blob.SetDamageOwnerPlayer(hoomanBlob.getPlayer());
						}
						//print("case 2 successfully created blob on server");
					}
                }
            }

            if(isServer() && !gunBlob.hasTag("vehicle") && gunBlob.get_u8("clip") > 0 && gunBlob.get_u8("clip") != 255){
                gunBlob.sub_u8("clip",1);
                CBitStream params;
                params.write_u8(gunBlob.get_u8("clip"));
                params.write_u8(gunBlob.get_u8("total"));
                gunBlob.SendCommand(gunBlob.getCommandID("set_clip"),params);
            }
			const int pitch_range = 10;
			if(gunBlob.hasTag("looped_sound"))
				gunBlob.getSprite().SetEmitSoundPaused(false);
			else
				gunBlob.getSprite().PlaySound(vars.FIRE_SOUND,1.0f,float(100*vars.FIRE_PITCH-pitch_range+XORRandom(pitch_range*2))*0.01f);
			
            if(vars.CART_SPRITE != "") {
                if(!vars.SELF_EJECTING){
                    gunBlob.add_u8("stored_carts",1);
                }
            }
			u16 too_fast = 2; //ticks
			
			if ((vars.FIRE_INTERVAL < too_fast && shot_count % too_fast == 0) || vars.FIRE_INTERVAL >= too_fast)
			{
				gunBlob.set_bool("make_recoil", true);
				MakeBangEffect(gunBlob, vars.ONOMATOPOEIA, 1.0f, false, Vec2f((XORRandom(10)-5) * 0.1, -(3/2)), gunBlob.get_Vec2f("fromBarrel") + Vec2f(XORRandom(11)-5,-XORRandom(4)-1));
			}
			
			gunBlob.add_u16("shotcount", 1);
			gunBlob.set_bool("do_cycle_sound", true);
        }
    }
}