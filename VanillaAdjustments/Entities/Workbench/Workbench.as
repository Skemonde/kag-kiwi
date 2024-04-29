// Workbench

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"
#include "getShopMenuHeight.as"
#include "KIWI_Locales.as";
#include "Tunes.as";
#include "EquipmentCommon"

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("can settle"); //for DieOnCollapse to prevent 2 second life :)

	InitWorkshop(this);
}


void InitWorkshop(CBlob@ this)
{
	InitCosts(); //read from cfg

	this.set_Vec2f("shop offset", Vec2f_zero);
	int teamnum = Maths::Min(this.getTeamNum(), 7);
	
	{
		ShopItem@ s = addShopItem(this, "Bucket", "$bucket$", "bucket", Descriptions::bucket, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Crate", "$crate_icon"+teamnum+"$", "crate", Descriptions::crate, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 150);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Knight Shield", "$knightshield_icon"+teamnum+"$", "knightshield", "Saves from any damage\n\nPress S to increase your shielding zone\n\n - Has better bash dash\n - Not very durable", true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 150);
	}
	{
		ShopItem@ s = addShopItem(this, "Helmet", "$helm$", "helm", "Military Helmet\n\n - Head hits don't deal crit damage\n - 5 less gunfire damage", false);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 5);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, Names::froggy, "$froggy$", "froggy", Descriptions::froggy, true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 3);
	}
	{
		ShopItem@ s = addShopItem(this, Names::empty, "$landmine_icon"+teamnum+"$", "landmine", "Отрывает ноги только так :3", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 12);
	}/* 
	{
		ShopItem@ s = addShopItem(this, "Walkie Talkie", "$radio_icon"+teamnum+"$", "wt", "You can chat in a bit different way than you do usually! Hold the WT in hands when chatting", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 3);
	} */
	{
		ShopItem@ s = addShopItem(this, "Riot Shield", "$riotshield$", "riotshield", "Saves from any damage\n\nPress S to increase your shielding zone\n\n - Bash deals damage\n - Medium Weight", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 10);
	}
	{
		ShopItem@ s = addShopItem(this, "Underbarrel Grenader", "$naderitem$", "naderitem", "You can attach it to a gun\n\nSingle-use item\n\nDrop a gun onto ground then press E while holding this item\n\nTO BE CHANGED, I HATE E BUTTONS", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 6);
	}
	{
		ShopItem@ s = addShopItem(this, "Combat Knife", "$combatknife$", "combatknife", "You can attach it to a gun\n\nSingle-use item\n\nDrop a gun onto ground then press E while holding this item\n\nTO BE CHANGED, I HATE E BUTTONS", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 2);
	}
	{
		ShopItem@ s = addShopItem(this, "Laser Pointer", "$pointer$", "pointer", "Laser Pointer\n\n - Increases bullet lifetime\n - Allows you to zoom out and aim ANY gun", false);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 10);
	}
	{
		ShopItem@ s = addShopItem(this, Names::empty, "$bino$", "bino", "Press S to see further or use a mouse scroll to get a better view", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 5);
	}
	{
		ShopItem@ s = addShopItem(this, "Lantern", "$lantern$", "lantern", Descriptions::lantern, false);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 1);
	}
	{
		ShopItem@ s = addShopItem(this, Names::lowcal, "$lowcal$", "lowcal", Descriptions::lowcal, true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 2);
	}
	{
		ShopItem@ s = addShopItem(this, Names::shotgunshells, "$shells$", "shells", Descriptions::shotgunshells, true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 8);
		//AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
	}
	{
		ShopItem@ s = addShopItem(this, Names::highpow, "$highpow$", "highpow", Descriptions::highpow, true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 5);
	}/* 
	{
		ShopItem@ s = addShopItem(this, "BURGIR", "$burgir_icon$", "food_5", Descriptions::burger, true);
		AddRequirement(s.requirements, "blob", "heart", "Small Medkit", 1);
		s.spawnNothing = true;
	} *//* 
	{
		ShopItem@ s = addShopItem(this, "Drill", "$drill$", "drill", "a Drill huh?", false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 4);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	} *//* 
	{
		ShopItem@ s = addShopItem(this, "Brick Hammer", "$masonhammer$", "masonhammer", "You can build with it!", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 8);
	} */
	{
		ShopItem@ s = addShopItem(this, "Steel Wrench", "$wrench_icon"+teamnum+"$", "wrench", "You can repair structures and vehicles with this one! Requires one steel bar for one use", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 5);
	}
	{
		ShopItem@ s = addShopItem(this, "Steel Crate", "$steelcrate_icon"+teamnum+"$", "steelcrate", "Very heavy steel crate. This one is much much more durable than the wooden one\n\nEnemies can not access its storage", false);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 10);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Anti-Tank Mine", "$tankmine_icon"+teamnum+"$", "tankmine", "Doesn't give a damn about filthy infantry", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 20);
	}/* 
	{
		ShopItem@ s = addShopItem(this, "Car", "$car_icon"+teamnum+"$", "kiy", "GO FAST!!", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 30);
		AddRequirement(s.requirements, "no more", "kiy", "Car", 1);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Tank", "$tank_icon"+teamnum+"$", "tankhull", "GO STRONG!!", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 75);
		AddRequirement(s.requirements, "no more", "tankhull", "Tank", 2);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	} *//* 
	{
		ShopItem@ s = addShopItem(this, "Pill of Undying", "$drug$", "drug", "Saves you from a knockout after your health reaches 0. Gives you 4 seconds of invincibility and 1 health point", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 6969);
	} */
	{
		ShopItem@ s = addShopItem(this, "Bandage", "$bandage$", "bandage", "Throw a bandage on a friend when they're down! It will makes them feel better", true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 80);
	}/* 
	{
		ShopItem@ s = addShopItem(this, "Heavy Helmet", "$hehelm$", "hehelm", "Heavy Helmet\n\n - Head hits don't deal crit damage\n - 40 less gunfire damage but not less than 10", false);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 6969);
	} */
	{
		ShopItem@ s = addShopItem(this, "Medic Helmet", "$medhelm_icon"+teamnum+"$", "medhelm", "Equip it to become a real medic!", true);
		AddRequirement(s.requirements, "blob", "helm", "Combat Helmet", 1);
		AddRequirement(s.requirements, "blob", "heart", "Heart", 1);
	}
	{
		ShopItem@ s = addShopItem(this, "Dragunov Round", "$draground$", "draground", "Big ammo for a big gun", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 4);
	}
	
	this.set_Vec2f("shop menu size", getShopMenuHeight(this, 4));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool isServer = getNet().isServer();

	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ConstructShort.ogg");
		u16 caller, item;
		if (!params.saferead_netid(caller) || !params.saferead_netid(item))
		{
			return;
		}
		string name = params.read_string();
		{
			CBlob@ callerBlob = getBlobByNetworkID(caller);
			if (callerBlob is null) return;
			CBlob@ carried = callerBlob.getCarriedBlob();
			
			string[]@ tokens = (name).split("_");
			if (tokens.size()>0 && !tokens[0].empty())
			{
				if (tokens[0] == "tape") {
					CBlob@ tape = server_CreateBlob("tape");
					if (tape !is null) {
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
						if (carried!is null) {
							callerBlob.server_PutInInventory(carried);
						}
						callerBlob.server_Pickup(food_item);
						food_item.set_u32("customData", parseInt(tokens[1]));
					}
				}
				else if (tokens[0] == "helm") {
					CBlob@ helm = server_CreateBlob("helm");
					if (helm !is null) {
						helm.setPosition(callerBlob.getPosition());
						if (!callerBlob.server_PutInInventory(helm))
							if (carried is null) callerBlob.server_Pickup(helm);
						PutHatOn(helm, callerBlob);
					}
				}
			}
		}
	}
}

//sprite - planks layer

void onInit(CSprite@ this)
{
	this.SetZ(50); //foreground

	CBlob@ blob = this.getBlob();
	CSpriteLayer@ planks = this.addSpriteLayer("planks", this.getFilename() , 16, 16, blob.getTeamNum(), blob.getSkinNum());

	if (planks !is null)
	{
		Animation@ anim = planks.addAnimation("default", 0, false);
		anim.AddFrame(6);
		planks.SetOffset(Vec2f(3.0f, -7.0f)+this.getOffset());
		planks.SetRelativeZ(-100);
	}
}
