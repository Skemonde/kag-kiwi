#include "FirearmVars"
#include "Skemlib"
#include "RulesCore"
#include "SoldatInfo"

const int CURSOR_DIMENSIONS = 16;

void onInit(CRules@ this)
{
	if (isClient())
	{
		Render::addScript(Render::layer_posthud, "KIWI_PlayerGUI", "GUIStuff", 0.0f);
		Render::addScript(Render::layer_last, "KIWI_PlayerGUI", "CursorStuff", 0.0f);
	}
}

void GUIStuff(int id)
{
	if (g_videorecording) return; // F6
	
	RenderCoins();
	
	RenderInventoryItems();
	
	RenderHealthBar();
	
	RenderFireModeSelector();
	
	RenderMedicSupplies();
	
    RenderVehicleGUI();
}

void CursorStuff(int id)
{
	if (g_videorecording) return; // F6
	
    RenderFirearmCursor();
}

void DrawRing(Vec2f pos, f32 radius, f32 step = 2, SColor Col = SColor(0xffffffff), f32 scale = 1, f32 percent = 1.0f, f32 offset_angle = 0)
{
	Vertex[] ring_dots;
	//step*=scale/2;
	//step*=Maths::Sqrt(radius);
	f32 circle_len = 2 * radius * 3.14f;
	step = 360.0f/circle_len*scale*1.5;
	
	for( f32 idx = 0; idx < 360*percent; idx+=step){
		
		f32 angle = idx;
		
		Vec2f DrawPos = Vec2f(radius,0);
		DrawPos.RotateByDegrees(angle);
		
		DrawPos = pos+DrawPos;
		
		Vec2f screen_dims = Vec2f(getDriver().getScreenWidth(), getDriver().getScreenHeight());
		if (DrawPos.x<0||DrawPos.x>screen_dims.x||DrawPos.y<0||DrawPos.y>screen_dims.y) continue;
		
		Vec2f Dimensions = Vec2f(1,1);
		
		Vec2f TopLeft = Vec2f(-Dimensions.x/2,-Dimensions.y/2)*2;
		Vec2f TopRight = Vec2f(Dimensions.x/2,-Dimensions.y/2)*2;
		Vec2f BotLeft = Vec2f(-Dimensions.x/2,Dimensions.y/2)*2;
		Vec2f BotRight = Vec2f(Dimensions.x/2,Dimensions.y/2)*2;
		
		TopLeft.RotateByDegrees(angle);
		TopRight.RotateByDegrees(angle);
		BotLeft.RotateByDegrees(angle);
		BotRight.RotateByDegrees(angle);
		
		f32 ring_z = 1540;
	
		ring_dots.push_back(Vertex(DrawPos.x+TopLeft.x*scale, DrawPos.y+TopLeft.y*scale, ring_z, 0, 1, Col)); //top left
		ring_dots.push_back(Vertex(DrawPos.x+TopRight.x*scale, DrawPos.y+TopRight.y*scale, ring_z, 1, 1, Col)); //top right
		ring_dots.push_back(Vertex(DrawPos.x+BotRight.x*scale, DrawPos.y+BotRight.y*scale, ring_z, 1, 0, Col)); //bot right
		ring_dots.push_back(Vertex(DrawPos.x+BotLeft.x*scale, DrawPos.y+BotLeft.y*scale, ring_z, 0, 0, Col)); //bot left
	}
	Render::RawQuads("pixel.png", ring_dots);
}

void RenderMedicSupplies()
{
	CBlob@ blob = getLocalPlayerBlob();
	if (blob is null) return;
	
	CPlayer@ local = getLocalPlayer();
	if (local is null) return;
	
	SoldatInfo@ info = getSoldatInfoFromUsername(local.getUsername());
	if (info is null) return;
	if (info.hat_name!="medhelm") return;
	
	const u8 MAX_BOMB_AMOUNT = 4;
	const u32 BOMB_PRODUCING_INTERVAL = 90;
	const string BOMB_NAME = "healingbomb";
	const string BOMB_AMOUNT_PROP = "current_bomb_amount";
	const string BOMB_CREATION_PROP = "last_bomb_make";
	const string BOMB_TROW_TIME_PROP = "last_bomb_throw";
	
	Driver@ driver = getDriver();
	Vec2f screen_tl = Vec2f();
	Vec2f screen_br = Vec2f(driver.getScreenWidth(), driver.getScreenHeight());
	
	Vec2f gui_pos = Vec2f(screen_tl.x+120, screen_tl.y+96);
	
	for (int bomb_id = 0; bomb_id<MAX_BOMB_AMOUNT; ++bomb_id) {
		f32 scale = 2.0f;
		GUI::DrawIcon("MedicGUI.png", (blob.get_u8(BOMB_AMOUNT_PROP)>bomb_id?1:0), Vec2f(8, 16), gui_pos+Vec2f(bomb_id*12*scale,0), scale, blob.getTeamNum());
	}
	GUI::SetFont("menu");
	GUI::DrawTextCentered("SPACE to make\na Treatment Vial", gui_pos+Vec2f(55, 80), color_white);
}

