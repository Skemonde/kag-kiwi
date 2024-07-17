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
	//this.set_TileType("background tile", CMap::tile_wood_back);

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
	this.set_Vec2f("shop menu size", Vec2f(5, 3));
	if (isClient())
		this.set_string("shop description", Descriptions::armory);
	this.set_u8("shop icon", 25);
	addTokens();
	int teamnum = Maths::Min(this.getTeamNum(), 7);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	this.set_string("required class", "soldat");
	{
		ShopItem@ s = addShopItem(this, "W.Tank M1", "$tank_icon"+teamnum+"$", "firsttank", "Simple wooden tank with some steel plating", false);
		AddRequirement(s.requirements, "dogtag", "", "", 4500);
		s.customButton = true;
		s.buttonwidth = 3;
		s.buttonheight = 2;
	}
	{
		ShopItem@ s = addShopItem(this, "Mortar", "$mortar_icon"+teamnum+"$", "mortarcarriage", "Can send anything you can pickup flying!", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 80);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 300);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 2;
	}
	{
		ShopItem@ s = addShopItem(this, "Mini-Nuke", "$nuka$", "nuka", "Flash kills EVERYTHING in a huge radius\nHas a two second timer when it hits the ground", true);
		AddRequirement(s.requirements, "dogtag", "", "", 25000);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	//this.set_Vec2f("shop menu size", getShopMenuHeight(this, 4));
}

void onTick(CBlob@ this)
{
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
	this.set_bool("shop available", this.isOverlapping(caller));
	
	this.set_Vec2f("shop offset", Vec2f(0, 0));
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