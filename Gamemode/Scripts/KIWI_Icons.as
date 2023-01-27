void onInit(CRules@ this)
{
	ReloadIcons(this);
}

void onReload(CRules@ this)
{
	ReloadIcons(this);
}

void ReloadIcons(CRules@ this)
{
	print("--- ADDING KIWI ICON TOKENS ----");
	
	//GUI
	AddIconToken("$icon_dogtag$", "dogtag.png", Vec2f(11, 14), 0);
	AddIconToken("$icon_locked$", "InteractionIcons.png", Vec2f(32, 32), 2);
	AddIconToken("$icon_unlocked$", "InteractionIcons.png", Vec2f(32, 32), 3);
	
}