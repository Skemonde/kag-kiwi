//script by Skemonde uwu

void UpdateInventoryOnClick(CBlob@ inventoryBlob, Vec2f pos = Vec2f(0,0))
{
	if (inventoryBlob is null) return;
	if (inventoryBlob.getInventory() is null) return;
	
	Vec2f center = getDriver().getScreenCenterPos();
	
	if (pos == Vec2f_zero)
		pos = center;
	
	CBlob@ caller_blob = getLocalPlayerBlob();
	if (caller_blob is null) return;
	
	//we only update inventory for the owner
	if (caller_blob !is inventoryBlob) return;
	
	caller_blob.ClearMenus();
	inventoryBlob.CreateInventoryMenu(pos);
}