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
#include "TradingKIWI"
#include "ScrollCommon"

void MakeWarTradeMenu(CBlob@ trader)
{
	InitCosts();
	int teamnum = Maths::Min(trader.getTeamNum(), 7);

	// build menu
	Vec2f menu_dims = Vec2f(7, 0);
	CreateTradeMenu(trader, menu_dims, "Trade");

	//first tier guns
	addTradeSeparatorItem(trader, "$GUNS_TIER_1$", Vec2f(menu_dims.x, 1));
	{
		TradeItem@ t = addTradeItem(trader, Names::revolver, "$revolver$", "revolver", Descriptions::revolver, true);
		AddRequirement(t.reqs, "coin", "", "", 20);
	}
	{
		TradeItem@ t = addTradeItem(trader, Names::drum_smg, "$drumsmg$", "drumsmg", Descriptions::drum_smg, true, Vec2f(2, 1));
		AddRequirement(t.reqs, "coin", "", "", 75);
	}
	{
		TradeItem@ t = addTradeItem(trader, Names::pump_shotgun, "$pumpshotgun$", "pumpshotgun", Descriptions::pump_shotgun, true, Vec2f(2, 1));
		AddRequirement(t.reqs, "coin", "", "", 300);
	}
	{
		TradeItem@ t = addTradeItem(trader, Names::semi_auto_rifle, "$semiautorifle$", "semiautorifle", Descriptions::semi_auto_rifle, true, Vec2f(2, 1));
		AddRequirement(t.reqs, "coin", "", "", 150);
	}
	{
		TradeItem@ t = addTradeItem(trader, Names::single_shot_nader, "$singleshotnader$", "singleshotnader", Descriptions::single_shot_nader, true, Vec2f(2, 1));
		AddRequirement(t.reqs, "coin", "", "", 250);
	}
	{
		TradeItem@ t = addTradeItem(trader, Names::bazooka, "$bazooka$", "bazooka", Descriptions::bazooka, true, Vec2f(2, 1));
		AddRequirement(t.reqs, "coin", "", "", 450);
	}
	addTradeEmptyItem(trader, Vec2f(3, 1));

	//second tier guns
	addTradeSeparatorItem(trader, "$GUNS_TIER_2$", Vec2f(menu_dims.x, 1));
	{
		TradeItem@ t = addTradeItem(trader, Names::semi_auto_pistol, "$semiautopistol$", "semiautopistol", Descriptions::semi_auto_pistol, false);
		AddRequirement(t.reqs, "blob", "mat_gold", "Gold", 25);
	}
	{
		TradeItem@ t = addTradeItem(trader, Names::pocket_smg, "$pocketsmg$", "pocketsmg", Descriptions::pocket_smg, false, Vec2f(2, 1));
		AddRequirement(t.reqs, "blob", "mat_gold", "Gold", 100);
	}
	{
		TradeItem@ t = addTradeItem(trader, Names::auto_shotgun, "$autoshotgun$", "autoshotgun", Descriptions::auto_shotgun, false, Vec2f(2, 1));
		AddRequirement(t.reqs, "blob", "mat_gold", "Gold", 100);
	}
	{
		TradeItem@ t = addTradeItem(trader, Names::assault_rifle, "$assaultrifle$", "assaultrifle", Descriptions::assault_rifle, false, Vec2f(2, 1));
		AddRequirement(t.reqs, "blob", "mat_gold", "Gold", 200);
	}
	{
		TradeItem@ t = addTradeItem(trader, Names::sniper_rifle, "$sniperrifle$", "sniperrifle", Descriptions::sniper_rifle, false, Vec2f(3, 1));
		AddRequirement(t.reqs, "blob", "mat_gold", "Gold", 300);
	}
	{
		TradeItem@ t = addTradeItem(trader, Names::anti_tank_rifle, "$antitankrifle$", "antitankrifle", Descriptions::anti_tank_rifle, false, Vec2f(4, 1));
		AddRequirement(t.reqs, "blob", "mat_gold", "Gold", 500);
	}
	{
		TradeItem@ t = addTradeItem(trader, "Flamer", "$flamethrower$", "flamethrower", "Flamer desc", false, Vec2f(2, 1));
		AddRequirement(t.reqs, "blob", "mat_gold", "Gold", 400);
	}
	{
		TradeItem@ t = addTradeItem(trader, "Rocket Launcher", "$multishotbazooka$", "multishotbazooka", "Rocket Launcher desc", false, Vec2f(2, 1));
		AddRequirement(t.reqs, "blob", "mat_gold", "Gold", 500);
	}
	addTradeEmptyItem(trader, Vec2f(3, 1));
	
	//items
	addTradeSeparatorItem(trader, "$AMMUNITION$", Vec2f(menu_dims.x, 1));
	{
		TradeItem@ t = addTradeItem(trader, Names::frag_grenade, "$froggy$", "froggy", Descriptions::frag_grenade, true);
		AddRequirement(t.reqs, "coin", "", "", 50);
	}
	{
		TradeItem@ t = addTradeItem(trader, Names::molotov, "$molotov$", "molotov", Descriptions::molotov, true);
		AddRequirement(t.reqs, "coin", "", "", 50);
	}
	{
		TradeItem@ t = addTradeItem(trader, Names::aerial_bomb, "$abomb$", "abomb", Descriptions::aerial_bomb, true);
		AddRequirement(t.reqs, "coin", "", "", 250);
	}
	{
		TradeItem@ t = addTradeItem(trader, Names::tank_shell, "$tankshells$", "tankshells", Descriptions::tank_shell, true);
		AddRequirement(t.reqs, "coin", "", "", 200);
	}
	{
		TradeItem@ t = addTradeItem(trader, Names::land_mine, "$landmine_icon"+7+"$", "landmine", Descriptions::land_mine, true);
		AddRequirement(t.reqs, "coin", "", "", 50);
	}
	{
		TradeItem@ t = addTradeItem(trader, Names::tank_mine, "$tankmine_icon"+7+"$", "tankmine", Descriptions::tank_mine, true);
		AddRequirement(t.reqs, "coin", "", "", 200);
	}
	{
		TradeItem@ t = addTradeItem(trader, Names::name_combat_helmet, "$helm$", "helm", Descriptions::combat_helmet, true);
		AddRequirement(t.reqs, "coin", "", "", 40);
	}
	{
		TradeItem@ t = addTradeItem(trader, Names::name_heavy_helmet, "$hehelm$", "hehelm", Descriptions::heavy_helmet, true);
		AddRequirement(t.reqs, "blob", "mat_gold", "Gold", 150);
	}
	{
		TradeItem@ t = addTradeItem(trader, Names::lowcal, "$lowcal$", "lowcal", Descriptions::lowcal, true);
		AddRequirement(t.reqs, "coin", "", "", 10);
	}
	{
		TradeItem@ t = addTradeItem(trader, Names::shotgunshells, "$shells$", "shells", Descriptions::shotgunshells, true);
		AddRequirement(t.reqs, "coin", "", "", 40);
	}
	{
		TradeItem@ t = addTradeItem(trader, Names::fuel_canister, "$fuelcanister$", "fuelcanister", Descriptions::fuel_canister, true);
		AddRequirement(t.reqs, "coin", "", "", 120);
	}
	{
		TradeItem@ t = addTradeItem(trader, Names::highpow, "$highpow$", "highpow", Descriptions::highpow, true);
		AddRequirement(t.reqs, "coin", "", "", 20);
	}
	{
		TradeItem@ t = addTradeItem(trader, Names::name_amogus, "$amogus_icon"+teamnum+"$", "sugoma", Descriptions::amogus, true);
		AddRequirement(t.reqs, "blob", "mat_gold", "Gold", 50);
	}
	{
		TradeItem@ t = addTradeItem(trader, Names::name_binoculars, "$bino$", "bino", Descriptions::binoculars, true);
		AddRequirement(t.reqs, "coin", "", "", 20);
	}
	{
		TradeItem@ t = addTradeItem(trader, Names::name_food, "$food_5$", "food", Descriptions::food, true);
		AddRequirement(t.reqs, "coin", "", "", 50);
	}
	
	trader.set_Vec2f("trade menu size", getTradeMenuHeight(trader, menu_dims.x));
}

