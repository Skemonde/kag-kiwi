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
	//if (blob.isMyPlayer())
	//	blob.Tag("has_inventory_opened");
}
/* 
void onTick(CInventory@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	
	if (!blob.isMyPlayer()) return;
	
	if (!getHUD().hasMenus())
		blob.Untag("has_inventory_opened");
}
 */
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
			pointer_params.write_u16(this.getNetworkID());
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
		
		CBlob@ knife = inv.getItem("bayonet");
		bool got_knife = knife !is null;
		CBitStream knife_params;
		bool can_attach_knife = got_knife && has_carried;
		if (can_attach_knife) {
			knife_params.write_u16(carried.getNetworkID());
			knife_params.write_u16(knife.getNetworkID());
			knife_params.write_u16(this.getNetworkID());
		}
		CGridButton@ empty_button_2 = tool.AddButton("$gun_addons_3"+(can_attach_knife?"_active$":"$"), "", Vec2f(1,1));
		if (empty_button_2 !is null) {
			empty_button_2.clickable = false;
		}
		CGridButton@ empty_button_3 = tool.AddButton("$gun_addons_4$", "", Vec2f(1,1));
		if (empty_button_3 !is null) {
			empty_button_3.clickable = false;
		}
		
		CBlob@ nader = inv.getItem("underbarrelnader");
		bool got_nader = nader !is null;
		CBitStream nader_params;
		bool can_attach_nader = got_nader && has_carried;
		if (can_attach_nader) {
			nader_params.write_u16(carried.getNetworkID());
			nader_params.write_u16(nader.getNetworkID());
			nader_params.write_u16(this.getNetworkID());
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

void onCommand(CInventory@ this, u8 cmd, CBitStream @params)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	if(cmd == blob.getCommandID("change altfire"))
	{
		u16 gun_id, item_id, holder_id;
		if (!params.saferead_u16(gun_id)) return;
		if (!params.saferead_u16(item_id)) return;
		if (!params.saferead_u16(holder_id)) return;
		CBlob@ gun = getBlobByNetworkID(gun_id);
		CBlob@ item = getBlobByNetworkID(item_id);
		CBlob@ holder = getBlobByNetworkID(holder_id);
		if (gun is null || item is null || holder is null) return;
		
		bool pointer = item.getName()=="pointer";
		
		FirearmVars@ vars;
		if (!gun.get("firearm_vars", @vars)) return;
		
		AttachmentPoint@ holder_underbarrel_addon = holder.getAttachments().getAttachmentPointByName("ADDON_UNDER_BARREL");
		AttachmentPoint@ holder_addon = holder.getAttachments().getAttachmentPointByName("ADDON");
		
		if (!pointer && holder_underbarrel_addon is null) return;
		if (pointer && holder_addon is null) return;
		
		AttachmentPoint@ gun_underbarrel_addon = gun.getAttachments().getAttachmentPointByName("ADDON_UNDER_BARREL");
		AttachmentPoint@ gun_addon = gun.getAttachments().getAttachmentPointByName("ADDON");
		
		if (!pointer && gun_underbarrel_addon is null) return;
		if (pointer && gun_addon is null) return;
		
		CBlob@ old_item = holder_underbarrel_addon.getOccupied();
		
		blob.server_PutOutInventory(item);
		item.set_u16("gun_id", gun.getNetworkID());
		item.Sync("gun_id", true);
		
		if (!pointer)
		{
			gun.set_u16("underbarrel_id", item.getNetworkID());
			gun.Sync("underbarrel_id", true);
		}
		else
		{
			gun.set_u16("pointer_id", item.getNetworkID());
			gun.Sync("pointer_id", true);
		}
		//blob.server_AttachTo(item, holder_underbarrel_addon);
		gun.server_DetachFrom(blob);
		blob.server_Pickup(gun);
		
		if (pointer)
		{
			item.set_f32("range", Maths::Max(256, vars.RANGE));
			item.Sync("range", true);
		}
		
		if (old_item !is null && !pointer)
		{
			old_item.set_u16("gun_id", 0);
			old_item.Sync("gun_id", true);
			old_item.set_u8("clip", 0);
			old_item.Sync("clip", true);
			old_item.server_DetachFromAll();
			old_item.setPosition(blob.getPosition());
			
			if (old_item.hasCommandID("set_clip"))
			{
				CBitStream params;
				params.write_u8(0);
				params.write_u8(0);
				params.write_bool(true);
				old_item.SendCommand(old_item.getCommandID("set_clip"), params);
			}
		}
	}
}