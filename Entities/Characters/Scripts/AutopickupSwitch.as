#include "KIWI_Locales.as";

const u8 GRID_SIZE = 48;
const u8 GRID_PADDING = 12;

void onCreateInventoryMenu(CInventory@ this, CBlob@ forBlob, CGridMenu@ menu)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;

	DrawAutopickupSwitch(blob, menu);
}

void DrawAutopickupSwitch(CBlob@ this, CGridMenu@ menu) {
	CRules@ rules = getRules();
	const Vec2f TOOL_POS = menu.getUpperLeftPosition() - Vec2f(GRID_PADDING, 0) + Vec2f(-1, 1) * GRID_SIZE / 2;
	
	CGridMenu@ tool = CreateGridMenu(TOOL_POS, this, Vec2f(1, 1), "");
	if (tool !is null)
	{
		tool.SetCaptionEnabled(false);
		
		CPlayer@ player = this.getPlayer();
		
		CBitStream params;
		string player_name = "";
		if (player !is null)
			player_name = player.getUsername();
		params.write_string(player_name);

		CGridButton@ button = tool.AddButton((rules.get_bool(player_name + "autopickup") ? "$icon_unlocked$" : "$icon_locked$"), "", 69, Vec2f(1, 1), params);
		if (button !is null)
		{
			button.SetHoverText((rules.get_bool(player_name + "autopickup") ? Descriptions::lockpickup : Descriptions::unlockpickup));
		}
	}
}

void onCommand(CInventory@ this, u8 cmd, CBitStream @params)
{
	if(cmd == 69)
	{
		string player_name;
		if(!params.saferead_string(player_name)) return;
		CRules@ rules = getRules();
		rules.Sync(player_name + "autopickup", true);
		rules.set_bool(player_name + "autopickup", !rules.get_bool(player_name + "autopickup"));
		print(player_name + "autopickup = " + rules.get_bool(player_name + "autopickup"));
	}
}