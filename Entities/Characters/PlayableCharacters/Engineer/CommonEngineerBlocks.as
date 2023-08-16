// CommonBuilderBlocks.as

//////////////////////////////////////
// Builder menu documentation
//////////////////////////////////////

// To add a new page;

// 1) initialize a new BuildBlock array,
// example:
// BuildBlock[] my_page;
// blocks.push_back(my_page);

// 2)
// Add a new string to PAGE_NAME in
// BuilderInventory.as
// this will be what you see in the caption
// box below the menu

// 3)
// Extend BuilderPageIcons.png with your new
// page icon, do note, frame index is the same
// as array index

// To add new blocks to a page, push_back
// in the desired order to the desired page
// example:
// BuildBlock b(0, "name", "icon", "description");
// blocks[3].push_back(b);

#include "BuildBlock"
#include "CustomBlocks"
#include "Requirements"
#include "Costs"
#include "TeamIconToken"

const string blocks_property = "blocks";
const string inventory_offset = "inventory offset";

void addCommonBuilderBlocks(BuildBlock[][]@ blocks, int team_num = 7, const string&in gamemode_override = "")
{
	InitCosts();
	addTokens();
	CRules@ rules = getRules();

	string gamemode = rules.gamemode_name;
	if (gamemode_override != "")
	{
		gamemode = gamemode_override;

	}
	CBlob@ localblob = getLocalPlayerBlob();
	if (localblob !is null) {
		team_num = localblob.getTeamNum();
	}

	BuildBlock[] page_0;
	blocks.push_back(page_0);
	{
		BuildBlock b(CMap::tile_castle, "stone_block", "$stone_block$", "Stone Block\nBasic building block");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", BuilderCosts::stone_block);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_castle_back, "back_stone_block", "$back_stone_block$", "Back Stone Wall\nExtra support");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", BuilderCosts::back_stone_block);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "stone_door", getTeamIcon("stone_door", "1x1StoneDoor.png", team_num, Vec2f(16, 8)), "Stone Door\nPlace next to walls");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", BuilderCosts::stone_door);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "trap_block", getTeamIcon("trap_block", "TrapBlock.png", team_num), "Trap Block\nOnly enemies can pass");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", BuilderCosts::stone_door);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_wood, "wood_block", "$wood_block$", "Wood Block\nCheap block\nwatch out for fire!");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", BuilderCosts::wood_block);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_wood_back, "back_wood_block", "$back_wood_block$", "Back Wood Wall\nCheap extra support");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", BuilderCosts::back_wood_block);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "wooden_door", getTeamIcon("wooden_door", "1x1WoodDoor.png", team_num, Vec2f(16, 8)), "Wooden Door\nPlace next to walls");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", BuilderCosts::wooden_door);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "bridge", getTeamIcon("bridge", "Bridge.png", team_num), "Trap Bridge\nOnly your team can stand on it");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", BuilderCosts::wooden_door);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "spikes", "$spikes$", "Spikes\nPlace on Stone Block\nfor Retracting Trap");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", BuilderCosts::spikes);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_window, "", "$window_tile$", "Window tile gives sunlight even in deepest caves");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 20);
		AddRequirement(b.reqs, "blob", "mat_steel", "Steel", 1);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "ladder", "$ladder$", "Ladder\nAnyone can climb it");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", BuilderCosts::ladder);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "wooden_platform", "$wooden_platform$", "Wooden Platform\nOne way platform");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", BuilderCosts::wooden_platform);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_steel_1x1, "", "$steel_block$", "Steel block is super effective against gunfire");
		AddRequirement(b.reqs, "blob", "mat_steel", "Steel", 16);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_bgsteelbeam, "", "$steel_beam$", "Steel beam is super effective against explosions");
		AddRequirement(b.reqs, "blob", "mat_steel", "Steel", 4);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "steeldoor", "$steeldoor_icon"+team_num+"$", "cool door");
		AddRequirement(b.reqs, "blob", "mat_steel", "Steel Bar", 25);
		blocks[0].push_back(b);
	}/* 
	{
		BuildBlock b(0, "mercurylamp", "$mercurylamp$", "mercury lamp");
		AddRequirement(b.reqs, "blob", "mat_steel", "Steel", 8);
		//AddRequirement(b.reqs, "blob", "lantern", "Lantern", 1);
		blocks[0].push_back(b);
	} */
	BuildBlock[] page_1;
	blocks.push_back(page_1);
	{
		BuildBlock b(0, "armory", "$armory_icon"+team_num+"$", "armory");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 200);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "storage", "$storage$", "storage");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 100);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[1].push_back(b);
	}/* 
	{
		BuildBlock b(0, "camp", "$camp_icon"+team_num+"$", "camp");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 300);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 300);
		b.buildOnGround = true;
		b.size.Set(64, 40);
		blocks[1].push_back(b);
	} */
	{	
		BuildBlock b(0, "fireplace", "$fireplace$", "Campfire\nCan be used to COOK various foods.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 200);
		b.buildOnGround = true;
		b.size.Set(16, 16);
		blocks[1].push_back(b);
    }
	{	
		BuildBlock b(0, "quarters", "$quarters$", "quarters");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[1].push_back(b);
    }
	{	
		BuildBlock b(0, "workbench", "$workbench$", "Workbench\nCan be used to CRAFT various items.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		b.buildOnGround = true;
		b.size.Set(32, 16);
		blocks[1].push_back(b);
    }
	AddIconToken("$mgs_sentry_icon$", "MGS_Icon.png", Vec2f(24, 24), 0, team_num);
	{	
		BuildBlock b(0, "sentry", "$mgs_sentry_icon$", "Machine Gun Sentry\n - Aims for enemy\n - Requires Highpow ammo\n - Can be upgraded up to 2 times");
		AddRequirement(b.reqs, "blob", "mat_steel", "Steel", 8);
		b.buildOnGround = true;
		b.size.Set(16, 16);
		blocks[1].push_back(b);
    }
	{
		BuildBlock b(0, "sandbag", "$sandbag$", "sandbag");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
		b.buildOnGround = true;
		b.size.Set(16, 8);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "quarry", "$quarry_icon"+team_num+"$", "quarry");
		AddRequirement(b.reqs, "blob", "mat_steel", "Steel", 12);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "assline", "$assline_icon"+team_num+"$", "Makes ammo from steel");
		AddRequirement(b.reqs, "blob", "mat_steel", "Steel", 4);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		AddRequirement(b.reqs, "no more", "assline", "Assembly Line", 1);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "stoneforge", "$stoneforge$", "Smelt iron bars from stone");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 150);
		b.buildOnGround = true;
		b.size.Set(24, 24);
		blocks[1].push_back(b);
	}
	BuildBlock[] page_2;
	blocks.push_back(page_2);
	{
		BuildBlock b(0, "wire", "$wire$", "Wire");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "elbow", "$elbow$", "Elbow");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "tee", "$tee$", "Tee");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "junction", "$junction$", "Junction");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "diode", "$diode$", "Diode");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "resistor", "$resistor$", "Resistor");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "inverter", "$inverter$", "Inverter");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "oscillator", "$oscillator$", "Oscillator");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "transistor", "$transistor$", "Transistor");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "toggle", "$toggle$", "Toggle");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "randomizer", "$randomizer$", "Randomizer");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "lamp", "$lamp$", "Lamp");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "emitter", "$emitter$", "Emitter");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "receiver", "$receiver$", "Receiver");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "magazine", "$magazine$", "Magazine");
		AddRequirement(b.reqs, "blob", "mat_stone", "Wood", 20);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "bolter", "$bolter$", "Bolter");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "dispenser", "$dispenser$", "Dispenser");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "obstructor", "$obstructor$", "Obstructor");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "spiker", "$spiker$", "Spiker");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 40);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "lever", "$lever$", "Lever");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "push_button", "$pushbutton$", "Button");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 40);
		blocks[2].push_back(b);
	}
	AddIconToken("$coin_slot$", "CoinSlot.png", Vec2f(16, 16), 0);
	{
		BuildBlock b(0, "coin_slot", "$coin_slot$", "Coin Slot");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 40);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "pressure_plate", "$pressureplate$", "Pressure Plate");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "sensor", "$sensor$", "Motion Sensor");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 40);
		blocks[2].push_back(b);
	}
	
	BuildBlock[] page_3;
	blocks.push_back(page_3);
}