void RenderInventoryItems()
{
	CBlob@ blob = getLocalPlayerBlob();
	if (blob is null) return;
	
	if (blob.exists("pilot_body_id")) {
		@blob = getBlobByNetworkID(blob.get_u16("pilot_body_id"));
		if (blob is null) return;
	}
	
	Vec2f tl = Vec2f(15, 0);
	Vec2f mouse_screen = getControls().getMouseScreenPos();
	
	if (isPlayerListShowing()) return;
	SColor col;
	u16 slot_size = 24*2;
	u16 inventory_gui_width = slot_size * 2;
	CInventory@ inv = blob.getInventory();
	if (inv is null) return;
	
	Vec2f mouse_pos = getControls().getInterpMouseScreenPos();
	
	string[] drawn;
	for (int i = 0; i < inv.getItemsCount(); i++)
	{
		CBlob@ item = inv.getItem(i);
		const string name = item.getName();
		const string frien_name = item.getInventoryName();
		
		u16 item_width = item.getSprite().getFrameWidth()*2;
		//f32 item_height = Maths::Max(Maths::Ceil((item.getSprite().getFrameHeight()*2)/slot_size)*slot_size, slot_size);
		u16 item_height = item.getSprite().getFrameHeight()*2;
		
		if (drawn.find(frien_name) == -1)
		{
			const int quantity = blob.getBlobCount(name);
			drawn.push_back(frien_name);
			
			Vec2f pane_dims = Vec2f(Maths::Max(2, Maths::Ceil((item.inventoryFrameDimension.x*2)/48))*48, 44);
			//if (mouse_screen.x < (tl.x+pane_dims.x)) return;
			Vec2f pane_tl = tl + Vec2f(0, (drawn.length) * slot_size - slot_size/2 - 6*(drawn.length));
			GUI::DrawPane(pane_tl, pane_tl+pane_dims, SColor(128, 255, 255, 255));

			f32 ratio = float(quantity) / float(item.maxQuantity);
			col = ratio > 0.5f ? SColor(255, 255, 255, 255) :
			      ratio > 0.3f ? SColor(255, 255, 255, 128) :
			      ratio > 0.2f ? SColor(255, 255, 192, 0) : SColor(255, 255, 80, 0);

			GUI::SetFont("menu");
			Vec2f quantity_dimensions(0,0);
			string quantity_text = "" + quantity;
			GUI::GetTextDimensions(quantity_text, quantity_dimensions);
				
			GUI::DrawIcon(
				item.inventoryIconName,
				item.inventoryIconFrame,
				item.inventoryFrameDimension,
				//tl + Vec2f((inventory_gui_width - item_width)/2, (drawn.length) * slot_size - (item_height)/2 - 6*(drawn.length)),
				pane_tl-item.inventoryFrameDimension+Vec2f(quantity_dimensions.x+item.inventoryFrameDimension.x+pane_dims.x/8, pane_dims.y/2),
				1.0f,
				blob.getTeamNum());
			
			GUI::DrawText(
				quantity_text,
				pane_tl+Vec2f(4, pane_dims.y/2),
				col);
			
			if (mouse_pos.x>pane_tl.x&&mouse_pos.x<(pane_tl.x+pane_dims.x)&&mouse_pos.y>pane_tl.y&&mouse_pos.y<(pane_tl.y+pane_dims.y)) {
				GUI::DrawTextCentered(""+frien_name, mouse_pos+Vec2f(0,-8), color_white);
				
				if (blob.isKeyJustPressed(key_action1)) {
					CBlob@ carried = blob.getCarriedBlob();
					if (carried !is null)
						blob.server_PutInInventory(carried);
					blob.server_Pickup(item);
				}
			}
		}
	}
}

void RenderGamemodeHUD()
{

}

