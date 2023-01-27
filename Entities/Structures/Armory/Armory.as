#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "Costs.as";
#include "GenericButtonCommon.as";
#include "KIWI_Locales.as";
#include "ProductionCommon.as";

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	//INIT COSTS
	InitCosts();

	// SHOP
	this.setInventoryName(Names::armory);
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 5));
	this.set_string("shop description", Descriptions::armory);
	this.set_u8("shop icon", 25);
	this.Tag("workshop");
	addTokens(this);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	this.set_string("required class", "soldat");
	this.Tag("huffpuff production");   // for production.as
	this.set_Vec2f("production offset", Vec2f(-16,0));
	
	//{
	//	CBitStream requirements;
	//	AddRequirement( requirements, "blob", "froggy", "Shark steak", 1 );
	//	ShopItem@ s = addProductionItem(this, Names::smg, "$kep$", "kep", Descriptions::smg, 6, true, 2, @requirements, 2);
	//}
	{
		ShopItem@ s = addShopItem(this, Names::lowcal, "$lowcal$", "lowcal", Descriptions::lowcal, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 1);
	}
	{
		ShopItem@ s = addShopItem(this, Names::revolver, "$revo$", "revo", Descriptions::revolver, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 2);
	}
	{
		ShopItem@ s = addShopItem(this, Names::smg, "$smg$", "smg", Descriptions::smg, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 3);
	}
	{
		ShopItem@ s = addShopItem(this, Names::smg, "$kep$", "kep", Descriptions::smg, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 4);
	}
	{
		ShopItem@ s = addShopItem(this, Names::highpow, "$highpow$", "highpow", Descriptions::highpow, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 3);
	}
	{
		ShopItem@ s = addShopItem(this, Names::rifle, "$rifle$", "rifle", Descriptions::rifle, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 4);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::mp, "$mp$", "mp", Descriptions::mp, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 3);
	}
	/*
	{
		ShopItem@ s = addShopItem(this, "Grenades", "$grenades$", "grenades", " Ammo for Grenade Launcher  ", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 5);
	}
	{
		ShopItem@ s = addShopItem(this, "Grenade Launcher", "$gl$", "gl", " A foe is hinding in a trench or behind a wall? This gun is a right choice!  ", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 25);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	*/
	{
		ShopItem@ s = addShopItem(this, Names::shotgunshells, "$shells$", "shells", Descriptions::shotgunshells, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 2);
	}
	{
		ShopItem@ s = addShopItem(this, Names::shotgun, "$shotgun$", "shotgun", Descriptions::shotgun, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 5);
	}
	{
		ShopItem@ s = addShopItem(this, Names::fa_shotgun, "$ass$", "ass", Descriptions::fa_shotgun, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 8);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::froggy, "$froggy$", "froggy", Descriptions::froggy, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 2);
	}
	{
		ShopItem@ s = addShopItem(this, Names::flashy, "$flashy$", "flashy", Descriptions::flashy, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 2);
	}
	{
		ShopItem@ s = addShopItem(this, Names::sniper, "$sniper$", "sniper", Descriptions::sniper, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 8);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::kushana, "$blaster$", "blaster", Descriptions::kushana, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 20);
	}
	{
		ShopItem@ s = addShopItem(this, Names::ruhm, "$ruhm$", "ruhm", Descriptions::ruhm, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 20);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::amogus, "$amogus_con$", "sugoma", Descriptions::amogus, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 69);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

	if (caller.getConfig() == this.get_string("required class"))
	{
		this.set_Vec2f("shop offset", Vec2f_zero);
	}
	else
	{
		this.set_Vec2f("shop offset", Vec2f(6, 0));
	}
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
	}
}

void addTokens(CBlob@ this)
{
	int teamnum = this.getTeamNum();
	if (teamnum > 6) teamnum = 7;

	AddIconToken("$amogus_con$", "AmogusIcon.png", Vec2f(24, 24), 0, 69);
}