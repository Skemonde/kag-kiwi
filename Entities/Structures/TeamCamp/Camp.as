#include "KIWI_Locales"
#include "ClassSelectMenu"
#include "RespawnCommandCommon"
#include "StandardRespawnCommand"
#include "StandardControlsCommon"
#include "GenericButtonCommon"

void onInit(CBlob@ this)
{
	//this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.setInventoryName("Delver's Camp");
	this.Tag("spawn");
	this.Tag("teamlocked tunnel");
	
	this.Tag("storingButton");
	this.Tag("takingItemButton");
	this.Tag("replenishButton");
	//this.Tag("remote_storage");
	
	this.getCurrentScript().tickFrequency = 60;
	this.set_bool("pickup", true);
	
	this.set_Vec2f("travel button pos", Vec2f(-this.getWidth()/2, this.getHeight()/2)/4);
	int teamnum = Maths::Min(this.getTeamNum(), 7);
	addTokens(this);
	
	//classes
	addPlayerClass(this, "Engineer", "$engi_class_icon"+teamnum+"$", "engi", "eh?");
	addPlayerClass(this, "Soldier", "$soldat_class_icon"+teamnum+"$", "soldat", "eeehhhh???");
	this.addCommandID("class menu");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("class menu"))
	{
		u16 callerID = params.read_u16();
		CBlob@ caller = getBlobByNetworkID(callerID);

		if (caller !is null && caller.isMyPlayer())
		{
			BuildRespawnMenuFor(this, caller);
		}
	}
	else
	{
		onRespawnCommand(this, cmd, params);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CPlayer@ player = caller.getPlayer();
	if (!canSeeButtons(this, caller)||(caller.getName()=="knight")) return;

	if (canChangeClass(this, caller) && this.getTeamNum()==caller.getTeamNum() && false)
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		caller.CreateGenericButton("$change_class$", Vec2f(8, 5), this, this.getCommandID("class menu"), getTranslatedString("Change class"), params);
	}

	// warning: if we don't have this button just spawn menu here we run into that infinite menus game freeze bug
}

bool isInRadius(CBlob@ this, CBlob @caller)
{
	return (this.getPosition() - caller.getPosition()).Length() < this.getRadius();
}

bool canPickup(CBlob@ blob)
{
	return blob.hasTag("firearm") || blob.hasTag("material");
}

void onTick(CBlob@ this)
{
	this.SetMinimapRenderAlways(false);
	this.SetMinimapVars("kiwi_minimap_icons.png", 6, Vec2f(1, 0.5f)*16);
	this.SetMinimapOutsideBehaviour(CBlob::minimap_arrow);
	
	PickupOverlap(this);
}

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	blob.getSprite().PlaySound("/PutInInventory.ogg");
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return this.getTeamNum()==forBlob.getTeamNum();
}

void PickupOverlap(CBlob@ this)
{
	if (getNet().isServer() && this.get_bool("pickup"))
	{
		if (this.getInventory().isFull()) return;
		Vec2f tl, br;
		this.getShape().getBoundingRect(tl, br);
		CBlob@[] blobs;
		this.getMap().getBlobsInBox(tl, br, @blobs);
		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ blob = blobs[i];
			if (!blob.isAttached() && blob.isOnGround() && canPickup(blob))
			{
				this.server_PutInInventory(blob);
			}
		}
	}
}

void addTokens(CBlob@ this)
{
	int teamnum = Maths::Min(this.getTeamNum(), 7);
	for (int team = 0; team <= 7; ++team) {
		AddIconToken("$engi_class_icon"+teamnum+"$", 		"EngiIcon.png", 			Vec2f(24, 24), 0, teamnum);
		AddIconToken("$soldat_class_icon"+teamnum+"$", 		"SoldatIcon.png", 			Vec2f(24, 24), 0, teamnum);
	}
}