void addTokens()
{
	for (int team_num = 0; team_num <= 7; ++team_num) {
		AddIconToken("$quarry_icon"+team_num+"$", 		"Quarry.png", 				Vec2f(40, 24), 4, team_num);
		AddIconToken("$camp_icon"+team_num+"$", 		"Camp.png", 				Vec2f(60, 40), 0, team_num);
		AddIconToken("$armory_icon"+team_num+"$", 		"armory.png", 				Vec2f(40, 24), 0, team_num);
		AddIconToken("$assline_icon"+team_num+"$", 		"AssemblyLineIcon.png", 	Vec2f(40, 24), 0, team_num);
		AddIconToken("$steeldoor_icon"+team_num+"$", 	"SteelDoor.png", 			Vec2f(16, 16), 0, team_num);
	}
}

ConfigFile@ openBlockBindingsConfig()
{
	ConfigFile cfg = ConfigFile();
	if (!cfg.loadFile("../Cache/BlockBindings.cfg"))
	{
		// write EmoteBinding.cfg to Cache
		cfg.saveFile("BlockBindings.cfg");

	}

	return cfg;
}

u8 read_block(ConfigFile@ cfg, string name, u8 default_value)
{
	u8 read_val = cfg.read_u8(name, default_value);
	return read_val;
}
