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
	
	ShopMadeItem@ onMadeItem = @onShopMadeItem;
	this.set("onShopMadeItem handle", @onMadeItem);

	InitWorkshop(this);
}

void InitWorkshop(CBlob@ this)
{
	//InitCosts(); //read from cfg

	this.set_Vec2f("shop offset", Vec2f_zero);
	int teamnum = Maths::Min(this.getTeamNum(), 7);
	
	{
		ShopItem@ s = addShopItem(this, "Bucket", "$bucket$", "bucket", Descriptions::bucket, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Crate", "$crate_icon"+teamnum+"$", "crate", Descriptions::crate, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 150);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::name_knight_shield, "$knightshield_icon"+teamnum+"$", "knightshield", Descriptions::knight_shield, true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 150);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::name_combat_helmet, "$helm$", "helm", Descriptions::combat_helmet, true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 5);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::frag_grenade, "$froggy$", "froggy", Descriptions::frag_grenade, true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 3);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::land_mine, "$landmine_icon"+teamnum+"$", "landmine", Descriptions::land_mine, true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 12);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}/* 
	{
		ShopItem@ s = addShopItem(this, "Walkie Talkie", "$radio_icon"+teamnum+"$", "wt", "You can chat in a bit different way than you do usually! Hold the WT in hands when chatting", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 3);
	} */
	{
		ShopItem@ s = addShopItem(this, Names::name_riot_shield, "$riotshield$", "riotshield", Descriptions::riot_shield, true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 10);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}/* 
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
	} */
	{
		ShopItem@ s = addShopItem(this, Names::name_binoculars, "$bino$", "bino", Descriptions::binoculars, true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 5);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::name_bayonet, "$bayonet$", "bayonet", Descriptions::bayonet, true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 6);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::name_laser_pointer, "$pointer$", "pointer", Descriptions::laser_pointer, true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 3);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::name_underbarrel_nader, "$underbarrelnader$", "underbarrelnader", Descriptions::underbarrel_nader, true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 30);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::lowcal, "$lowcal$", "lowcal", Descriptions::lowcal, true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 2);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::draground, "$draground$", "draground", Descriptions::draground, true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 4);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::tank_shell, "$tankshells$", "tankshells", Descriptions::tank_shell, true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 30);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Lantern", "$lantern$", "lantern", Descriptions::lantern, false);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 1);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::highpow, "$highpow$", "highpow", Descriptions::highpow, true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 5);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::shotgunshells, "$shells$", "shells", Descriptions::shotgunshells, true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 8);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
		//AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
	}/* 
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
		ShopItem@ s = addShopItem(this, Names::name_wrench, "$wrench_icon"+teamnum+"$", "wrench", Descriptions::wrench, true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 5);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::name_mason_hammer, "$masonhammer$", "masonhammer", Descriptions::mason_hammer, true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 2);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::name_steel_crate, "$steelcrate_icon"+teamnum+"$", "steelcrate", Descriptions::steel_crate, false);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 10);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::tank_mine, "$tankmine_icon"+teamnum+"$", "tankmine", Descriptions::tank_mine, true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 20);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
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
		ShopItem@ s = addShopItem(this, Names::name_medic_helmet, "$medhelm_icon"+teamnum+"$", "medhelm", Descriptions::medic_helmet, true);
		AddRequirement(s.requirements, "blob", "helm", "Combat Helmet", 1);
		AddRequirement(s.requirements, "blob", "heart", "Heart", 1);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::name_bandage, "$bandage$", "bandage", Descriptions::bandage, true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 40);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::name_shovel, "$shovel$", "shovel", Descriptions::shovel, true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 8);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	}
	
	this.set_Vec2f("shop menu size", getShopMenuHeight(this, 4));
}

bool isInventoryAccessible( CBlob@ this, CBlob@ forBlob )
{
	return false;
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
	
	CBlob@ callerBlob = getBlobByNetworkID(caller_id);
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
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool isServer = getNet().isServer();

	if (cmd == this.getCommandID("shop made item client") && isClient())
	{
		this.getSprite().PlaySound("/ConstructShort.ogg");
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
