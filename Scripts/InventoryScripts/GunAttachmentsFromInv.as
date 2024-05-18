//script by Skemonde uwu
#include "KIWI_Locales"
#include "UpdateInventoryOnClick"
#include "FirearmVars"

const u8 GRID_SIZE = 48;
const u8 GRID_PADDING = 12;
const u8 CAPTURE_PADDING = 32;

void onInit(CInventory@ this)
{
	this.getBlob().addCommandID("change altfire");
}

void onCreateInventoryMenu(CInventory@ this, CBlob@ forBlob, CGridMenu@ menu)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;

	DrawAvailableAttachments(blob, menu, forBlob);
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

void DrawAvailableAttachments(CBlob@ this, CGridMenu@ menu, CBlob@ forBlob) {
	Vec2f inventory_space = this.getInventory().getInventorySlots();
	string[] available_attachments;
	CInventory@ inv = this.getInventory();
	if (inv is null) return;
	CBlob@ carried = this.getCarriedBlob();
	
	for (int counter = 0; counter<inv.getItemsCount(); ++counter) {
		CBlob@ item = inv.getItem(counter);
		
		//no nulls
		if (item is null) continue;
		
		//if not a gun attachment item
		if (!item.exists("alt_fire_item")||(item.hasScript("StandardFire.as")&&item.getName()!="combatknife")) continue;
		
		//if already is added
		if (available_attachments.find(item.getName())>-1) continue;
		
		//knife can be that item when you pick it up from inventory :)
		//if (carried is item) return;
		
		available_attachments.push_back(item.getName());
	}
	
	const Vec2f MENU_DIMS = Vec2f(3, 2);
	const Vec2f TOOL_POS = Vec2f(menu.getUpperLeftPosition().x+3*GRID_SIZE/2, menu.getUpperLeftPosition().y+6*GRID_SIZE/2+CAPTURE_PADDING);
	CGridMenu@ tool = CreateGridMenu(TOOL_POS, this, MENU_DIMS, "");
	if (tool !is null)
	{
		tool.SetCaptionEnabled(false);
		
		bool has_carried = carried !is null;
		
		CGridButton@ empty_button_1 = tool.AddButton("$gun_addons_1$", "", Vec2f(1,1));
		if (empty_button_1 !is null) {
			empty_button_1.clickable = false;
		}
		
		CBlob@ pointer = inv.getItem("pointer");
		bool got_pointer = pointer !is null;
		CBitStream pointer_params;
		bool can_attach_pointer = got_pointer && has_carried;
		if (can_attach_pointer) {
			pointer_params.write_u16(carried.getNetworkID());
			pointer_params.write_u16(pointer.getNetworkID());
		}
		CGridButton@ pointer_button = tool.AddButton("$gun_addons_2"+(can_attach_pointer?"_active$":"$"), "", this.getCommandID("change altfire"), Vec2f(1, 1), pointer_params);
		if (pointer_button !is null)
		{
			pointer_button.clickable = can_attach_pointer;
			if (can_attach_pointer)
				pointer_button.SetHoverText("Attach a Laser Pointer to your gun!\n");
			else
				pointer_button.SetHoverText("Need a Laser Pointer\n");
		}
		
		CBlob@ knife = inv.getItem("combatknife");
		bool got_knife = knife !is null;
		CBitStream knife_params;
		bool can_attach_knife = got_knife && has_carried;
		if (can_attach_knife) {
			knife_params.write_u16(carried.getNetworkID());
			knife_params.write_u16(knife.getNetworkID());
		}
		CGridButton@ empty_button_2 = tool.AddButton("$gun_addons_3"+(can_attach_knife?"_active$":"$"), "", Vec2f(1,1));
		if (empty_button_2 !is null) {
			empty_button_2.clickable = false;
		}
		CGridButton@ empty_button_3 = tool.AddButton("$gun_addons_4$", "", Vec2f(1,1));
		if (empty_button_3 !is null) {
			empty_button_3.clickable = false;
		}
		
		CBlob@ nader = inv.getItem("naderitem");
		bool got_nader = nader !is null;
		CBitStream nader_params;
		bool can_attach_nader = got_nader && has_carried;
		if (can_attach_nader) {
			nader_params.write_u16(carried.getNetworkID());
			nader_params.write_u16(nader.getNetworkID());
		}
		CGridButton@ nader_button = tool.AddButton("$gun_addons_5"+(can_attach_nader?"_active$":"$"), "", this.getCommandID("change altfire"), Vec2f(1, 1), nader_params);
		if (nader_button !is null)
		{
			nader_button.clickable = can_attach_nader;
			if (can_attach_nader)
				nader_button.SetHoverText("Attach an Underbarrel 'Nader to your gun!\n");
			else
				nader_button.SetHoverText("Need a Underbarrel 'Nader\n");
		}
		
		CGridButton@ knife_button = tool.AddButton("$gun_addons_6"+(can_attach_knife?"_active$":"$"), "", this.getCommandID("change altfire"), Vec2f(1, 1), knife_params);
		if (knife_button !is null)
		{
			knife_button.clickable = can_attach_knife;
			if (can_attach_knife)
				knife_button.SetHoverText("Attach a Bayonet to your gun!\n");
			else
				knife_button.SetHoverText("Need a Bayonet\n");
		}
	}
}

