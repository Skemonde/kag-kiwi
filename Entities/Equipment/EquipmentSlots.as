//script by Skemonde uwu
#include "KIWI_Locales"
#include "UpdateInventoryOnClick"
#include "EquipmentCommon"
#include "VarsSync"

const u8 GRID_SIZE = 48;
const u8 GRID_PADDING = 12;

void onInit(CInventory@ this)
{
	this.getBlob().addCommandID("equip item");
	this.getBlob().add_u8("inventory_buttons_amount", 1);
}

void onCreateInventoryMenu(CInventory@ this, CBlob@ forBlob, CGridMenu@ menu)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	if (blob.getPlayer() is null || !blob.isMyPlayer() ) return;

	DrawEquipmentSlots(blob, menu, forBlob);
}

void DrawEquipmentSlots(CBlob@ this, CGridMenu@ menu, CBlob@ forBlob) {
	CRules@ rules = getRules();
	Vec2f inventory_space = this.getInventory().getInventorySlots();
	const Vec2f TOOL_POS = menu.getUpperLeftPosition() - Vec2f(GRID_SIZE, -GRID_SIZE) - Vec2f(GRID_PADDING, 0) + Vec2f(1, 1) * GRID_SIZE / 2;
	
	CGridMenu@ tool = CreateGridMenu(TOOL_POS, this, Vec2f(1, 1), "");
	if (tool !is null)
	{
		tool.SetCaptionEnabled(false);
		
		CPlayer@ player = null;
		CBlob@ carried = null;
		if (forBlob is null) {
			@player = this.getPlayer();
			@carried = this.getCarriedBlob();
		}
		
		u16 carried_id = 0;
		if (carried !is null)
			carried_id = carried.getNetworkID();
		
		if (player !is null) {
			CBitStream params;
			string player_name = "";
			player_name = player.getUsername();
			
			SoldatInfo[]@ infos = getSoldatInfosFromRules();
			if (infos is null) return;
			SoldatInfo our_info = getSoldatInfoFromUsername(player_name);
			if (our_info is null) return;
			int info_idx = getInfoArrayIdx(our_info);
			
			string player_hat = infos[info_idx].hat_name;
			bool has_helm = !player_hat.empty();
			
			params.write_string(player_name);
			params.write_u16(carried_id);
			params.write_bool(true);
			AddIconToken("$dummy_bare$", "EquipmentIcons.png", Vec2f(24, 24), 0);
			AddIconToken("$dummy_helm$", "EquipmentIcons.png", Vec2f(24, 24), 1);
	
			CGridButton@ button = tool.AddButton(has_helm?"$dummy_helm$":"$dummy_bare$", "", this.getCommandID("equip item"), Vec2f(1, 1), params);
			if (button !is null)
			{
				if (!has_helm)
					button.SetHoverText("equip item");
				else
					button.SetHoverText("take it off");
			}
		}
	}
}

string[] suitable_hat_items = {
	"helm",
	"bucket",
	"medhelm",
	"hehelm",
	"mp",
	
	"none"
};

void onCommand(CInventory@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getBlob().getCommandID("equip item"))
	{
		//if (!isServer()) return;
		string player_name;
		u16 carried_id;
		bool need_to_refresh;
		if(!params.saferead_string(player_name)) return;
		if(!params.saferead_u16(carried_id)) return;
		if(!params.saferead_bool(need_to_refresh)) return;
		CRules@ rules = getRules();
		
		SoldatInfo[]@ infos = getSoldatInfosFromRules();
		if (infos is null) return;
		SoldatInfo our_info = getSoldatInfoFromUsername(player_name, infos);
		if (our_info is null) return;
		int info_idx = getInfoArrayIdx(our_info);
		
		string player_hat = infos[info_idx].hat_name;
		bool has_helm = !player_hat.empty();
		
		CPlayer@ player = getPlayerByUsername(player_name);
		if (player is null) return;
		CBlob@ blob = player.getBlob();
		CBlob@ carried = getBlobByNetworkID(carried_id);
		if (blob is null) return;

		if (!has_helm) {
			if (carried !is null && suitable_hat_items.find(carried.getName())>-1) {
				
				infos[info_idx].hat_name = carried.getName();
				
				string associated_script = carried.get_string("associated_script");
				addHatScript(blob, associated_script);
				//print(player_name + " helm state is changed to " + true);
				carried.server_Die();
				blob.getSprite().PlaySound("CycleInventory");
			}
		} else {
			CBlob@ new_helm = server_CreateBlob(player_hat);
			if (isServer()) {
				//print(player_name + " helm state is changed to " + false);
				blob.server_Pickup(new_helm);
				infos[info_idx].hat_name = "";
			}
			if (new_helm !is null) {
				string associated_script = new_helm.get_string("associated_script");
				removeHatScript(blob, associated_script);
			}
		}
		getRules().set("soldat_infos", infos);
		server_SyncPlayerVars(getRules());
		
		if (need_to_refresh) UpdateInventoryOnClick(blob);
		
		//this updates hat layer :P
		if (isServer())
			blob.SendCommand(blob.getCommandID("set head to update"));
	}
}