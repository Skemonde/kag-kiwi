//script by Skemonde uwu
void UpdateInventoryOnClick(CBlob@ caller)
{
	Vec2f center = getDriver().getScreenCenterPos();
	caller.ClearMenus();
	CPlayer@ caller_player = caller.getPlayer();
	if (caller.getInventory() !is null && caller_player !is null && caller_player.isMyPlayer())
		caller.CreateInventoryMenu(center);
}