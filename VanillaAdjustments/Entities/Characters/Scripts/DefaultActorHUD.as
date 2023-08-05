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

void renderHPBar(CBlob@ blob, Vec2f origin)
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
	GUI::DrawProgressBar(origin, origin+Vec2f(256, 32), blob.getHealth()/blob.getInitialHealth());
	GUI::SetFont("menu");
	GUI::DrawTextCentered(formatFloat(blob.getHealth()*20, "", 0, 0)+" HPs", origin+Vec2f(256, 32)/2, color_white);
	
	GUI::DrawText("Cletta captured "+getRules().get_u8("team1flags")+" flags", under_health, GetColorFromTeam(0, 255, 1));
	GUI::DrawText("Imperata captured "+getRules().get_u8("team0flags")+" flags", under_health+Vec2f(0, 16), GetColorFromTeam(1, 255, 1));
	u8 flag_team = getRules().get_u8("team1flags")>getRules().get_u8("team0flags")?0:(getRules().get_u8("team0flags")==getRules().get_u8("team1flags")?-1:1);
	GUI::DrawIcon("CTFGui.png", 0, Vec2f(16, 32), under_health+Vec2f(180, -8), 1.0f, flag_team);

	return;
	for (f32 step = 0.0f; step < (blob.getHealth() > blob.getInitialHealth() ? blob.getHealth() : blob.getInitialHealth()); step += 1.0f)
	{
		//GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 1, Vec2f(16, 32), origin + Vec2f(segmentWidth * HPs, 0));
		f32 thisHP = blob.getHealth() - step;
		if (step >= blob.getInitialHealth())
			shift_value = 1;

		//if (thisHP > 0)
		{
			Vec2f heartoffset = Vec2f(2, 2);
			Vec2f heartpos = origin + Vec2f(segmentWidth * HPs, 0) + heartoffset;

			if (thisHP <= 0.25f)
			{
				GUI::DrawIcon(heartFile, 2+sprite_shift*shift_value, Vec2f(32, 32), heartpos);
			}
			else if (thisHP <= 0.5f)
			{
				GUI::DrawIcon(heartFile, 1+sprite_shift*shift_value, Vec2f(32, 32), heartpos);
			}
			else
			{
				GUI::DrawIcon(heartFile, 0+sprite_shift*shift_value, Vec2f(32, 32), heartpos);
			}
			blob.set_Vec2f("healthRightSide", heartpos+Vec2f(segmentWidth, 0));
		}

		HPs++;
	}

	//GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 3, Vec2f(16, 32), origin + Vec2f(32 * HPs, 0));
}

void onInit(CSprite@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
}

void onRender(CSprite@ this)
{
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
	renderHPBar(blob, ul);
	//GUI::DrawIcon("Entities/Common/GUI/BaseGUI.png", 0, Vec2f(128,32), topLeft);
}
