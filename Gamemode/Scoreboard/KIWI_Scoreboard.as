#include "ColoredNameToggleCommon.as"
#include "SocialStatus"

f32 getKDR(CPlayer@ p)
{
	return p.getKills() / Maths::Max(f32(p.getDeaths()), 1.0f);
}

f32 getSkillScore(CPlayer@ dude)
{
	return Maths::Pow(dude.getKills() + dude.getAssists(), 2) / Maths::Max(f32(dude.getDeaths()), 1.0f) * 10;
}

SColor getNameColour(CPlayer@ p)
{
	SColor c;
	CPlayer@ localplayer = getLocalPlayer();
	bool showColor = (p !is localplayer && isSpecial(localplayer)) || coloredNameEnabled(getRules(), p);

	if (p.isDev() && showColor) {
		c = SColor(0xffb400ff); //dev
	} else if (p.isGuard() && showColor) {
		c = SColor(0xffa0ffa0); //guard
	} else if (isAdmin(p) && showColor) {
		c = SColor(0xfffa5a00); //admin
	} else if (kiwiBadge(p.getUsername())) {
		c = SColor(0xff00ff00); //kiwi contributor
	} else if (p.getOldGold() && !p.isBot()) {
		c = SColor(0xffffEE44); //my player
	} else {
		c = SColor(0xffcccccc); //normal
	}

	if(p.getBlob() is null && p.getTeamNum() != getRules().getSpectatorTeamNum())
	{
		uint b = c.getBlue();
		uint g = c.getGreen();
		uint r = c.getRed();

		b -= 95;
		g -= 95;
		r -= 95;

		b = Maths::Max(b, 25);
		g = Maths::Max(g, 25);
		r = Maths::Max(r, 25);

		c.setBlue(b);
		c.setGreen(g);
		c.setRed(r);

	}

	return c;

}

void setSpectatePlayer(string username)
{
	CPlayer@ player = getLocalPlayer();
	CPlayer@ target = getPlayerByUsername(username);
	if((player.getBlob() is null || player.getBlob().hasTag("dead")) && player !is target && target !is null)
	{
		CRules@ rules = getRules();
		rules.set_bool("set new target", true);
		rules.set_string("new target", username);

	}

}

