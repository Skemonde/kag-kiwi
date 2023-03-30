#include "KIWI_Locales"

const u8 GRID_SIZE = 48;
const u8 GRID_PADDING = 12;
Vec2f TOOL_POS = Vec2f_zero;

void onInit(CInventory@ this)
{
	this.getBlob().addCommandID("set item for LMB");
	this.getBlob().addCommandID("set item for RMB");
}

void onCreateInventoryMenu(CInventory@ this, CBlob@ forBlob, CGridMenu@ menu)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;

	DrawMouseBindings(blob, menu, forBlob);
}

void DrawMouseBindings(CBlob@ this, CGridMenu@ menu, CBlob@ forBlob) {
	if (isClient())
		TOOL_POS = menu.getUpperLeftPosition() + Vec2f(1,-1)*GRID_SIZE - Vec2f(0, GRID_PADDING);
	UpdateMouseBindings(this, forBlob);
}

void UpdateMouseBindings(CBlob@ this, CBlob@ forBlob) {
	CGridMenu@ tool = CreateGridMenu(TOOL_POS, this, Vec2f(2, 2), "");
	if (tool !is null)
	{
		tool.SetCaptionEnabled(false);
		tool.deleteAfterClick = false;
		
		CPlayer@ player = null;
		u16 lmb_binded_id = this.get_u16("LMB_item_netid"), rmb_binded_id = this.get_u16("RMB_item_netid");
		CBlob@ carried = null, lmb_binded = getBlobByNetworkID(lmb_binded_id), rmb_binded = getBlobByNetworkID(rmb_binded_id);
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
	
			AddIconToken("$LMB$", "Keys.png", Vec2f(16, 16), 8);
			AddIconToken("$RMB$", "Keys.png", Vec2f(16, 16), 9);
			CGridButton@ l_button = tool.AddButton(((lmb_binded_id == 0 || lmb_binded is null)?"":("$"+lmb_binded.getName()+"$")), "", this.getCommandID("set item for LMB"), Vec2f(1, 2), params);
			if (l_button !is null)
			{
				l_button.SetHoverText("LMB");
			}
			CGridButton@ r_button = tool.AddButton(((rmb_binded_id == 0 || rmb_binded is null)?"":("$"+rmb_binded.getName()+"$")), "", this.getCommandID("set item for RMB"), Vec2f(1, 2), params);
			if (r_button !is null)
			{
				r_button.SetHoverText("RMB");
			}
		}
	}
}

void onRender(CSprite@ this)
{
	GUI::DrawIconByName("$LMB$", TOOL_POS);
	GUI::DrawIconByName("$RMB$", TOOL_POS+Vec2f(GRID_SIZE,0));
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
	}
}