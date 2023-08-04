#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "Costs.as";
#include "GenericButtonCommon.as";
#include "KIWI_Locales.as";
#include "ProductionCommon.as";
#include "Tunes"
#include "getShopMenuHeight"

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
	this.set_Vec2f("shop menu size", Vec2f(4, 8));
	if (isClient())
		this.set_string("shop description", Descriptions::armory);
	this.set_u8("shop icon", 25);
	addTokens();
	int teamnum = Maths::Min(this.getTeamNum(), 7);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	this.set_string("required class", "soldat");
	{
		ShopItem@ s = addShopItem(this, Names::revolver, "$revo$", "revo", Descriptions::revolver, true);
		AddRequirement(s.requirements, "coin", "", "", 2);
	}
	{
		ShopItem@ s = addShopItem(this, Names::smg, "$spp$", "spp", Descriptions::smg, true);
		AddRequirement(s.requirements, "coin", "", "", 10);
	}
	{
		ShopItem@ s = addShopItem(this, Names::shotgun, "$shaggy$", "shaggy", Descriptions::shotgun, true);
		AddRequirement(s.requirements, "coin", "", "", 20);
	}
	{
		ShopItem@ s = addShopItem(this, Names::rifle, "$bifle$", "bifle", Descriptions::rifle, true);
		AddRequirement(s.requirements, "coin", "", "", 40);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::mp, "$mp$", "mp", Descriptions::mp, true);
		AddRequirement(s.requirements, "coin", "", "", 10);
	}
	{
		ShopItem@ s = addShopItem(this, "Submachine Gun \"KEP\n", "$kep$", "kep", "An interesting thing! The more you shoot the worse your accuracy gets!!! Shoot by small bursts!", true);
		AddRequirement(s.requirements, "coin", "", "", 30);
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
		ShopItem@ s = addShopItem(this, Names::fa_shotgun, "$ass$", "ass", Descriptions::fa_shotgun, true);
		AddRequirement(s.requirements, "coin", "", "", 40);
		s.customButton = false;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::empty, "$arr$", "arr", Descriptions::empty, true);
		AddRequirement(s.requirements, "coin", "", "", 60);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::froggy, "$froggy$", "froggy", Descriptions::froggy, true);
		AddRequirement(s.requirements, "coin", "", "", 6);
	}
	{
		ShopItem@ s = addShopItem(this, Names::empty, "$radio_icon"+teamnum+"$", "wt", "Call a tank into battle! \n\nNote: Transmitter is a single-use item", true);
		AddRequirement(s.requirements, "coin", "", "", 52);
	}/* 
	{
		ShopItem@ s = addShopItem(this, Names::flashy, "$flashy$", "flashy", Descriptions::flashy, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 2);
	} *//* 
	{
		ShopItem@ s = addShopItem(this, Names::sniper, "$sniper$", "sniper", Descriptions::sniper, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	} */
	{
		ShopItem@ s = addShopItem(this, Names::empty, "$landmine_icon"+teamnum+"$", "landmine", "Отрывает ноги только так :3", true);
		AddRequirement(s.requirements, "coin", "", "", 4);
	}
	{
		ShopItem@ s = addShopItem(this, Names::empty, "$tankmine_icon"+teamnum+"$", "tankmine", "Doesn't give a damn about a filthy infantry", true);
		AddRequirement(s.requirements, "coin", "", "", 20);
	}
	{
		ShopItem@ s = addShopItem(this, "Military Helmet", "$helm$", "helm", "Military Helmet\n\n - Head hits don't deal crit damage\n - 5 less gunfire damage", true);
		AddRequirement(s.requirements, "coin", "", "", 5);
	}
	{
		ShopItem@ s = addShopItem(this, Names::amogus, "$amogus_icon"+teamnum+"$", "sugoma", Descriptions::amogus, true);
		AddRequirement(s.requirements, "coin", "", "", 69);
	}
	{
		ShopItem@ s = addShopItem(this, Names::empty, "$goodluck$", "goodluck", Descriptions::empty, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 40);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::empty, "$grenades$", "grenades", "These are for underbarrel grenader!!", true);
		AddRequirement(s.requirements, "coin", "", "", 6);
	}
	{
		ShopItem@ s = addShopItem(this, Names::empty, "$bino$", "bino", "Press S to see further or use a mouse scroll to get a better view", true);
		AddRequirement(s.requirements, "coin", "", "", 2);
	}
	{
		ShopItem@ s = addShopItem(this, Names::empty, "$tape$", "tape", Descriptions::empty, false);
		AddRequirement(s.requirements, "coin", "", "", 2);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Boombox", "$boombox_icon"+teamnum+"$", "boombox", "Get yourself a fancy boombox! Now! \n\nNote: it does require tapes tho..\nNote: only your team will hear a boombox of your color", true);
		AddRequirement(s.requirements, "coin", "", "", 5);
		AddRequirement(s.requirements, "no more", "boombox", "Boombox", 1);
	}
	{
		ShopItem@ s = addShopItem(this, Names::empty, "$wrench$", "wrench", Descriptions::empty, false);
		AddRequirement(s.requirements, "coin", "", "", 10);
		AddRequirement(s.requirements, "no more", "wrench", "Wrench", 1);
	}/* 
	{
		ShopItem@ s = addShopItem(this, Names::kushana, "$blaster$", "blaster", Descriptions::kushana, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 200);
	}
	{
		ShopItem@ s = addShopItem(this, Names::ruhm, "$ruhm$", "ruhm", Descriptions::ruhm, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 200);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	} */  
	{
		ShopItem@ s = addShopItem(this, Names::lowcal, "$lowcal$", "lowcal", Descriptions::lowcal, true);
		AddRequirement(s.requirements, "coin", "", "", 2);
	}
	{
		ShopItem@ s = addShopItem(this, Names::shotgunshells, "$shells$", "shells", Descriptions::shotgunshells, true);
		AddRequirement(s.requirements, "coin", "", "", 10);
	}
	{
		ShopItem@ s = addShopItem(this, Names::highpow, "$highpow$", "highpow", Descriptions::highpow, true);
		AddRequirement(s.requirements, "coin", "", "", 5);
	}
	{
		ShopItem@ s = addShopItem(this, "BURGIR", "$burgir_icon$", "food_5", Descriptions::burger, true);
		AddRequirement(s.requirements, "coin", "", "", 2);
		s.spawnNothing = true;
	}
	this.set_Vec2f("shop menu size", getShopMenuHeight(this, 5));
	return;
	
	ShopItem[]@ shop_items;
	if (!this.get(SHOP_ARRAY, @shop_items))
	{
		return;
	}
	if (shop_items.length<1) return;
	int squared_inventory_space = 0;
	const int SHOP_MENU_WIDTH = 5;
	for (int counter = 0; counter < shop_items.length; ++counter) {
		ShopItem@ item = @shop_items[counter];
		if (item is null) { continue; }
		if (item.customButton)
			squared_inventory_space += item.buttonwidth * item.buttonheight;
		else
			squared_inventory_space += 1;
	}
	this.set_Vec2f("shop menu size", Vec2f(SHOP_MENU_WIDTH, Maths::Floor(squared_inventory_space/SHOP_MENU_WIDTH)+(squared_inventory_space%SHOP_MENU_WIDTH==0?0:1)));
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
		u16 caller, item;
		if (!params.saferead_netid(caller) || !params.saferead_netid(item))
		{
			return;
		}
		string name = params.read_string();
		{
			CBlob@ callerBlob = getBlobByNetworkID(caller);
			if (callerBlob is null)
			{
				return;
			}
			string[]@ tokens = (name).split("_");
			if (tokens.size()>0 && !tokens[0].empty())
			{
				if (tokens[0] == "tape") {
					CBlob@ tape = server_CreateBlob("tape");
					if (tape !is null) {
						CBlob@ carried = callerBlob.getCarriedBlob();
						if (carried!is null) {
							callerBlob.server_PutInInventory(carried);
						}
						callerBlob.server_Pickup(tape);
						if (tokens.size()>1 && !tokens[1].empty())
							tape.set_u32("customData", parseInt(tokens[1]));
						else
							tape.set_u32("customData", XORRandom(tunes.length()-1));
					}
				}
				else if (tokens[0] == "food") {
					string[]@ tokens = (name).split("_");
					CBlob@ food_item = server_CreateBlob("food");
					if (food_item !is null) {
						CBlob@ carried = callerBlob.getCarriedBlob();
						if (carried!is null) {
							callerBlob.server_PutInInventory(carried);
						}
						callerBlob.server_Pickup(food_item);
						food_item.set_u32("customData", parseInt(tokens[1]));
					}
				}
			}
		}
	}
}

void addTokens()
{
	for (int team = 0; team <= 7; ++team) {
		AddIconToken("$amogus_icon"+team+"$", 				"AmogusIcon.png", 			Vec2f(24, 24), 0, 69);
		AddIconToken("$landmine_icon"+team+"$", 			"AntiPersonnelMine.png", 	Vec2f(16, 8), 0, team);
		AddIconToken("$tankmine_icon"+team+"$", 			"AntiMaterielMine.png", 	Vec2f(16, 8), 0, team);
		AddIconToken("$radio_icon"+team+"$", 				"WalkieTalkie.png", 		Vec2f(9, 16), 0, team);
		AddIconToken("$boombox_icon"+team+"$", 				"Boombox.png", 				Vec2f(16, 16), 0, team);
	}
}