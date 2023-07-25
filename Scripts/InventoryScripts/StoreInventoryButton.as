//script by Skemonde uwu

bool storing_enabled = false;
bool grabbing_enabled = false;
bool taking_item_enabled = false;
const u8 GRID_SIZE = 48;
const u8 GRID_PADDING = 12;

void onInit(CInventory@ this)
{
	this.getBlob().addCommandID("store inventory");
	this.getBlob().addCommandID("get items from inventory");
	this.getBlob().addCommandID("pick from first slot");
}

void onCreateInventoryMenu(CInventory@ this, CBlob@ forBlob, CGridMenu@ menu)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;

	makeInventoryManageMenu(blob, menu, forBlob);
}

void makeInventoryManageMenu(CBlob@ this, CGridMenu@ menu, CBlob@ forBlob) {
	if (forBlob is null) return;
	
	storing_enabled = this.hasTag("storingButton");
	grabbing_enabled = this.hasTag("grabbingButton");
	taking_item_enabled = this.hasTag("takingItemButton") && (this.getTeamNum()<7 && forBlob.getTeamNum()==this.getTeamNum() || this.getTeamNum()>6);
	
	const u16 COOLDOWN = 60;
	const Vec2f MENU_DIMS(1, (storing_enabled?1:0)+(grabbing_enabled?1:0)+(taking_item_enabled?1:0));
	const Vec2f TOOL_POS = menu.getUpperLeftPosition() - Vec2f(GRID_PADDING, 0) + Vec2f(-MENU_DIMS.x, MENU_DIMS.y) * GRID_SIZE / 2;
	
	if (MENU_DIMS.y<1) return;
	
	CGridMenu@ tool = CreateGridMenu(TOOL_POS, this, MENU_DIMS, "");
	if (tool !is null)
	{
		tool.SetCaptionEnabled(false);
		tool.deleteAfterClick = false;
		
		CBitStream params;
		params.write_u16(forBlob.getNetworkID());

		AddIconToken("$store_inventory$", "InteractionIcons.png", Vec2f(32, 32), 28);
		AddIconToken("$empty_storage$", "InteractionIcons.png", Vec2f(32, 32), 20, 3);
		if (storing_enabled) {
			CGridButton@ button = tool.AddButton("$store_inventory$", "", this.getCommandID("store inventory"), Vec2f(1, 1), params);
			if (button !is null) {
				button.SetHoverText("Store All");
				if (getGameTime()<(this.get_u32("last_grabbing") + COOLDOWN)) {
					button.SetEnabled(false);
					button.SetHoverText("Not so fast!!!");
				}
			}
		}
		if (grabbing_enabled) {
			CGridButton@ button = tool.AddButton("$empty_storage$", "", this.getCommandID("get items from inventory"), Vec2f(1, 1), params);
			if (button !is null) {
				button.SetHoverText("Get All Items");
				if (getGameTime()<(this.get_u32("last_storing") + COOLDOWN)) {
					button.SetEnabled(false);
					button.SetHoverText("Not so fast!!!");
				}
			}
		}
		if (taking_item_enabled) {
			CGridButton@ button = tool.AddButton("$empty_storage$", "", this.getCommandID("pick from first slot"), Vec2f(1, 1), params);
			if (button !is null) {
				button.SetHoverText("Pick from First Slot");
				//button.SetEnabled(getGameTime()>(this.get_u32("last_storing") + COOLDOWN));
			}
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
				if (inv is null) return;
				
				while (inv.getItemsCount() > 0)
				{
					//it's better to start from the last item in OUR inventory so OUR inventory order isn't shuffled in case when we cannot fit an item into ANOTHER inventory
					int last_item_index = inv.getItemsCount()-1;
					CBlob@ item = inv.getItem(last_item_index);
					if (!blob.server_PutInInventory(item))
					{
						//your stuff doesn't fit! take it back :P
						caller.server_PutInInventory(item);
						break;
					}
					blob.set_u32("last_storing", getGameTime());
				}
			}
		}
		if (cmd == blob.getCommandID("get items from inventory"))
		{
			CBlob@ caller = getBlobByNetworkID(params.read_u16());
			if (caller !is null)
			{				
				while (this.getItemsCount() > 0)
				{
					int last_item_index = this.getItemsCount()-1;
					CBlob@ item = this.getItem(last_item_index);
					if (!caller.server_PutInInventory(item))
					{
						blob.server_PutInInventory(item);
						break;
					}
					blob.set_u32("last_grabbing", getGameTime());
				}
			}
		}
		if (cmd == blob.getCommandID("pick from first slot"))
		{
			CBlob@ caller = getBlobByNetworkID(params.read_u16());
			if (caller !is null)
			{				
				if (this.getItemsCount() > 0)
				{
					CBlob@ item = this.getItem(0);
					if (!caller.server_PutInInventory(item))
					{
						blob.server_PutInInventory(item);
					}
					blob.set_u32("last_grabbing", getGameTime());
				}
			}
		}
	}
}