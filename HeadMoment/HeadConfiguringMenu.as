#define CLIENT_ONLY

void onMainMenuCreated(CRules@ this, CContextMenu@ menu)
{
	CContextMenu@ bindingsMenu = Menu::addContextMenu(menu, getTranslatedString("Headstuff"));
	Menu::addContextItem(bindingsMenu, getTranslatedString("Head Configure"), "HeadConfiguring.as", "void HeadConfiguringMenu()");
}