float drawServerInfo(float y)
{
	GUI::SetFont("menu");

	Vec2f pos(getScreenWidth()/2, y);
	float width = 200;
	f32 game_x = 200-2;


	CNet@ net = getNet();
	CMap@ map = getMap();
	CRules@ rules = getRules();

	string info = getTranslatedString(rules.gamemode_name) + ": " + getTranslatedString(rules.gamemode_info);
	SColor white(0xffffffff);
	string mapName = getTranslatedString("Map name : ")+rules.get_string("map_name");
	Vec2f dim;
	GUI::GetTextDimensions(info, dim);
	if(dim.x + 15 > width)
		width = dim.x + 15;

	GUI::GetTextDimensions(net.joined_servername, dim);
	if(dim.x + 15 > width)
		width = dim.x + 15;

	GUI::GetTextDimensions(mapName, dim);
	if(dim.x + 15 > width)
		width = dim.x + 15;


	pos.x -= width/2;
	Vec2f bot = pos;
	bot.x += width;
	bot.y += 120;


	float maxMenuWidth = 700;
	float screenMidX = getScreenWidth()/2;
	Vec2f topleft(Maths::Max( 100, screenMidX-maxMenuWidth), pos.y);
	//GUI::DrawPane(topleft, Vec2f(getScreenWidth()-topleft.x, bot.y), SColor(0xffcccccc));
	//makeWebsiteButton(topleft, "Github ", "https://github.com/Skemonde/kag-kiwi");
	//GUI::DrawPane(pos, bot, SColor(0xffcccccc));
	
	u8 kiwi_frame = 0;
	Vec2f kiwi_dims(16,16);
	f32 kiwi_scale = 1.0f;

	{//server info
		//GUI::DrawFramedPane(Vec2f(topleft.x+game_x-2, topleft.y), Vec2f(topleft.x+game_x+200, bot.y));
		GUI::DrawFramedPane(Vec2f(topleft.x+game_x+310-2, topleft.y), Vec2f(getScreenWidth()-topleft.x, bot.y));
		Vec2f s_info_pos(topleft.x+game_x+310-2+8, y+8);
		
		GUI::DrawFramedPane(topleft, Vec2f(topleft.x+200, bot.y));
		GUI::DrawIcon("kiwi_logo.png", kiwi_frame, Vec2f(200,104), Vec2f(topleft.x+6, topleft.y+10), 0.5f, 0.5f, 0, color_white);
		GUI::DrawText("Server Info", s_info_pos, SColor(0xff00ff00));
		s_info_pos.y += 15;
		GUI::DrawText(net.joined_servername, s_info_pos, white);
		s_info_pos.y += 15;
		GUI::DrawText(info, s_info_pos, white);
		s_info_pos.y += 15;
		GUI::DrawText(net.joined_ip, s_info_pos, white);
		s_info_pos.y += 15;
		GUI::DrawText(mapName, s_info_pos, white);
		
		f32 lang_step = 18;
		Vec2f flag_offset(-22,1);
		Vec2f jp_text_offset(0,-2);
		Vec2f lang_pos(getScreenWidth()-440, topleft.y+10);
		//en
		GUI::DrawIcon("flag_en.png", 0, Vec2f(10, 8), lang_pos+flag_offset, 1.0f, 1.0f, 0, color_white);
		GUI::DrawText("English is the main language", lang_pos, SColor(0xffffc64b));
		//ru
		lang_pos.y += lang_step;
		GUI::DrawIcon("flag_ru.png", 0, Vec2f(10, 8), lang_pos+flag_offset, 1.0f, 1.0f, 0, color_white);
		GUI::DrawText("Этот мод имеет перевод на русский", lang_pos, SColor(0xffffc64b));
		//de
		lang_pos.y += lang_step;
		GUI::DrawIcon("flag_de.png", 0, Vec2f(10, 8), lang_pos+flag_offset, 1.0f, 1.0f, 0, color_white);
		GUI::DrawText("Diese Mod hat eine Übersetzung ins Deutsche", lang_pos, SColor(0xffffc64b));
		//es
		lang_pos.y += lang_step;
		GUI::DrawIcon("flag_es.png", 0, Vec2f(10, 8), lang_pos+flag_offset, 1.0f, 1.0f, 0, color_white);
		GUI::DrawText("No saber ni papa de algo", lang_pos, SColor(0xffffc64b));
		//jp
		lang_pos.y += lang_step;
		GUI::DrawIcon("flag_jp.png", 0, Vec2f(10, 8), lang_pos+flag_offset, 1.0f, 1.0f, 0, color_white);
		GUI::SetFont("genjyuu");
		GUI::DrawText("死にてぇヤツだけ掛かってこい", lang_pos+jp_text_offset, SColor(0xffffc64b));
		GUI::SetFont("menu");
	}
	
	{//game info
		Vec2f game_info_tl = Vec2f(topleft.x+game_x, topleft.y);
		GUI::DrawFramedPane(game_info_tl, Vec2f(game_info_tl.x+310, bot.y));
		f32 daytime = getMap().getDayTime();
		f32 minutes_in_hour = 60;
		f32 float_in_hour = 1.0f/24;
		f32 float_in_min = float_in_hour/minutes_in_hour;
		f32 actual_hour = daytime/float_in_hour;
		f32 floor_actual_hour = Maths::Floor(actual_hour);
		f32 current_hour = Maths::Floor(actual_hour%12)==0?12:Maths::Floor(actual_hour%12);
		f32 current_minute = minutes_in_hour-Maths::Ceil((Maths::Ceil(daytime/float_in_hour)-daytime/float_in_hour)/float_in_min/minutes_in_hour/0.4f);
		
		// 23:00-04:59 - night		6 hours
		// 05:00-08:59 - morning	4 hours
		// 09:00-19:59 - day		11 hours
		// 20:00-22:59 - evening	3 hours
		
		string daytime_name = "Night";
		
		if (floor_actual_hour>=5&&floor_actual_hour<9
			&&(floor_actual_hour==5&&current_minute>=0||floor_actual_hour!=5)
			&&(floor_actual_hour==9&&current_minute<1||floor_actual_hour!=9))
			daytime_name = "Morning";
		else if (floor_actual_hour>=9&&floor_actual_hour<20
			&&(floor_actual_hour==9&&current_minute>=0||floor_actual_hour!=9)
			&&(floor_actual_hour==20&&current_minute<1||floor_actual_hour!=20))
			daytime_name = "Day";
		else if (floor_actual_hour>=20&&floor_actual_hour<23
			&&(floor_actual_hour==20&&current_minute>=0||floor_actual_hour!=20)
			&&(floor_actual_hour==23&&current_minute<1||floor_actual_hour!=23))
			daytime_name = "Evening";
		
		Vec2f g_info_pos = Vec2f(game_info_tl.x+8, y+8);
		
		GUI::DrawIcon("kiwi_icon.png", kiwi_frame, kiwi_dims, Vec2f(game_info_tl.x+310, bot.y)-kiwi_dims*kiwi_scale*2.5f, kiwi_scale, kiwi_scale, 0, color_white);
		GUI::DrawText("Game Info", g_info_pos, SColor(0xff00ff00));
		g_info_pos.y += 15;
		GUI::DrawText(getRules().get_bool("cursor_recoil_enabled")?"Cursor recoils after made shots":"Cursor does NOT recoil",
			Vec2f(g_info_pos.x, g_info_pos.y), color_white);
		
		g_info_pos.y += 15;
		GUI::DrawText(!getRules().get_bool("ammo_usage_enabled")?"Reloading is completely FREE":"Reloading requires ammo",
			Vec2f(g_info_pos.x, g_info_pos.y), color_white);
		
		const u16 MAX_U16 = -1;
		const u16 DAY_MIN = getRules().daycycle_speed;
		g_info_pos.y += 15;
		GUI::DrawText(DAY_MIN==MAX_U16?"Time's stopped":"Time's going (full cycle: "+DAY_MIN+" real minutes)",
			Vec2f(g_info_pos.x, g_info_pos.y), color_white);
		
		g_info_pos.y += 15;
		GUI::DrawText(formatFloat(current_hour, "0", 2, 0)+":"+formatFloat(current_minute, "0", 2, 0)+(daytime>0.5?"PM":"AM")+" "+daytime_name,
			Vec2f(g_info_pos.x, g_info_pos.y), color_white);
			
		g_info_pos.y += 15;
		GUI::DrawText(getTranslatedString("Match time: {TIME}").replace("{TIME}", "" + timestamp((getRules().exists("match_time") ? getRules().get_u32("match_time") : getGameTime())/getTicksASecond())), g_info_pos, white);
	}
		
	GUI::SetFont("menu");
	return bot.y;
}

