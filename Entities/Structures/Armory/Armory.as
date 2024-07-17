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
	int teamnum = Maths::Min(this.getTeamNum(), 7);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	this.set_string("required class", "soldat");
	{
		ShopItem@ s = addShopItem(this, Names::revolver, "$revolver$", "revolver", Descriptions::revolver, true);
		AddRequirement(s.requirements, "coin", "", "", 20);
	}
	{
		ShopItem@ s = addShopItem(this, Names::drum_smg, "$drumsmg$", "drumsmg", Descriptions::drum_smg, true);
		AddRequirement(s.requirements, "coin", "", "", 75);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::pump_shotgun, "$pumpshotgun$", "pumpshotgun", Descriptions::pump_shotgun, true);
		AddRequirement(s.requirements, "coin", "", "", 300);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::semi_auto_rifle, "$semiautorifle$", "semiautorifle", Descriptions::semi_auto_rifle, true);
		AddRequirement(s.requirements, "coin", "", "", 150);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::single_shot_nader, "$singleshotnader$", "singleshotnader", Descriptions::single_shot_nader, true);
		AddRequirement(s.requirements, "coin", "", "", 250);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::bazooka, "$bazooka$", "bazooka", Descriptions::bazooka, true);
		AddRequirement(s.requirements, "coin", "", "", 450);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::semi_auto_pistol, "$semiautopistol$", "semiautopistol", Descriptions::semi_auto_pistol, true);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 25);
	}
	{
		ShopItem@ s = addShopItem(this, Names::pocket_smg, "$pocketsmg$", "pocketsmg", Descriptions::pocket_smg, true);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 100);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::auto_shotgun, "$autoshotgun$", "autoshotgun", Descriptions::auto_shotgun, true);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 100);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::assault_rifle, "$assaultrifle$", "assaultrifle", Descriptions::assault_rifle, true);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 200);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::sniper_rifle, "$sniperrifle$", "sniperrifle", Descriptions::sniper_rifle, true);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 300);
		s.customButton = true;
		s.buttonwidth = 3;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::anti_tank_rifle, "$antitankrifle$", "antitankrifle", Descriptions::anti_tank_rifle, true);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 500);
		s.customButton = true;
		s.buttonwidth = 4;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::froggy, "$froggy$", "froggy", Descriptions::froggy, true);
		AddRequirement(s.requirements, "coin", "", "", 50);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Molotov", "$molotov$", "molotov", "It roasts you have no idea", true);
		AddRequirement(s.requirements, "coin", "", "", 50);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Aerial Bomb", "$abomb$", "abomb", "Big aerial bomb you can use with a mortar\nHas a two second timer when it hits the ground", true);
		AddRequirement(s.requirements, "coin", "", "", 250);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}/* 
	{
		ShopItem@ s = addShopItem(this, "Big Bomb", "$bigbomb$", "bigbomb", "Huge bomb you can use with a mortar\nHas a two second timer when it hits the ground", true);
		AddRequirement(s.requirements, "coin", "", "", 3000);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}*/
	{
		ShopItem@ s = addShopItem(this, "Tank Shells", "$tankshells$", "tankshells", "A big shell for a big cannon", true);
		AddRequirement(s.requirements, "coin", "", "", 200);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}/* 
	{
		ShopItem@ s = addShopItem(this, Names::empty, "$radio_icon"+teamnum+"$", "wt", "Call a tank into battle! \n\nNote: Transmitter is a single-use item", true);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 50);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	} */
	{
		ShopItem@ s = addShopItem(this, "Anti-Personnel Mine", "$landmine_icon"+7+"$", "landmine", "Goes off only when a victim steps off it", true);
		AddRequirement(s.requirements, "coin", "", "", 50);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Anti-Tank Mine", "$tankmine_icon"+7+"$", "tankmine", "Doesn't give a damn about filthy infantry", true);
		AddRequirement(s.requirements, "coin", "", "", 200);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Helmet", "$helm$", "helm", "Military Helmet\n\n - Head hits don't deal crit damage\n - 5 less gunfire damage", true);
		AddRequirement(s.requirements, "coin", "", "", 40);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Heavy Helmet", "$hehelm$", "hehelm", "Heavy Helmet\n\n - Head hits don't deal crit damage\n - 40 less gunfire damage but not less than 10", false);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 150);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::lowcal, "$lowcal$", "lowcal", Descriptions::lowcal, true);
		AddRequirement(s.requirements, "coin", "", "", 10);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::shotgunshells, "$shells$", "shells", Descriptions::shotgunshells, true);
		AddRequirement(s.requirements, "coin", "", "", 40);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::highpow, "$highpow$", "highpow", Descriptions::highpow, true);
		AddRequirement(s.requirements, "coin", "", "", 20);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::amogus, "$amogus_icon"+teamnum+"$", "sugoma", Descriptions::amogus, true);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 50);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::empty, "$bino$", "bino", "Press S to see further or use a mouse scroll to get a better view", true);
		AddRequirement(s.requirements, "coin", "", "", 20);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}/* 
	{
		ShopItem@ s = addShopItem(this, "W.Tank M1", "$tank_icon"+teamnum+"$", "firsttank", "Simple wooden tank with some steel plating", false);
		AddRequirement(s.requirements, "dogtag", "", "", 4500);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	} */
	{
		ShopItem@ s = addShopItem(this, "BURGIR", "$food_5$", "food_5", Descriptions::burger, true);
		AddRequirement(s.requirements, "coin", "", "", 50);
		s.spawnNothing = true;
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}/* 
	{
		ShopItem@ s = addShopItem(this, Names::empty, "$tape$", "tape", Descriptions::empty, false);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 50);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Boombox", "$boombox_icon"+7+"$", "boombox", "Get yourself a fancy boombox! Now! \n\nNote: it does require tapes tho..\nNote: only your team will hear a boombox of your color", true);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 100);
		AddRequirement(s.requirements, "no more", "boombox", "Boombox", 1);
	} */
	this.set_Vec2f("shop menu size", getShopMenuHeight(this, 7));
}

bool canPickup(CBlob@ blob)
{
	return (blob.hasTag("firearm") || blob.hasTag("ammo") || blob.hasTag("explosive"))&&!blob.hasTag("landmine");
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
	this.set_bool("shop available", this.isOverlapping(caller));
	
	this.set_Vec2f("shop offset", Vec2f(8, 0));
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