//archer HUD

#include "ArcherCommon.as";
#include "ActorHUDStartPos.as";

const string iconsFilename = "Entities/Characters/Archer/ArcherIcons.png";
const int slotsSize = 6;

void onInit(CSprite@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
	this.getBlob().set_u8("gui_HUD_slots_width", slotsSize);
}

//void ManageCursors(CBlob@ this)
//{
//}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	//ManageCursors(blob);

	if (g_videorecording)
		return;

	CPlayer@ player = blob.getPlayer();

	// draw inventory
	Vec2f tl = getActorHUDStartPosition(blob, slotsSize);
	DrawInventoryOnHUD(blob, Vec2f(16, 80));

	// draw coins
	const int coins = player !is null ? player.getCoins() : 0;
	//DrawCoinsOnHUD(blob, coins, tl, slotsSize - 2);

	//class weapon icon
	//GUI::DrawIcon("bullet_huh", 0, Vec2f(16, 24), tl + Vec2f(8 + (slotsSize - 1) * 40, -6), 1.0f, blob.getTeamNum());
}
