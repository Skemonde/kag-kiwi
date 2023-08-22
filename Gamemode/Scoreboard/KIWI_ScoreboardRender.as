#include "KIWI_Scoreboard"
#include "KIWI_Playercard"
#include "Accolades"
#include "ColoredNameToggleCommon"
#include "SocialStatus"
#include "KIWI_Locales"
#include "Skemlib"
#include "Ranklist"
#include "RulesCore"
#include "KIWI_RulesCore"
#include "BaseTeamInfo"

CPlayer@ hoveredPlayer;
Vec2f hoveredPos;

int hovered_card = -1;
int hovered_rank = -1;

bool draw_age = false;
bool draw_tier = false;

float scoreboardMargin = 52.0f;
float scrollOffset = 0.0f;
float scrollSpeed = 4.0f;
float maxMenuWidth = 700;
float screenMidX = getScreenWidth()/2;

bool mouseWasPressed2 = false;

//colors
	u32 col_white = 0xffffffff;
	u32 col_gold = 0xffe0e050;
	u32 col_deadred = 0xffC65B5B;
	u32 col_darkgrey = 0xff404040;
	u32 col_middlegrey = 0xff808080;
	u32 col_lightgrey = 0xffcccccc;

//returns the bottom
float drawScoreboard(CPlayer@ localplayer, CPlayer@[] players, Vec2f topleft, CTeam@ team, u8 team_num)
{
	KIWICore@ core;
	if (!getRules().get("core", @core)) return 0;
	//if we don't want to display spectators we return immediately
	if (players.size() <= 0 || team is null)
		return topleft.y;
	bool left_scoreboard = ((localplayer.getTeamNum() != team_num && !(localplayer.getTeamNum() > 1)) || (team_num == 1 && localplayer.getTeamNum() > 1));

	CRules@ rules = getRules();
	Vec2f orig = topleft; //save for later

	f32 lineheight = 16;
	f32 padheight = 6;
	f32 stepheight = 23;//lineheight + padheight;
	f32 boardsgap = 6;
	f32 pane_length = (getScreenWidth()/2-boardsgap)-topleft.x;
	Vec2f bottomright(getScreenWidth()/2-boardsgap, topleft.y + (players.length + 5.5) * (stepheight+9)-48);
	//what team will be on the right side?
	//if player is in spectators red is always on the right side
	//otherwise right side is for enemy team
	if (left_scoreboard) {
		topleft = Vec2f(bottomright.x+boardsgap*2, topleft.y);
		bottomright = Vec2f(bottomright.x+boardsgap*2+pane_length, bottomright.y);
	}
	SColor team_col;// = SColor(175, team.color.getRed(), team.color.getGreen(), team.color.getBlue());
	SColor special_clantag = SColor(0xff7becbf);
	
	team_col = GetColorFromTeam(team_num, 175);
	//GUI::DrawFramedPane(topleft-Vec2f(4,4), bottomright+Vec2f(4,4));
	GUI::DrawPane(topleft, bottomright, team_col);

	//offset border
	topleft.x += stepheight;
	bottomright.x -= stepheight;
	topleft.y += stepheight;

	GUI::SetFont("menu");

	//draw team info
	//print("index "+getArrayIndexFromTeamNum(core.teams, team_num));
	GUI::DrawIcon("Emblems.png", getArrayIndexFromTeamNum(core.teams, team_num), Vec2f(32, 32), topleft-Vec2f(16,17), 1.0f, team_num);
	string team_name = core.teams[getArrayIndexFromTeamNum(core.teams, team_num)].name;
	if (false)
	switch (team_num) {
		case 6:
		case 0:
		team_name = Names::team_skyblue; break;
		case 1:
		team_name = Names::team_red; break;
	}
	GUI::DrawText(team_name, Vec2f(topleft.x + 48, topleft.y), SColor(col_white));
	GUI::DrawText(players.size()+" soldiers", Vec2f(bottomright.x - 110, topleft.y), SColor(0xffffffff));

	topleft.y += stepheight * 2;
	
	f32 rank_offset = 0;
	f32 nickname_offset = 64;
	f32 kag_username_offset = nickname_offset + 160;
	f32 ping_offset = 26;
	f32 info_icon_offset = ping_offset + 32;
	f32 kills_offset = info_icon_offset + 64;
	//f32 deaths_offset = kills_offset + 64;
	//print(info_icon_offset+"");
	//draw player table header
	GUI::DrawText(Descriptions::rank, topleft, SColor(col_white));
	GUI::DrawText(Descriptions::nickname, Vec2f(topleft.x + nickname_offset, topleft.y), SColor(col_white));
	GUI::DrawText(Descriptions::username, Vec2f(topleft.x + kag_username_offset, topleft.y), SColor(col_white));
	GUI::DrawText(Descriptions::ping, Vec2f(bottomright.x - ping_offset, topleft.y), SColor(col_white));
	//GUI::DrawIcon("ScoreboardIcons.png", 0, Vec2f(16, 16), Vec2f(bottomright.x - ping_offset, topleft.y+4), 1.0f, team_num);
	GUI::DrawText(Descriptions::kills, Vec2f(bottomright.x - kills_offset, topleft.y), SColor(col_white));

	topleft.y += stepheight * 0.25f;

	CControls@ controls = getControls();
	Vec2f mousePos = controls.getMouseScreenPos();
	string playerCardToDraw = "";

	//draw players
	for (u32 i = 0; i < players.length; i++)
	{
		CPlayer@ p = players[i];

		topleft.y += stepheight+9;
		bottomright.y = topleft.y + lineheight;

		bool playerHover = mousePos.y > topleft.y - 12 && mousePos.y < topleft.y + 12
			&& ((left_scoreboard && mousePos.x > getScreenWidth()/2) || (!left_scoreboard && mousePos.x < getScreenWidth()/2)) && hovered_card<0 ;

		if (playerHover)
		{
			if (controls.mousePressed1)
			{
				setSpectatePlayer(p.getUsername());
			}

			if (controls.mousePressed2 && !mouseWasPressed2)
			{
				// reason for this is because this is called multiple per click (since its onRender, and clicking is updated per tick)
				// we don't want to spam anybody using a clipboard history program
				if (getFromClipboard() != p.getUsername())
				{
					CopyToClipboard(p.getUsername());
					rules.set_u16("client_copy_time", getGameTime());
					rules.set_string("client_copy_name", p.getUsername());
					rules.set_Vec2f("client_copy_pos", mousePos + Vec2f(0, -10));
				}
			}
		}

		Vec2f lineoffset = Vec2f(0, -2);

		const bool deadPlayer = p.getBlob() is null || p.getBlob().hasTag("dead") || p.getBlob().hasTag("undead");
		u32 underlinecolor = col_darkgrey;
		
		u32 playercolour = p.isMyPlayer() ? col_gold : col_lightgrey;
		playercolour = deadPlayer ? col_deadred : playercolour;
		
		string username = p.getUsername();
		u32 usercolor = kiwiBadge(username)?0xff00ff00:col_middlegrey;
		
		Vec2f username_actualsize = Vec2f_zero;
		GUI::GetTextDimensions(username, username_actualsize);
		
		if (playerHover)
		{
			playercolour = col_white;
			@hoveredPlayer = p;
			hoveredPos = topleft;
			hoveredPos.x = bottomright.x - 150;
		}

		f32 underline_shift = 3;
		GUI::DrawLine2D(Vec2f(topleft.x+4, bottomright.y + underline_shift + 1) + lineoffset, Vec2f(bottomright.x, bottomright.y + underline_shift + 1) + lineoffset, SColor(underlinecolor));
		GUI::DrawLine2D(Vec2f(topleft.x+4, bottomright.y + underline_shift) + lineoffset, Vec2f(bottomright.x, bottomright.y + underline_shift) + lineoffset, SColor(playercolour));

		int initial_rank = 0, rank_shift = 4, shift_value = 0;

		CBlob@ b = p.getBlob();
		initial_rank = rules.get_u8(username+"rank");

		int player_rank = initial_rank + rank_shift * shift_value;
		
		if (p.isMyPlayer())
			GUI::DrawIcon("localplayer_en.png", 0, Vec2f(64, 32), topleft + Vec2f(-128, -48), 1.0f, p.getTeamNum());
		Vec2f rank_icon_pos = topleft + Vec2f(0, -16);
		GUI::DrawIcon("ranks.png", player_rank, Vec2f(16, 16), rank_icon_pos, 1.0f, p.getTeamNum());
		
		if (mousePos.x > rank_icon_pos.x -4 && mousePos.x < rank_icon_pos.x + 24 && mousePos.y < rank_icon_pos.y + 24 && mousePos.y > rank_icon_pos.y -4)
		{
			hovered_rank = player_rank;
		}

		string playername = p.getCharacterName();
		string clantag = p.getClantag();
		if (p.isBot())
		clantag = "Bot";

		if(getSecurity().isPlayerNameHidden(p) && getLocalPlayer() !is p)
		{
			if(isAdmin(getLocalPlayer()))
			{
				playername = username + "(hidden: " + clantag + " " + playername + ")";
				clantag = "";

			}
			else
			{
				playername = username;
				clantag = "";
			}
		}

		//head icon

		//TODO: consider maybe the skull emoji for dead players?
		int headIndex = 0;
		string headTexture = "", hatTexture = "";
		int teamIndex = p.getTeamNum();

		if (b !is null)
		{
			headIndex = b.get_s32("head index");
			headTexture = b.get_string("head texture");
			teamIndex = b.getTeamNum();
			hatTexture = b.get_string("hat_name");
		}

		if (headTexture != "")
		{
			GUI::DrawIcon(headTexture, headIndex, Vec2f(16, 16), topleft + Vec2f(32, -12), 1.0f, teamIndex);
		}
		if (hatTexture != "" && (rules.get_bool(username + "helm")/*  || rules.get_u8(username+"rank")>3 */))
			GUI::DrawIcon(hatTexture, 0, Vec2f(32, 32), topleft + Vec2f(16, -44) + Vec2f(-1, 6)*2, 1.0f, teamIndex);

		//have to calc this from ticks
		s32 ping_in_ms = s32(p.getPing() * 1000.0f / 30.0f);

		//how much room to leave for names and clantags
		Vec2f clantag_actualsize(0, 0);
		Vec2f playername_actualsize(0, 0);

		//render the player + stats
		SColor namecolour = playercolour;
		//SColor namecolour = getNameColour(p);

		//right align clantag
		if (clantag != "")
		{
			GUI::GetTextDimensions(clantag, clantag_actualsize);
			GUI::GetTextDimensions(playername, playername_actualsize);
			GUI::DrawText(clantag, topleft + Vec2f(nickname_offset, 0), p.isBot()?special_clantag:SColor(col_middlegrey));
			//draw name alongside
			GUI::DrawText(playername, topleft + Vec2f(nickname_offset + clantag_actualsize.x + 8, 0), namecolour);
		}
		else
		{
			//draw name alone
			GUI::DrawText(playername, topleft + Vec2f(nickname_offset, 0), namecolour);
		}
		
		if (i < 1) //draw only above the first player in the array
			GUI::DrawIcon("moreinfo_en.png", 0, Vec2f(64, 32), Vec2f(bottomright.x - info_icon_offset-54, topleft.y-10-68), 1.0f, 69);
		//making info icon for displaying a player's card
		GUI::DrawIcon("info_icon", 0, Vec2f(16, 16), Vec2f(bottomright.x - info_icon_offset, topleft.y-10), 1.0f, 69);
		if (playerHover && mousePos.x > bottomright.x - info_icon_offset && mousePos.x < bottomright.x - info_icon_offset + 24)
		{
			if (hovered_card < 0)
				hovered_card = i;
		}

		GUI::DrawText("" + username, Vec2f(topleft.x + kag_username_offset, topleft.y), usercolor);
		u8 ping_icon_index = 4;
		if (ping_in_ms < 100)
			//green - gut
			ping_icon_index = 0;
		else if (ping_in_ms < 166)
			//yellow - decent
			ping_icon_index = 1;
		else if (ping_in_ms < 266)
			//orang - okish
			ping_icon_index = 2;
		else if (ping_in_ms < 1000)
			//red - bad!
			ping_icon_index = 3;
		else
			//in case your ping is bigger than a second
			//exclamation mark - you do have a connection issue :kag_death:
			ping_icon_index = 4;

			
		if (playerHover && mousePos.x > bottomright.x - ping_offset && mousePos.x < bottomright.x - ping_offset + 16 + 6)
		{
			drawHoverText(formatFloat(ping_in_ms, "", 0, 0)+" ms ", Vec2f(bottomright.x - ping_offset - 32, topleft.y));
		}
			
		GUI::DrawIcon("ping_icons.png", ping_icon_index, Vec2f(16, 16), Vec2f(bottomright.x - ping_offset, topleft.y-16), 1.0f, 69);
		//GUI::DrawText("" + ping_in_ms, Vec2f(bottomright.x - 330, topleft.y), SColor(0xffffffff));
		GUI::DrawText("" + p.getKills(), Vec2f(bottomright.x - kills_offset, topleft.y), SColor(0xffffffff));
		//GUI::DrawText("" + p.getDeaths(), Vec2f(bottomright.x - deaths_offset, topleft.y), SColor(0xffffffff));
		//GUI::DrawText("" + p.getAssists(), Vec2f(bottomright.x - 120, topleft.y), SColor(0xffffffff));
		//GUI::DrawText("" + formatFloat(getSkillScore(p), "", 0, 0), Vec2f(bottomright.x - 50, topleft.y), SColor(0xffffffff));
		if (hovered_rank > -1) {
			drawRankPane(hovered_rank, rank_icon_pos, p.getTeamNum());
			drawHoverText(ranknames[hovered_rank], rank_icon_pos);
		}
		hovered_rank = -1;
	}//end of cycle of displaying every given player

	// username copied text, goes at bottom to overlay above everything else
	uint durationLeft = rules.get_u16("client_copy_time");

	if ((durationLeft + 64) > getGameTime())
	{
		durationLeft = getGameTime() - durationLeft;
		DrawFancyCopiedText(rules.get_string("client_copy_name"), rules.get_Vec2f("client_copy_pos"), durationLeft);
	}

	return topleft.y;
	//return orig.y;
}

