#define CLIENT_ONLY
#include "KIWI_Locales.as";

void onMainMenuCreated(CRules@ this, CContextMenu@ menu)
{
	CContextMenu@ bindingsMenu = Menu::addContextMenu(menu, getTranslatedString(Names::headtab));
	Menu::addContextItem(bindingsMenu, getTranslatedString(Names::headcfg), "HeadpackSetting.as", "void HeadpackChoosingMenu()");
}