void DrawAvailableAttachmentsOld(CBlob@ this, CGridMenu@ menu, CBlob@ forBlob) {
	Vec2f inventory_space = this.getInventory().getInventorySlots();
	string[] available_attachments;
	CInventory@ inv = this.getInventory();
	if (inv is null) return;
	CBlob@ carried = this.getCarriedBlob();
	
	for (int counter = 0; counter<inv.getItemsCount(); ++counter) {
		CBlob@ item = inv.getItem(counter);
		
		//no nulls
		if (item is null) continue;
		
		//if not a gun attachment item
		if (!item.exists("alt_fire_item")||(item.hasScript("StandardFire.as")&&item.getName()!="combatknife")) continue;
		
		//if already is added
		if (available_attachments.find(item.getName())>-1) continue;
		
		//knife can be that item when you pick it up from inventory :)
		//if (carried is item) return;
		
		available_attachments.push_back(item.getName());
	}
	
	if (available_attachments.size()>0&&carried !is null&&carried.exists("clip"))
	{
		const Vec2f MENU_DIMS = Vec2f(1, available_attachments.size());
		//const Vec2f TOOL_POS = menu.getUpperLeftPosition() - Vec2f(GRID_PADDING, 0) - Vec2f(1, 0) * GRID_SIZE / 2;
		const Vec2f TOOL_POS = Vec2f(menu.getUpperLeftPosition().x-MENU_DIMS.x*GRID_SIZE/2-GRID_PADDING, menu.getUpperLeftPosition().y+(MENU_DIMS.y+4)*GRID_SIZE/2);
		CGridMenu@ tool = CreateGridMenu(TOOL_POS, this, MENU_DIMS, "");
		if (tool !is null)
		{
			tool.SetCaptionEnabled(false);
			
			for (int button_idx = 0; button_idx<available_attachments.size(); button_idx++) {
				CBlob@ item = inv.getItem(available_attachments[button_idx]);
				if (item is null || item is carried) continue;
				CBitStream params;
				params.write_u16(carried.getNetworkID());
				params.write_u16(item.getNetworkID());
				
				FirearmVars@ vars;
				if (!carried.get("firearm_vars", @vars)) return;
				
				CGridButton@ button = tool.AddButton("$"+item.getName()+"$", "", this.getCommandID("change altfire"), Vec2f(1, 1), params);
				if (button !is null)
				{
					button.SetHoverText("Attach "+item.getInventoryName()+" to your gun!\n");
					if (item.get_u8("alt_fire_item") == carried.get_u8("override_alt_fire") ||
						vars.ALT_FIRE == item.get_u8("alt_fire_item")) {
						button.SetEnabled(false);
						button.SetHoverText(item.getInventoryName()+"\n\n"+"You've already got that attachment on your gun!\n");
					}
					if (carried.hasTag("cant have gun attachments") || vars.MELEE) {
						button.SetEnabled(false);
						button.SetHoverText(item.getInventoryName()+"\n\n"+"Can't have attachments on this baby!\n");
					}
				}
			}
		}
	} else if (this.isMyPlayer())
	{
		const Vec2f MENU_DIMS = Vec2f(1, 1);
		const Vec2f TOOL_POS = Vec2f(menu.getUpperLeftPosition().x-MENU_DIMS.x*GRID_SIZE/2-GRID_PADDING, menu.getUpperLeftPosition().y+(MENU_DIMS.y+4)*GRID_SIZE/2);
		CGridMenu@ tool = CreateGridMenu(TOOL_POS, this, MENU_DIMS, "");
		if (tool !is null)
		{
			tool.SetCaptionEnabled(false);
			CGridButton@ button = tool.AddButton("$SPP$", "", this.getCommandID("change altfire"), Vec2f(1, 1));
			if (button !is null)
			{
				button.SetEnabled(false);
				button.SetHoverText("Press this button\nwith a $col-radical_red$GUN IN HANDS$col-radical_red$\nto affix a gun attachment\n$col-radical_red$FROM$col-radical_red$ your inventory\n");
			}
		}
	}
}

