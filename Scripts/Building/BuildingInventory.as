// Builder logic

#include "BuilderCommon.as";
#include "PlacementCommon.as";
#include "Help.as";
#include "CommonEngineerBlocks.as";
#include "KnockedCommon.as";
#include "ThrowCommon.as";
#include "isHoldingBrickHammer"

namespace Builder
{
	enum Cmd
	{
		nil = 0,
		TOOL_CLEAR = 31,
		PAGE_SELECT = 32,

		make_block = 64,
		make_reserved = 99
	};

	enum Page
	{
		PAGE_ZERO = 0,
		//PAGE_ONE,
		//PAGE_TWO,
		//PAGE_THREE,
		PAGE_COUNT
	};
}

const string[] PAGE_NAME =
{
	"Tiles",
	"Structures",
	"Components",
	"Device"
};

const u8 GRID_SIZE = 48;
const u8 GRID_PADDING = 12;

const Vec2f MENU_SIZE(4, 4);
const u32 SHOW_NO_BUILD_TIME = 90;

const bool QUICK_SWAP_ENABLED = false;

void onInit(CInventory@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;

	if (!blob.exists(blocks_property))
	{
		BuildBlock[][] blocks;
		addCommonBuilderBlocks(blocks, blob.getTeamNum());
		blob.set(blocks_property, blocks);
	}

	if (!blob.exists(inventory_offset))
	{
		blob.set_Vec2f(inventory_offset, Vec2f(0, 174));
	}

	AddIconToken("$BUILDER_CLEAR$", "BuilderIcons.png", Vec2f(32, 32), 2);

	for(u8 i = 0; i < Builder::PAGE_COUNT; i++)
	{
		AddIconToken("$"+PAGE_NAME[i]+"$", "BuilderPageIcons.png", Vec2f(48, 24), i);
	}

	blob.addCommandID("make block");
	blob.addCommandID("make block client");
	blob.addCommandID("tool clear");
	blob.addCommandID("tool clear client");
	blob.addCommandID("page select");
	blob.addCommandID("page select client");

	blob.set_Vec2f("backpack position", Vec2f_zero);

	blob.set_u8("build page", 0);

	blob.set_u8("buildblob", 255);
	blob.set_TileType("buildtile", 0);

	blob.set_u32("cant build time", 0);
	blob.set_u32("show build time", 0);

	this.getCurrentScript().removeIfTag = "dead";
}