void RenderCoins()
{
	CPlayer@ local = getLocalPlayer();
	if (local is null) return;
	CBlob@ blob = getLocalPlayerBlob();
	
	int coins = local.getCoins();
	
	Vec2f tl = Vec2f();
	tl+=Vec2f(260,0);
	Vec2f br(getDriver().getScreenWidth(), getDriver().getScreenHeight());
	GUI::SetFont("menu");
	
	if (local.getTeamNum()==6) {
		u32 your_tags = getRules().get_u32("team_6_tags");
		GUI::DrawText("Your team " + your_tags + " Damage Points", tl + Vec2f(-112, 16), color_white);
		u32 enemy_tags = getRules().get_u32("team_1_tags");
		GUI::DrawText("Enemy team " + enemy_tags + " Damage Points", tl + Vec2f(-112, 32), color_white);
		GUI::DrawText("You get these for dealing damage", tl + Vec2f(-112, 48), SColor(0xffcccccc));
		GUI::DrawText("AND getting damaged", tl + Vec2f(-112, 64), SColor(0xffcccccc));
	} else if (local.getTeamNum()==1) {
		u32 your_tags = getRules().get_u32("team_1_tags");
		GUI::DrawText("Your team " + your_tags + " Damage Points", tl + Vec2f(-112, 16), color_white);
		u32 enemy_tags = getRules().get_u32("team_6_tags");
		GUI::DrawText("Enemy team " + enemy_tags + " Damage Points", tl + Vec2f(-112, 32), color_white);
		GUI::DrawText("You get these for dealing damage", tl + Vec2f(-112, 48), SColor(0xffcccccc));
		GUI::DrawText("AND getting damaged", tl + Vec2f(-112, 64), SColor(0xffcccccc));
	} else if (local.getTeamNum()==200) {
		u32 blue_tags = getRules().get_u32("team_6_tags");
		GUI::DrawText("Blu team " + blue_tags + " Damage Points", tl + Vec2f(-240, 16), color_white);
		u32 red_tags = getRules().get_u32("team_1_tags");
		GUI::DrawText("Red team " + red_tags + " Damage Points", tl + Vec2f(-240, 32), color_white);
		GUI::DrawText("You get these for dealing damage", tl + Vec2f(-240, 48), SColor(0xffcccccc));
		GUI::DrawText("AND getting damaged", tl + Vec2f(-240, 64), SColor(0xffcccccc));
	}
	
	if (blob !is null)
	{
		tl+=Vec2f(-105, 66);
		GUI::DrawIconByName("$COIN$", tl + Vec2f(-16, 8));
		GUI::DrawText("" + coins + " coins"/* \n\n(1 kill gives you 1 coin)" */, tl + Vec2f(16, 16), color_white);
		//u32 tags = getRules().get_u32("team_"+local.getTeamNum()+"_tags");
		//GUI::DrawText("" + tags + " Damage Points"/* \n\n(1 kill gives you 1 coin)" */, tl + Vec2f(16, 32), color_white);
	}
	
	if (getRules().get_bool("quit_on_new_map")) {
		//GUI::SetFont("casio");
		u8 non_red_value = getGameTime()%int(255/14)*14;
		GUI::DrawText("SERVER WILL BE RESTARTED\n\nAFTER THIS MATCH",
			Vec2f(br.x, tl.y) + Vec2f(-220, 20), SColor(255, 255, non_red_value, non_red_value));
	}
}