void drawRankPane(u8 hovered_rank, Vec2f pos, u8 teamnum)
{
	//main pane
	Vec2f paneDims = Vec2f(32+16, 56+16)*2;
	Vec2f topLeft = pos;//-Vec2f(paneDims.x/2+32,-8);
	Vec2f botRight = topLeft+Vec2f(paneDims.x,paneDims.y);
	//GUI::DrawPane(topLeft, botRight);
	GUI::DrawIcon("ranks_big", hovered_rank, Vec2f(32, 56), pos+Vec2f(-16, -112), 1.0f, teamnum);
}

void onRenderScoreboard(CRules@ this)
{
	RulesCore@ core;
	if (!getRules().get("core", @core)) return;
	CControls@ controls = getControls();
	//sort players
	CPlayer@[] blueplayers;
	CPlayer@[] redplayers;
	
	CPlayer@[] spectators;
	for (u32 i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ p = getPlayer(i);
		f32 kdr = getKDR(p);
		f32 kills = p.getKills();
		bool inserted = false;
		if (p.getTeamNum() == this.getSpectatorTeamNum())
		{
			spectators.push_back(p);
			continue;
		}

		int teamNum = p.getTeamNum();
		if (teamNum == core.teams[0].index) //blue team
		{
			for (u32 j = 0; j < blueplayers.length; j++)
			{
				//if (getKDR(blueplayers[j]) < kdr)
				if (blueplayers[j].getKills() < kills)
				{
					blueplayers.insert(j, p);
					inserted = true;
					break;
				}
			}

			if (!inserted)
				blueplayers.push_back(p);

		}
		else if (teamNum == core.teams[1].index) //red team
		{
			for (u32 j = 0; j < redplayers.length; j++)
			{
				//if (getKDR(redplayers[j]) < kdr)
				if (redplayers[j].getKills() < kills)
				{
					redplayers.insert(j, p);
					inserted = true;
					break;
				}
			}

			if (!inserted)
				redplayers.push_back(p);

		}
	}

	//draw board

	CPlayer@ localPlayer = getLocalPlayer();
	if (localPlayer is null)
		return;
	int localTeam = localPlayer.getTeamNum();
	//if (localTeam != 0 && localTeam != 1)
	//	localTeam = 0;

	@hoveredPlayer = null;

	Vec2f topleft(Maths::Max( 100, screenMidX-maxMenuWidth), 150);
	Vec2f spec_topleft(topleft.x,0);
	f32 old_topleft_y;
	drawServerInfo(40);

	// start the scoreboard lower or higher.
	topleft.y -= scrollOffset;

	//(reset)
	hovered_accolade = -1;
	hovered_age = -1;
	hovered_tier = -1;

	//draw the scoreboards
	
	//in case we're in blue team we render it first and only after that we render scoreboard for an enemy team
	for (int renderedTeamNum = 0; renderedTeamNum < core.teams.size(); ++renderedTeamNum) {
		if (localTeam == core.teams[renderedTeamNum].index || (localTeam == this.getSpectatorTeamNum() && renderedTeamNum == 0)) {
			old_topleft_y = spec_topleft.y;
			spec_topleft.y = drawScoreboard(localPlayer, blueplayers, topleft, this.getTeam(core.teams[0].index), core.teams[0].index);
			if (spec_topleft.y < old_topleft_y)
				spec_topleft.y = old_topleft_y;
		}
		else {
			old_topleft_y = spec_topleft.y;
			spec_topleft.y = drawScoreboard(localPlayer, redplayers, topleft, this.getTeam(core.teams[1].index), core.teams[1].index);
			if (spec_topleft.y < old_topleft_y)
				spec_topleft.y = old_topleft_y;
		}
	}

	if (spectators.length > 0)
	{
		//draw spectators
		spec_topleft.y += 56;
		f32 stepheight = 16;
		Vec2f bottomright(getScreenWidth() - spec_topleft.x - 4, spec_topleft.y + stepheight * 2);
		f32 specy = spec_topleft.y + stepheight * 0.5;
		GUI::DrawPane(spec_topleft, bottomright, SColor(0x80c0c0c0));

		Vec2f textdim;
		string s = getTranslatedString("Spectators:");
		GUI::GetTextDimensions(s, textdim);

		GUI::DrawText(s, Vec2f(spec_topleft.x + 5, specy), SColor(0xffaaaaaa));

		f32 specx = spec_topleft.x + textdim.x + 15;
		for (u32 i = 0; i < spectators.length; i++)
		{
			CPlayer@ p = spectators[i];
			if (specx < bottomright.x - 100)
			{
				string name = p.getCharacterName();
				if (i != spectators.length - 1)
					name += ",";
				GUI::GetTextDimensions(name, textdim);
				SColor namecolour = getNameColour(p);
				GUI::DrawText(name, Vec2f(specx, specy), namecolour);
				specx += textdim.x + 10;
			}
			else
			{
				GUI::DrawText(getTranslatedString("and more ..."), Vec2f(specx, specy), SColor(0xffaaaaaa));
				break;
			}
		}

		spec_topleft.y += 52;
	}

	float scoreboardHeight = spec_topleft.y + scrollOffset;
	float screenHeight = getScreenHeight()-100;

	if(scoreboardHeight > screenHeight) {
		Vec2f mousePos = controls.getMouseScreenPos();
		
		//scrollSpeed = Maths::Abs(mousePos.y-screenHeight/2);
		float fullOffset = (scoreboardHeight + scoreboardMargin) - screenHeight;

		if(scrollOffset < fullOffset && mousePos.y > screenHeight*0.83f) {
			scrollOffset += scrollSpeed;
		}
		else if(scrollOffset > 0.0f && mousePos.y < screenHeight*0.16f) {
			scrollOffset -= scrollSpeed;
		}

		scrollOffset = Maths::Clamp(scrollOffset, 0.0f, fullOffset);
	}
	
	Vec2f mousePos = controls.getMouseScreenPos();
	bool left_side = mousePos.x<getScreenWidth()/2;
	Vec2f card_pos = Vec2f(left_side?topleft.x:getScreenWidth()/2, topleft.y)+Vec2f(getScreenWidth()/3.75, topleft.y-64+(23+9)*hovered_card);
	Vec2f card_topLeft = card_pos+Vec2f(-80,0);
	Vec2f card_botRight = card_topLeft+Vec2f(playerCardDims.x,playerCardDims.y);
	if (mousePos.y>card_botRight.y||mousePos.y<card_topLeft.y||mousePos.x>card_botRight.x||mousePos.x<card_topLeft.x||controls.mousePressed1) {
		//debug thing to check the borderlines
		if (hovered_card > -1)
		GUI::DrawBubble(card_topLeft, card_botRight);
		
		hovered_card = -1;
	}
	
	if (hovered_card != -1) {
		CPlayer@ player = null;
		if (left_side) {
			if (localTeam == 0 || (localTeam == this.getSpectatorTeamNum())) {
				if (blueplayers.size()>hovered_card)
					@player = blueplayers[hovered_card];
			}
			else {
				if (redplayers.size()>hovered_card)
					@player = redplayers[hovered_card];
			}
		} else {
			if (localTeam == 0 || (localTeam == this.getSpectatorTeamNum())) {
				if (redplayers.size()>hovered_card)
					@player = redplayers[hovered_card];
			}
			else {
				if (blueplayers.size()>hovered_card)
					@player = blueplayers[hovered_card];
			}
		}
		if (player !is null) {
			makePlayerCard(player, card_topLeft);
		}
	}

	drawPlayerCard(hoveredPlayer, hoveredPos);

	mouseWasPressed2 = controls.mousePressed2; 
}

