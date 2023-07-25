#include "HeadSetting.as";
#include "KIWI_Locales.as";

u8 getPacksAmount()
{
	u8 amount = 0;
	//shitcode ahead
	for (u8 i = 0; i < 100; ++i)
	{
		if(CFileMatcher("Headpack"+i).hasMatch())
			++amount;
		else return amount;
	}
	return 0;
}

void onInit(CRules@ this)
{
	this.addCommandID("set_head_index");
	this.addCommandID("choose_headpack");
}

void addPackIcons(CPlayer@ player)
{
	//load head icons
	if (CFileMatcher(player.getUsername()).hasMatch())
		AddIconToken("Headpack"+player.getUsername()+"Icon", player.getUsername(), Vec2f(HEAD_DIMENSION, HEAD_DIMENSION), 0);
	else
		AddIconToken("Headpack"+player.getUsername()+"Icon", "BuilderIcons.png", Vec2f(32, 32), 2);
	for (u8 i = 0; i < getPacksAmount(); i++)
	{
		AddIconToken("Headpack"+i+"Icon", "Headpack"+i, Vec2f(HEAD_DIMENSION, HEAD_DIMENSION), 3);
	}
}

void HeadpackChoosingMenu()
{
	CPlayer@ player = getLocalPlayer();
	if (player !is null && player.isMyPlayer())
	{
		addPackIcons(player);
		ShowHeadpackMenu(player);
	}
}

void ShowHeadpackMenu(CPlayer@ player)
{
	if (!player.isMyPlayer()) return;
	//hide main menu and other gui
	Menu::CloseAllMenus();
	getHUD().ClearMenus(true);

	CRules@ rules = getRules();
	Vec2f center = getDriver().getScreenCenterPos();
	string description = Descriptions::choose_headpack;
	
	u8 separator_height = 1;

	//display main grid menu
	CGridMenu@ menu = CreateGridMenu(center, null, Vec2f(MAX_WIDTH, 1+Maths::Ceil((getPacksAmount()+1)/MAX_WIDTH)+separator_height), description);
	if (menu !is null)
	{
		menu.deleteAfterClick = false;
		
		CGridButton@ separator = menu.AddTextButton(description, Vec2f(MAX_WIDTH, separator_height));
		separator.clickable = false;
		separator.SetEnabled(false);
		
		//display a button for custom head
		CBitStream uparams;
		uparams.write_string(player.getUsername());
		uparams.write_string(player.getUsername());
		CGridButton@ unique_pack = menu.AddButton("Headpack"+player.getUsername()+"Icon", description, rules.getCommandID("choose_headpack"), Vec2f(2, 1), uparams);
		if (!CFileMatcher(player.getUsername()).hasMatch())
		{
			unique_pack.clickable = false;
		}
		//display headpack choosing menu
		for (int i = 0; i < getPacksAmount(); i++)
		{
			CBitStream params;
			params.write_string(player.getUsername());
			params.write_string("Headpack"+i);
			CGridButton@ button = menu.AddButton("Headpack"+i+"Icon", description, rules.getCommandID("choose_headpack"), Vec2f(2, 1), params);
		}
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("choose_headpack"))
	{
		string player_name;
		string chosen_headpack;
		if(!params.saferead_string(player_name)) return;
		if(!params.saferead_string(chosen_headpack)) return;
		CRules@ rules = getRules();
		CPlayer@ player = getPlayerByUsername(player_name);
		rules.set_string(player_name + "Headpack", chosen_headpack);
		HeadConfiguringMenu();
		if (player !is null && player.isMyPlayer())
		{
			//Sound::Play("levelup", player.getBlob().getPosition(), 2.4f, 0.95f + (XORRandom(4)-2)*0.01);
		}
	}
	else if(cmd == this.getCommandID("set_head_index"))
	{
		string player_name;
		u8 head_index;
		if(!params.saferead_string(player_name)) return;
		if(!params.saferead_u8(head_index)) return;
		CRules@ rules = getRules();
		CPlayer@ player = getPlayerByUsername(player_name);
		rules.set_u8(player_name + "HeadIndex", head_index);
		if (player !is null) {
			CBlob@ blob = player.getBlob();
			if (blob !is null)
				blob.getSprite().RemoveSpriteLayer("head");
		}
		if (player !is null && player.isMyPlayer())
		{
			Sound::Play("levelup", player.getBlob().getPosition(), 2.4f, 0.95f + (XORRandom(4)-2)*0.01);
		}
	}
}