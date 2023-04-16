//script by Skemonde uwu
#include "KIWI_Locales"

const u8 GRID_SIZE = 48;
const u8 GRID_PADDING = 12;

void onInit(CInventory@ this)
{
	this.getBlob().addCommandID("player pickup logic");
	this.getBlob().addCommandID("structure pickup logic");
	this.getBlob().add_u8("inventory_buttons_amount", 1);
}

void onCreateInventoryMenu(CInventory@ this, CBlob@ forBlob, CGridMenu@ menu)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;

	DrawAutopickupSwitch(blob, menu, forBlob);
}

void DrawAutopickupSwitch(CBlob@ this, CGridMenu@ menu, CBlob@ forBlob) {
	CRules@ rules = getRules();
	const Vec2f TOOL_POS = menu.getUpperLeftPosition() + Vec2f(0,1)*GRID_SIZE*(1-1) - Vec2f(GRID_PADDING, 0) + Vec2f(-1, 1) * GRID_SIZE / 2;
	
	CGridMenu@ tool = CreateGridMenu(TOOL_POS, this, Vec2f(1, 1), "");
	if (tool !is null)
	{
		tool.SetCaptionEnabled(false);
		
		CPlayer@ player = null;
		if (forBlob is null)
			@player = this.getPlayer();
		
		if (player !is null) {
			CBitStream params;
			string player_name = "";
			player_name = player.getUsername();
			params.write_string(player_name);
	
			CGridButton@ button = tool.AddButton((rules.get_bool(player_name + "autopickup") ? "$unlock$" : "$lock$"), "", this.getCommandID("player pickup logic"), Vec2f(1, 1), params);
			if (button !is null)
			{
				button.SetHoverText((rules.get_bool(player_name + "autopickup") ? Descriptions::lockpickup : Descriptions::unlockpickup));
			}
		} else {
			CBitStream params;
			params.write_u16(this.getNetworkID());
			CGridButton@ button = tool.AddButton((this.get_bool("pickup") ? "$unlock$" : "$lock$"), "", this.getCommandID("structure pickup logic"), Vec2f(1, 1), params);
			if (button !is null)
			{
				button.SetHoverText((this.get_bool("pickup") ? Descriptions::lockpickup : Descriptions::unlockpickup));
			}
		}
	}
}

void onCommand(CInventory@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getBlob().getCommandID("player pickup logic"))
	{
		string player_name;
		if(!params.saferead_string(player_name)) return;
		CRules@ rules = getRules();
		rules.Sync(player_name + "autopickup", true);
		rules.set_bool(player_name + "autopickup", !rules.get_bool(player_name + "autopickup"));
		//print(player_name + "autopickup = " + rules.get_bool(player_name + "autopickup"));
	}
	if (cmd == this.getBlob().getCommandID("structure pickup logic"))
	{
		CBlob@ blob = getBlobByNetworkID(params.read_u16());
		if (blob !is null) {
			blob.set_bool("pickup", !blob.get_bool("pickup"));
			//print(blob.getName()+" pickup is now "+blob.get_bool("pickup"));
		}
	}
}