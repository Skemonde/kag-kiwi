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
	string charactername = "";
	string username = "";
	if (player !is null) {
		charactername = player.getCharacterName();
		username = player.getUsername();
	}
	else
		charactername = (!blob.hasTag("dead")&&!blob.hasTag("bot")||blob.isBot()?(blob.get_string("sleeper_name").empty()||!blob.exists("sleeper_name")?"Mook ":"Unconscious "):"")+blob.getInventoryName();
	CBlob@ localblob = getLocalPlayerBlob();
	bool teammate = false;
	bool displayOwnName = true;
	if (localblob !is null) {
		if (localblob is blob) return;
		teammate = blob.getTeamNum() == localblob.getTeamNum() && player !is null;
		displayOwnName = blob !is localblob;
	}
	
	if (mouseOnBlob || (u_shownames && localblob !is null && displayOwnName && teammate))
	{
		Vec2f name_dims = Vec2f_zero;
		GUI::SetFont("menu");
		GUI::GetTextDimensions(charactername, name_dims);
		Vec2f pos2d = blob.getInterpolatedScreenPos() + Vec2f(0, 20);
		Vec2f topLeft = pos2d+Vec2f(0, 16) - (name_dims/2+Vec2f(4,0)+(mouseOnBlob?Vec2f(24,0):Vec2f_zero));
		Vec2f botRight = pos2d+Vec2f(0, 16) + (name_dims/2+Vec2f(8,4));
		
		u8 teamnum = Maths::Min(blob.getTeamNum(), 7);
		SColor name_color = GetColorFromTeam(teamnum);
		SColor squad_seven_color = GetColorFromTeam(7);
		
		GUI::DrawRectangle(topLeft, botRight, SColor(128,0,0,0));
		GUI::DrawTextCentered(charactername, pos2d+Vec2f(0, 16), name_color);
		
		if (getRules().exists(username+"rank") && mouseOnBlob) {
			u8 player_rank = Maths::Min(ranknames.size()-1, getRules().get_u8(username+"rank"));
			string rankname = "Platoon Leader";
			if (player_rank < 4)
				rankname = ranknames[player_rank]+" "+blob.getInventoryName();
			else
				rankname = ranknames[player_rank];
			Vec2f rankname_dims;
			GUI::GetTextDimensions(rankname, rankname_dims);
			f32 x_shift = Maths::Max(rankname_dims.x, name_dims.x);
			GUI::DrawIcon("ranks.png", player_rank, Vec2f(16,16), pos2d+Vec2f(-name_dims.x/2-28, -5), 1.0f);
			//GUI::DrawText(rankname, pos2d+Vec2f(-x_shift/2, 32), squad_seven_color);
		}
	}
}