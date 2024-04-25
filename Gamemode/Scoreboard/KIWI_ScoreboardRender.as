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
#include "SoldatInfo"
#include "HeadCommon"

CPlayer@ hoveredPlayer;
Vec2f hoveredPos;
Vec2f hovered_pos;
int hovered_player;
Vec2f card_pos;

int hovered_card = -1;
int hovered_rank = -1;

bool draw_age = false;
bool draw_tier = false;

Vec2f screen_dims = Vec2f(getScreenWidth(), getScreenHeight());

float scoreboardMargin = 52.0f;
float scrollOffset = 0.0f;
float scrollSpeed = 4.0f;
float maxMenuWidth = 700;
float screenMidX = screen_dims.x/2;

bool mouseWasPressed2 = false;

//colors
	u32 col_white = 0xffffffff;
	u32 col_gold = 0xffe0e050;
	u32 col_cyan = 0xff31dcbf;
	u32 col_pink = 0xffff77a8;
	u32 col_deadred = 0xff893333;
	u32 col_darkgrey = 0xff404040;
	u32 col_middlegrey = 0xff808080;
	u32 col_lightgrey = 0xffcccccc;

//returns the bottom
float drawScoreboard(CPlayer@ localplayer, CPlayer@[] players, Vec2f topleft, u8 team_num, Vec2f &out pane_tl, Vec2f &out pane_br)
{
	KIWICore@ core;
	if (!getRules().get("core", @core)) return 0;
	//if we don't want to display spectators we return immediately
	if (players.size() <= 0)
		return topleft.y;
	
	bool spec_pane = team_num == getRules().getSpectatorTeamNum();
	bool always_at_left = team_num == 3 || spec_pane;
	
	bool left_scoreboard = !always_at_left&&((localplayer.getTeamNum() != team_num && !(localplayer.getTeamNum() > 1)) || (team_num == 1 && localplayer.getTeamNum() > 1));

	CRules@ rules = getRules();
	CControls@ controls = getControls();
	Vec2f mousePos = controls.getMouseScreenPos();
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
	if (spec_pane)
		bottomright = Vec2f(bottomright.x+boardsgap*2+pane_length, bottomright.y);
	SColor team_col;// = SColor(175, team.color.getRed(), team.color.getGreen(), team.color.getBlue());
	SColor special_clantag = SColor(0xff7becbf);
	
	team_col = GetColorFromTeam(team_num, 175);
	//GUI::DrawFramedPane(topleft-Vec2f(4,4), bottomright+Vec2f(4,4));
	GUI::DrawPane(topleft, bottomright, team_col);
	pane_tl = topleft;
	pane_br = bottomright;
	//print("from func "+topleft+bottomright);

	//offset border
	topleft.x += stepheight;
	bottomright.x -= stepheight;
	topleft.y += stepheight;

	GUI::SetFont("menu");

	//draw team info
	//print("index "+getArrayIndexFromTeamNum(core.teams, team_num));
	int team_idx = getArrayIndexFromTeamNum(core.teams, team_num);
	string team_name = "Spect.s";
	
	if (team_idx>=0) {
		GUI::DrawIcon("Emblems.png", team_idx, Vec2f(32, 32), topleft-Vec2f(16,17), 1.0f, team_num);
		team_name = core.teams[team_idx].name;
		//if (false)
		switch (team_num) {
			case 6:
				team_name = Names::team_skyblue; break;
			case 1:
				team_name = Names::team_red; break;
			case 3:
				team_name = "Undeads"; break;
		}
	}
	
	GUI::SetFont("military");
	GUI::DrawText(team_name, Vec2f(topleft.x + 52, topleft.y), SColor(col_white));
	GUI::SetFont("menu");
	int team_players = 0;//core.teams[team_idx].players_count;
	team_players = players.size();
	GUI::DrawText(team_players+" soldier"+(team_players>1?"s":""), Vec2f(bottomright.x - 75, topleft.y-16), SColor(0xffffffff));
	GUI::DrawText("Click on categories\nto sort the player list", Vec2f(topleft.x + 200, topleft.y), SColor(col_middlegrey));

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
	bool LMB = controls.mousePressed1;
	u8 sorting = rules.get_u8("sorting_type");
	
	Vec2f kills_tl = Vec2f(bottomright.x - kills_offset, topleft.y);
	Vec2f kills_br = kills_tl+Vec2f(3,1.5)*16;
	//GUI::DrawPane(kills_tl, kills_br, SColor(0x33ffffff));
	if (sorting != 0 && LMB && mousePos.x>kills_tl.x && mousePos.x<kills_br.x && mousePos.y>kills_tl.y && mousePos.y<kills_br.y) {
		rules.set_u8("sorting_type", 0);
	}
	
	Vec2f rank_br = topleft+Vec2f(3,1.5)*16;
	//GUI::DrawPane(topleft, rank_br, SColor(0x33ffffff));
	if (sorting != 1 && LMB && mousePos.x>topleft.x && mousePos.x<rank_br.x && mousePos.y>topleft.y && mousePos.y<rank_br.y) {
		rules.set_u8("sorting_type", 1);
	}
	
	Vec2f name_tl = Vec2f(topleft.x + kag_username_offset, topleft.y);
	Vec2f name_br = name_tl+Vec2f(7.5,1.5)*16;
	//GUI::DrawPane(name_tl, name_br, SColor(0x33ffffff));
	if (sorting != 2 && LMB && mousePos.x>name_tl.x && mousePos.x<name_br.x && mousePos.y>name_tl.y && mousePos.y<name_br.y) {
		rules.set_u8("sorting_type", 2);
	}
	
	Vec2f nick_tl = Vec2f(topleft.x + nickname_offset, topleft.y);
	Vec2f nick_br = nick_tl+Vec2f(5,1.5)*16;
	//GUI::DrawPane(nick_tl, nick_br, SColor(0x33ffffff));
	if (sorting != 3 && LMB && mousePos.x>nick_tl.x && mousePos.x<nick_br.x && mousePos.y>nick_tl.y && mousePos.y<nick_br.y) {
		rules.set_u8("sorting_type", 3);
	}
	
	Vec2f sorting_icon_pos = Vec2f(-12, 2);
	switch (sorting) {
		case 0:
			sorting_icon_pos += kills_tl;
			break;
		case 1:
			sorting_icon_pos += topleft;
			break;
		case 2:
			sorting_icon_pos += name_tl;
			break;
		case 3:
			sorting_icon_pos += nick_tl;
			break;
	}
	
	GUI::DrawIcon("sorting_down.png", 0, Vec2f(16, 16), sorting_icon_pos, 1.0f, team_num);
	
	GUI::DrawText(Descriptions::rank, topleft, SColor(col_white));
	GUI::DrawText(Descriptions::nickname, nick_tl, SColor(col_white));
	GUI::DrawText(Descriptions::username, name_tl, SColor(col_white));
	GUI::DrawText(Descriptions::ping, Vec2f(bottomright.x - ping_offset, topleft.y), SColor(col_white));
	//GUI::DrawIcon("ScoreboardIcons.png", 0, Vec2f(16, 16), Vec2f(bottomright.x - ping_offset, topleft.y+4), 1.0f, team_num);
	GUI::DrawText(Descriptions::kills, kills_tl, SColor(col_white));
	
	

	topleft.y += stepheight * 0.25f;

	string playerCardToDraw = "";

	//draw players
	for (u32 i = 0; i < players.length; i++)
	{
		CPlayer@ p = players[i];
		string username = p.getUsername();
		SoldatInfo@ info = getSoldatInfoFromUsername(username);
		bool infos_exist = info !is null;

		topleft.y += stepheight+9;
		bottomright.y = topleft.y + lineheight;

		//old stupid logic
		//might need to see what it did tho
		//bool playerHover = mousePos.y > topleft.y - 12 && mousePos.y < topleft.y + 12 && ((left_scoreboard && mousePos.x > getScreenWidth()/2) || (!left_scoreboard && mousePos.x < getScreenWidth()/2)) && hovered_card<0 ;
			
		bool playerHover = mousePos.x>topleft.x&&mousePos.x<bottomright.x&&mousePos.y>topleft.y&&mousePos.y<bottomright.y;

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

		const bool deadPlayer = (p.getBlob() is null || p.getBlob().hasTag("halfdead") || p.getBlob().hasTag("dead") || p.getBlob().hasTag("undead"))&&p.getTeamNum()!=getRules().getSpectatorTeamNum();
		u32 underlinecolor = col_darkgrey;
		
		u32 playercolour = p.isMyPlayer() ? col_gold : col_lightgrey;
		playercolour = deadPlayer ? col_deadred : playercolour;
		
		//u32 usercolor = kiwiBadge(username)?0xff00ff00:(p.getOldGold()?0xffffEE44:col_middlegrey);
		SColor usercolor = getNameColour(p);
		
		Vec2f username_actualsize = Vec2f_zero;
		GUI::GetTextDimensions(username, username_actualsize);
		
		if (playerHover)
		{
			playercolour = col_white;
			@hoveredPlayer = p;
			hoveredPos = topleft;
			hoveredPos.x = screen_dims.x*0.1;
		}

		f32 underline_shift = 3;
		
		if (infos_exist&&info.commanding&&false) {
			GUI::DrawPane(Vec2f(topleft.x-2, bottomright.y-34), Vec2f(bottomright.x+6, bottomright.y+4), SColor(playercolour));
			GUI::DrawPane(Vec2f(topleft.x+2, bottomright.y-30), Vec2f(bottomright.x+2, bottomright.y), SColor(underlinecolor));
		}
		
		GUI::DrawLine2D(Vec2f(topleft.x+4, bottomright.y + underline_shift + 1) + lineoffset, Vec2f(bottomright.x, bottomright.y + underline_shift + 1) + lineoffset, SColor(underlinecolor));
		GUI::DrawLine2D(Vec2f(topleft.x+4, bottomright.y + underline_shift) + lineoffset, Vec2f(bottomright.x, bottomright.y + underline_shift) + lineoffset, SColor(playercolour));

		int initial_rank = 0, rank_shift = 4, shift_value = 0;

		CBlob@ b = p.getBlob();
		
		initial_rank = rules.get_u8(username+"rank");
		initial_rank = infos_exist?info.rank:0;

		int player_rank = Maths::Min(initial_rank + rank_shift * shift_value, ranknames.size()-2);
		
		if (p.isMyPlayer())
			GUI::DrawIcon("localplayer_en.png", 0, Vec2f(64, 32), topleft + Vec2f(-128, -48), 1.0f, p.getTeamNum());
		Vec2f rank_icon_pos = topleft + Vec2f(4, -16);
		GUI::DrawIcon("ranks.png", player_rank, Vec2f(16, 16), rank_icon_pos, 1.0f, p.getTeamNum());
		
		if (mousePos.x > rank_icon_pos.x -4 && mousePos.x < rank_icon_pos.x + 24 && mousePos.y < rank_icon_pos.y + 24 && mousePos.y > rank_icon_pos.y -4)
		{
			hovered_rank = player_rank;
			hovered_pos = rank_icon_pos;
			hovered_player = i;
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
		SColor head_col(0xffffffff);

		if (b !is null)
		{
			headIndex = b.get_s32("head index");
			headTexture = b.get_string("head texture");
			teamIndex = b.getTeamNum();
			hatTexture = b.get_string("hat_name");
		} else {
			if (teamIndex!=getRules().getSpectatorTeamNum())
				head_col = col_deadred;
			//head_col = SColor(0xffaa0000);
			
			//there's no need to call all the calculations when we can just ask player blob what their head is
			headIndex = getHeadSpecs(p, headTexture);
		}
		

		if (headTexture != "")
		{
			GUI::DrawIcon(headTexture, headIndex, Vec2f(16, 16), topleft + Vec2f(32, -12), 1.0f, 1.0f, teamIndex, head_col);
		}
		
		if (hatTexture != "")
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
		u8 card_variants_amount = CFileImage("id_card_icon").getWidth()/16;
		Vec2f card_icon_pos = Vec2f(bottomright.x - info_icon_offset, topleft.y-8);
		GUI::DrawIcon("id_card_icon", p.getNetworkID()%card_variants_amount+(p.getOldGold()&&!p.isBot()?card_variants_amount:0), Vec2f(16, 16), card_icon_pos, 1.0f, 69);
		if (playerHover && mousePos.x > bottomright.x - info_icon_offset && mousePos.x < bottomright.x - info_icon_offset + 24)
		{
			if (hovered_card < 0) {
				hovered_card = i;
				hovered_pos = card_icon_pos;
			}
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
		if (hovered_rank > -1 && false) {
			drawRankPane(hovered_rank, rank_icon_pos, p.getTeamNum());
			drawHoverText(ranknames[hovered_rank], rank_icon_pos);
		}
		//hovered_rank = -1;
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

//todo make it a good way so it's not copy-pasted from kiwi_chat.as
CPlayer@ getPlayerByNamePart(string username)
{
	username = username.toLower();
	
	for (int i=0; i<getPlayerCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		string playerName = player.getUsername().toLower();
		string playerNickname = player.getCharacterName().toLower();
		
		bool match_in_username = playerName == username || (username.size()>=3 && playerName.findFirst(username,0)==0);
		bool match_in_nickname = playerNickname == username || (username.size()>=3 && playerNickname.findFirst(username,0)==0);
		
		if (match_in_username || match_in_nickname) return player;
	}
	return null;
}

void fillPlayerArraySortedByUsername( CPlayer@[] &out array, u8 team )
{
	string[] names;
	for (u32 i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ p = getPlayer(i);
		if (p is null) continue;
		if (p.getTeamNum()!=team) continue;
		
		names.push_back(p.getUsername().toLower());
	}
	names.sortAsc();
	for (u32 i = 0; i < names.size(); ++i)
	{
		CPlayer@ p = getPlayerByNamePart(names[i]);
		if (p is null) continue;
		array.push_back(p);
	}
}

void fillPlayerArraySortedByNickname( CPlayer@[] &out array, u8 team )
{
	string[] names;
	for (u32 i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ p = getPlayer(i);
		if (p is null) continue;
		if (p.getTeamNum()!=team) continue;
		
		names.push_back(p.getCharacterName().toLower());
	}
	names.sortAsc();
	for (u32 i = 0; i < names.size(); ++i)
	{
		CPlayer@ p = getPlayerByNamePart(names[i]);
		if (p is null) continue;
		array.push_back(p);
	}
}

void onRenderScoreboard(CRules@ this)
{
	RulesCore@ core;
	if (!getRules().get("core", @core)) return;
	CControls@ controls = getControls();
	//sort players
	CPlayer@[] blueplayers;
	CPlayer@[] redplayers;
	CPlayer@[] undead_players;
	
	CPlayer@[] spectators;
	
	u8 sorting = getRules().get_u8("sorting_type");
	bool sort_by_kills = sorting==0;
	bool sort_by_rank = sorting==1;
	bool sort_by_name = sorting==2;
	bool sort_by_nick = sorting==3;
	
	if (sort_by_name) {
		fillPlayerArraySortedByUsername(blueplayers, core.teams[0].index);
		fillPlayerArraySortedByUsername(redplayers, core.teams[1].index);
		fillPlayerArraySortedByUsername(undead_players, 3);
	} else if (sort_by_nick) {
		fillPlayerArraySortedByNickname(blueplayers, core.teams[0].index);
		fillPlayerArraySortedByNickname(redplayers, core.teams[1].index);
		fillPlayerArraySortedByNickname(undead_players, 3);
	}
	
	for (u32 i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ p = getPlayer(i);
		f32 kdr = getKDR(p);
		f32 kills = p.getKills();
		SoldatInfo@ p_info = getSoldatInfoFromUsername(p.getUsername());
		//@p_info = null;
		//if (p_info is null || p.getUsername()=="TheCustomerMan") continue;
		int rank = p_info is null ? 0 : p_info.rank;
		bool inserted = false;
		if (p.getTeamNum() == this.getSpectatorTeamNum())
		{
			spectators.push_back(p);
			continue;
		}

		int teamNum = p.getTeamNum();
		if (teamNum == core.teams[0].index && !sort_by_name && !sort_by_nick) //blue team
		{
			for (u32 j = 0; j < blueplayers.length; j++)
			{
				SoldatInfo@ team_p_info = getSoldatInfoFromUsername(blueplayers[j].getUsername());
				//if (team_p_info is null) continue;
				
				bool insert_kills = blueplayers[j].getKills() < kills;
				bool insert_rank = team_p_info is null ? false : team_p_info.rank < rank;
				
				if ((sort_by_kills && insert_kills) || (sort_by_rank && insert_rank))
				{
					blueplayers.insert(j, p);
					inserted = true;
					break;
				}
			}

			if (!inserted)
				blueplayers.push_back(p);

		}
		else if (teamNum == core.teams[1].index && !sort_by_name && !sort_by_nick) //red team
		{
			for (u32 j = 0; j < redplayers.length; j++)
			{
				SoldatInfo@ team_p_info = getSoldatInfoFromUsername(redplayers[j].getUsername());
				//if (team_p_info is null) continue;
				
				bool insert_kills = redplayers[j].getKills() < kills;
				bool insert_rank = team_p_info is null ? false : team_p_info.rank < rank;
				
				if ((sort_by_kills && insert_kills) || (sort_by_rank && insert_rank))
				{
					redplayers.insert(j, p);
					inserted = true;
					break;
				}
			}

			if (!inserted)
				redplayers.push_back(p);
			
		}
		else if (teamNum == 3 && !sort_by_name && !sort_by_nick) //undead team
		{
			for (u32 j = 0; j < undead_players.length; j++)
			{
				SoldatInfo@ team_p_info = getSoldatInfoFromUsername(undead_players[j].getUsername());
				//if (team_p_info is null) continue;
				
				bool insert_kills = undead_players[j].getKills() < kills;
				bool insert_rank = team_p_info is null ? false : team_p_info.rank < rank;
				
				if ((sort_by_kills && insert_kills) || (sort_by_rank && insert_rank))
				{
					undead_players.insert(j, p);
					inserted = true;
					break;
				}
			}

			if (!inserted)
				undead_players.push_back(p);
			
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
	topleft.y = drawServerInfo(40)+2;

	// start the scoreboard lower or higher.
	topleft.y -= scrollOffset;

	//(reset)
	hovered_accolade = -1;
	hovered_age = -1;
	hovered_tier = -1;

	//need those to know which array of players we should check for creating a player card
	Vec2f bluz_pane_tl();
	Vec2f bluz_pane_br();
	
	Vec2f redz_pane_tl();
	Vec2f redz_pane_br();
	
	Vec2f dedz_pane_tl();
	Vec2f dedz_pane_br();
	
	Vec2f spec_pane_tl();
	Vec2f spec_pane_br();
	
	//draw the scoreboards
	
	//in case we're in blue team we render it first and only after that we render scoreboard for an enemy team
	for (int renderedTeamNum = 0; renderedTeamNum < core.teams.size(); ++renderedTeamNum) {
		if (localTeam == core.teams[renderedTeamNum].index || (localTeam == this.getSpectatorTeamNum() && renderedTeamNum == 0)) {
			old_topleft_y = spec_topleft.y;
			spec_topleft.y = drawScoreboard(localPlayer, blueplayers, topleft, core.teams[0].index, bluz_pane_tl, bluz_pane_br);
			if (spec_topleft.y < old_topleft_y)
				spec_topleft.y = old_topleft_y;
		}
		else {
			old_topleft_y = spec_topleft.y;
			spec_topleft.y = drawScoreboard(localPlayer, redplayers, topleft, core.teams[1].index, redz_pane_tl, redz_pane_br);
			if (spec_topleft.y < old_topleft_y)
				spec_topleft.y = old_topleft_y;
		}
	}
	//print("from hook "+bluz_pane_tl+bluz_pane_br);
	
	if (undead_players.size()>0) {
		spec_topleft.y += 56;
		spec_topleft.y = drawScoreboard(localPlayer, undead_players, spec_topleft, 3, dedz_pane_tl, dedz_pane_br);
	}
	spec_topleft.y += 56;
	spec_topleft.y = drawScoreboard(localPlayer, spectators, spec_topleft, getRules().getSpectatorTeamNum(), spec_pane_tl, spec_pane_br);

	if (spectators.length > 0 && false)
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
	//Vec2f card_pos = Vec2f(left_side?topleft.x:getScreenWidth()/2, topleft.y)+Vec2f(getScreenWidth()/3.75, topleft.y-64+(23+9)*hovered_card);
	
	//have to keep the whole scoreboard offset in mind :>
	//card_pos.y -= scrollOffset;
	Vec2f card_topLeft = hovered_pos+Vec2f(-0.164f*screen_dims.x,0);
	card_topLeft = hovered_pos-Vec2f(playerCardDims.x/2, 0);
	Vec2f card_botRight = card_topLeft+Vec2f(playerCardDims.x,playerCardDims.y);
	bool click_to_close = controls.mousePressed1;
	bool left_card_bounds = mousePos.y>card_botRight.y||mousePos.y<card_topLeft.y||mousePos.x>card_botRight.x||mousePos.x<card_topLeft.x;
	if (click_to_close||left_card_bounds) {
		//debug thing to check the borderlines
		if (g_debug > 0 && hovered_card > -1)
		GUI::DrawBubble(card_topLeft, card_botRight);
		
		hovered_card = -1;
	}
	
	bool on_blue_pane = hovered_pos.x>bluz_pane_tl.x&&hovered_pos.x<bluz_pane_br.x&&hovered_pos.y>bluz_pane_tl.y&&hovered_pos.y<bluz_pane_br.y;
	bool on_red_pane = hovered_pos.x>redz_pane_tl.x&&hovered_pos.x<redz_pane_br.x&&hovered_pos.y>redz_pane_tl.y&&hovered_pos.y<redz_pane_br.y;
	bool on_purp_pane = hovered_pos.x>dedz_pane_tl.x&&hovered_pos.x<dedz_pane_br.x&&hovered_pos.y>dedz_pane_tl.y&&hovered_pos.y<dedz_pane_br.y;
	bool on_spec_pane = hovered_pos.x>spec_pane_tl.x&&hovered_pos.x<spec_pane_br.x&&hovered_pos.y>spec_pane_tl.y&&hovered_pos.y<spec_pane_br.y;
	
	if (hovered_card != -1) {
		CPlayer@ player = null;
		
		if (on_blue_pane) {
			if (blueplayers.size()>hovered_card) @player = blueplayers[hovered_card];
		}
		if (on_red_pane) {
			if (redplayers.size()>hovered_card) @player = redplayers[hovered_card];
		}
		if (on_purp_pane) {
			if (undead_players.size()>hovered_card) @player = undead_players[hovered_card];
		}
		if (on_spec_pane) {
			if (spectators.size()>hovered_card) @player = spectators[hovered_card];
		}
		
		//prevent algorythm from drawing card which doesn't fit on screen
		f32 outbounds_y_difference = card_botRight.y-getDriver().getScreenHeight()+32.0f/704*getDriver().getScreenHeight();
		//do something about drawing position if it doesn't fit
		if (outbounds_y_difference>0) {
			card_topLeft = Vec2f(card_topLeft.x, card_topLeft.y-outbounds_y_difference);
		}
		
		if (player !is null) {
			makePlayerCard(player, card_topLeft);
		}
	}
	
	if (hovered_rank > -1) {
		CPlayer@ player = null;
		
		if (on_blue_pane) {
			if (blueplayers.size()>hovered_player) @player = blueplayers[hovered_player];
		}
		if (on_red_pane) {
			if (redplayers.size()>hovered_player) @player = redplayers[hovered_player];
		}
		if (on_purp_pane) {
			if (undead_players.size()>hovered_player) @player = undead_players[hovered_player];
		}
		if (on_spec_pane) {
			if (spectators.size()>hovered_player) @player = spectators[hovered_player];
		}
		
		drawRankPane(hovered_rank, hovered_pos, player.getTeamNum());
		drawHoverText(ranknames[hovered_rank], hovered_pos);
		hovered_rank = -1;
	}

	//old vanilla func
	//drawPlayerCard(hoveredPlayer, hoveredPos);

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
	this.set_u8("sorting_type", 1);
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
