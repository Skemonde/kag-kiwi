const u8 MAX_WIDTH = 6;
const u8 HEAD_DIMENSION = 16;
const u8 HEAD_FRAMES = 4;

u8 getHeadsAmount(string head_file)
{
	if(CFileMatcher(head_file).hasMatch())
	{
		u8 amount = (CFileImage(head_file).getHeight() * CFileImage(head_file).getWidth()) / (HEAD_DIMENSION*HEAD_DIMENSION*HEAD_FRAMES);
		return amount;
	}
	else return 0;
}

void addHeadIcons(CPlayer@ player)
{
	CRules@ rules = getRules();
	//load head icons
	for (u16 i = 0; i < getHeadsAmount(rules.get_string(player.getUsername() + "Headpack")); i++)
	{
		AddIconToken(player.getUsername()+"Head"+i, rules.get_string(player.getUsername() + "Headpack"), Vec2f(HEAD_DIMENSION, HEAD_DIMENSION), HEAD_FRAMES*i);
	}
}

void HeadConfiguringMenu()
{
	CPlayer@ player = getLocalPlayer();
	if (player !is null && player.isMyPlayer())
	{
		addHeadIcons(player);
		ShowHeadMenu(player);
	}
}

void ShowHeadMenu(CPlayer@ player)
{
	//hide main menu and other gui
	Menu::CloseAllMenus();
	getHUD().ClearMenus(true);

	CRules@ rules = getRules();
	Vec2f center = getDriver().getScreenCenterPos();
	string description = getTranslatedString("Set your custom head!!!!!");
	
	u8 separator_height = 2;

	//display main grid menu
	CGridMenu@ menu = CreateGridMenu(center, null, Vec2f(MAX_WIDTH, 1+Maths::Ceil(getHeadsAmount(rules.get_string(player.getUsername() + "Headpack"))/MAX_WIDTH)+separator_height), description);
	if (menu !is null)
	{
		menu.deleteAfterClick = false;
		
		CGridButton@ separator = menu.AddTextButton(getTranslatedString("Select a head you want"), Vec2f(MAX_WIDTH, separator_height));
		separator.clickable = false;
		separator.SetEnabled(false);
		
		//display head configure menu
		for (int i = 0; i < getHeadsAmount(rules.get_string(player.getUsername() + "Headpack")); i++)
		{
			CBitStream params;
			params.write_string(player.getUsername());
			params.write_u8(i);
			CGridButton@ button = menu.AddButton(player.getUsername()+"Head"+i, description, rules.getCommandID("set_head_index"), Vec2f(1, 1), params);
		}
	}
}