void MakeBlocksMenu(CInventory@ this, const Vec2f &in INVENTORY_CE)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;

	BuildBlock[][]@ blocks;
	blob.get(blocks_property, @blocks);
	if (blocks is null) return;

	const u8 PAGE = blob.get_u8("build page");
	Vec2f menuSize = (PAGE==1||true?Vec2f(6, MENU_SIZE.y):MENU_SIZE);
	const Vec2f MENU_CE = Vec2f(0, menuSize.y * -GRID_SIZE) + INVENTORY_CE;

	CGridMenu@ menu = CreateGridMenu(MENU_CE, blob, menuSize, getTranslatedString("Build"));
	if (menu !is null)
	{
		menu.deleteAfterClick = false;

		const u8 PAGE = blob.get_u8("build page");

		for(u8 i = 0; i < blocks[PAGE].length; i++)
		{
			BuildBlock@ b = blocks[PAGE][i];
			if (b is null) continue;
			string block_desc = getTranslatedString(b.description);
			CBitStream params;
			params.write_u8(i);
			CGridButton@ button = menu.AddButton(b.icon, "\n" + block_desc, blob.getCommandID("make block"), params);
			if (button is null) continue;

			button.selectOneOnClick = true;

			CBitStream missing;
			if (hasRequirements(this, b.reqs, missing, not b.buildOnGround))
			{
				button.hoverText = block_desc + "\n" + getButtonRequirementsText(b.reqs, false);
			}
			else
			{
				button.hoverText = block_desc + "\n" + getButtonRequirementsText(missing, true);
				button.SetEnabled(false);
			}

			CBlob@ carryBlob = getBuildingBlob(blob);
			if (carryBlob !is null && carryBlob.getName() == b.name)
			{
				button.SetSelected(1);
			}
			else if (b.tile == blob.get_TileType("buildtile") && b.tile != 0)
			{
				button.SetSelected(1);
			}
		}

		const Vec2f TOOL_POS = menu.getUpperLeftPosition() - Vec2f(GRID_PADDING, 0) + Vec2f(-1, 1) * GRID_SIZE / 2;

		CGridMenu@ tool = CreateGridMenu(TOOL_POS, blob, Vec2f(1, 1), "");
		if (tool !is null)
		{
			tool.SetCaptionEnabled(false);

			CGridButton@ clear = tool.AddButton("$BUILDER_CLEAR$", "", blob.getCommandID("tool clear"), Vec2f(1, 1));
			if (clear !is null)
			{
				clear.SetHoverText(getTranslatedString("Stop building\n"));
			}
		}

		// index menu only available in sandbox
		
		if (Builder::PAGE_COUNT<2) return;

		const Vec2f INDEX_POS = Vec2f(menu.getLowerRightPosition().x + GRID_PADDING + GRID_SIZE, menu.getUpperLeftPosition().y + GRID_SIZE * Builder::PAGE_COUNT / 2);

		CGridMenu@ index = CreateGridMenu(INDEX_POS, blob, Vec2f(2, Builder::PAGE_COUNT), "Type");
		if (index !is null)
		{
			index.deleteAfterClick = false;


			for(u8 i = 0; i < Builder::PAGE_COUNT; i++)
			{
				CBitStream params;
				params.write_u8(i);
				CGridButton@ button = index.AddButton("$"+PAGE_NAME[i]+"$", PAGE_NAME[i], blob.getCommandID("page select"), Vec2f(2, 1), params);
				if (button is null) continue;

				button.selectOneOnClick = true;

				if (i == PAGE)
				{
					button.SetSelected(1);
				}
			}
		}
	}
}

void onCreateInventoryMenu(CInventory@ this, CBlob@ forBlob, CGridMenu@ menu)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	if (!isHoldingBrickHammer(blob)) return;

	const Vec2f INVENTORY_CE = (this.getInventorySlots()) * GRID_SIZE / 2 + menu.getUpperLeftPosition();
	blob.set_Vec2f("backpack position", INVENTORY_CE);

	//blob.ClearGridMenusExceptInventory();
	//blob.ClearGridMenus();
	//ClearCarriedBlock(forBlob);

	MakeBlocksMenu(this, INVENTORY_CE);
}

