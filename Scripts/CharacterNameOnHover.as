#include "Skemlib"
#include "SoldatInfo"
#include "Ranklist"

void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;

	CBlob@ blob = this.getBlob();
	Vec2f center = blob.getPosition();
	Vec2f mouseWorld = getControls().getMouseWorldPos();
	const f32 renderRadius = (blob.getRadius()) * 3;
	bool mouseOnBlob = (mouseWorld - center).getLength() < renderRadius;
	CPlayer@ player = blob.getPlayer();
	
	string clantag = "";
	string charactername = "";
	string username = "";
	
	SColor ordinary_clantag = SColor(0xff808080);
	SColor special_clantag = SColor(0xff7becbf);
	SColor clantag_col = ordinary_clantag;
	
	if (player !is null) {
		bool isBot = player.isBot();
		username = player.getUsername();
		if (isBot) {
			clantag = "Bot ";
			clantag_col = special_clantag;
		} else {
			clantag = player.getClantag()+" ";
		}
		// character name consists of clantag as well so it should be rendered as some players use a blank charname and clantag for a name
		charactername = player.getCharacterName();
	}
	else {
		bool isSleeper = !(blob.get_string("sleeper_name").empty()||!blob.exists("sleeper_name"));
		bool hasNoPlayer = !blob.hasTag("dead")&&!blob.hasTag("bot")||blob.isBot();
		//bool isBot 
		
		// check if player blob has player binded to it
		// if it doesn't have a player check if it's a bot or a sleeper
		//
		// mook is a word for a stupid or incompetent person
		// in vanilla this word is used for bots :P
		// i kinda love it
		
		if (hasNoPlayer) {
			clantag = "Mook ";
			clantag_col = special_clantag;
			if (isSleeper)
				clantag = "Unconscious ";
		} else {
			clantag = "";
		}
		//clantag = hasNoPlayer?(isSleeper?"Unconscious ":"Mook "):"";
		
		charactername = blob.getInventoryName();
		
		// still can check for rank even if player left
		if (blob.exists("sleeper_name") && !blob.get_string("sleeper_name").empty()) {
			username = blob.get_string("sleeper_name");
		}
	}
	
	CBlob@ localblob = getLocalPlayerBlob();
	CPlayer@ local = getLocalPlayer();
	
	bool specs = local !is null && local.getTeamNum()==getRules().getSpectatorTeamNum();
	
	bool teammate = false;
	bool displayOwnName = true;
	if (localblob !is null) {
		teammate = blob.getTeamNum() == localblob.getTeamNum() && player !is null;
		displayOwnName = blob !is localblob;
	}
	bool teammates_displaying = u_shownames && localblob !is null && teammate;
	// sitting will make enemies incapable of seeing your name
	bool should_display = displayOwnName && (!blob.isKeyPressed(key_down)&&!teammate||teammate);
	
	if ((mouseOnBlob || teammates_displaying) && should_display || specs)
	{
		bool has_rank = getRules().exists(username+"rank");
		Vec2f name_dims = Vec2f_zero;
		Vec2f clan_dims = Vec2f_zero;
		GUI::SetFont("menu");
		GUI::GetTextDimensions(charactername, name_dims);
		GUI::GetTextDimensions(clantag+"  ", clan_dims);
		Vec2f display_dims = Vec2f(clan_dims.x+name_dims.x, name_dims.y>clan_dims.y?name_dims.y:clan_dims.y);
		
		Vec2f pos2d = blob.getInterpolatedScreenPos() + Vec2f(0, 20);
		Vec2f topLeft = pos2d+Vec2f(0, 16) - (display_dims/2+Vec2f(4,0)+(mouseOnBlob&&has_rank?Vec2f(24,0):Vec2f_zero));
		Vec2f botRight = pos2d+Vec2f(0, 16) + (display_dims/2+Vec2f(8,4));
		
		u8 teamnum = Maths::Min(blob.getTeamNum(), 7);
		SColor name_color = GetColorFromTeam(teamnum);
		SColor squad_seven_color = GetColorFromTeam(7);
		
		GUI::DrawRectangle(topLeft, botRight, SColor(mouseOnBlob?192:64,0,0,0));
		
		bool not_so_far = (localblob !is null && (blob.getPosition()-localblob.getPosition()).Length()<256);
		
		if (mouseOnBlob && (specs || teammate || not_so_far))
			drawHealthBar(blob, topLeft, botRight);
		
		GUI::DrawTextCentered(charactername, pos2d+Vec2f(0, 16)+Vec2f(clan_dims.x/2,0), name_color);
		GUI::DrawTextCentered(clantag, pos2d+Vec2f(0, 16)+Vec2f(-name_dims.x/2,0), clantag_col);
		
		if (has_rank && mouseOnBlob) {
			SoldatInfo@ info = getSoldatInfoFromUsername(player.getUsername());
			bool infos_exist = info !is null;
			if (!infos_exist) return;
		
			u8 player_rank = Maths::Min(ranknames.size()-1, info.rank);
			string rankname = "Platoon Leader";
			if (player_rank < 4)
				rankname = ranknames[player_rank]+" "+blob.getInventoryName();
			else
				rankname = ranknames[player_rank];
			Vec2f rankname_dims;
			GUI::GetTextDimensions(rankname, rankname_dims);
			f32 x_shift = Maths::Max(rankname_dims.x, display_dims.x);
			GUI::DrawIcon("ranks.png", player_rank, Vec2f(16,16), pos2d+Vec2f(-display_dims.x/2-28, -5), 1.0f, blob.getTeamNum());
			//GUI::DrawText(rankname, pos2d+Vec2f(-x_shift/2, 32), squad_seven_color);
		}
	}
}

