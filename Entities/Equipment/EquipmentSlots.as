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
	this.getBlob().addCommandID("equip item client");
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
	
			CGridButton@ button = tool.AddButton(has_helm?"$"+player_hat+"$":"$head_builder_normal$", "", this.getCommandID("equip item"), Vec2f(1, 1), params);
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
	if (cmd == this.getBlob().getCommandID("equip item client"))
	{
		string player_name; if(!params.saferead_string(player_name)) return;
		bool equipping; if (!params.saferead_bool(equipping)) return;
		if (!equipping) return;
		
		CPlayer@ player = getPlayerByUsername(player_name);
		if (player is null) return;
		CBlob@ blob = player.getBlob();
		if (blob is null) return;
		
		SoldatInfo[]@ infos = getSoldatInfosFromRules();
		if (infos is null) return;
		SoldatInfo our_info = getSoldatInfoFromUsername(player_name);
		if (our_info is null) return;
		int info_idx = getInfoArrayIdx(our_info);
		
		if (infos[info_idx].hat_scripts.size()>0)
		{
			addHatScript(blob, infos[info_idx].hat_scripts[0]);
		}
		
		Sound::Play("equip_iron3", blob.getPosition());
	}
	if (cmd == this.getBlob().getCommandID("equip item"))
	{
		if (!isServer()) return;

		string player_name;
		u16 carried_id;
		bool need_to_refresh;
		if(!params.saferead_string(player_name)) return;
		if(!params.saferead_u16(carried_id)) return;
		if(!params.saferead_bool(need_to_refresh)) return;
		CRules@ rules = getRules();
		
		CPlayer@ player = getPlayerByUsername(player_name);
		if (player is null) return;
		CBlob@ blob = player.getBlob();
		CBlob@ carried = getBlobByNetworkID(carried_id);
		if (blob is null) return;
		
		bool holding_headwear = carried !is null && suitable_hat_items.find(carried.getName())>-1;
		
		if (!isServer()) return;
		
		SoldatInfo[]@ infos = getSoldatInfosFromRules();
		if (infos is null) return;
		SoldatInfo our_info = getSoldatInfoFromUsername(player_name);
		if (our_info is null) return;
		int info_idx = getInfoArrayIdx(our_info);
		
		string player_hat = infos[info_idx].hat_name;
		bool has_helm = !player_hat.empty();

		if (!has_helm) {
			if (holding_headwear) {
				
				infos[info_idx].hat_name = carried.getName();
				
				string associated_script = carried.get_string("associated_script");
				addHatScript(blob, associated_script);
				infos[info_idx].hat_scripts.push_back(associated_script);
				//print(player_name + " helm state is changed to " + true);
				carried.server_Die();
				//blob.getSprite().PlaySound("CycleInventory");
			}
		} else {			
			CBlob@ new_helm = server_CreateBlob(player_hat);
			if (isServer()) {
				//print(player_name + " helm state is changed to " + false);
				blob.server_Pickup(new_helm);
				infos[info_idx].hat_name = "";
				infos[info_idx].clearHatScripts();
			}
			if (new_helm !is null) {
				string associated_script = new_helm.get_string("associated_script");
				removeHatScript(blob, associated_script);
			}		
			if (holding_headwear && isServer()) {
				CBitStream n_params;
				n_params.write_string(player_name);
				n_params.write_u16(carried_id);
				n_params.write_bool(true);
				this.getBlob().SendCommand(this.getBlob().getCommandID("equip item"), n_params);
			} else if (!holding_headwear && carried !is null) {
				blob.server_PutInInventory(carried);
			}
		}
		getRules().set("soldat_infos", infos);
		server_SyncPlayerVars(getRules());
		
		//doing after syncing all the hat_scripts
		CBitStream n_params;
		n_params.write_string(player_name);
		n_params.write_bool(holding_headwear);
		blob.SendCommand(blob.getCommandID("equip item client"), n_params);
		
		//if (need_to_refresh) UpdateInventoryOnClick(blob);
		
		//this updates hat layer :P
		if (isServer())
			blob.SendCommand(blob.getCommandID("set head to update"));

		if (blob.hasTag("has_inventory_opened")) UpdateInventoryOnClick(blob);
	}
}