void onInit(CBlob@ this)
{
	MakeWarTradeMenu(this);
	this.set_bool("shop available", false);
	
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = 300;

	//INIT COSTS
	InitCosts();
	
	ShopMadeItem@ onMadeItem = @onShopMadeItem;
	this.set("onShopMadeItem handle", @onMadeItem);

	// SHOP
	this.setInventoryName(Names::armory);
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 8));
	if (isClient())
		this.set_string("shop description", Descriptions::armory);
	this.set_u8("shop icon", 25);
	addTokens();

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	this.set_string("required class", "soldat");
}

bool canPickup(CBlob@ blob)
{
	bool sub_gun = blob.exists("gun_id");
	return (blob.hasTag("firearm")/*  || blob.hasTag("ammo") || blob.hasTag("explosive") */)&&!(blob.getVelocity().Length()>0||blob.hasTag("landmine")||sub_gun);
}

void onTick(CBlob@ this)
{
	if (this.getInventory().isFull()) return;

	CBlob@[] blobs;
	if (getMap().getBlobsInBox(this.getPosition() + Vec2f(128, 96), this.getPosition() + Vec2f(-128, -96), @blobs))
	{
		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ blob = blobs[i];

			if ((canPickup(blob)) && !blob.isAttached())
			{
				if (isClient() && this.getInventory().canPutItem(blob)) blob.getSprite().PlaySound("/PutInInventory.ogg");
				if (isServer()) this.server_PutInInventory(blob);
			}
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());

	//CButton@ button = caller.CreateGenericButton(15, Vec2f(0,-8), this, this.getCommandID("menu"), "Set Item", params);
	if (!canSeeButtons(this, caller)) return;

	if (caller.getConfig() == this.get_string("required class"))
	{
		this.set_Vec2f("shop offset", Vec2f_zero);
	}
	else
	{
		this.set_Vec2f("shop offset", Vec2f(6, 0));
	}
	//this.set_bool("shop available", this.isOverlapping(caller));
	
	this.set_Vec2f("shop offset", Vec2f(4, 0));
	this.inventoryButtonPos = Vec2f(-8, 0);
}

