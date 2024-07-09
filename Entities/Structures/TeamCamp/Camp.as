#include "KIWI_Locales"
#include "StandardControlsCommon"

void onInit(CBlob@ this)
{
	//this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.setInventoryName("Delver's Camp");
	this.Tag("spawn");
	
	this.Tag("storingButton");
	this.Tag("takingItemButton");
	this.Tag("replenishButton");
	this.Tag("teamlocked tunnel");
	
	this.getCurrentScript().tickFrequency = 60;
	this.set_bool("pickup", true);
	
	this.set_Vec2f("travel button pos", Vec2f(-this.getWidth()/2, this.getHeight()/2)/4);
}

void onChangeTeam( CBlob@ this, const int oldTeam )
{
	Capture(this, this.getTeamNum());
	CheckIfAllCapsAreCaptured(this);
}

void CheckIfAllCapsAreCaptured(CBlob@ this)
{
	CBlob@[] camp_blobs;
	if (!getBlobsByName("camp", camp_blobs)) return;
	
	u16[] team_nums;
	u16[] team_camps;
	
	for (int idx = 0; idx < camp_blobs.size(); ++idx)
	{
		CBlob@ c_camp = camp_blobs[idx];
		if (c_camp is null) continue;
		
		//adding team to the list of teams
		u8 camp_team = c_camp.getTeamNum();
		
		if (team_nums.find(camp_team)<0) {
			team_nums.push_back(camp_team);
			team_camps.push_back(0);
		}
		
		//summing to the amount of camp for the team
		team_camps[team_nums.find(camp_team)] += 1;
	}
	
	if (team_nums.size()<2) {
		getRules().SetTeamWon(team_nums[0]);
		getRules().SetCurrentState(GAME_OVER);
	}
}

void Capture(CBlob@ this, const int attackerTeam)
{
	if (getNet().isServer())
	{
		// convert all buildings and doors

		CBlob@[] blobsInRadius;
		if (this.getMap().getBlobsInRadius(this.getPosition(), this.getRadius() / 0.5f, @blobsInRadius))
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob @b = blobsInRadius[i];
				if (b.getTeamNum() != attackerTeam && (b.hasTag("door") ||
				                                       b.hasTag("building") ||
				                                       b.getName() == "workbench" ||
				                                       b.hasTag("migrant") ||
				                                       b.getName() == "spikes" ||
				                                       b.getName() == "trap_block" ||
													   b.getName() == "bridge"))
				{
					b.server_setTeamNum(attackerTeam);
				}
			}
		}
	}

	this.server_setTeamNum(attackerTeam);
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