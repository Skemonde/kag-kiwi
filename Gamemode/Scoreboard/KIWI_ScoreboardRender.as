#include "KIWI_Scoreboard.as";
#include "Accolades.as";
#include "ColoredNameToggleCommon.as";
#include "SocialStatus.as";
#include "KIWI_Locales.as";

CPlayer@ hoveredPlayer;
Vec2f hoveredPos;

int hovered_rank = -1;
int hovered_accolade = -1;
int hovered_age = -1;
int hovered_tier = -1;
int hovered_ping = -1;
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

string[] age_description = {
	"New Player - Welcome them to the game!",
	//first month
	"This player has 1 to 2 weeks of experience",
	"This player has 2 to 3 weeks of experience",
	"This player has 3 to 4 weeks of experience",
	//first year
	"This player has 1 to 2 months of experience",
	"This player has 2 to 3 months of experience",
	"This player has 3 to 6 months of experience",
	"This player has 6 to 9 months of experience",
	"This player has 9 to 12 months of experience",
	//cake day
	"Cake Day - it's this player's KAG Birthday!",
	//(gap in the sheet)
	"", "", "", "", "", "",
	//established player
	"This player has 1 year of experience",
	"This player has 2 years of experience",
	"This player has 3 years of experience",
	"This player has 4 years of experience",
	"This player has 5 years of experience",
	"This player has 6 years of experience",
	"This player has 7 years of experience",
	"This player has 8 years of experience",
	"This player has 9 years of experience",
	"This player has over a decade of experience"
};

string[] tier_description = {
	"", //f2p players, no description
	"This player is a Squire Supporter",
	"This player is a Knight Supporter",
	"This player is a Royal Guard Supporter",
	"This player is a Round Table Supporter"
};

