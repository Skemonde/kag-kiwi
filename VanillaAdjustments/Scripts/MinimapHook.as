#include "Skemlib"
#include "CustomBlocks"

///Minimap Code
SColor color_sky = SColor(0xffA5BDC8);
SColor color_dirt = SColor(0xff844715);
SColor color_dirt_backwall = SColor(0xff3B1406);
SColor color_stone = SColor(0xff8B6849);
SColor color_thickstone = SColor(0xff42484B);
SColor color_gold = SColor(0xffFEA53D);
SColor color_bedrock = SColor(0xff2D342D);
SColor color_wood = SColor(0xffC48715);
SColor color_wood_backwall = SColor(0xff552A11);
SColor color_castle = SColor(0xff637160);
SColor color_castle_backwall = SColor(0xff313412);
SColor color_water = SColor(0xff2cafde);
SColor color_fire = SColor(0xffd5543f);

const SColor c_white = SColor(255, 255, 255, 255);
const SColor c_black = SColor(255, 0, 0, 0);
const SColor c_dark_blue = SColor(0xff25245f);
const SColor c_missing = SColor(255, 255, 0, 255);

const SColor c_sky = SColor(255, 237, 204, 166);

const SColor c_sky_top = SColor(0xff7fcffa);
const SColor c_sky_bottom = SColor(0xffaaaacc);

const SColor c_dirt = SColor(255, 191, 145, 87);
const SColor c_dirt_bg = SColor(255, 150, 115, 69);
const SColor c_stone = SColor(255, 130, 106, 76);
const SColor c_thickStone = SColor(255, 102, 88, 70);
const SColor c_bedrock = SColor(255, 71, 71, 61);
const SColor c_gold = SColor(255, 237, 190, 47);

const SColor c_castle = SColor(0xff656e70);
const SColor c_castle_moss = SColor(0xff292a2b);
const SColor c_wood = SColor(0xff845235);
const SColor c_grass = SColor(0xff8bd21a);

