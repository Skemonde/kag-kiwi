const u8 MAX_WIDTH = 6;
const u8 HEAD_DIMENSION = 16;
const u8 HEAD_FRAMES = 4;

u8 getHeadsAmount(string file_name)
{
	u8 amount = (CFileImage(file_name).getHeight() * CFileImage(file_name).getWidth()) / (HEAD_DIMENSION*HEAD_DIMENSION*HEAD_FRAMES);
	return amount;
}

void onInit(CRules@ this)
{
	this.addCommandID("set_head_index");
}

void addHeadIcons(CPlayer@ player)
{
	//load head icons
	for (u16 i = 0; i < getHeadsAmount(player.getUsername()); i++)
	{
		AddIconToken(player.getUsername()+"Head"+i, player.getUsername(), Vec2f(HEAD_DIMENSION, HEAD_DIMENSION), HEAD_FRAMES*i);
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
	CGridMenu@ menu = CreateGridMenu(center, null, Vec2f(MAX_WIDTH, 1+Maths::Ceil(getHeadsAmount(player.getUsername())/MAX_WIDTH)+separator_height), description);
	if (menu !is null)
	{
		menu.deleteAfterClick = false;
		
		CGridButton@ separator = menu.AddTextButton(getTranslatedString("Select a head you want"), Vec2f(MAX_WIDTH, separator_height));
		separator.clickable = false;
		separator.SetEnabled(false);
		
		//display head configure menu
		for (int i = 0; i < getHeadsAmount(player.getUsername()); i++)
		{
			CBitStream params;
			params.write_string(player.getUsername());
			params.write_u8(i);
			CGridButton@ button = menu.AddButton(player.getUsername()+"Head"+i, description, rules.getCommandID("set_head_index"), Vec2f(1, 1), params);
		}
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("set_head_index"))
	{
		string player_name;
		u8 head_index;
		if(!params.saferead_string(player_name)) return;
		if(!params.saferead_u8(head_index)) return;
		CRules@ rules = getRules();
		CPlayer@ player = getPlayerByUsername(player_name);
		rules.set_u8(player_name + "HeadIndex", head_index);
		if (player !is null && player.isMyPlayer())
		{
			Sound::Play("levelup", player.getBlob().getPosition(), 2.4f, 0.95f + (XORRandom(4)-2)*0.01);
		}
	}
}