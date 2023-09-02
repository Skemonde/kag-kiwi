// show menu that only allows to join spectator

#include "SwitchFromSpec.as"
#include "RulesCore.as"
#include "KIWI_Locales.as"

const int BUTTON_SIZE = 2;

void onInit(CRules@ this)
{
	this.addCommandID("pick teams");
	this.addCommandID("pick none");

	AddIconToken("$BLUZ_TEAM$", "Emblems.png", Vec2f(32, 32), 0, 6);
	AddIconToken("$REDZ_TEAM$", "Emblems.png", Vec2f(32, 32), 1, 1);
	AddIconToken("$TEAMGENERIC$", "Emblems.png", Vec2f(32, 32), 2, 7);
}

void ShowTeamMenu(CRules@ this)
{
	if (getLocalPlayer() is null)
	{
		return;
	}
	
	RulesCore@ core;
	this.get("core", @core);
	if (core is null) return;
	
	u8 teams_amount = core.teams.size();

	getHUD().ClearMenus(true);

	CGridMenu@ menu = CreateGridMenu(getDriver().getScreenCenterPos(), null, Vec2f((teams_amount + 0.5f) * BUTTON_SIZE, BUTTON_SIZE), "Change team");

	if (menu !is null)
	{
		CBitStream exitParams;
		menu.AddKeyCommand(KEY_ESCAPE, this.getCommandID("pick none"), exitParams);
		menu.SetDefaultCommand(this.getCommandID("pick none"), exitParams);
		
		//bluz
		{
			CBitStream params;
			params.write_u16(getLocalPlayer().getNetworkID());
			params.write_u8(core.teams[0].index);
			CGridButton@ button =  menu.AddButton("$BLUZ_TEAM$", Names::team_skyblue, this.getCommandID("pick teams"), Vec2f(BUTTON_SIZE, BUTTON_SIZE), params);
		}
		
		// spectator
		{
			CBitStream params;
			params.write_u16(getLocalPlayer().getNetworkID());
			params.write_u8(this.getSpectatorTeamNum());
			CGridButton@ button2 = menu.AddButton("$SPECTATOR$", getTranslatedString("Spectator"), this.getCommandID("pick teams"), Vec2f(BUTTON_SIZE / 2, BUTTON_SIZE), params);
		}

		//redz
		{
			CBitStream params;
			params.write_u16(getLocalPlayer().getNetworkID());
			params.write_u8(core.teams[1].index);
			CGridButton@ button =  menu.AddButton("$REDZ_TEAM$", Names::team_red, this.getCommandID("pick teams"), Vec2f(BUTTON_SIZE, BUTTON_SIZE), params);
		}
	}
}

// the actual team changing is done in the player management script -> onPlayerRequestTeamChange()

void ReadChangeTeam(CRules@ this, CBitStream @params)
{
	CPlayer@ player = getPlayerByNetworkId(params.read_u16());
	u8 team = params.read_u8();

	if (player is getLocalPlayer())
	{
		if (CanSwitchFromSpec(this, player, team))
		{
			ChangeTeam(player, team);
			CBlob@ hooman = player.getBlob();
			if (hooman !is null) hooman.server_Die();
		}
		else
		{
			client_AddToChat("Game is currently full. Please wait for a new slot before switching teams.", ConsoleColour::GAME);
			Sound::Play("NoAmmo.ogg");
		}
	}
}

void ChangeTeam(CPlayer@ player, u8 team)
{
	player.client_ChangeTeam(team);
	getHUD().ClearMenus();
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("pick teams"))
	{
		ReadChangeTeam(this, params);
	}
	else if (cmd == this.getCommandID("pick none"))
	{
		getHUD().ClearMenus();
	}
}