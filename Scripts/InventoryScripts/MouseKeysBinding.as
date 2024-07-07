//script by Skemonde uwu
#include "KIWI_Locales"
#include "UpdateInventoryOnClick"
#include "Skemlib"
#include "SoldatInfo"
#include "VarsSync"

const u8 GRID_SIZE = 48;
const u8 GRID_PADDING = 12;
const Vec2f MENU_DIMS = Vec2f(3, 2);
Vec2f tool_pos = Vec2f_zero;

void onInit(CBlob@ this)
{
	this.set_u16("LMB_item_netid", 0);
	this.set_u16("MMB_item_netid", 0);
	this.set_u16("RMB_item_netid", 0);
	
	this.set_string("LMB_item_name", "");
	this.set_string("MMB_item_name", "");
	this.set_string("RMB_item_name", "");
	
	this.set_u32("last_LMB_time", 0);
	this.set_u32("last_MMB_time", 0);
	this.set_u32("last_RMB_time", 0);
	
	this.addCommandID("LMB_item_choosed");
	this.addCommandID("MMB_item_choosed");
	this.addCommandID("RMB_item_choosed");
	this.addCommandID("update binding menu");
}

void onTick(CBlob@ this)
{
	CBlob@ carried = this.getCarriedBlob();
	//if(isServer() && (getGameTime()) % 30 == 0){
	//	this.Sync("LMB_item_netid", true);
	//	this.Sync("MMB_item_netid", true);
	//	this.Sync("RMB_item_netid", true);
	//}
	
	if (!this.isMyPlayer()||!isClient()||this.hasTag("halfdead")) return;
	
	u16 lmb_binded_id = this.get_u16("LMB_item_netid"),
		mmb_binded_id = this.get_u16("MMB_item_netid"),
		rmb_binded_id = this.get_u16("RMB_item_netid");
	CBlob@ lmb_binded = getBlobByNetworkID(lmb_binded_id),
		mmb_binded = getBlobByNetworkID(mmb_binded_id),
		rmb_binded = getBlobByNetworkID(rmb_binded_id);
		
	string player_name = this.getPlayer().getUsername();
			
	SoldatInfo[]@ infos = getSoldatInfosFromRules();
	if (infos is null) return;
	SoldatInfo our_info = getSoldatInfoFromUsername(player_name);
	if (our_info is null) return;
	
	string 	lmb_binded_name = our_info.lmb_bind_name,
			mmb_binded_name = our_info.mmb_bind_name,
			rmb_binded_name = our_info.rmb_bind_name;
		
	CControls@ controls = this.getControls();
	bool interacting = getHUD().hasButtons() || getHUD().hasMenus() || this.isAttached();
	if (interacting || controls is null) return;
	
	//left ctrl + one of main mouse buttons
	u32 doube_click_interval = 12;
	if (carried is null || carried !is null && carried.getName() != lmb_binded_name) {
		if (this.getInventory().getCount(lmb_binded_name)>0) {
			if (controls.isKeyJustPressed(KEY_LBUTTON)) {
				if (this.get_u32("last_LMB_time")>(getGameTime()-doube_click_interval))
				{
					this.SendCommand(this.getCommandID("LMB_item_choosed"));
				}
				this.set_u32("last_LMB_time", getGameTime());
			}
		}
	}
	if (carried is null || carried !is null && carried.getName() != mmb_binded_name) {
		if (this.getInventory().getCount(mmb_binded_name)>0) {
			if (controls.isKeyJustPressed(KEY_MBUTTON)) {
				if (this.get_u32("last_MMB_time")>(getGameTime()-doube_click_interval))
				{
					this.SendCommand(this.getCommandID("MMB_item_choosed"));
				}
				this.set_u32("last_MMB_time", getGameTime());
			}
		}
	}
	if (carried is null || carried !is null && carried.getName() != rmb_binded_name) {
		if (this.getInventory().getCount(rmb_binded_name)>0) {
			if (controls.isKeyJustPressed(KEY_RBUTTON)) {
				if (this.get_u32("last_RMB_time")>(getGameTime()-doube_click_interval))
				{
					this.SendCommand(this.getCommandID("RMB_item_choosed"));
				}
				this.set_u32("last_RMB_time", getGameTime());
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (this.getInventory() is null) return;
	if (this.getPlayer() is null) return;
	
	string player_name = this.getPlayer().getUsername();
			
	SoldatInfo[]@ infos = getSoldatInfosFromRules();
	if (infos is null) return;
	SoldatInfo our_info = getSoldatInfoFromUsername(player_name);
	if (our_info is null) return;
	
	string 	lmb_binded_name = our_info.lmb_bind_name,
			mmb_binded_name = our_info.mmb_bind_name,
			rmb_binded_name = our_info.rmb_bind_name;
	
	CBlob@ lmb_binded = this.getInventory().getItem(lmb_binded_name),
		mmb_binded = this.getInventory().getItem(mmb_binded_name),
		rmb_binded = this.getInventory().getItem(rmb_binded_name);
	bool interacting = getHUD().hasButtons() || getHUD().hasMenus() || this.isAttached();
	if (interacting) return;
	if(cmd == this.getCommandID("LMB_item_choosed"))
	{
		if (lmb_binded is null) return;
		CBlob@ carried = this.getCarriedBlob();
		
		bool putting_carried_in = false;
		if (carried !is null) {
			if (carried.hasTag("firearm")) return;
			
			if (carried is lmb_binded) return;
			putting_carried_in = true;
		}
		
		lmb_binded.SetFacingLeft(this.isFacingLeft());
		this.server_Pickup(lmb_binded);
		if (putting_carried_in) this.server_PutInInventory(carried);
	}
	if(cmd == this.getCommandID("MMB_item_choosed"))
	{
		if (mmb_binded is null) return;
		CBlob@ carried = this.getCarriedBlob();
		
		bool putting_carried_in = false;
		if (carried !is null && carried !is mmb_binded)
			putting_carried_in = true;
		
		mmb_binded.SetFacingLeft(this.isFacingLeft());
		this.server_Pickup(mmb_binded);
		if (putting_carried_in) this.server_PutInInventory(carried);
	}
	if(cmd == this.getCommandID("RMB_item_choosed"))
	{
		if (rmb_binded is null) return;
		CBlob@ carried = this.getCarriedBlob();
		
		bool putting_carried_in = false;
		if (carried !is null && carried !is rmb_binded)
			putting_carried_in = true;
		
		rmb_binded.SetFacingLeft(this.isFacingLeft());
		this.server_Pickup(rmb_binded);
		if (putting_carried_in) this.server_PutInInventory(carried);
	}
}

void onInit(CInventory@ this)
{
	this.getBlob().addCommandID("set item for LMB");
	this.getBlob().addCommandID("set item for MMB");
	this.getBlob().addCommandID("set item for RMB");
}

void onCreateInventoryMenu(CInventory@ this, CBlob@ forBlob, CGridMenu@ menu)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	if (blob.getPlayer() is null || !blob.isMyPlayer() ) return;

	DrawMouseBindings(blob, menu, forBlob);
}

void DrawMouseBindings(CBlob@ this, CGridMenu@ menu, CBlob@ forBlob) {
	Vec2f inv_dims = getGridMenuDims(menu);
	if (isClient())
		tool_pos = Vec2f(menu.getLowerRightPosition().x+MENU_DIMS.x*GRID_SIZE/2+GRID_PADDING, menu.getUpperLeftPosition().y+MENU_DIMS.y*GRID_SIZE/2);
	UpdateMouseBindings(this, forBlob);
}

void UpdateMouseBindings(CBlob@ this, CBlob@ forBlob)
{
	CGridMenu@ tool = CreateGridMenu(tool_pos, this, MENU_DIMS, "Click with item");
	if (tool !is null)
	{
		tool.SetCaptionEnabled(false);
		tool.deleteAfterClick = false;
		tool.SetCaptionEnabled(true);
		
		CPlayer@ player = null;
		u16 lmb_binded_id = this.get_u16("LMB_item_netid"),
			mmb_binded_id = this.get_u16("MMB_item_netid"),
			rmb_binded_id = this.get_u16("RMB_item_netid");
		CBlob@ carried = null,
			lmb_binded = getBlobByNetworkID(lmb_binded_id),
			mmb_binded = getBlobByNetworkID(mmb_binded_id),
			rmb_binded = getBlobByNetworkID(rmb_binded_id);
		if (forBlob is null) {
			@player = this.getPlayer();
			@carried = this.getCarriedBlob();
		} else {
			@player = forBlob.getPlayer();
			@carried = forBlob.getCarriedBlob();
		}
		
		u16 carried_id = 0;
		if (carried !is null)
			carried_id = carried.getNetworkID();
		
		if (player !is null) {
			string player_name = "";
			player_name = player.getUsername();
			
			SoldatInfo[]@ infos = getSoldatInfosFromRules();
			if (infos is null) return;
			SoldatInfo our_info = getSoldatInfoFromUsername(player_name);
			if (our_info is null) return;
			
			string 	lmb_binded_name = our_info.lmb_bind_name,
					mmb_binded_name = our_info.mmb_bind_name,
					rmb_binded_name = our_info.rmb_bind_name;
			
			CBitStream params;
			params.write_u16(this.getNetworkID());
			params.write_u16(carried_id);
	
			AddIconToken("$mouse_keys$", "mouse_buttons.png", Vec2f(72, 16), 8);
			CGridButton@ icon_button = tool.AddButton("$mouse_keys$", "", Vec2f(3,1));
			if (icon_button !is null) {
				icon_button.clickable = false;
			}
			CGridButton@ l_button = tool.AddButton(((lmb_binded_name.empty())?"":("$"+lmb_binded_name+"$")), "", this.getCommandID("set item for LMB"), Vec2f(1, 1), params);
			if (l_button !is null)
			{
				l_button.SetHoverText("Double click with LMB\nto take out quickly\n");
			}
			CGridButton@ m_button = tool.AddButton(((mmb_binded_name.empty())?"":("$"+mmb_binded_name+"$")), "", this.getCommandID("set item for MMB"), Vec2f(1, 1), params);
			if (m_button !is null)
			{
				m_button.SetHoverText("Double click with MMB\nto take out quickly\n");
			}
			CGridButton@ r_button = tool.AddButton(((rmb_binded_name.empty())?"":("$"+rmb_binded_name+"$")), "", this.getCommandID("set item for RMB"), Vec2f(1, 1), params);
			if (r_button !is null)
			{
				r_button.SetHoverText("Double click with RMB\nto take out quickly\n");
			}
		}
	}
}

void onCommand(CInventory@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getBlob().getCommandID("update binding menu"))
	{
		u16 caller_id;
		if (!params.saferead_u16(caller_id)) return;
		u16 carried_id;
		if (!params.saferead_u16(carried_id)) return;
		CBlob@ caller = getBlobByNetworkID(caller_id);
		
		if (caller is null) return;
		
		if (caller.hasTag("has_inventory_opened") && caller.isKeyPressed(key_inventory)) UpdateInventoryOnClick(caller);
	}
	if (cmd == this.getBlob().getCommandID("set item for LMB"))
	{
		u16 caller_id;
		if (!params.saferead_u16(caller_id)) return;
		u16 carried_id;
		if (!params.saferead_u16(carried_id)) return;
		CBlob@ caller = getBlobByNetworkID(caller_id);
		CBlob@ carried = getBlobByNetworkID(carried_id);
		
		if (caller is null) return;
		CPlayer@ player = caller.getPlayer();
		if (player is null) return;
		
		SoldatInfo[]@ infos = getSoldatInfosFromRules();
		if (infos is null) return;
		SoldatInfo our_info = getSoldatInfoFromUsername(player.getUsername());
		if (our_info is null) return;
		int info_idx = getInfoArrayIdx(our_info);
		
		infos[info_idx].lmb_bind_name = carried !is null ? carried.getName() : "";
		getRules().set("soldat_infos", infos);
		server_SyncPlayerVars(getRules());
		
		this.getBlob().SendCommand(this.getBlob().getCommandID("update binding menu"), params);
	}
	if (cmd == this.getBlob().getCommandID("set item for MMB"))
	{
		u16 caller_id;
		if (!params.saferead_u16(caller_id)) return;
		u16 carried_id;
		if (!params.saferead_u16(carried_id)) return;
		CBlob@ caller = getBlobByNetworkID(caller_id);
		CBlob@ carried = getBlobByNetworkID(carried_id);
		
		if (caller is null) return;
		CPlayer@ player = caller.getPlayer();
		if (player is null) return;
		
		SoldatInfo[]@ infos = getSoldatInfosFromRules();
		if (infos is null) return;
		SoldatInfo our_info = getSoldatInfoFromUsername(player.getUsername());
		if (our_info is null) return;
		int info_idx = getInfoArrayIdx(our_info);
		
		infos[info_idx].mmb_bind_name = carried !is null ? carried.getName() : "";
		getRules().set("soldat_infos", infos);
		server_SyncPlayerVars(getRules());
		
		this.getBlob().SendCommand(this.getBlob().getCommandID("update binding menu"), params);
	}
	if (cmd == this.getBlob().getCommandID("set item for RMB"))
	{
		u16 caller_id;
		if (!params.saferead_u16(caller_id)) return;
		u16 carried_id;
		if (!params.saferead_u16(carried_id)) return;
		CBlob@ caller = getBlobByNetworkID(caller_id);
		CBlob@ carried = getBlobByNetworkID(carried_id);
		
		if (caller is null) return;
		CPlayer@ player = caller.getPlayer();
		if (player is null) return;
		
		SoldatInfo[]@ infos = getSoldatInfosFromRules();
		if (infos is null) return;
		SoldatInfo our_info = getSoldatInfoFromUsername(player.getUsername());
		if (our_info is null) return;
		int info_idx = getInfoArrayIdx(our_info);
		
		infos[info_idx].rmb_bind_name = carried !is null ? carried.getName() : "";
		getRules().set("soldat_infos", infos);
		server_SyncPlayerVars(getRules());
		
		this.getBlob().SendCommand(this.getBlob().getCommandID("update binding menu"), params);
	}
}