void drawHoverText(string desc, Vec2f pos, u32 text_col = col_white)
{
	Vec2f size(0, 0);
	GUI::GetTextDimensions(desc, size);

	Vec2f tl = pos - Vec2f(size.x / 2, 0);
	Vec2f br = tl + size;

	//margin
	Vec2f expand(8, 8);
	tl -= expand;
	br += expand;

	GUI::DrawPane(tl, br, SColor(0xffffffff));
	GUI::DrawText(desc, tl + expand, SColor(text_col));
}

void onTick(CRules@ this)
{
	if (!isPlayerListShowing() && hovered_card>-1)
	{
		hovered_card = -1; //deactivate any cards
	}
	
	if(isServer() && (this.getCurrentState() == GAME || this.getCurrentState() == INTERMISSION)) //zombie thing
	{
		this.add_u32("match_time", 1);
		this.Sync("match_time", true);
	}
}

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	if(isServer())
	{
		this.set_u32("match_time", 0);
		this.Sync("match_time", true);
		getMapName(this);
	}
}

void getMapName(CRules@ this)
{
	CMap@ map = getMap();
	if(map !is null)
	{
		string[] name = map.getMapName().split('/');	 //Official server maps seem to show up as
		string mapName = name[name.length() - 1];		 //``Maps/CTF/MapNameHere.png`` while using this instead of just the .png
		mapName = getFilenameWithoutExtension(mapName);  // Remove extension from the filename if it exists

		this.set_string("map_name", mapName);
		this.Sync("map_name",true);
	}
}

void DrawFancyCopiedText(string username, Vec2f mousePos, uint duration)
{
	string text = "Username copied: " + username;
	Vec2f pos = mousePos - Vec2f(0, duration);
	int col = (255 - duration * 3);

	GUI::DrawTextCentered(text, pos, SColor((255 - duration * 4), col, col, col));
}

string GetFancyNumber(string initial_string, string splitter = "'") {
	string new_string = "";
	print("" + initial_string);
	int init_length = initial_string.length(), new_length = init_length+Maths::Floor(init_length/3);
	new_string.set_length(new_length);
	print("" + new_length);
	for (int i = 0, amogus = 0; i < init_length; ++i) {
		new_string[i]=initial_string[i];
		if ((init_length-i-1) % 3 == 0 && new_string.length() < new_length) {
			++i;
			new_string[i]=splitter[0];
			++i;
		}
	}
	print("Sosk" + new_string + "eeeew");
	return new_string;
}