void onShopMadeItem(CBitStream@ params)
{
	if (!isServer()) return;
	
	u16 this_id, caller_id, item_id;
	string name;

	if (!params.saferead_u16(this_id) || !params.saferead_u16(caller_id) || !params.saferead_u16(item_id) || !params.saferead_string(name))
	{
		return;
	}
	
	{
		CBlob@ callerBlob = getBlobByNetworkID(caller_id);
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

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item client"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
	}
}

void addTokens()
{
	for (int teamnum = 0; teamnum <= 7; ++teamnum) {
		AddIconToken("$amogus_icon"+teamnum+"$", 			"AmogusIcon.png", 			Vec2f(24, 24), 0, 69);
		AddIconToken("$landmine_icon"+teamnum+"$", 			"AntiPersonnelMine.png", 	Vec2f(16, 8), 0, teamnum);
		AddIconToken("$tankmine_icon"+teamnum+"$", 			"AntiMaterielMine.png", 	Vec2f(16, 8), 0, teamnum);
		AddIconToken("$radio_icon"+teamnum+"$", 			"WalkieTalkie.png", 		Vec2f(9, 16), 0, teamnum);
		AddIconToken("$boombox_icon"+teamnum+"$", 			"Boombox.png", 				Vec2f(16, 16), 0, teamnum);
		AddIconToken("$medhelm_icon"+teamnum+"$", 			"MedicHelm.png", 			Vec2f(16, 16), 0, teamnum);
	}
}