void CalculateMinimapColour(CMap@ this, u32 offset, TileType type, SColor &out col)
{
	const int w = this.tilemapwidth;
	const int h = this.tilemapheight;

	const int x = offset % w;
	const int y = offset / w;
	const Vec2f pos = Vec2f(x * 8, y * 8);

	const f32 heightGradient = y / f32(h);

	const Tile tile = this.getTile(offset);

	bool air = type == CMap::tile_empty;

	const u8 flags = tile.flags;
	bool bg = flags & Tile::BACKGROUND != 0;
	bool solid = flags & Tile::SOLID != 0;

	// if (this.isTileGround(tile) || this.isTileStone(tile) || this.isTileBedrock(tile) || this.isTileGold(tile) || this.isTileThickStone(tile) || this.isTileCastle(tile) || this.isTileWood(tile))

	if (!air)
	{
		TileType l = this.getTile(offset - 1).type;
		TileType r = this.getTile(offset + 1).type;
		TileType u = this.getTile(offset - w).type;
		TileType d = this.getTile(offset + w).type;
		
		Vec2f pos_l = this.getTileWorldPosition(offset - 1);
		Vec2f pos_r = this.getTileWorldPosition(offset + 1);
		Vec2f pos_u = this.getTileWorldPosition(offset - w);
		Vec2f pos_d = this.getTileWorldPosition(offset + w);
		
		Vec2f pos_ul = this.getTileWorldPosition(offset - 1 - w);
		Vec2f pos_ur = this.getTileWorldPosition(offset + 1 - w);
		Vec2f pos_dl = this.getTileWorldPosition(offset - 1 + w);
		Vec2f pos_dr = this.getTileWorldPosition(offset + 1 + w);
		
		bool should_have_outline = false;

		// TODO: Shove damage frame numbers into an enum
		switch(type)
		{
			// DIRT
			case CMap::tile_ground:
			case CMap::tile_ground_d1:
			case 30:
			case CMap::tile_ground_d0:
			//
			case CMap::tile_ground_back:
			//
			case CMap::tile_bedrock:
				col = c_dirt;
				col = col.getInterpolated(c_black, 0.90f);
				if (this.isTileGrass(u))
				{
					col = c_grass;
					col = col.getInterpolated(c_black, 0.70f);
					//col = col.getInterpolated(c_grass, 0.20f);
				}
				should_have_outline = true;
			break;
			/* 
			// DIRT BACKGROUND
			case CMap::tile_ground_back:
				col = c_dirt_bg;
				col = col.getInterpolated(c_black, 0.80);
			break;
			 */
			// THICKSTONE
			case CMap::tile_thickstone:
			case CMap::tile_thickstone_d1:
			case 215:
			case 216: // OTHER DAMAGE FRAMES
			case 217:
			case CMap::tile_thickstone_d0:
				col = c_thickStone;
				col = c_dirt;
				col = col.getInterpolated(c_black, 0.90f);
				//should_have_outline = true;
			break;

			// STONE
			case CMap::tile_stone:
			case CMap::tile_stone_d1:
			case 101:
			case 102:
			case 103:
			case CMap::tile_stone_d0:
				col = c_stone;
				col = c_dirt;
				col = col.getInterpolated(c_black, 0.90f);
				//should_have_outline = true;
			break;
			
			// BEDROCK
			//case CMap::tile_bedrock:
				//col = SColor(0xff8b6f39);
				//col = c_bedrock;
				//should_have_outline = true;
			//break;
			
			// GOLD
			case CMap::tile_gold:
			case 90:
			case 91:
			case 92:
			case 93:
			case 94:
				col = c_gold;
				col = col.getInterpolated(c_dirt, 0.50f);
				should_have_outline = true;
			break;

			// MOSS
			case CMap::tile_castle_moss:
			case 225:
			case 226:
			case 227:
			case 228:
			case 229:
			case 230:
			case 231:
			case 232:
			case 233:
			case 234:
			case 235:
			case 236:
			case 237:
			case 238:
			case 239:
			case 340:
				col = c_castle;
			break;

			// CASTLE
			case CMap::tile_castle:
			case CMap::tile_castle_d1:
			case 59:
			case 60:
			case 61:
			case 62:
			case CMap::tile_castle_d0:
			case 64:
			case 65:
			case 66:
			case 67:
			case 68:
			case 69:
			case 70:
			case 71:
			case 72:
			case 73:
			case 74:
			case 75:
			case 76:
			case 77:
			case 78:
			case 79:
				col = c_castle;
			break;

			// WOOD
			case CMap::tile_wood:
			case 199:
			case CMap::tile_wood_d1:
			case 201:
			case 202:
			case CMap::tile_wood_d0:
			case CMap::tile_wood_back:
			case 206:
			case 207:
				col = c_wood;
			break;

			// GRASS
			case CMap::tile_grass:
			case 26:
			case 27:
			case 28:
				col = c_grass;
				col = col.getInterpolated(SColor(0xffffffff), (x % 2) * 1.00f);
				should_have_outline = true;
			break;
			
			// KIWI
			
			// STEEL
			case CMap::tile_bgsteelbeam:
				col = c_castle_moss;
				//col = col.getInterpolated(c_white, 0.90f);
			break;
			
			default:
				col = c_missing;
			break;
		}
		
		// KIWI
		
		// STEEL
		if (isTileSteel(type, true))
		{
			col = c_white;
			col = col.getInterpolated(c_dark_blue, 0.90f);
			//should_have_outline = true;
		}
		// WINDOW
		if (isTileWindow(type))
		{
			col = c_white;
			col = col.getInterpolated(SColor(0x00ffffff), 0.05f);
			//should_have_outline = true;
		}

		if (!solid)
		{
			col = col.getInterpolated(c_black, 0.70f);
			bool near_tile_empty = isTileAir(l) || isTileAir(r) || isTileAir(u) || isTileAir(d);
			bool should_be_thin = isTileAir(l) && isTileAir(r) || isTileAir(u) && isTileAir(d);
			bool near_tile_backwall = !this.isTileSolid(pos_l) || !this.isTileSolid(pos_r) || !this.isTileSolid(pos_u) || !this.isTileSolid(pos_d);
			bool near_tile_solid = this.isTileSolid(pos_l) || this.isTileSolid(pos_r) || this.isTileSolid(pos_u) || this.isTileSolid(pos_d) || this.isTileSolid(pos_ul) || this.isTileSolid(pos_ur) || this.isTileSolid(pos_dl) || this.isTileSolid(pos_dr);
			u8 solid_count = 0;
			if (this.isTileSolid(pos_l))
				solid_count += 1;
			if (this.isTileSolid(pos_r))
				solid_count += 1;
			if (this.isTileSolid(pos_u))
				solid_count += 1;
			if (this.isTileSolid(pos_d))
				solid_count += 1;
			
			if (true)
			{
				if (this.isTileSolid(pos_ul))
					solid_count += 1;
				if (this.isTileSolid(pos_ur))
					solid_count += 1;
				if (this.isTileSolid(pos_dl))
					solid_count += 1;
				if (this.isTileSolid(pos_dr))
					solid_count += 1;
			}
			
			if (near_tile_solid)
			{
				if (!near_tile_empty)
				{
					col = col.getInterpolated(c_black, 0.90f-0.075f*solid_count);
					//col = col.getInterpolated(c_white, 1.00f - ((heightGradient) * 0.05f));
				}
			}
			else if (should_be_thin)
				col = col.getInterpolated(c_white, 0.60f);
		}
		else 
		{
			bool near_tile_empty = isTileAir(l) || isTileAir(r) || isTileAir(u) || isTileAir(d);
			bool near_tile_backwall = !this.isTileSolid(pos_l) || !this.isTileSolid(pos_r) || !this.isTileSolid(pos_u) || !this.isTileSolid(pos_d);
			if (false && should_have_outline && near_tile_backwall)
			{
				col = col.getInterpolated(c_black, near_tile_empty?0.80f:0.50f);
			}
		}

		col = col.getInterpolated(c_white, 1.00f - ((1.00f - heightGradient) * 0.25f));
	}
	else
	{
		// col = c_sky;
		col = c_sky_bottom;
		col = col.getInterpolated(c_sky_top, heightGradient);
		col = col.getInterpolated(c_sky, 0.75f);
	}

	if (this.isInWater(pos)) col = col.getInterpolated(SColor(0xff2cafde), 0.5f);
	// if (this.isTileInFire(x, y)) col = col.getInterpolated(fire_colors[XORRandom(fire_colors.length)], 0.5f);
}

