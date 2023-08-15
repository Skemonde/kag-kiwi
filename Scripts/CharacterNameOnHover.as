#include "Skemlib"
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
	bool teammate = false;
	bool displayOwnName = true;
	if (localblob !is null) {
		teammate = blob.getTeamNum() == localblob.getTeamNum() && player !is null;
		displayOwnName = blob !is localblob;
	}
	bool teammates_displaying = u_shownames && localblob !is null && teammate;
	// sitting will make enemies incapable of seeing your name
	bool should_display = displayOwnName && (!blob.isKeyPressed(key_down)&&!teammate||teammate);
	
	if ((mouseOnBlob || teammates_displaying) && should_display)
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
		
		GUI::DrawRectangle(topLeft, botRight, SColor(mouseOnBlob?1927:64,0,0,0));
		GUI::DrawTextCentered(charactername, pos2d+Vec2f(0, 16)+Vec2f(clan_dims.x/2,0), name_color);
		GUI::DrawTextCentered(clantag, pos2d+Vec2f(0, 16)+Vec2f(-name_dims.x/2,0), clantag_col);
		
		if (has_rank && mouseOnBlob) {
			u8 player_rank = Maths::Min(ranknames.size()-1, getRules().get_u8(username+"rank"));
			string rankname = "Platoon Leader";
			if (player_rank < 4)
				rankname = ranknames[player_rank]+" "+blob.getInventoryName();
			else
				rankname = ranknames[player_rank];
			Vec2f rankname_dims;
			GUI::GetTextDimensions(rankname, rankname_dims);
			f32 x_shift = Maths::Max(rankname_dims.x, display_dims.x);
			GUI::DrawIcon("ranks.png", player_rank, Vec2f(16,16), pos2d+Vec2f(-display_dims.x/2-28, -5), 1.0f);
			//GUI::DrawText(rankname, pos2d+Vec2f(-x_shift/2, 32), squad_seven_color);
		}
	}
}