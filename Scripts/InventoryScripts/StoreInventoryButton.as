#include "KIWI_Locales.as";

const u8 GRID_SIZE = 48;
const u8 GRID_PADDING = 12;

void onInit(CInventory@ this)
{
	this.getBlob().addCommandID("store inventory");
	this.getBlob().add_u8("inventory_buttons_amount", 1);
}

void onCreateInventoryMenu(CInventory@ this, CBlob@ forBlob, CGridMenu@ menu)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;

	DrawStoreInventoryButton(blob, menu, forBlob);
}

void DrawStoreInventoryButton(CBlob@ this, CGridMenu@ menu, CBlob@ forBlob) {
	if (forBlob is null) return;
	CRules@ rules = getRules();
	const Vec2f TOOL_POS = menu.getUpperLeftPosition() + Vec2f(0,1)*GRID_SIZE*(2-1) - Vec2f(GRID_PADDING, 0) + Vec2f(-1, 1) * GRID_SIZE / 2;
	
	CGridMenu@ tool = CreateGridMenu(TOOL_POS, this, Vec2f(1, 1), "");
	if (tool !is null)
	{
		tool.SetCaptionEnabled(false);
		tool.deleteAfterClick = false;
		
		CBitStream params;
		params.write_u16(forBlob.getNetworkID());

		CGridButton@ button = tool.AddButton("$store_inventory$", "", this.getCommandID("store inventory"), Vec2f(1, 1), params);
		if (button !is null)
		{
			button.SetHoverText("Store All");
		}
	}
}

void onCommand(CInventory@ this, u8 cmd, CBitStream @params)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	if (isServer())
	{
		if (cmd == blob.getCommandID("store inventory"))
		{
			CBlob@ caller = getBlobByNetworkID(params.read_u16());
			if (caller !is null)
			{
				CInventory @inv = caller.getInventory();
				if (caller.getName() == "builder")
				{
					CBlob@ carried = caller.getCarriedBlob();
					if (carried !is null)
					{
						// TODO: find a better way to check and clear blocks + blob blocks || fix the fundamental problem, blob blocks not double checking requirement prior to placement.
						if (carried.hasTag("temp blob"))
						{
							carried.server_Die();
						}
					}
				}
				
				if (inv !is null)
				{
					while (inv.getItemsCount() > 0)
					{
						CBlob@ item = inv.getItem(0);
						if (!blob.server_PutInInventory(item))
						{
							print("HALO??");
							caller.server_PutInInventory(item);
							break;
						}
					}
				}
			}
		}
	}
}