void onCommand(CInventory@ this, u8 cmd, CBitStream@ params)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;

	if (cmd == blob.getCommandID("make block") && isServer())
	{
		CPlayer@ callerp = getNet().getActiveCommandPlayer();
		if (callerp is null) return;

		CBlob@ callerb = callerp.getBlob();
		if (callerb is null) return;
		if (callerb !is blob) return;
		BuildBlock[][]@ blocks;
		if (!blob.get(blocks_property, @blocks)) return;

		u8 i;
		if (!params.saferead_u8(i)) return; 

		CBitStream sparams;
		sparams.write_u8(i);
		blob.SendCommand(blob.getCommandID("make block client"), sparams);

		const u8 PAGE = blob.get_u8("build page");
		if (blocks !is null && i >= 0 && i < blocks[PAGE].length)
		{
			BuildBlock@ block = @blocks[PAGE][i];
			bool canBuildBlock = canBuild(blob, @blocks[PAGE], i) && !isKnocked(blob);
			if (!canBuildBlock)
			{
				return;
			}

			CBlob@ carryBlob = getBuildingBlob(blob);
			if (carryBlob !is null)
			{
				// check if this isn't what we wanted to create
				if (carryBlob.getName() == block.name)
				{
					return;
				}

				if (carryBlob.hasTag("temp blob"))
				{
					carryBlob.Untag("temp blob");
					carryBlob.server_Die();
				}
				else
				{
					// try put into inventory whatever was in hands
					// creates infinite mats duplicating if used on build block, not great :/
					if (!block.buildOnGround && !blob.server_PutInInventory(carryBlob))
					{
						carryBlob.server_DetachFromAll();
					}
				}
			}

			if (block.tile == 0)
			{
				server_BuildBlob(blob, @blocks[PAGE], i);
			}
			else
			{
				blob.set_TileType("buildtile", block.tile);
			}
		}
	}
	else if (cmd == blob.getCommandID("make block client") && isClient())
	{
		BuildBlock[][]@ blocks;
		if (!blob.get(blocks_property, @blocks)) return;

		u8 i;
		if (!params.saferead_u8(i)) return; 

		const u8 PAGE = blob.get_u8("build page");
		if (blocks !is null && i >= 0 && i < blocks[PAGE].length)
		{
			BuildBlock@ block = @blocks[PAGE][i];
			bool canBuildBlock = canBuild(blob, @blocks[PAGE], i) && !isKnocked(blob);
			if (!canBuildBlock)
			{
				if (blob.isMyPlayer())
				{
					blob.getSprite().PlaySound("/NoAmmo", 0.5);
				}
				return;
			}

			if (block.tile == 0)
			{
				server_BuildBlob(blob, @blocks[PAGE], i);
			}
			else
			{
				blob.set_TileType("buildtile", block.tile);
			}

			if (blob.isMyPlayer())
			{
				SetHelp(blob, "help self action", "builder", getTranslatedString("$Build$Build/Place  $LMB$"), "", 3);
			}
		}
	}
	else if (cmd == blob.getCommandID("tool clear") && isServer())
	{
		CPlayer@ callerp = getNet().getActiveCommandPlayer();
		if (callerp is null) return;

		CBlob@ callerb = callerp.getBlob();
		if (callerb is null) return;
		if (callerb !is blob) return;

		ClearCarriedBlock(blob);

		blob.server_SendCommandToPlayer(blob.getCommandID("tool clear client"), callerp);
	}
	else if (cmd == blob.getCommandID("tool clear client") && isClient())
	{
		blob.ClearGridMenus();

		ClearCarriedBlock(blob);
	}
	else if (cmd == blob.getCommandID("page select") && isServer())
	{
		CPlayer@ callerp = getNet().getActiveCommandPlayer();
		if (callerp is null) return;

		CBlob@ callerb = callerp.getBlob();
		if (callerb is null) return;
		if (callerb !is blob) return;

		u8 page;
		if (!params.saferead_u8(page)) return;

		blob.set_u8("build page", page);

		ClearCarriedBlock(blob);

		CBitStream sparams;
		sparams.write_u8(page);
		blob.server_SendCommandToPlayer(blob.getCommandID("page select client"), sparams, callerp);
	}
	else if (cmd == blob.getCommandID("page select client") && isClient())
	{
		u8 page;
		if (!params.saferead_u8(page)) return;

		blob.ClearGridMenus();
		blob.set_u8("build page", page);

		ClearCarriedBlock(blob);

		if (blob is getLocalPlayerBlob())
		{
			blob.CreateInventoryMenu(blob.get_Vec2f("backpack position"));
		}
	}
}

u8[] blockBinds = {
	0, 1, 2, 3, 4, 5, 6, 7, 8
};

void onInit(CBlob@ this)
{
	this.set_Vec2f("inventory offset", Vec2f(0.0f, 160.0f));
	
	ConfigFile@ cfg = openBlockBindingsConfig();
	
	AddCursor(this);

	for (uint i = 0; i < 9; i++)
	{
		blockBinds[i] = read_block(cfg, "block_" + (i + 1), blockBinds[i]);
	}

}

void onTick(CBlob@ this)
{
	if (this !is getLocalPlayerBlob())
	{
		return;
	}

	if (this.hasTag("reload blocks"))
	{
		this.Untag("reload blocks");
		onInit(this);
	}
	
	if (this.isKeyPressed(key_pickup)) {
		ClearCarriedBlock(this);
	}

	CControls@ controls = getControls();
	if (controls.ActionKeyPressed(AK_BUILD_MODIFIER))
	{
		for (uint i = 0; i < 9; i++)
		{
			if (controls.isKeyJustPressed(KEY_KEY_1 + i))
			{
				this.SendCommand(Builder::make_block + blockBinds[i]);
			}
		}

	}
}