//returns the bottom
float drawScoreboard(CPlayer@ localplayer, CPlayer@[] players, Vec2f topleft, CTeam@ team, u8 team_num)
{
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
	Vec2f bottomright(getScreenWidth()/2-boardsgap, topleft.y + (players.length + 5.5) * stepheight);
	//what team will be on the right side?
	//if player is in spectators red is always on the right side
	//otherwise right side is for enemy team
	if (left_scoreboard) {
		topleft = Vec2f(bottomright.x+boardsgap*2, topleft.y);
		bottomright = Vec2f(bottomright.x+boardsgap*2+pane_length, bottomright.y);
	}
	SColor team_col = SColor(175, team.color.getRed(), team.color.getGreen(), team.color.getBlue());
	//GUI::DrawFramedPane(topleft-Vec2f(4,4), bottomright+Vec2f(4,4));
	GUI::DrawPane(topleft, bottomright, team_col);

	//offset border
	topleft.x += stepheight;
	bottomright.x -= stepheight;
	topleft.y += stepheight;

	GUI::SetFont("menu");

	//draw team info
	GUI::DrawIcon("Emblems.png", team_num, Vec2f(32, 32), topleft-Vec2f(16,24), 1.0f);
	string team_name = team.getName();
	GUI::DrawText(team_name, Vec2f(topleft.x + 48, topleft.y), SColor(col_white));
	//GUI::DrawText(getTranslatedString("Players: {PLAYERCOUNT}").replace("{PLAYERCOUNT}", "" + players.length), Vec2f(bottomright.x - 400, topleft.y), SColor(0xffffffff));

	topleft.y += stepheight * 2;

	const int accolades_start = 770;
	const int age_start = accolades_start + 80;

	draw_age = false;
	for(int i = 0; i < players.length; i++) {
		if (players[i].getRegistrationTime() > 0) {
			//draw_age = true;
			break;
		}
	}

	draw_tier = false;
	for(int i = 0; i < players.length; i++) {
		if (players[i].getSupportTier() > 0) {
			//draw_tier = true;
			break;
		}
	}
	const int tier_start = (draw_age ? age_start : accolades_start) + 70;
	
	f32 rank_offset = 0;
	f32 nickname_offset = 64;
	f32 kag_username_offset = nickname_offset + 160;
	f32 ping_offset = kag_username_offset + 160;
	f32 kills_offset = ping_offset + 64;
	f32 deaths_offset = kills_offset + 64;
	//draw player table header
	GUI::DrawText(Descriptions::rank, topleft, SColor(col_white));
	GUI::DrawText(Descriptions::nickname, Vec2f(topleft.x + nickname_offset, topleft.y), SColor(col_white));
	GUI::DrawText(Descriptions::username, Vec2f(topleft.x + kag_username_offset, topleft.y), SColor(col_white));
	GUI::DrawText(Descriptions::ping, Vec2f(topleft.x + ping_offset, topleft.y), SColor(col_white));
	GUI::DrawText(Descriptions::kills, Vec2f(topleft.x + kills_offset, topleft.y), SColor(col_white));
	//GUI::DrawText("Deaths", Vec2f(bottomright.x - deaths_offset, topleft.y), SColor(0xffffffff));
	//GUI::DrawText(getTranslatedString("Assists"), Vec2f(bottomright.x - 120, topleft.y), SColor(0xffffffff));
	//GUI::DrawText("Score", Vec2f(bottomright.x - 50, topleft.y), SColor(0xffffffff));
	//GUI::DrawText(getTranslatedString("Accolades"), Vec2f(bottomright.x - accolades_start, topleft.y), SColor(0xffffffff));
	if(draw_age)
	{
		GUI::DrawText(getTranslatedString("Age"), Vec2f(bottomright.x - age_start, topleft.y), SColor(col_white));
	}
	if(draw_tier)
	{
		GUI::DrawText(getTranslatedString("Tier"), Vec2f(bottomright.x - tier_start, topleft.y), SColor(col_white));
	}

	topleft.y += stepheight * 0.25f;

	CControls@ controls = getControls();
	Vec2f mousePos = controls.getMouseScreenPos();

	//draw players
	for (u32 i = 0; i < players.length; i++)
	{
		CPlayer@ p = players[i];

		topleft.y += stepheight;
		bottomright.y = topleft.y + lineheight;

		bool playerHover = mousePos.y > topleft.y && mousePos.y < topleft.y + 15
			&& ((left_scoreboard && mousePos.x > getScreenWidth()/2) || (!left_scoreboard && mousePos.x < getScreenWidth()/2)) ;

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
		
		u32 playercolour = deadPlayer ? col_deadred : col_lightgrey;
		
		playercolour = p.isMyPlayer() ? col_gold : playercolour;
		u32 usercolor = col_middlegrey;
		
		string username = p.getUsername();
		Vec2f username_actualsize = Vec2f_zero;
		string title = getStatus(username, usercolor, p);
		GUI::GetTextDimensions(username, username_actualsize);
		
		if (playerHover && mousePos.x > topleft.x + kag_username_offset && mousePos.x < topleft.x + kag_username_offset + username_actualsize.x)
		{
			if (!title.empty())
				drawHoverText(title, Vec2f(topleft.x + kag_username_offset + username_actualsize.x/2, topleft.y+32), usercolor);
		}
		
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

		/* string tex = "";
		u16 frame = 0;
		Vec2f framesize;
		if (p.isMyPlayer())
		{
			tex = "ScoreboardIcons.png";
			frame = 4;
			framesize.Set(16, 16);
		}
		else
		{
			tex = p.getScoreboardTexture();
			frame = p.getScoreboardFrame();
			framesize = p.getScoreboardFrameSize();
		}
		if (tex != "")
		{
			GUI::DrawIcon(tex, frame, framesize, topleft, 0.5f, p.getTeamNum());
		} */

		int initial_rank = 0, rank_shift = 4, shift_value = 0;

		CBlob@ b = p.getBlob();
		
		if (b !is null) {
			if (p.getBlob().hasTag("general") || username == "TheCustomerMan")
				initial_rank = 2;
			else if (p.getBlob().hasTag("officer") || p.getBlob().hasTag("commander"))
				shift_value = 1;
		}
		initial_rank = Maths::Floor(p.getKills()/33);

		int player_rank = initial_rank + rank_shift * shift_value;
		
		if (p.isMyPlayer())
			GUI::DrawIcon("localplayer.png", 0, Vec2f(16, 16), topleft + Vec2f(-32, -16), 1.0f, p.getTeamNum());
		GUI::DrawIcon("ranks.png", player_rank, Vec2f(16, 16), topleft + Vec2f(0, -16), 1.0f, p.getTeamNum());
		
		if (playerHover && mousePos.x > topleft.x && mousePos.x < topleft.x + 16)
		{
			hovered_rank = player_rank;
		}

		string playername = p.getCharacterName();
		string clantag = p.getClantag();

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
		string headTexture = "";
		int teamIndex = p.getTeamNum();

		if (b !is null)
		{
			headIndex = b.get_s32("head index");
			headTexture = b.get_string("head texture");
			teamIndex = b.get_s32("head team");
		}
		//it doesn't look good design-wise
		/* 
		else {
			headIndex = 0;
			headTexture = "kag_skull.png";
			teamIndex = 69;
		} */

		if (headTexture != "")
		{
			GUI::DrawIcon(headTexture, headIndex, Vec2f(16, 16), topleft + Vec2f(32, -12), 1.0f, teamIndex);
		}

		//have to calc this from ticks
		s32 ping_in_ms = s32(p.getPing() * 1000.0f / 30.0f);

		//how much room to leave for names and clantags
		Vec2f clantag_actualsize(0, 0);

		//render the player + stats
		SColor namecolour = playercolour;
		//SColor namecolour = getNameColour(p);

		//right align clantag
		if (clantag != "")
		{
			GUI::GetTextDimensions(clantag, clantag_actualsize);
			GUI::DrawText(clantag, topleft + Vec2f(nickname_offset, 0), SColor(col_middlegrey));
			//draw name alongside
			GUI::DrawText(playername, topleft + Vec2f(nickname_offset + clantag_actualsize.x + 8, 0), namecolour);
		}
		else
		{
			//draw name alone
			GUI::DrawText(playername, topleft + Vec2f(nickname_offset, 0), namecolour);
		}

		//draw account age indicator
		if (draw_age)
		{
			int regtime = p.getRegistrationTime();
			if (regtime > 0)
			{
				int reg_month = Time_Month(regtime);
				int reg_day = Time_MonthDate(regtime);
				int reg_year = Time_Year(regtime);

				int days = Time_DaysSince(regtime);

				int age_icon_start = 32;
				int icon = 0;
				//less than a month?
				if (days < 28)
				{
					int week = days / 7;
					icon = week;
				}
				else
				{
					//we use 30 day "months" here
					//for simplicity and consistency of badge allocation
					int months = days / 30;
					if (months < 12)
					{
						switch(months) {
							case 0:
							case 1:
								icon = 0;
								break;
							case 2:
								icon = 1;
								break;
							case 3:
							case 4:
							case 5:
								icon = 2;
								break;
							case 6:
							case 7:
							case 8:
								icon = 3;
								break;
							case 9:
							case 10:
							case 11:
							default:
								icon = 4;
								break;
						}
						icon += 4;
					}
					else
					{
						//figure out birthday
						int month_delta = Time_Month() - reg_month;
						int day_delta = Time_MonthDate() - reg_day;
						int birthday_delta = -1;

						if (month_delta < 0 || month_delta == 0 && day_delta < 0)
						{
							birthday_delta = -1;
						}
						else if (month_delta == 0 && day_delta == 0)
						{
							birthday_delta = 0;
						}
						else
						{
							birthday_delta = 1;
						}

						//check if its cake day
						if (birthday_delta == 0)
						{
							icon = 9;
						}
						else
						{
							//check if we're in the extra "remainder" days from using 30 month days
							if(days < 366)
							{
								//(9 months badge still)
								icon = 8;
							}
							else
							{
								//years delta
								icon = (Time_Year() - reg_year) - 1;
								//before or after birthday?
								if (birthday_delta == -1)
								{
									icon -= 1;
								}
								//ensure sane
								icon = Maths::Clamp(icon, 0, 9);
								//shift line
								icon += 16;
							}
						}
					}
				}

				float x = bottomright.x - age_start + 8;
				float extra = 8;
				GUI::DrawIcon("AccoladeBadges", age_icon_start + icon, Vec2f(16, 16), Vec2f(x, topleft.y), 0.5f, p.getTeamNum());

				if (playerHover && mousePos.x > x - extra && mousePos.x < x + 16 + extra)
				{
					hovered_age = icon;
				}
			}

		}

		//draw support tier
		if(draw_tier)
		{
			int tier = p.getSupportTier();

			if(tier > 0)
			{
				int tier_icon_start = 15;
				float x = bottomright.x - tier_start + 8;
				float extra = 8;
				GUI::DrawIcon("AccoladeBadges", tier_icon_start + tier, Vec2f(16, 16), Vec2f(x, topleft.y), 0.5f, p.getTeamNum());

				if (playerHover && mousePos.x > x - extra && mousePos.x < x + 16 + extra)
				{
					hovered_tier = tier;
				}
			}

		}

		//render player accolades
		Accolades@ acc = getPlayerAccolades(username);
		if (false)
		{
			//(remove crazy amount of duplicate code)
			int[] badges_encode = {
				//count,                icon,  show_text, group

				//misc accolades
				(acc.community_contributor ?
					1 : 0),             4,     0,         0,
				(acc.github_contributor ?
					1 : 0),             5,     0,         0,
				(acc.map_contributor ?
					1 : 0),             6,     0,         0,
				(acc.moderation_contributor && (
						//always show accolade of others if local player is special
						(p !is localplayer && isSpecial(localplayer)) ||
						//always show accolade for ex-admins
						!isSpecial(p) ||
						//show accolade only if colored name is visible
						coloredNameEnabled(getRules(), p)
					) ?
					1 : 0),             7,     0,         0,
				(p.getOldGold() ?
					1 : 0),             8,     0,         0,

				//tourney badges
				acc.gold,               0,     1,         1,
				acc.silver,             1,     1,         1,
				acc.bronze,             2,     1,         1,
				acc.participation,      3,     1,         1,

				//(final dummy)
				0, 0, 0, 0,
			};
			//encoding per-group
			int[] group_encode = {
				//singles
				accolades_start,                 24,
				//medals
				accolades_start - (24 * 5 + 12), 38,
			};

			for(int bi = 0; bi < badges_encode.length; bi += 4)
			{
				int amount    = badges_encode[bi+0];
				int icon      = badges_encode[bi+1];
				int show_text = badges_encode[bi+2];
				int group     = badges_encode[bi+3];

				int group_idx = group * 2;

				if(
					//non-awarded
					amount <= 0
					//erroneous
					|| group_idx < 0
					|| group_idx >= group_encode.length
				) continue;

				int group_x = group_encode[group_idx];
				int group_step = group_encode[group_idx+1];

				float x = bottomright.x - group_x;

				GUI::DrawIcon("AccoladeBadges", icon, Vec2f(16, 16), Vec2f(x, topleft.y), 0.5f, p.getTeamNum());
				if (show_text > 0)
				{
					string label_text = "" + amount;
					int label_center_offset = label_text.size() < 2 ? 4 : 0;
					GUI::DrawText(
						label_text,
						Vec2f(x + 15 + label_center_offset, topleft.y),
						SColor(0xffffffff)
					);
				}

				if (playerHover && mousePos.x > x && mousePos.x < x + 16)
				{
					hovered_accolade = icon;
				}

				//handle repositioning
				group_encode[group_idx] -= group_step;

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

		//small test how ping icons look ingame :P
		/* if (!p.exists("pen"))
			p.set_u8("pen", XORRandom(5));
		else
			ping_icon_index = p.get_u8("pen"); */
			
		if (playerHover && mousePos.x > topleft.x + ping_offset && mousePos.x < topleft.x + ping_offset + 16 + 6)
		{
			drawHoverText(formatFloat(ping_in_ms, "", 0, 0)+" ms ", Vec2f(topleft.x + ping_offset - 32, topleft.y));
		}
			
		GUI::DrawIcon("ping_icons.png", ping_icon_index, Vec2f(16, 16), Vec2f(topleft.x + ping_offset, topleft.y-16), 1.0f, 69);
		//GUI::DrawText("" + ping_in_ms, Vec2f(bottomright.x - 330, topleft.y), SColor(0xffffffff));
		GUI::DrawText("" + p.getKills(), Vec2f(topleft.x + kills_offset, topleft.y), SColor(0xffffffff));
		//GUI::DrawText("" + p.getDeaths(), Vec2f(bottomright.x - deaths_offset, topleft.y), SColor(0xffffffff));
		//GUI::DrawText("" + p.getAssists(), Vec2f(bottomright.x - 120, topleft.y), SColor(0xffffffff));
		//GUI::DrawText("" + formatFloat(getSkillScore(p), "", 0, 0), Vec2f(bottomright.x - 50, topleft.y), SColor(0xffffffff));
	}

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

void onRenderScoreboard(CRules@ this)
{
	//sort players
	CPlayer@[] blueplayers;
	CPlayer@[] redplayers;
	CPlayer@[] greenplayers;
	CPlayer@[] purpleplayers;
	CPlayer@[] spectators;
	for (u32 i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ p = getPlayer(i);
		f32 kdr = getKDR(p);
		bool inserted = false;
		if (p.getTeamNum() == this.getSpectatorTeamNum())
		{
			spectators.push_back(p);
			continue;
		}

		int teamNum = p.getTeamNum();
		if (teamNum == 0) //blue team
		{
			for (u32 j = 0; j < blueplayers.length; j++)
			{
				if (getKDR(blueplayers[j]) < kdr)
				{
					blueplayers.insert(j, p);
					inserted = true;
					break;
				}
			}

			if (!inserted)
				blueplayers.push_back(p);

		}
		else if (teamNum == 1) //red team
		{
			for (u32 j = 0; j < redplayers.length; j++)
			{
				if (getKDR(redplayers[j]) < kdr)
				{
					redplayers.insert(j, p);
					inserted = true;
					break;
				}
			}

			if (!inserted)
				redplayers.push_back(p);

		}
		else if (teamNum == 2) //red team
		{
			for (u32 j = 0; j < greenplayers.length; j++)
			{
				if (getKDR(greenplayers[j]) < kdr)
				{
					greenplayers.insert(j, p);
					inserted = true;
					break;
				}
			}

			if (!inserted)
				greenplayers.push_back(p);

		}
		else if (teamNum == 3) //red team
		{
			for (u32 j = 0; j < purpleplayers.length; j++)
			{
				if (getKDR(purpleplayers[j]) < kdr)
				{
					purpleplayers.insert(j, p);
					inserted = true;
					break;
				}
			}

			if (!inserted)
				purpleplayers.push_back(p);

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
	//first we draw a board for team player is in
	/* switch (localTeam) {
		case 0:
			old_topleft_y = spec_topleft.y;
			spec_topleft.y = drawScoreboard(localPlayer, blueplayers, topleft, this.getTeam(localTeam), localTeam);
			if (spec_topleft.y < old_topleft_y)
				spec_topleft.y = old_topleft_y;
			break;
		case 1:
			old_topleft_y = spec_topleft.y;
			spec_topleft.y = drawScoreboard(localPlayer, redplayers, topleft, this.getTeam(localTeam), localTeam);
			if (spec_topleft.y < old_topleft_y)
				spec_topleft.y = old_topleft_y;
			//print("hey red");
			break;
		case 2:
			old_topleft_y = spec_topleft.y;
			spec_topleft.y = drawScoreboard(localPlayer, greenplayers, topleft, this.getTeam(localTeam), localTeam);
			if (spec_topleft.y < old_topleft_y)
				spec_topleft.y = old_topleft_y;
			//print("hey grun");
			break;
		case 3:
			old_topleft_y = spec_topleft.y;
			spec_topleft.y = drawScoreboard(localPlayer, purpleplayers, topleft, this.getTeam(localTeam), localTeam);
			if (spec_topleft.y < old_topleft_y)
				spec_topleft.y = old_topleft_y;
			break;
	} */

	//in case we're in blue team we render it first and only after that we render scoreboard for an enemy team
	if (localTeam == 0) {
		old_topleft_y = spec_topleft.y;
		spec_topleft.y = drawScoreboard(localPlayer, blueplayers, topleft, this.getTeam(0), 0);
		if (spec_topleft.y < old_topleft_y)
			spec_topleft.y = old_topleft_y;
	}
	else {
		old_topleft_y = spec_topleft.y;
		spec_topleft.y = drawScoreboard(localPlayer, redplayers, topleft, this.getTeam(1), 1);
		if (spec_topleft.y < old_topleft_y)
			spec_topleft.y = old_topleft_y;
	}

	if (localTeam == 1) {
		old_topleft_y = spec_topleft.y;
		spec_topleft.y = drawScoreboard(localPlayer, blueplayers, topleft, this.getTeam(0), 0);
		if (spec_topleft.y < old_topleft_y)
			spec_topleft.y = old_topleft_y;
	}
	else {
		old_topleft_y = spec_topleft.y;
		spec_topleft.y = drawScoreboard(localPlayer, redplayers, topleft, this.getTeam(1), 1);
		if (spec_topleft.y < old_topleft_y)
			spec_topleft.y = old_topleft_y;
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
	CControls@ controls = getControls();

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

	drawPlayerCard(hoveredPlayer, hoveredPos);

	drawHoverExplanation(hovered_accolade, hovered_age, hovered_tier, Vec2f(getScreenWidth() * 0.5, topleft.y));

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

void drawHoverExplanation(int hovered_accolade, int hovered_age, int hovered_tier, Vec2f centre_top)
{
	if( //(invalid/"unset" hover)
		(hovered_accolade < 0
		 || hovered_accolade >= accolade_description.length) &&
		(hovered_age < 0
		 || hovered_age >= age_description.length) &&
		(hovered_tier < 0
		 || hovered_tier >= tier_description.length)
	) {
		return;
	}

	string desc = getTranslatedString(
		(hovered_accolade >= 0) ?
			accolade_description[hovered_accolade] :
			hovered_age >= 0 ?
				age_description[hovered_age] :
				tier_description[hovered_tier]
	);

	Vec2f size(0, 0);
	GUI::GetTextDimensions(desc, size);

	Vec2f tl = centre_top - Vec2f(size.x / 2, 0);
	Vec2f br = tl + size;

	//margin
	Vec2f expand(8, 8);
	tl -= expand;
	br += expand;

	GUI::DrawPane(tl, br, SColor(0xffffffff));
	GUI::DrawText(desc, tl + expand, SColor(0xffffffff));
}

void onTick(CRules@ this)
{
	if(isServer() && this.getCurrentState() == GAME)
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