void RenderHealthBar()
{
	RulesCore@ core;
	if (!getRules().get("core", @core)) return;
	CBlob@ blob = getLocalPlayerBlob();
	if (blob is null) return;
	
	if (blob.hasTag("invincible")&&blob.getName()!="soldat") return;
	
	if (blob.exists("pilot_body_id")) {
		@blob = getBlobByNetworkID(blob.get_u16("pilot_body_id"));
		if (blob is null) return;
	}
	
	//if ((!blob.exists("death health")||blob.get_f32("death health")==0)&&blob.getHealth()<=0) return;
	
	Render::SetTransformScreenspace();
	
	Vec2f origin = Vec2f(200, 9);
	//origin = Vec2f_zero;
	origin = Vec2f(16, 16);
	
	Vec2f hp_bar_dims = Vec2f(354, 35);
	origin = Vec2f(getDriver().getScreenWidth()/3.2-hp_bar_dims.x/2, getDriver().getScreenHeight()-hp_bar_dims.y*2);
	Vec2f under_health = origin+Vec2f(256, 32)/2+Vec2f(-128, 24);
	f32 health_percentage = Maths::Clamp(blob.getHealth()/blob.getInitialHealth(), 0, 1.0f);
	
	//red tint for screen
	GUI::DrawRectangle(Vec2f(),	Vec2f(getDriver().getScreenWidth(), getDriver().getScreenHeight()), SColor(Maths::Max(0, 105-health_percentage*150), 255, 0, 0));
	
	if (blob.exists("death health")&&blob.get_f32("death health")!=0)
	{
		if (blob.getHealth()<=0) {
			health_percentage = Maths::Clamp(1-blob.getHealth()/blob.get_f32("death health"), 0, 1.0f);
		}
	}
	else
		health_percentage = 0;
	
	GUI::DrawButtonPressed(origin-Vec2f(1, 1)*4, origin+Vec2f(hp_bar_dims.x+2, hp_bar_dims.y+2)+Vec2f(1, 1)*4);
	SColor hp_bar_col;
	hp_bar_col.setAlpha(255);
	hp_bar_col.setRed(Maths::Clamp(255-512*(health_percentage-0.7f), 0, 255));
	hp_bar_col.setGreen(Maths::Clamp(255*(health_percentage+0.3f), 0, 255));
	hp_bar_col.setBlue(0);
	
	if (blob.getHealth()<=0)
		hp_bar_col=SColor(0xff888888);
	
	SColor hp_bar2_col;
	hp_bar2_col.setAlpha(255);
	hp_bar2_col.setRed(hp_bar_col.getRed()*0.66);
	hp_bar2_col.setGreen(hp_bar_col.getGreen()*0.66);
	hp_bar2_col.setBlue(100);
	SColor hp_bar3_col;
	hp_bar3_col.setAlpha(255);
	hp_bar3_col.setRed(hp_bar_col.getRed()*0.33);
	hp_bar3_col.setGreen(hp_bar_col.getGreen()*0.33);
	hp_bar3_col.setBlue(50);
	const u8 MIN_BAR_WIDTH = 2;
	u16 health_width = Maths::Max(4, Maths::Round(hp_bar_dims.x*health_percentage/MIN_BAR_WIDTH)*MIN_BAR_WIDTH);
	GUI::DrawRectangle(origin+Vec2f(2, 1.0f*2/30*hp_bar_dims.y), 		origin+Vec2f(health_width, hp_bar_dims.y), hp_bar_col);
	GUI::DrawRectangle(origin+Vec2f(2, 1.0f*14/30*hp_bar_dims.y), 	origin+Vec2f(health_width, hp_bar_dims.y-1.0f*2/30*hp_bar_dims.y), hp_bar2_col);
	GUI::DrawRectangle(origin+Vec2f(2, 1.0f*2/30*hp_bar_dims.y), 		origin+Vec2f(health_width, 1.0f*6/30*hp_bar_dims.y), hp_bar2_col);
	GUI::DrawRectangle(origin+Vec2f(2, 1.0f*16/30*hp_bar_dims.y), 	origin+Vec2f(health_width, 1.0f*24/30*hp_bar_dims.y), hp_bar3_col);
	GUI::DrawRectangle(origin+Vec2f(health_width-4, 2), origin+Vec2f(health_width, hp_bar_dims.y), hp_bar_col);
	//GUI::DrawProgressBar(origin, origin+Vec2f(256, 32), health_percentage);
	GUI::SetFont("menu");
	/* 
	GUI::DrawText("Cletta captured "+getRules().get_u8("team1flags")+" flags", under_health, GetColorFromTeam(core.teams[0].index, 255, 1));
	GUI::DrawText("Imperata captured "+getRules().get_u8("team6flags")+" flags", under_health+Vec2f(0, 16), GetColorFromTeam(core.teams[1].index, 255, 1));
	u8 flag_team = getRules().get_u8("team1flags")>getRules().get_u8("team6flags")?0:(getRules().get_u8("team6flags")==getRules().get_u8("team1flags")?-1:1);
	GUI::DrawIcon("CTFGui.png", 0, Vec2f(16, 32), under_health+Vec2f(180, -8), 1.0f, flag_team);
	 */
	f32 healthbar_width = hp_bar_dims.x-2;
	u8 cell_amount = 8;
	for (int cell = 0; cell< cell_amount; ++cell) {
		u16 current_x = Maths::Round((cell+1)*((healthbar_width)/(cell_amount))/MIN_BAR_WIDTH)*MIN_BAR_WIDTH;
		Vec2f current_pos = Vec2f(origin.x+2+current_x, origin.y);
		GUI::DrawRectangle(current_pos+Vec2f(0, 1.0f*2/30*hp_bar_dims.y), current_pos+Vec2f(2, hp_bar_dims.y), current_x<(health_width-2)?hp_bar2_col:color_black);
	}
	//left
	GUI::DrawRectangle(origin, origin+Vec2f(2, hp_bar_dims.y+2), color_black);
	//right?
	GUI::DrawRectangle(origin+Vec2f(hp_bar_dims.x, 2), origin+Vec2f(hp_bar_dims.x, hp_bar_dims.y+2), color_black);
	//top
	GUI::DrawRectangle(origin, origin+Vec2f(hp_bar_dims.x, 2), color_black);
	//down
	GUI::DrawRectangle(origin+Vec2f(0, hp_bar_dims.y), origin+Vec2f(hp_bar_dims.x, hp_bar_dims.y+2), color_black);
	//text
	GUI::DrawTextCentered(formatFloat(blob.getHealth()*20, "", 0, 0)+" HPs", origin+Vec2f(hp_bar_dims.x+2, hp_bar_dims.y+10.0f/30*hp_bar_dims.y)/2, color_white);
}