void onRender(CSprite@ this)
{
	CMap@ map = getMap();

	CBlob@ blob = this.getBlob();
	CBlob@ localBlob = getLocalPlayerBlob();
	if (localBlob is blob)
	{
		// no build zone show
		const bool onground = blob.isOnGround();
		const u32 time = blob.get_u32( "cant build time" );
		if (time + SHOW_NO_BUILD_TIME > getGameTime())
		{
			Vec2f space = blob.get_Vec2f( "building space" );
			Vec2f offsetPos = getBuildingOffsetPos(blob.getPosition(), map, space);

			const f32 scalex = getDriver().getResolutionScaleFactor();
			const f32 zoom = getCamera().targetDistance * scalex;
			Vec2f aligned = getDriver().getScreenPosFromWorldPos( offsetPos );

			for (f32 step_x = 0.0f; step_x < space.x ; ++step_x)
			{
				for (f32 step_y = 0.0f; step_y < space.y ; ++step_y)
				{
					Vec2f temp = ( Vec2f( step_x + 0.5, step_y + 0.5 ) * map.tilesize );
					Vec2f v = offsetPos + temp;
					Vec2f pos = aligned + (temp - Vec2f(0.5f,0.5f)* map.tilesize) * 2 * zoom;
					if (!onground || map.getSectorAtPosition(v , "no build") !is null || map.isTileSolid(v) || blobBlockingBuilding(map, v))
					{
						// draw red
						GUI::DrawIcon( "CrateSlots.png", 5, Vec2f(8,8), pos, zoom );
					}
					else
					{
						// draw white
						GUI::DrawIcon( "CrateSlots.png", 9, Vec2f(8,8), pos, zoom );
					}
					//break;
				}
				//break;
			}
		}

		// show cant build
		if (blob.isKeyPressed(key_action1) || blob.get_u32("show build time") + 15 > getGameTime())
		{
			if (blob.isKeyPressed(key_action1))
			{
				blob.set_u32( "show build time", getGameTime());
			}

			Vec2f cam_offset = getCamera().getInterpolationOffset();

			BlockCursor @bc;
			blob.get("blockCursor", @bc);
			if (bc !is null)
			{
				if (bc.blockActive || bc.blobActive)
				{
					Vec2f pos = blob.getPosition();
					Vec2f myPos =  blob.getInterpolatedScreenPos() + Vec2f(0.0f,(pos.y > blob.getAimPos().y) ? -blob.getRadius() : blob.getRadius());
					Vec2f aimPos2D = getDriver().getScreenPosFromWorldPos( blob.getAimPos() + cam_offset );

					if (!bc.hasReqs)
					{
						const string missingText = getButtonRequirementsText( bc.missing, true );
						Vec2f boxpos( myPos.x, myPos.y - 120.0f );
						GUI::DrawText( getTranslatedString("Requires\n") + missingText, Vec2f(boxpos.x - 50, boxpos.y - 15.0f), Vec2f(boxpos.x + 50, boxpos.y + 15.0f), color_black, false, false, true );
					}
					else if (bc.cursorClose)
					{
						if (bc.rayBlocked)
						{
							Vec2f blockedPos2D = getDriver().getScreenPosFromWorldPos(bc.rayBlockedPos + cam_offset);
							GUI::DrawArrow2D( aimPos2D, blockedPos2D, SColor(0xffdd2212) );
						}

						if (!bc.buildableAtPos && !bc.sameTileOnBack) //no build indicator drawing
						{
							CMap@ map = getMap();
							Vec2f middle = blob.getAimPos() + Vec2f(map.tilesize*0.5f, map.tilesize*0.5f);
							CMap::Sector@ sector = map.getSectorAtPosition( middle, "no build");
							if (sector !is null)
							{
								GUI::DrawRectangle( getDriver().getScreenPosFromWorldPos(sector.upperleft), getDriver().getScreenPosFromWorldPos(sector.lowerright), SColor(0x65ed1202) );
							}
							else
							{
								CBlob@[] blobsInRadius;
								if (map.getBlobsInRadius( middle, map.tilesize, @blobsInRadius ))
								{
									for (uint i = 0; i < blobsInRadius.length; i++)
									{
										CBlob @b = blobsInRadius[i];
										if (!b.isAttached())
										{
											Vec2f bpos = b.getInterpolatedPosition();
											float w = b.getWidth();
											float h = b.getHeight();

											if (b.getAngleDegrees() % 180 != 0) //swap dimentions
											{
												float t = w;
												w = h;
												h = t;
											}

											GUI::DrawRectangle( getDriver().getScreenPosFromWorldPos(bpos + Vec2f(w/-2.0f, h/-2.0f)),
																getDriver().getScreenPosFromWorldPos(bpos + Vec2f(w/2.0f, h/2.0f)),
																SColor(0x65ed1202) );
										}
									}
								}
							}
						}
					}
					else if (getBuildingBlob(blob) is null || getBuildingBlob(blob).hasTag("temp blob")) // only display the red arrow while we are building
					{
						const f32 maxDist = getMaxBuildDistance(blob) + 8.0f;
						Vec2f norm = aimPos2D - myPos;
						const f32 dist = norm.Normalize();
						norm *= (maxDist - dist);
						GUI::DrawArrow2D( aimPos2D, aimPos2D + norm, SColor(0xffdd2212) );
					}
				}
			}
		}
	}
}

