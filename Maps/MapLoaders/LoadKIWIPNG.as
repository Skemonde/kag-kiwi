// киви

#include "BasePNGLoader"
#include "MinimapHook"
//#include "addCharacterToBlob"
//#include "Edward"
#include "Tunes"
#include "RulesCore"
#include "KIWI_RespawnSystem"

namespace KIWI_colors
{
	enum color
	{
		armory = 0xff4c565d,
		zombie_portal = 0xffb575f9,
		camp = 0xff5b6bf6,
		edward = 0xffc02020,
		campfire = 0xffdf7126,
		mercury_lamp = 0xffe0e050,
		cave_door = 0xff4d1f11,
		boombox = 0xff877b5c,
		boombox_tape = 0xffa69871,
		sandbag = 0xffffccaa,
		heavy_mg = 0xff4d443c,
		m_tank = 0xff504010,
		apc = 0xff42630e,
		drill = 0xffd27801,
		crusher = 0xff33660d,
		commtower = 0xff2b9b66,
		flagbase = 0xffd77bba,
		conveyor = 0xffd95763,
		conveyor_m = 0xffd977a3,
		stone_forge = 0xffc28469,
		mining_rig = 0xff622216,
		field_stall = 0xffffccf2,
		ruhm = 0xff64180c,
		assembly = 0xff913620,
		steel_door = 0xff342a97,
		crate = 0xff66161c,
		workbench = 0xff8688aa,
		deposit = 0xff291e0e,
		pointflag = 0xff58c894,
		
		nothing = 0xffffffff
	};
}

class KIWIPNGLoader : PNGLoader
{
	KIWIPNGLoader()
	{
		super();
	}
	