string timestamp(uint s)
{
	string ret;
	int hours = s/60/60;
	if (hours > 0)
		ret += hours + getTranslatedString("h ");

	int minutes = s/60%60;
	if (minutes < 10)
		ret += "0";

	ret += minutes + getTranslatedString("m ");

	int seconds = s%60;
	if (seconds < 10)
		ret += "0";

	ret += seconds + getTranslatedString("s ");

	return ret;
}

void makeWebsiteButton(Vec2f pos, const string&in text, const string&in website)
{
	Vec2f dim;
	GUI::GetTextDimensions(text, dim);

	const f32 width = dim.x + 20;
	const f32 height = 40;
	//const Vec2f tl = Vec2f(getScreenWidth() - 10 - width - pos.x, pos.y);
	//const Vec2f br = Vec2f(getScreenWidth() - 10 - pos.x, tl.y + height);
	const Vec2f tl = pos-dim/2-Vec2f(1, 1)*10;
	const Vec2f br = pos+dim/2+Vec2f(1, 1)*10;

	CControls@ controls = getControls();
	const Vec2f mousePos = controls.getMouseScreenPos();

	const bool hover = (mousePos.x > tl.x && mousePos.x < br.x && mousePos.y > tl.y && mousePos.y < br.y);
	if (hover)
	{
		if (controls.mousePressed1)
		{
			Sound::Play("option");
			controls.setMousePosition(Vec2f(getScreenWidth()*0.46f, getScreenHeight()*0.53f));
			OpenWebsite(website);
			
			//controls.setMousePosition(mousePos);
			GUI::DrawButtonPressed(tl, br);
		} else {
			GUI::DrawButtonHover(tl, br);
		}
	}
	else
	{
		GUI::DrawButton(tl, br);
	}

	GUI::DrawTextCentered(text, pos, 0xffffffff);
}

void drawPlayerCard(CPlayer@ player, Vec2f pos)
{
	/*
	if(player!is null)
	{
		GUI::SetFont("menu");

		f32 stepheight = 8;
		Vec2f atopleft = pos;
		atopleft.x -= stepheight;
		atopleft.y -= stepheight*2;
		Vec2f abottomright = atopleft;
		abottomright.y += 96 + 16 + 48;
		abottomright.x += 96 + 16;

		//int namecolour = getNameColour(player);
		GUI::DrawIconDirect("playercard.png", atopleft, Vec2f(0, 0), Vec2f(60, 94));
		GUI::DrawText(player.getUsername(), Vec2f(pos.x + 2, atopleft.y+10), SColor(0xffffffff));
		player.drawAvatar(Vec2f(atopleft.x+6*2, atopleft.y+16*2), 1.0f);
		atopleft.y += 96 + 30;
		atopleft.x += 8;
		GUI::DrawIconDirect("playercardicons.png", Vec2f(atopleft.x, atopleft.y), Vec2f(16*2, 0), Vec2f(16, 16));
		GUI::DrawText("9600", Vec2f(atopleft.x+32, atopleft.y+6), SColor(0xffffffff));
		atopleft.y += 23;
		GUI::DrawIconDirect("playercardicons", Vec2f(atopleft.x, atopleft.y), Vec2f(16*3, 0), Vec2f(16, 16));
		GUI::DrawText("450", Vec2f(atopleft.x+32, atopleft.y+6), SColor(0xffffffff));

	}
	*/

}
