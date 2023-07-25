//script by Skemonde uwu
#include "KIWI_Locales"
#include "UpdateInventoryOnClick"

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

	DrawEquipmentSlots(blob, menu, forBlob);
}

void DrawEquipmentSlots(CBlob@ this, CGridMenu@ menu, CBlob@ forBlob) {
	CRules@ rules = getRules();
	Vec2f inventory_space = this.getInventory().getInventorySlots();
	const Vec2f TOOL_POS = menu.getUpperLeftPosition() + Vec2f(inventory_space.x*GRID_SIZE, 0) + Vec2f(GRID_PADDING, 0) + Vec2f(1, 1) * GRID_SIZE / 2;
	
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
			bool has_helm = rules.get_bool(player_name + "helm");
			params.write_string(player_name);
			params.write_u16(carried_id);
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
	"mp"
};

void onCommand(CInventory@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getBlob().getCommandID("equip item"))
	{
		string player_name;
		u16 carried_id;
		if(!params.saferead_string(player_name)) return;
		if(!params.saferead_u16(carried_id)) return;
		CRules@ rules = getRules();
		bool has_helm = rules.get_bool(player_name + "helm");
		CPlayer@ player = getPlayerByUsername(player_name);
		if (player is null) return;
		CBlob@ blob = player.getBlob();
		CBlob@ carried = getBlobByNetworkID(carried_id);
		if (blob is null) return;

		if (!has_helm) {
			if (carried !is null && suitable_hat_items.find(carried.getName())>-1) {
				rules.set_bool(player_name + "helm", true);
				rules.set_string(player_name + "hat_name", carried.getName());
				//print(player_name + " helm state is changed to " + true);
				carried.server_Die();
			}
		} else {
			rules.set_bool(player_name + "helm", false);
			if (isServer()) {
				//print(player_name + " helm state is changed to " + false);
				CBlob@ new_helm = server_CreateBlob(rules.get_string(player_name + "hat_name"));
				blob.server_Pickup(new_helm);
				rules.set_string(player_name + "hat_name", "");
			}
		}
		
		UpdateInventoryOnClick(blob);
		//this updates hat layer :P
		blob.getSprite().RemoveSpriteLayer("hat");
		blob.getSprite().RemoveSpriteLayer("head");
		
	}
}