	void handlePixel(const SColor &in pixel, int offset) override
	{
		RulesCore@ core;
		getRules().get("core", @core);
		
		PNGLoader::handlePixel(pixel, offset);
		int map_center_x = map.tilemapwidth/2,
			struct_pos_x = map.getTileWorldPosition(offset).x/map.tilesize,
			blue = core !is null ? core.teams[0].index : 6,
			red = core !is null ? core.teams[1].index : 1,
			//first half of map with this color will be blue and the left one will colored red
			team_colored = struct_pos_x < map_center_x-8 ? blue : (struct_pos_x > map_center_x+8 ? red : 7),
			elven = 2,
			undead = 3,
			neutral = -1;
			
		bool facing_center = team_colored==1?true:false;
			
		CBlob@ blob_to_spawn = null;
		Vec2f spawn_offset = Vec2f();
		bool mirrored = false;
		u8 song_id = 5;
		//autotile(offset);
			
		switch (pixel.color)
		{
			case KIWI_colors::armory:
				spawnBlob(map, "armory", offset, team_colored, true, Vec2f(0, 0));
				autotile(offset); break;
				
			case KIWI_colors::stone_forge:
				spawnBlob(map, "stoneforge", offset, team_colored, true, Vec2f(0, 0));
				autotile(offset); break;
				
			case KIWI_colors::mining_rig:
				@blob_to_spawn = spawnBlob(map, "miningrig", offset, team_colored, true, Vec2f(0, -20));
				if (blob_to_spawn is null) break;
				
				blob_to_spawn.Tag("invincible");
				blob_to_spawn.SetFacingLeft(team_colored==1?(mirrored?false:true):(mirrored?true:false));
				autotile(offset); break;
				
			//case KIWI_colors::drill:
			//	spawnBlob(map, "drill", offset, team_colored, false, Vec2f(0, 0));
			//	autotile(offset); break;
				
			case KIWI_colors::crate:
				spawnBlob(map, "crate", offset, team_colored, false, Vec2f(0, 0));
				autotile(offset); break;
				
			case KIWI_colors::steel_door:
				spawnBlob(map, "steeldoor", offset, team_colored, true, Vec2f(0, -4));
				autotile(offset); break;
			
			case KIWI_colors::zombie_portal:
				spawnBlob(map, "zombieportal", offset, undead, true, Vec2f(-4, -4));
				autotile(offset); break;
				
			case KIWI_colors::deposit:
				if (mapHasNeighbourPixel(offset)) break;
				spawnBlob(map, "deposit", offset, team_colored, true, mapHasNeighbourPixel(offset, false)?Vec2f(4, 0):Vec2f(0, 0));
				autotile(offset); break;
				
			case KIWI_colors::workbench:
				if (mapHasNeighbourPixel(offset)) break;
				@blob_to_spawn = spawnBlob(map, "craftingtable", offset, team_colored, true, mapHasNeighbourPixel(offset, false)?Vec2f(4, -8):Vec2f(0, -8));
				if (blob_to_spawn is null) break;
				
				blob_to_spawn.SetFacingLeft(team_colored==1?true:false);
				autotile(offset); break;
				
			case KIWI_colors::pointflag:
				spawnBlob(map, "pointflag", offset, neutral, true, Vec2f(0, -60));
				autotile(offset); break;
				
			case 0xffd369ff:
				spawn_offset -= Vec2f(0, 15);
			case KIWI_colors::crusher:
				if (mapHasNeighbourPixel(offset)) break;
				@blob_to_spawn = spawnBlob(map, "crusher", offset, neutral, true, mapHasNeighbourPixel(offset, false)?Vec2f(4, 0):spawn_offset);
				if (blob_to_spawn is null) break;
				
				blob_to_spawn.SetFacingLeft(team_colored==1?true:false);
				autotile(offset); break;
				
			case KIWI_colors::commtower:
				if (mapHasNeighbourPixel(offset)) break;
				@blob_to_spawn = spawnBlob(map, "commtower", offset, team_colored, true, mapHasNeighbourPixel(offset, false)?Vec2f(4, 0):Vec2f(0, -24));
				if (blob_to_spawn is null) break;
				
				blob_to_spawn.SetFacingLeft(team_colored==1?true:false);
				autotile(offset); break;
				
			case KIWI_colors::conveyor_m:
				mirrored = true;
			case KIWI_colors::conveyor:
				@blob_to_spawn = spawnBlob(map, "advancedconveyor", offset, team_colored, true, Vec2f_zero);
				if (blob_to_spawn is null) break;
				
				blob_to_spawn.SetFacingLeft(team_colored==1?(mirrored?false:true):(mirrored?true:false));
				autotile(offset); break;
				
			case KIWI_colors::sandbag:
				if (mapHasNeighbourPixel(offset)) break;
				spawnBlob(map, "sandbag", offset, team_colored, false, mapHasNeighbourPixel(offset, false)?Vec2f(4, 0):Vec2f_zero);
				//getMap().SetTile(offset, getMap().getTile(offset-1).type);
				autotile(offset); break;
				
			case map_colors::blue_main_spawn:
			case map_colors::red_main_spawn:
				spawn_offset += Vec2f(0, -8);
			case 0xffd3beff:
			case KIWI_colors::camp:
				if (mapHasNeighbourPixel(offset)) break;
				spawnBlob(map, "camp", offset, team_colored, true, spawn_offset+(mapHasNeighbourPixel(offset, false)?Vec2f(4, 4):Vec2f(-4, 4)));
				autotile(offset); break;
				
			case KIWI_colors::assembly:
				@blob_to_spawn = spawnBlob(map, "assline", offset, team_colored, true, Vec2f());
				if (blob_to_spawn !is null) {
					CBitStream pack;
					pack.write_u8(17);
					//blob_to_spawn.SendCommand(blob_to_spawn.getCommandID("set"), pack);
				}
				autotile(offset); break;
				
			case KIWI_colors::field_stall:
				if (mapHasNeighbourPixel(offset)) break;
				spawnBlob(map, "constructionyard", offset, team_colored, true, (mapHasNeighbourPixel(offset, false)?Vec2f(4, 4):Vec2f(-4, 4)));
				autotile(offset); break;
				
			case KIWI_colors::flagbase:
				if (mapHasNeighbourPixel(offset)) break;
				spawnBlob(map, "flag_base", offset, team_colored, true, mapHasNeighbourPixel(offset, false)?Vec2f(4, 4):Vec2f(0, 4));
				autotile(offset); break;
				
			case KIWI_colors::edward:
				spawnBlob(map, "ed", offset, elven, false, Vec2f(-4, -4));
				autotile(offset); break;
				
			case KIWI_colors::campfire:
				spawnBlob(map, "campfire", offset, neutral, true, Vec2f(-4, 0));
				autotile(offset); break;
				
			case KIWI_colors::mercury_lamp:
				spawnBlob(map, "mercurylamp", offset, neutral, true, Vec2f(0, 0));
				autotile(offset); break;
				
			case KIWI_colors::ruhm:
				spawnBlob(map, "ruhm", offset, neutral, true, Vec2f(0, 0));
				autotile(offset); break;
				
			case KIWI_colors::m_tank:
				@blob_to_spawn = spawnBlob(map, "firsttank", offset, team_colored, false, Vec2f(0, 0));
				if (blob_to_spawn is null) break;
				
				blob_to_spawn.SetFacingLeft(team_colored==1?true:false);
				
				autotile(offset); break;
				
			case KIWI_colors::apc:
				@blob_to_spawn = spawnBlob(map, "brsn", offset, team_colored, false, Vec2f(0, 0));
				if (blob_to_spawn is null) break;
				
				//blob_to_spawn.SetFacingLeft(team_colored==1?true:false);
				
				autotile(offset); break;
				
			case KIWI_colors::heavy_mg:
				@blob_to_spawn = spawnBlob(map, "tripod", offset, team_colored, false, Vec2f(-2*(team_colored==1?-1:1), -4));
				if (blob_to_spawn is null) break;
				
				blob_to_spawn.SetFacingLeft(team_colored==1?true:false);
				
				autotile(offset); break;
				
			case KIWI_colors::boombox:
				@blob_to_spawn = spawnBlob(map, "boombox", offset, neutral, false, Vec2f(0, 0));
				if (blob_to_spawn is null) break;
				
				blob_to_spawn.set_u32("tune", song_id);
				blob_to_spawn.getSprite().SetEmitSound(tunes[song_id]);
				
				autotile(offset); break;
				
			case KIWI_colors::boombox_tape:
				@blob_to_spawn = spawnBlob(map, "tape", offset, neutral, false, Vec2f(0, 0));
				if (blob_to_spawn is null) break;
				blob_to_spawn.set_u32("customData", 1);
				
				autotile(offset); break;
				
			case KIWI_colors::cave_door:
				spawnBlob(map, "cavedoor", offset, elven, true, Vec2f(-4, -4));
				autotile(offset); break;
		};
	}
};

bool mapHasNeighbourPixel(int offset, bool left_neighbour = true)
{
	CMap@ map = getMap();
	
	CFileImage map_image(map.getMapName());
	if (!map_image.canRead()) return false;
	//print("map name "+map.getMapName());
	
	map_image.setPixelPosition(map.getTileSpacePosition(offset));
	SColor initial_color = map_image.readPixel();
	map_image.setPixelPosition(map.getTileSpacePosition(offset+(left_neighbour?-1:1)));
	SColor neighbour_color = map_image.readPixel();
	//print("init color ("+initial_color.getRed()+", "+initial_color.getGreen()+", "+initial_color.getBlue()+")");
	//print("neighbour color ("+neighbour_color.getRed()+", "+neighbour_color.getGreen()+", "+neighbour_color.getBlue()+")");
	return neighbour_color == initial_color;
}

bool LoadMap(CMap@ map, const string& in fileName)
{
	KIWIPNGLoader loader();

	MiniMap::Initialise();

	return loader.loadMap(map, fileName);
}
