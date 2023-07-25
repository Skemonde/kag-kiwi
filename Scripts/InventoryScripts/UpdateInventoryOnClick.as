//script by Skemonde uwu
void UpdateInventoryOnClick(CBlob@ inventoryBlob, Vec2f pos = Vec2f(0,0))
{
	Vec2f center = getDriver().getScreenCenterPos();
	if (pos == Vec2f_zero)
		pos = center;
	CBlob@ caller_blob = getLocalPlayerBlob();
	if (caller_blob is null) return;
	caller_blob.ClearMenus();
	if (inventoryBlob.getInventory() !is null && caller_blob is inventoryBlob)
		inventoryBlob.CreateInventoryMenu(pos);
}