//default actor hud
// a bar with hearts in the bottom left, bottom right free for actor specific stuff

#include "ActorHUDStartPos"
#include "Skemlib"

void renderBackBar(Vec2f origin, f32 width, f32 scale)
{
	return;
	for (f32 step = 0.0f; step < width / scale - 64; step += 64.0f * scale)
	{
		GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 1, Vec2f(64, 32), origin + Vec2f(step * scale, 0), scale);
	}

	GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 1, Vec2f(64, 32), origin + Vec2f(width - 128 * scale, 0), scale);
}

void renderFrontStone(Vec2f farside, f32 width, f32 scale)
{
	return;
	for (f32 step = 0.0f; step < width / scale - 16.0f * scale * 2; step += 16.0f * scale * 2)
	{
		GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 2, Vec2f(16, 32), farside + Vec2f(-step * scale - 32 * scale, 0), scale);
	}

	if (width > 16)
	{
		GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 2, Vec2f(16, 32), farside + Vec2f(-width, 0), scale);
	}

	GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 0, Vec2f(16, 32), farside + Vec2f(-width - 32 * scale, 0), scale);
	GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 3, Vec2f(16, 32), farside, scale);
}

/* void renderHPBar(CBlob@ blob, Vec2f origin)
{
	origin = Vec2f(200, 9);
	//origin = Vec2f_zero;
	origin = Vec2f(16, 16);
	string heartFile = "BigHearts.png";
	int segmentWidth = 56;
	//GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 0, Vec2f(16, 32), origin + Vec2f(-segmentWidth, 0));
	int HPs = 0;
	int sprite_shift = 4;
	int shift_value = 0;
	Vec2f under_health = origin+Vec2f(256, 32)/2+Vec2f(-128, 24);
	f32 health_percentage = Maths::Clamp(blob.getHealth()/blob.getInitialHealth(), 0, 1.0f);
	GUI::DrawSunkenPane(origin-Vec2f(1, 1)*4, origin+Vec2f(256, 32)+Vec2f(1, 1)*4);
	SColor hp_bar_col;
	hp_bar_col.setAlpha(255);
	hp_bar_col.setRed(Maths::Clamp(255-512*(health_percentage-0.7f), 0, 255));
	hp_bar_col.setGreen(Maths::Clamp(255*(health_percentage+0.3f), 0, 255));
	hp_bar_col.setBlue(0);
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
	u16 health_width = Maths::Round(256*health_percentage/MIN_BAR_WIDTH)*MIN_BAR_WIDTH;
	GUI::DrawRectangle(origin, origin+Vec2f(health_width, 32), hp_bar_col);
	GUI::DrawRectangle(origin+Vec2f(0, 14), origin+Vec2f(health_width, 28), hp_bar2_col);
	GUI::DrawRectangle(origin, origin+Vec2f(health_width, 6), hp_bar2_col);
	GUI::DrawRectangle(origin+Vec2f(0, 16), origin+Vec2f(health_width, 24), hp_bar3_col);
	GUI::DrawRectangle(origin+Vec2f(health_width-2, 0), origin+Vec2f(health_width, 32), hp_bar_col);
	//GUI::DrawProgressBar(origin, origin+Vec2f(256, 32), health_percentage);
	GUI::SetFont("menu");
	
	GUI::DrawText("Cletta captured "+getRules().get_u8("team1flags")+" flags", under_health, GetColorFromTeam(0, 255, 1));
	GUI::DrawText("Imperata captured "+getRules().get_u8("team0flags")+" flags", under_health+Vec2f(0, 16), GetColorFromTeam(1, 255, 1));
	u8 flag_team = getRules().get_u8("team1flags")>getRules().get_u8("team0flags")?0:(getRules().get_u8("team0flags")==getRules().get_u8("team1flags")?-1:1);
	GUI::DrawIcon("CTFGui.png", 0, Vec2f(16, 32), under_health+Vec2f(180, -8), 1.0f, flag_team);
	
	f32 healthbar_width = 256-4;
	u8 cell_amount = 8;
	for (int cell = 0; cell< cell_amount; ++cell) {
		u16 current_x = Maths::Round((cell+1)*((healthbar_width)/(cell_amount))/MIN_BAR_WIDTH)*MIN_BAR_WIDTH;
		Vec2f current_pos = Vec2f(origin.x+2+current_x, origin.y);
		GUI::DrawRectangle(current_pos, current_pos+Vec2f(2, 32), current_x<(health_width-2)?hp_bar2_col:color_black);
	}
	GUI::DrawRectangle(origin, origin+Vec2f(2, 32), color_black);
	GUI::DrawRectangle(origin+Vec2f(254, 0), origin+Vec2f(256, 32), color_black);
	GUI::DrawRectangle(origin, origin+Vec2f(256, 2), color_black);
	GUI::DrawRectangle(origin+Vec2f(0, 30), origin+Vec2f(256, 32), color_black);
	GUI::DrawTextCentered(formatFloat(blob.getHealth()*20, "", 0, 0)+" HPs", origin+Vec2f(256, 40)/2, color_white);
} */

void onInit(CSprite@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
}

void onRender(CSprite@ this)
{
	return;
	if (g_videorecording)
		return;

	CBlob@ blob = this.getBlob();
	Vec2f dim = Vec2f(402, 64);
	Vec2f ul(getHUDX() - dim.x / 2.0f, getHUDY() - dim.y + 12);
	Vec2f lr(ul.x + dim.x, ul.y + dim.y);
	//GUI::DrawPane(ul, lr);
	renderBackBar(ul, dim.x, 1.0f);
	u8 bar_width_in_slots = blob.get_u8("gui_HUD_slots_width");
	f32 width = bar_width_in_slots * 40.0f;
	renderFrontStone(ul + Vec2f(dim.x + 40, 0), width, 1.0f);
	//renderHPBar(blob, ul);
	//GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 0, Vec2f(128,32), topLeft);
}