bool isTileAir(u16 tile_type)
{
	return tile_type == CMap::tile_empty ||
			getMap().isTileGrass(tile_type);
}

/*
void CalculateMinimapColour( CMap@ map, u32 offset, TileType tile, SColor &out col)
{
	int X = offset % map.tilemapwidth;
	int Y = offset / map.tilemapwidth;

	Vec2f pos = Vec2f(X, Y);

	float ts = map.tilesize;
	Tile ctile = map.getTile(pos * ts);

	bool show_gold = getRules().get_bool("show_gold");

	///Colours
	const SColor color_minimap_open         (color_sky);
	const SColor color_minimap_ground       (color_dirt);
	const SColor color_minimap_back         (color_dirt_backwall);
	const SColor color_minimap_stone        (color_stone);
	const SColor color_minimap_thickstone   (color_thickstone);
	const SColor color_minimap_gold         (color_gold);
	const SColor color_minimap_bedrock      (color_bedrock);
	const SColor color_minimap_wood         (color_wood);
	const SColor color_minimap_castle       (color_castle);

	const SColor color_minimap_castle_back  (color_castle_backwall);
	const SColor color_minimap_wood_back    (color_wood_backwall);

	const SColor color_minimap_water        (color_water);
	const SColor color_minimap_fire         (color_fire);
	
	if (map.isTileGold(tile))  
	{ 
		col = show_gold ? color_minimap_gold : color_minimap_ground;
	} 
	else if (map.isTileGround(tile))
	{
		col = color_minimap_ground;
	}
	else if (map.isTileThickStone(tile))
	{
		col = color_minimap_thickstone;
	}
	else if (map.isTileStone(tile))
	{
		col = color_minimap_stone;
	}
	else if (map.isTileBedrock(tile))
	{
		col = color_minimap_bedrock;
	}
	else if (isTileSteel(tile, true))
	{
		col = SColor(0xff7685ac);
	}
	else if (isTileBGSteelBeam(tile))
	{
		col = SColor(0xff1b2632);
	}
	else if (map.isTileWood(tile)) 
	{ 
		col = color_minimap_wood;
	} 
	else if (map.isTileCastle(tile))      
	{ 
		col = color_minimap_castle;
	} 
	else if (map.isTileBackgroundNonEmpty(ctile) && !map.isTileGrass(tile)) {
		
		// TODO(hobey): maybe check if there's a door/platform on this backwall and make a custom color for them?
		if (tile == CMap::tile_castle_back) 
		{ 
			col = color_minimap_castle_back;
		} 
		else if (tile == CMap::tile_wood_back)   
		{ 
			col = color_minimap_wood_back;
		} 
		else                                     
		{ 
			col = color_minimap_back;
		}
		
	} 
	else 
	{
		col = color_minimap_open;
	}
	
	///Tint the map based on Fire/Water State
	if (map.isInWater( pos * ts ))
	{
		col = col.getInterpolated(color_minimap_water,0.5f);
	}
	else if (map.isInFire( pos * ts ))
	{
		//col = col.getInterpolated(color_minimap_fire,0.5f);
	}
	return;
	f32 x1 = getRules().get_f32("barrier_x1");
	f32 x2 = getRules().get_f32("barrier_x2");

	f32 distance = x2 - x1;

	f32 step = distance / 5;
	SColor blue_team_col = GetColorFromTeam(0);
	SColor red_team_col = GetColorFromTeam(1);
	SColor neutral_team_col = GetColorFromTeam();
	
	if (true)
	for (int i=0; i<5; ++i)
	{
		u8 zone_team = Maths::Min(getRules().get_u16("towzone" + i + "team"), 7);
		if (pos.x*ts >= x1+step*i && pos.x*ts < x1+step*(i+1))
			col = col.getInterpolated((getRules().isMatchRunning() ? GetColorFromTeam(zone_team) : neutral_team_col), (zone_team == 1 ? 0.8f : 0.7f));
	}
	if (!map.isTileBedrock(tile)) {
		if (pos.x*ts >= x2)
			col = col.getInterpolated(red_team_col, 0.8f);
		if (pos.x*ts < x1)
			col = col.getInterpolated(blue_team_col, 0.7f);
	}
}
*/