bool holderBannedFromUsingGuns(CBlob@ holder, CBlob@ gun)
{
	return holder.getName()=="engi"&&!gun.hasTag("handgun");
}

void RenderFireModeSelector()
{
    CBlob@ holder = getLocalPlayerBlob();
    if (holder is null) return;
    
	AttachmentPoint@ pickup_point = holder.getAttachments().getAttachmentPointByName("PICKUP");
	if (pickup_point is null) return;
	
    CBlob@ b = pickup_point.getOccupied(); 
    CPlayer@ p = holder.getPlayer(); //get player holding this
	
	if (b is null || p is null) return;
	
	FirearmVars@ vars;
	b.get("firearm_vars", @vars);
	if (vars is null) {
		//error("Firearm vars is null! on renderFirearmCursor() in KIWI_PlayerGUI.as");
		return;
	}
	
	Vec2f mouse_pos = getControls().getInterpMouseScreenPos();
	
	if (isFullscreen())
		mouse_pos += Vec2f(-4, -5);
	else
		mouse_pos += Vec2f(1, 0);
	mouse_pos += Vec2f(0.5, 1.5);
	
	
	if (b.getName()!="kb") return;
	//making fire mode selector
	Vertex[] selector_hand;
	Vertex[] selector_back;
	Vec2f Dimensions = Vec2f(32, 24);
	//Vec2f mouse_pos = getControls().getInterpMouseScreenPos();
	f32 angle = 40+0*getGameTime()%30*(360/30);
	Vec2f rotoff = Vec2f(-22.5, 0);
	Vec2f selector_pos = mouse_pos + Vec2f(22, -0.5);
	
	Vec2f TopLeft = Vec2f(-Dimensions.x/2, -Dimensions.y/2)*2;
	Vec2f TopRight = Vec2f(Dimensions.x/2, -Dimensions.y/2)*2;
	Vec2f BotLeft = Vec2f(-Dimensions.x/2, Dimensions.y/2)*2;
	Vec2f BotRight = Vec2f(Dimensions.x/2, Dimensions.y/2)*2;
	
	//modifying them for the selector back
	TopLeft.RotateByDegrees(angle, rotoff);
	TopRight.RotateByDegrees(angle, rotoff);
	BotLeft.RotateByDegrees(angle, rotoff);
	BotRight.RotateByDegrees(angle, rotoff);
	
	selector_back.push_back(Vertex(selector_pos.x + TopLeft.x,
		selector_pos.y + TopLeft.y, 1, 0, 1, color_white)); //top left
	selector_back.push_back(Vertex(selector_pos.x + TopRight.x,
		selector_pos.y + TopRight.y, 1, 1, 1, color_white)); //top right
	selector_back.push_back(Vertex(selector_pos.x + BotRight.x,
		selector_pos.y + BotRight.y, 1, 1, 0, color_white)); //bot right
	selector_back.push_back(Vertex(selector_pos.x + BotLeft.x,
		selector_pos.y + BotLeft.y, 1, 0, 0, color_white)); //bot left
	
	u8 current_firemode = b.get_u8("firemode");
	switch (current_firemode) {
		case 0:
			angle = -33;
			break;
		case 1:
			angle = 33;
			break;
	}
	
	//modifying them for the selector hand
	TopLeft.RotateByDegrees(angle, rotoff);
	TopRight.RotateByDegrees(angle, rotoff);
	BotLeft.RotateByDegrees(angle, rotoff);
	BotRight.RotateByDegrees(angle, rotoff);
					
	selector_hand.push_back(Vertex(selector_pos.x + TopLeft.x,
		selector_pos.y + TopLeft.y, 1, 0, 1, color_white)); //top left
	selector_hand.push_back(Vertex(selector_pos.x + TopRight.x,
		selector_pos.y + TopRight.y, 1, 1, 1, color_white)); //top right
	selector_hand.push_back(Vertex(selector_pos.x + BotRight.x,
		selector_pos.y + BotRight.y, 1, 1, 0, color_white)); //bot right
	selector_hand.push_back(Vertex(selector_pos.x + BotLeft.x,
		selector_pos.y + BotLeft.y, 1, 0, 0, color_white)); //bot left
		
	Render::SetTransformScreenspace();
	Render::RawQuads("fire_mode_selector.png", selector_back);
	Render::RawQuads("selector_hand.png", selector_hand);
}

