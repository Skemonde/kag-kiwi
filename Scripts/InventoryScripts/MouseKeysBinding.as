//script by Skemonde uwu
#include "KIWI_Locales"
#include "UpdateInventoryOnClick"
#include "Skemlib"

const u8 GRID_SIZE = 48;
const u8 GRID_PADDING = 12;
const Vec2f MENU_DIMS = Vec2f(3, 2);
Vec2f tool_pos = Vec2f_zero;

void onInit(CBlob@ this)
{
	this.set_u16("LMB_item_netid", 0);
	this.set_u16("MMB_item_netid", 0);
	this.set_u16("RMB_item_netid", 0);
	
	this.set_u32("last_LMB_time", 0);
	this.set_u32("last_MMB_time", 0);
	this.set_u32("last_RMB_time", 0);
	
	this.addCommandID("LMB_item_choosed");
	this.addCommandID("MMB_item_choosed");
	this.addCommandID("RMB_item_choosed");
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
	CControls@ controls = this.getControls();
	bool interacting = getHUD().hasButtons() || getHUD().hasMenus() || this.isAttached();
	if (interacting || controls is null) return;
	
	//left ctrl + one of main mouse buttons
	u32 doube_click_interval = 12;
	if (lmb_binded !is null) {
		if (this.getInventory().isInInventory(lmb_binded)) {
			if (controls.isKeyJustPressed(KEY_LBUTTON)) {
				if (this.get_u32("last_LMB_time")>(getGameTime()-doube_click_interval))
				{
					this.SendCommand(this.getCommandID("LMB_item_choosed"));
				}
				this.set_u32("last_LMB_time", getGameTime());
			}
		}
	}
	if (mmb_binded !is null) {
		if (this.getInventory().isInInventory(mmb_binded)) {
			if (controls.isKeyJustPressed(KEY_MBUTTON)) {
				if (this.get_u32("last_MMB_time")>(getGameTime()-doube_click_interval))
				{
					this.SendCommand(this.getCommandID("MMB_item_choosed"));
				}
				this.set_u32("last_MMB_time", getGameTime());
			}
		}
	}
	if (rmb_binded !is null) {
		if (this.getInventory().isInInventory(rmb_binded)) {
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
	u16 lmb_binded_id = this.get_u16("LMB_item_netid"),
		mmb_binded_id = this.get_u16("MMB_item_netid"),
		rmb_binded_id = this.get_u16("RMB_item_netid");
	CBlob@ lmb_binded = getBlobByNetworkID(lmb_binded_id),
		mmb_binded = getBlobByNetworkID(mmb_binded_id),
		rmb_binded = getBlobByNetworkID(rmb_binded_id);
	bool interacting = getHUD().hasButtons() || getHUD().hasMenus() || this.isAttached();
	if (interacting) return;
	if(cmd == this.getCommandID("LMB_item_choosed"))
	{
		if (lmb_binded is null) return;
		CBlob@ carried = this.getCarriedBlob();
		
		if (carried !is null) {
			if (carried.hasTag("firearm")) return;
			
			if (carried is lmb_binded) return;
			
			this.server_PutInInventory(carried);
		}
		
		lmb_binded.SetFacingLeft(this.isFacingLeft());
		this.server_Pickup(lmb_binded);
	}
	if(cmd == this.getCommandID("MMB_item_choosed"))
	{
		if (mmb_binded is null) return;
		CBlob@ carried = this.getCarriedBlob();
		
		if (carried !is null && carried !is mmb_binded)
			this.server_PutInInventory(carried);
		
		mmb_binded.SetFacingLeft(this.isFacingLeft());
		this.server_Pickup(mmb_binded);
	}
	if(cmd == this.getCommandID("RMB_item_choosed"))
	{
		if (rmb_binded is null) return;
		CBlob@ carried = this.getCarriedBlob();
		
		if (carried !is null && carried !is rmb_binded)
			this.server_PutInInventory(carried);
		
		rmb_binded.SetFacingLeft(this.isFacingLeft());
		this.server_Pickup(rmb_binded);
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
			
			CBitStream params;
			params.write_u16(this.getNetworkID());
			params.write_u16(carried_id);
	
			AddIconToken("$mouse_keys$", "mouse_buttons.png", Vec2f(72, 16), 8);
			CGridButton@ icon_button = tool.AddButton("$mouse_keys$", "", Vec2f(3,1));
			if (icon_button !is null) {
				icon_button.clickable = false;
			}
			CGridButton@ l_button = tool.AddButton(((lmb_binded_id == 0 || lmb_binded is null)?"":("$"+lmb_binded.getName()+"$")), "", this.getCommandID("set item for LMB"), Vec2f(1, 1), params);
			if (l_button !is null)
			{
				l_button.SetHoverText("Double click with LMB\nto take out quickly\n");
			}
			CGridButton@ m_button = tool.AddButton(((mmb_binded_id == 0 || mmb_binded is null)?"":("$"+mmb_binded.getName()+"$")), "", this.getCommandID("set item for MMB"), Vec2f(1, 1), params);
			if (m_button !is null)
			{
				m_button.SetHoverText("Double click with MMB\nto take out quickly\n");
			}
			CGridButton@ r_button = tool.AddButton(((rmb_binded_id == 0 || rmb_binded is null)?"":("$"+rmb_binded.getName()+"$")), "", this.getCommandID("set item for RMB"), Vec2f(1, 1), params);
			if (r_button !is null)
			{
				r_button.SetHoverText("Double click with RMB\nto take out quickly\n");
			}
		}
	}
}

void onCommand(CInventory@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getBlob().getCommandID("set item for LMB"))
	{
		u16 caller_id;
		if (!params.saferead_u16(caller_id)) return;
		u16 carried_id;
		if (!params.saferead_u16(carried_id)) return;
		CBlob@ caller = getBlobByNetworkID(caller_id);
		CBlob@ carried = getBlobByNetworkID(carried_id);
		caller.set_u16("LMB_item_netid", carried_id);
		
		UpdateInventoryOnClick(caller);
	}
	if (cmd == this.getBlob().getCommandID("set item for MMB"))
	{
		u16 caller_id;
		if (!params.saferead_u16(caller_id)) return;
		u16 carried_id;
		if (!params.saferead_u16(carried_id)) return;
		CBlob@ caller = getBlobByNetworkID(caller_id);
		CBlob@ carried = getBlobByNetworkID(carried_id);
		caller.set_u16("MMB_item_netid", carried_id);
		
		UpdateInventoryOnClick(caller);
	}
	if (cmd == this.getBlob().getCommandID("set item for RMB"))
	{
		u16 caller_id;
		if (!params.saferead_u16(caller_id)) return;
		u16 carried_id;
		if (!params.saferead_u16(carried_id)) return;
		CBlob@ caller = getBlobByNetworkID(caller_id);
		CBlob@ carried = getBlobByNetworkID(carried_id);
		caller.set_u16("RMB_item_netid", carried_id);
		
		UpdateInventoryOnClick(caller);
	}
}