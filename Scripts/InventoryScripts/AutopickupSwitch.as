//script by Skemonde uwu
#include "KIWI_Locales"
#include "UpdateInventoryOnClick"
#include "KIWI_Players&Teams"
#include "KIWI_RespawnSystem"
#include "RulesCore"
#include "SoldatInfo"
#include "VarsSync"
#include "Skemlib"

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
	if (blob.getPlayer() is null || !blob.isMyPlayer() ) return;

	DrawAutopickupSwitch(blob, menu, forBlob);
	
	if (blob.isMyPlayer())
		blob.Tag("has_inventory_opened");
}

void onTick(CInventory@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	
	if (!blob.isMyPlayer()) return;
	
	if (!getHUD().hasMenus())
		blob.Untag("has_inventory_opened");
}

void DrawAutopickupSwitch(CBlob@ this, CGridMenu@ menu, CBlob@ forBlob) {
	CRules@ rules = getRules();
	const Vec2f TOOL_POS = menu.getUpperLeftPosition() + Vec2f(0,1)*GRID_SIZE*(1-1) - Vec2f(GRID_PADDING, 0) + Vec2f(-1, 1) * GRID_SIZE / 2;	
	CPlayer@ player = null;
	if (forBlob is null)
		@player = this.getPlayer();
	if (player is null) return;
	
	string player_name = player.getUsername();
	SoldatInfo[]@ infos = getSoldatInfosFromRules();
	if (infos is null) return;
	SoldatInfo our_info = getSoldatInfoFromUsername(player_name);
	if (our_info is null) return;
			
	CGridMenu@ tool = CreateGridMenu(TOOL_POS, this, Vec2f(1, 1), "");
	if (tool !is null)
	{
		tool.SetCaptionEnabled(false);
		
		if (true) {
			CBitStream params;
			params.write_string(player_name);
			
			bool auto_pickup = our_info.autopickup;
	
			CGridButton@ button = tool.AddButton((auto_pickup ? "$unlock$" : "$lock$"), "", this.getCommandID("player pickup logic"), Vec2f(1, 1), params);
			if (button !is null)
			{
				button.SetHoverText((auto_pickup ? Descriptions::lockpickup : Descriptions::unlockpickup));
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
		
		CPlayer@ player = getPlayerByUsername(player_name);
		if (player is null) return;
		
		SoldatInfo[]@ infos = getSoldatInfosFromRules();
		if (infos is null) return;
		SoldatInfo our_info = getSoldatInfoFromUsername(player_name);
		if (our_info is null) return;
		int info_idx = getInfoArrayIdx(our_info);
		
		infos[info_idx].autopickup = !our_info.autopickup;
		getRules().set("soldat_infos", infos);
		server_SyncPlayerVars(getRules());
		
		CBlob@ blob = player.getBlob();
		if (blob is null) return;
		UpdateInventoryOnClick(blob);
	}
	if (cmd == this.getBlob().getCommandID("structure pickup logic"))
	{
		CBlob@ blob = getBlobByNetworkID(params.read_u16());
		if (blob !is null) {
			blob.set_bool("pickup", !blob.get_bool("pickup"));
			//cannot update because it doesn't build a menu exactly for me so when i get something from inventory it doesn't get inside my inventory
			//UpdateInventoryOnClick(blob);
			//print(blob.getName()+" pickup is now "+blob.get_bool("pickup"));
		}
	}
}