void RenderVehicleGUI()
{
	CBlob@ local = getLocalPlayerBlob();
	if (local is null) return;
	if (!local.isAttached()) return;
	bool controlling_tank = false;
	
	CBlob@ local_vehicle = getBlobByNetworkID(local.get_u16("my vehicle"));
	if (local_vehicle is null) return;
	if (!local.isAttachedTo(local_vehicle)) return;
	
	controlling_tank = true;
	
	if (!controlling_tank) return;
	
	CBlob@ cannon = getBlobByNetworkID(local_vehicle.get_u16("cannon_id"));
	if (cannon is null) return;
	
	const bool FLIP = cannon.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	
	FirearmVars@ vars;
	cannon.get("firearm_vars", @vars);
	if (vars is null) {
		error("Firearm vars obj is null! on RenderVehicleGUI() in KIWI_PlayerGUI.as");
		return;
	}
	
	Vec2f screen_pos_offset = Vec2f(12, 32);
	
	Vec2f tl = screen_pos_offset+local_vehicle.getInterpolatedScreenPos()-Vec2f(local_vehicle.getWidth(), 6);
	Vec2f br = screen_pos_offset+local_vehicle.getInterpolatedScreenPos()+Vec2f(local_vehicle.getWidth(), 6);
	
	u32 time_from_reload_start = getGameTime()-cannon.get_u32("last_shot_time");
	f32 reload_perc = 1-Maths::Min(1, 1.0f*time_from_reload_start/vars.FIRE_INTERVAL);
	if (reload_perc>=1) reload_perc = 0;
	
	GUI::DrawSunkenPane(tl-Vec2f(8, 1)*4, br+Vec2f(1, 1)*4);
	GUI::DrawProgressBar(tl, br, reload_perc);
	// "+vars.AMMO_TYPE[0]+"
	GUI::DrawIconByName("$draground_icon$", tl-Vec2f(7.5, 2.5)*4, 1, 1, local.getTeamNum(), color_white);
	string cannon_angle = formatFloat(-constrainAngle(cannon.getAngleDegrees()-local_vehicle.getAngleDegrees())*FLIP_FACTOR, "", 1, 1);
	f32 tank_x = local_vehicle.getPosition().x-getMap().tilemapwidth*getMap().tilesize/2;
	string compass = (tank_x < 0 ? "West:" : "East:")+formatFloat(Maths::Abs(tank_x), "", 0, 0);
	
	GUI::SetFont("menu");
	
	string ammo_text = "ammo "+local_vehicle.getBlobCount(vars.AMMO_TYPE[0]);
	string angle_text = "cannon "+cannon_angle+"°";
	string pos_text = "compass "+compass;
	string veh_text = "tank "+formatFloat(constrainAngle(1.0f*local_vehicle.getAngleDegrees()), "", 1, 1)+"°";
	
	f32 font_scale = 1;
	GUIDrawTextOutlined(ammo_text, tl+Vec2f(-7.25, 5.0)*4, color_white, color_black, font_scale);
	GUIDrawTextOutlined(angle_text, tl+Vec2f(-7.25, 8.0)*4, SColor(0xff999999), color_black, font_scale);
	GUIDrawTextOutlined(pos_text, tl+Vec2f(-7.25, 11.0)*4, SColor(0xff999999), color_black, font_scale);
	GUIDrawTextOutlined(veh_text, tl+Vec2f(-7.25, 14.0)*4, SColor(0xff999999), color_black, font_scale);
	GUI::SetFont("menu");
	//print("AYOOOOO");
}