void drawHealthBar(CBlob@ blob, Vec2f old_tl, Vec2f old_br)
{
	//if (blob.getHealth()<=0) return;
	//this should only take your attention when your friend/enemy is hurt
	//if (blob.getHealth()>=blob.getInitialHealth()) return;
	const u8 MIN_BAR_WIDTH = 2;
	
	f32 health_percentage = Maths::Clamp(blob.getHealth()/blob.getInitialHealth(), 0, 1.0f);
	f32 red_tint = health_percentage;
	if (blob.getHealth()<=0) {
		health_percentage = Maths::Clamp(1-blob.getHealth()/blob.get_f32("death health"), 0, 1.0f);
		red_tint = 0.01f;
	}
	SColor hp_bar_col;
	hp_bar_col.setAlpha(255);
	hp_bar_col.setRed(Maths::Clamp(255-512*(red_tint-0.7f), 0, 255));
	hp_bar_col.setGreen(Maths::Clamp(255*(red_tint+0.3f), 0, 255));
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
	
	Vec2f tl = old_tl+Vec2f(0, old_br.y-old_tl.y);
	Vec2f br = old_br+Vec2f(0, old_br.y-old_tl.y);
	
	Vec2f hp_bar_dims = Vec2f(br.x-tl.x, br.y-tl.y);
	
	GUI::DrawRectangle(tl, br, SColor(192,0,0,0));
	GUI::DrawRectangle(tl+Vec2f(1, 1)*2, br-Vec2f(1, 1)*2, hp_bar2_col);
	GUI::DrawRectangle(tl+Vec2f(1, 1)*4, br-Vec2f(1, 1)*4, SColor(255,0,0,0));
	f32 ratio = blob.getHealth() / blob.getInitialHealth();
	const u8 MIN_LEN = 2;
	u16 hp_bar_len = Maths::Clamp(Maths::Ceil(((br.x-4)-(tl.x+4))*health_percentage/MIN_LEN)*MIN_LEN, MIN_LEN*3, (br.x-tl.x-8)/1);
	GUI::DrawRectangle(tl+Vec2f(1, 1)*4, Vec2f(tl.x+hp_bar_len+4, br.y-4), hp_bar_col);
	GUI::DrawRectangle(tl+Vec2f(1, 2)*4, Vec2f(tl.x+hp_bar_len+4, br.y-6), hp_bar3_col);
	
	u16 health_width = Maths::Max(4, Maths::Round(hp_bar_dims.x*health_percentage/MIN_BAR_WIDTH)*MIN_BAR_WIDTH);
	
	f32 healthbar_width = hp_bar_dims.x-4;
	u16 cell_amount = Maths::Round(blob.getInitialHealth()*20/25);
	for (int cell = 0; cell< cell_amount-1; ++cell) {
		u16 current_x = Maths::Round((cell+1)*((healthbar_width)/(cell_amount))/MIN_BAR_WIDTH)*MIN_BAR_WIDTH;
		Vec2f current_pos = Vec2f(tl.x+2+current_x, tl.y);
		GUI::DrawRectangle(current_pos+Vec2f(0, 1.0f*2/30*hp_bar_dims.y+3), current_pos+Vec2f(2, hp_bar_dims.y-4), current_x<(health_width-2)?hp_bar2_col:hp_bar3_col);
	}
	//GUI::DrawText(""+blob.getHealth()*20, Vec2f(tl.x, br.y-18), SColor(0xffffffff));
}