void onCommand(CInventory@ this, u8 cmd, CBitStream @params)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	if(cmd == blob.getCommandID("change altfire"))
	{
		u16 gun_id, item_id;
		if (!params.saferead_u16(gun_id)) return;
		if (!params.saferead_u16(item_id)) return;
		CBlob@ gun = getBlobByNetworkID(gun_id);
		CBlob@ item = getBlobByNetworkID(item_id);
		if (gun is null || item is null) return;
		
		FirearmVars@ vars;
		if (!gun.get("firearm_vars", @vars)) return;
		
		int old_altfire = gun.get_u8("override_alt_fire");
		if(old_altfire == AltFire::Unequip) //in case override value is 0 we use altfire type from vars
			old_altfire = vars.ALT_FIRE;
		
		gun.set_u8("override_alt_fire", item.get_u8("alt_fire_item"));
		if (item.exists("alt_fire_interval"))
			gun.set_u8("override_altfire_interval", item.get_u16("alt_fire_interval"));
			
		const u8 ALTFIRE_AMMO_IDX = 1;
		
		gun.Untag("laser_pointer");
		switch (item.get_u8("alt_fire_item")) {
			case AltFire::UnderbarrelNader:
			{
				if (vars.AMMO_TYPE.size()<2) {
					vars.AMMO_TYPE.push_back("froggy");
				} else {
					vars.AMMO_TYPE[ALTFIRE_AMMO_IDX].opAssign("froggy");
				}
				break;
			}
			
			case AltFire::LaserPointer:
			{
				break;
			}
			
			default:
			{
				if (vars.AMMO_TYPE.size()>1)
					vars.AMMO_TYPE.erase(ALTFIRE_AMMO_IDX);
			}
		};
		
		string old_item_name = "";
		switch (old_altfire) {
			case AltFire::UnderbarrelNader:
			{
				old_item_name = "naderitem";
				break;
			}
			case AltFire::LaserPointer:
			{
				old_item_name = "pointer";
				break;
			}
			case AltFire::Bayonet:
			{
				old_item_name = "combatknife";
				break;
			}
		}
		if (!old_item_name.empty()&&isServer()) {
			CBlob@ previous_addon = server_CreateBlob(old_item_name, blob.getTeamNum(), blob.getPosition());
			if (previous_addon !is null) {
				blob.server_PutInInventory(previous_addon);
			}
		}
		
		blob.server_PutOutInventory(item);
		item.server_Die();
		
		if (blob.isMyPlayer()) {
			//blob.ClearGridMenus();
			UpdateInventoryOnClick(blob);
		}
	}
}