void RenderFirearmCursor()
{
    CBlob@ holder = getLocalPlayerBlob();
    if (holder is null) return;
    
	AttachmentPoint@ pickup_point = holder.getAttachments().getAttachmentPointByName("PICKUP");
	if (pickup_point is null) return;
	
    CBlob@ b = pickup_point.getOccupied(); 
    CPlayer@ p = holder.getPlayer(); //get player holding this

	if (b is null || p is null) {
		getHUD().SetDefaultCursor();
		return;
	}

	if (!b.exists("clip")) {
		getHUD().SetDefaultCursor();
		return; //make sure its a valid gun
	}
	
	if (!b.isAttached()||holderBannedFromUsingGuns(holder, b)) {
		getHUD().SetDefaultCursor();
		return;
	}
	
	FirearmVars@ vars;
	b.get("firearm_vars", @vars);
	if (vars is null) {
		//error("Firearm vars is null! on renderFirearmCursor() in KIWI_PlayerGUI.as");
		return;
	}
	int AltFire = b.get_u8("override_alt_fire");
	if(AltFire == AltFire::Unequip) //in case override value is 0 we use altfire type from vars
		AltFire = vars.ALT_FIRE;
	
	if (vars.MELEE) {
		getHUD().SetDefaultCursor();
		return;
	}
    
	Vec2f mouse_pos = getControls().getInterpMouseScreenPos();
    Vec2f ammos_offset = Vec2f(0, -CURSOR_DIMENSIONS*2 + 7);
    Vec2f digit = Vec2f(5, 7);
    
    uint8 clip = b.get_u8("clip");
    uint8 clipsize = vars.CLIP;
    uint8 total = vars.TOTAL;//get clip and ammo total for easy access later

    Render::SetTransformScreenspace();
    
    if (!isClient()) return;
	
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
	if (getHUD().hasButtons() || getHUD().hasMenus() || isPlayerListShowing() || getControls().isMenuOpened() || getRules().get_bool("show_gamehelp"))
	{
		getHUD().SetDefaultCursor();
		return;
	}
	else {
		getHUD().SetCursorImage(cursor_file, Vec2f(1, 1));
		getHUD().SetCursorOffset(Vec2f(-20, -20));
	}
	/* 
	if (isFullscreen())
		mouse_pos += Vec2f(-4, -5);
	else
		mouse_pos += Vec2f(1, 0);
	mouse_pos += Vec2f(0.5, 1.5);
	 */
	//cursor circle
	{
		f32 idk = 15;
		f32 radius = 7;
		f32 pip_size = 2;
		f32 min = 0;
		u32 max = (360/idk);
		DrawRing(mouse_pos, radius, 	3, color_black, 3);
		DrawRing(mouse_pos, radius, 	3, Col);
		
		//DrawRing(mouse_pos, radius+2, 	3, color_black);
		
		/* 
		for (int i = 0; i < max; i++) {
			Vec2f rec_pos = mouse_pos+Vec2f(radius, 0).RotateBy(max-idk*i);
			GUI::DrawRectangle(rec_pos-Vec2f(1, 1)*(pip_size+4)/2, rec_pos+Vec2f(1, 1)*(pip_size+4)/2, color_black);
		}
		for (int i = 0; i < max; i++) {
			//GUI::DrawCircle(mouse_pos, 12+i*0.75, Col);
			Vec2f rec_pos = mouse_pos+Vec2f(radius, 0).RotateBy(max-idk*i);
			GUI::DrawRectangle(rec_pos-Vec2f(1, 1)*pip_size/2, rec_pos+Vec2f(1, 1)*pip_size/2, Col);
		} */
	}
		
	u8 clipsize_symbols = 1;
	if (clipsize > 9)
		clipsize_symbols = 2;
	if (clipsize > 99)
		clipsize_symbols = 3;
	GUI::SetFont("newspaper");
	
	Vec2f holder_pos = holder.getPosition()-holder.getVelocity();
	f32 side_b = (holder.getAimPos()-holder_pos).Length();
	f32 side_c = Maths::Abs((holder.getAimPos()-holder_pos).RotateBy(-b.get_f32("gunangle")).x);
	f32 spread = getSpreadFromData(b);
	if (vars.COOLING_INTERVAL>0)
		spread = getSpreadFromShotsInTime(b);
	side_c = spread/2;
	f32 side_a = Maths::Sqrt(Maths::Pow(side_b, 2)*Maths::Pow(side_c, 2)-2.0f*side_b*side_c*Maths::Cos(b.get_f32("gunangle")));
	f32 rot_step = 0.3f;
	const f32 SCALEX = getDriver().getResolutionScaleFactor();
	const f32 ZOOM = getCamera().targetDistance * SCALEX;
	side_a *= ZOOM;
	side_a = Maths::Max(6, side_a*0.035);
	//a lot of magiK numbers :P
	rot_step = 0.7f-side_a*3.14/4000; // it's cool and that but it's a lot, really
	//rot_step = 1.1f;
	//print("side a "+side_a);
	//print("rot_step "+rot_step);
	
	DrawRing(mouse_pos, side_a, rot_step, SColor(0xffff660d), 1.5f);
	/* for (int i = 0; i < 360/rot_step; i++) {
		Vec2f rec_pos = mouse_pos+Vec2f(side_a, 0).RotateBy(rot_step*i);
		if (rec_pos.x<0||rec_pos.y<0||rec_pos.x>getDriver().getScreenWidth()||rec_pos.y>getDriver().getScreenHeight()) continue;
		GUI::DrawRectangle(rec_pos-Vec2f(1, 1)*1, rec_pos+Vec2f(1, 1)*1, SColor(0xffff660d));
		//if (i>=4) continue;
	} */
	
	GUI::DrawRectangle(mouse_pos-Vec2f(side_a*1.3, 1), mouse_pos+Vec2f(side_a*1.3, 1), SColor(0xffff660d));
	GUI::DrawRectangle(mouse_pos-Vec2f(1, side_a*1.3), mouse_pos+Vec2f(1, side_a*1.3), SColor(0xffff660d));
	
	{
		u32 time_from_last_shot = getGameTime()-b.get_u32("last_shot_time");
		f32 interval_perc = Maths::Min(1, 1.0f*time_from_last_shot/vars.FIRE_INTERVAL);
		if (interval_perc>=1) interval_perc = 0;
		DrawRing(mouse_pos, 12, 	3, Col, 1.5f, interval_perc, 90);
		u32 time_from_reload_start = getGameTime()-b.get_u32("reload_start_time");
		f32 reload_perc = Maths::Min(1, 1.0f*time_from_reload_start/vars.RELOAD_TIME);
		if (reload_perc>=1) reload_perc = 0;
		bool reloading_still_happens = b.get_u8("clip")!=vars.CLIP;
		if (reloading_still_happens)
			DrawRing(mouse_pos, 16, 	3, SColor(0xff2bd753), 3, reload_perc, 90);
	}
	
	bool reloading = b.get_u8("gun_state")==RELOADING;
	bool reloading_still_happens = b.get_u8("clip")!=vars.CLIP;
	
	if (reloading&&reloading_still_happens) {
		f32 idk = 30.0f;
		f32 radius = 14;
		f32 percentage = 1-(1.0f*b.get_u8("actionInterval") / vars.RELOAD_TIME);
		f32 pip_size = 5;
		f32 min = 0;
		u32 max = Maths::Ceil((360*percentage)/idk);
		for (int i = 0; i < max; i++) {
			Vec2f rec_pos = mouse_pos+Vec2f(radius, 0).RotateBy(max-idk*i);
			GUI::DrawRectangle(rec_pos-Vec2f(1, 1)*pip_size/2, rec_pos+Vec2f(1, 1)*pip_size/2, SColor(0xff2bd753));
		}
	}
	
	u8 outline_width = 2;
	string ammo_desc = (clip<255?(formatInt(clip, "9", clipsize_symbols)+"/"+clipsize):"inf");
	
	//clamping pos so text doesn't get drawn out of bounds
	Vec2f ammo_desc_dims;
	GUI::GetTextDimensions(ammo_desc, ammo_desc_dims);
	mouse_pos = Vec2f(Maths::Clamp(mouse_pos.x, ammo_desc_dims.x/2, getDriver().getScreenWidth()-ammo_desc_dims.x/2),
					  Maths::Max(ammo_desc_dims.x/2, mouse_pos.y));
	
	//i hate kag
	GUIDrawTextCenteredOutlined(ammo_desc, mouse_pos+Vec2f(-2, -23), Col, color_black);

	switch (AltFire) {
		case AltFire::UnderbarrelNader:{
			string nader_text = (vars.AMMO_TYPE.size()>1?""+(holder.getBlobCount(vars.AMMO_TYPE[1])):"");
			if (!nader_text.empty())
				GUIDrawTextCenteredOutlined(nader_text, mouse_pos+Vec2f(0, 25), color_white, color_black);
		break;}
		case AltFire::Bayonet:{
			string bayo_text = "bayonet";
			
			GUIDrawTextCenteredOutlined(bayo_text, mouse_pos+Vec2f(0, 23), color_white, color_black);
		break;}
	}
}