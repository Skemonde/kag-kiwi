void UpdateInventoryOnClick(CBlob@ caller)
{
	Vec2f center = getDriver().getScreenCenterPos(); // center of screen
	caller.ClearMenus();
	if (caller.getInventory() !is null)
		caller.CreateInventoryMenu(center);
}