//(avoid conflict with any other functions)
namespace MiniMap
{
	Vec2f clampInsideMap(Vec2f pos, CMap@ map)
	{
		return Vec2f(
			Maths::Clamp(pos.x, 0, (map.tilemapwidth - 0.1f) * map.tilesize),
			Maths::Clamp(pos.y, 0, (map.tilemapheight - 0.1f) * map.tilesize)
		);
	}

	bool isForegroundOutlineTile(Tile tile, CMap@ map)
	{
		return !map.isTileSolid(tile);
	}

	bool isOpenAirTile(Tile tile, CMap@ map)
	{
		return tile.type == CMap::tile_empty ||
			map.isTileGrass(tile.type);
	}

	bool isBackgroundOutlineTile(Tile tile, CMap@ map)
	{
		return isOpenAirTile(tile, map);
	}

	bool isGoldOutlineTile(Tile tile, CMap@ map, bool is_gold)
	{
		return is_gold ?
			!map.isTileSolid(tile.type) :
			map.isTileGold(tile.type);
	}

	//setup the minimap as required on server or client
	void Initialise()
	{
		CRules@ rules = getRules();
		CMap@ map = getMap();

		//add sync script
		//done here to avoid needing to modify gamemode.cfg
		if (!rules.hasScript("MinimapSync.as"))
		{
			rules.AddScript("MinimapSync.as");
		}

		//init appropriately
		if (isServer())
		{
			//load values from cfg
			ConfigFile cfg();
			cfg.loadFile("Base/Rules/MinimapSettings.cfg");

			map.legacyTileMinimap = cfg.read_bool("legacy_minimap", false);
			bool show_gold = cfg.read_bool("show_gold", true);
			bool custom_colors = cfg.read_bool("custom_colors", true);

			//write out values for serialisation
			rules.set_bool("legacy_minimap", map.legacyTileMinimap);
			rules.set_bool("show_gold", show_gold);
			rules.set_bool("custom_colors", custom_colors);
		}
		if (isClient())
		{
			// customizable colors for blocks
			ConfigFile cfg();
			if (cfg.loadFile("../Cache/MinimapColors.cfg"))
			{
				if (rules.get_bool("custom_colors") == true)
				{
					color_sky.set(parseInt(cfg.read_string("color_sky"), 16));
					color_sky.setAlpha(255);

					color_dirt.set(parseInt(cfg.read_string("color_dirt"), 16));
					color_dirt.setAlpha(255);

					color_dirt_backwall.set(parseInt(cfg.read_string("color_dirt_backwall"), 16));
					color_dirt_backwall.setAlpha(255);

					color_stone.set(parseInt(cfg.read_string("color_stone"), 16));
					color_stone.setAlpha(255);

					color_thickstone.set(parseInt(cfg.read_string("color_thickstone"), 16));
					color_thickstone.setAlpha(255);

					color_gold.set(parseInt(cfg.read_string("color_gold"), 16));
					color_gold.setAlpha(255);

					color_bedrock.set(parseInt(cfg.read_string("color_bedrock"), 16));
					color_bedrock.setAlpha(255);

					color_wood.set(parseInt(cfg.read_string("color_wood"), 16));
					color_wood.setAlpha(255);

					color_wood_backwall.set(parseInt(cfg.read_string("color_wood_backwall"), 16));
					color_wood_backwall.setAlpha(255);

					color_castle.set(parseInt(cfg.read_string("color_castle"), 16));
					color_castle.setAlpha(255);

					color_castle_backwall.set(parseInt(cfg.read_string("color_castle_backwall"), 16));
					color_castle_backwall.setAlpha(255);

					color_water.set(parseInt(cfg.read_string("color_water"), 16));
					color_water.setAlpha(255);

					color_fire.set(parseInt(cfg.read_string("color_fire"), 16));
					color_fire.setAlpha(255);
				}
			}
			else
			{
				// grab the one with defaults from base
				if (!cfg.loadFile("MinimapColors.cfg"))
				{
					warn("missing default map colors");
					cfg.add_string("color_sky", "A5BDC8");
					cfg.add_string("color_dirt", "844715");
					cfg.add_string("color_dirt_backwall", "3B1406");
					cfg.add_string("color_stone", "8B6849");
					cfg.add_string("color_thickstone", "42484B");
					cfg.add_string("color_gold", "FEA53D");
					cfg.add_string("color_bedrock", "D342D");
					cfg.add_string("color_wood", "C48715");
					cfg.add_string("color_wood_backwall", "552A11");
					cfg.add_string("color_castle", "637160");
					cfg.add_string("color_castle_backwall", "313412");
				 	cfg.add_string("color_water", "2cafde");
					cfg.add_string("color_fire", "d5543f");
					cfg.saveFile("MinimapColors.cfg");
				}

				cfg.saveFile("MinimapColors.cfg");
			}

			//write defaults for now
			map.legacyTileMinimap = false;
			rules.set_bool("show_gold", true);
		}
	}
}