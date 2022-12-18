#include "BulletTrails.as";
#include "BulletClass.as";
#include "BulletCase.as";

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
    Render::addScript(Render::layer_prehud, "BulletMain", "GUIStuff", 0.0f);
    
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
                    Vec2f mouse_pos = getControls().getInterpMouseScreenPos();
                    Vec2f ammos_offset = Vec2f(0, -32);
                    Vec2f digit = Vec2f(5, 7);
                    
                    uint8 clip = b.get_u8("clip");
                    uint8 clipsize = b.get_u8("clip_size");
                    uint8 total = b.get_u8("total");//get clip and ammo total for easy access later
                        
                    if (getHUD().hasButtons())
                    {
                        getHUD().SetDefaultCursor();
                    }
                    else
                    {
                        // set cursor
                        getHUD().SetCursorImage("AimCrossCircle.png", Vec2f(16, 16));
                        getHUD().SetCursorOffset(Vec2f(-24, -24));
                    }

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
                            Yellow = SColor(255,255,255,0),
                            Red = SColor(255,255,0,0);
                        
                        if (clip <= (clipsize/2)) //when clip is only half-full
                        {
                            if (clip < 1) UnitsCol = Red; //when clip doesn't have ammo AT ALL
                            else UnitsCol = Yellow;
                            
                            Col = Yellow;
                        }
                        else
                        {
                            UnitsCol = White;
                            Col = White;
                        }
                        
                        Vertex[] current_digit_units;
                        
                        current_digit_units.push_back(Vertex(mouse_pos.x + ammos_offset.x - digit.x - 10,
                            mouse_pos.y + ammos_offset.y + digit.y, 1, 0, 1, UnitsCol)); //top left
                        current_digit_units.push_back(Vertex(mouse_pos.x + ammos_offset.x + digit.x - 10,
                            mouse_pos.y + ammos_offset.y + digit.y, 1, 1, 1, UnitsCol)); //top right
                        current_digit_units.push_back(Vertex(mouse_pos.x + ammos_offset.x + digit.x - 10,
                            mouse_pos.y + ammos_offset.y - digit.y, 1, 1, 0, UnitsCol)); //bot right
                        current_digit_units.push_back(Vertex(mouse_pos.x + ammos_offset.x - digit.x - 10,
                            mouse_pos.y + ammos_offset.y - digit.y, 1, 0, 0, UnitsCol)); //bot left
                        
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
                            mouse_pos.y + ammos_offset.y + digit.y, 1, 0, 1, White)); //top left
                        char_slash.push_back(Vertex(mouse_pos.x + ammos_offset.x + digit.x,
                            mouse_pos.y + ammos_offset.y + digit.y, 1, 1, 1, White)); //top right
                        char_slash.push_back(Vertex(mouse_pos.x + ammos_offset.x + digit.x,
                            mouse_pos.y + ammos_offset.y - digit.y, 1, 1, 0, White)); //bot right
                        char_slash.push_back(Vertex(mouse_pos.x + ammos_offset.x - digit.x,
                            mouse_pos.y + ammos_offset.y - digit.y, 1, 0, 0, White)); //bot left
                            
                        Vertex[] out_of_hundreds;
                        
                        out_of_hundreds.push_back(Vertex(mouse_pos.x + ammos_offset.x - digit.x + out_of_hundreds_offset,
                            mouse_pos.y + ammos_offset.y + digit.y, 1, 0, 1, White)); //top left
                        out_of_hundreds.push_back(Vertex(mouse_pos.x + ammos_offset.x + digit.x + out_of_hundreds_offset,
                            mouse_pos.y + ammos_offset.y + digit.y, 1, 1, 1, White)); //top right
                        out_of_hundreds.push_back(Vertex(mouse_pos.x + ammos_offset.x + digit.x + out_of_hundreds_offset,
                            mouse_pos.y + ammos_offset.y - digit.y, 1, 1, 0, White)); //bot right
                        out_of_hundreds.push_back(Vertex(mouse_pos.x + ammos_offset.x - digit.x + out_of_hundreds_offset,
                            mouse_pos.y + ammos_offset.y - digit.y, 1, 0, 0, White)); //bot left
                            
                        Vertex[] out_of_tens;
                        
                        out_of_tens.push_back(Vertex(mouse_pos.x + ammos_offset.x - digit.x + out_of_tens_offset,
                            mouse_pos.y + ammos_offset.y + digit.y, 1, 0, 1, White)); //top left
                        out_of_tens.push_back(Vertex(mouse_pos.x + ammos_offset.x + digit.x + out_of_tens_offset,
                            mouse_pos.y + ammos_offset.y + digit.y, 1, 1, 1, White)); //top right
                        out_of_tens.push_back(Vertex(mouse_pos.x + ammos_offset.x + digit.x + out_of_tens_offset,
                            mouse_pos.y + ammos_offset.y - digit.y, 1, 1, 0, White)); //bot right
                        out_of_tens.push_back(Vertex(mouse_pos.x + ammos_offset.x - digit.x + out_of_tens_offset,
                            mouse_pos.y + ammos_offset.y - digit.y, 1, 0, 0, White)); //bot left
                            
                        Vertex[] out_of_units;
                        
                        out_of_units.push_back(Vertex(mouse_pos.x + ammos_offset.x - digit.x + out_of_units_offset,
                            mouse_pos.y + ammos_offset.y + digit.y, 1, 0, 1, White)); //top left
                        out_of_units.push_back(Vertex(mouse_pos.x + ammos_offset.x + digit.x + out_of_units_offset,
                            mouse_pos.y + ammos_offset.y + digit.y, 1, 1, 1, White)); //top right
                        out_of_units.push_back(Vertex(mouse_pos.x + ammos_offset.x + digit.x + out_of_units_offset,
                            mouse_pos.y + ammos_offset.y - digit.y, 1, 1, 0, White)); //bot right
                        out_of_units.push_back(Vertex(mouse_pos.x + ammos_offset.x - digit.x + out_of_units_offset,
                            mouse_pos.y + ammos_offset.y - digit.y, 1, 0, 0, White)); //bot left
                        
                        Render::RawQuads("digit" + FindDigit(clip, 0) + ".png", current_digit_units);
                        if (clip > 9) Render::RawQuads("digit" + FindDigit(clip, 1) + ".png", current_digit_tens);
                        if (clip > 99) Render::RawQuads("digit" + FindDigit(clip, 2) + ".png", current_digit_hundreds);
                        
                        Render::RawQuads("char_slash.png", char_slash);
                        
                        if (clipsize > 99) Render::RawQuads("digit" + FindDigit(clipsize, 2) + ".png", out_of_hundreds);
                        if (clipsize > 9) Render::RawQuads("digit" + FindDigit(clipsize, 1) + ".png", out_of_tens);
                        Render::RawQuads("digit" + FindDigit(clipsize, 0) + ".png", out_of_units);
                        
                        //GUI::DrawIcon("piwo.png", Vec2f(mouse_pos.x + 32, mouse_pos.y), getCamera().targetDistance * getDriver().getResolutionScaleFactor());
                    }
                }
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
            f32 angle = params.read_f32();
            const Vec2f pos = params.read_Vec2f();
            
            const f32 spread  = float(gunBlob.get_u8("spread"))*0.5f;
            const u8 b_count = gunBlob.get_u8("b_count");
            
            if(gunBlob.get_bool("uniform_spread")){
                const f32 random_spacing = float(spread*2)/float(b_count);
            
                for(u8 a = 0; a < b_count; a++)
                {
                    f32 tempAngle = angle-spread+random_spacing*0.5f+random_spacing*a;
                    tempAngle += r.NextRanged(2) != 0 ? -r.NextRanged(random_spacing*0.5f) : r.NextRanged(random_spacing*0.5f);
                    BulletObj@ bullet = BulletObj(hoomanBlob,gunBlob,tempAngle,pos);
                    bullet_holder.AddNewObj(bullet);
                }
            } else {
                for(u8 a = 0; a < b_count; a++){
                    f32 tempAngle = angle + (r.NextRanged(2) != 0 ? -r.NextRanged(spread) : r.NextRanged(spread));
                    BulletObj@ bullet = BulletObj(hoomanBlob,gunBlob,tempAngle,pos);
                    bullet_holder.AddNewObj(bullet);
                }
            }

            if(isServer()){
                gunBlob.sub_u8("clip",1);
                CBitStream params;
                params.write_u8(gunBlob.get_u8("clip"));
                params.write_u8(gunBlob.get_u8("total"));
                gunBlob.SendCommand(gunBlob.getCommandID("set_clip"),params);
            }
            gunBlob.getSprite().PlaySound(gunBlob.get_string("sound"));
			
            string cartSpr = gunBlob.get_string("cart_sprite");
            if(cartSpr != ""){
                if(gunBlob.get_bool("self_ejecting")){
                    if(hoomanBlob.isFacingLeft())
                    {
                        f32 oAngle = (angle % 360) + 180;
                        ParticleCase2(cartSpr,gunBlob.getPosition(),oAngle);
                    }
                    else
                    {
                        ParticleCase2(cartSpr,gunBlob.getPosition(),angle);
                    }
                } else {
                    gunBlob.add_u8("stored_carts",1);
                }
            }
        }
    }
}