bool blobBlockingBuilding(CMap@ map, Vec2f v)
{
	CBlob@[] overlapping;
	map.getBlobsAtPosition(v, @overlapping);
	for(uint i = 0; i < overlapping.length; i++)
	{
		CBlob@ o_blob = overlapping[i];
		CShape@ o_shape = o_blob.getShape();
		if (o_blob !is null &&
			o_shape !is null &&
			!o_blob.isAttached() &&
			o_shape.isStatic() &&
			!o_shape.getVars().isladder)
		{
			return true;
		}
	}
	return false;
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	if (attachedPoint.name=="PICKUP") {
		ClearCarriedBlock(this);
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	if (detached.getName()=="masonhammer"&&!detached.hasTag("quick_detach")) {
		ClearCarriedBlock(this);
	}
	// ignore collision for built blob
	BuildBlock[][]@ blocks;
	if (!this.get("blocks", @blocks))
	{
		return;
	}

	const u8 PAGE = this.get_u8("build page");
	for (u8 i = 0; i < blocks[PAGE].length; i++)
	{
		BuildBlock@ block = blocks[PAGE][i];
		if (block !is null && block.name == detached.getName())
		{
			this.IgnoreCollisionWhileOverlapped(null);
			detached.IgnoreCollisionWhileOverlapped(null);
		}
	}

	// BUILD BLOB
	// take requirements from blob that is built and play sound
	// put out another one of the same
	if (detached.hasTag("temp blob"))
	{
		detached.Untag("temp blob");
		
		if (!detached.hasTag("temp blob placed"))
		{
			detached.server_Die();
			return;
		}

		uint i = this.get_u8("buildblob");
		if (i >= 0 && i < blocks[PAGE].length)
		{
			BuildBlock@ b = blocks[PAGE][i];
			if (b.name == detached.getName())
			{
				this.set_u8("buildblob", 255);
				this.set_TileType("buildtile", 0);

				CInventory@ inv = this.getInventory();

				CBitStream missing;
				if (hasRequirements(inv, b.reqs, missing, not b.buildOnGround))
				{
					server_TakeRequirements(inv, b.reqs);
				}
				// take out another one if in inventory
				server_BuildBlob(this, blocks[PAGE], i);
			}
		}
	}
	else if (detached.getName() == "seed")
	{
		if (not detached.hasTag('temp blob placed')) return;

		CBlob@ anotherBlob = this.getInventory().getItem(detached.getName());
		if (anotherBlob !is null)
		{
			this.server_Pickup(anotherBlob);
		}
	}
}

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	//return;
	// destroy built blob if somehow they got into inventory
	if (blob.hasTag("temp blob"))
	{
		blob.server_Die();
		blob.Untag("temp blob");
	}

	if (this.isMyPlayer() && blob.hasTag("material"))
	{
		SetHelp(this, "help inventory", "builder", "$Help_Block1$$Swap$$Help_Block2$           $KEY_HOLD$$KEY_F$", "", 3);
	}
}
