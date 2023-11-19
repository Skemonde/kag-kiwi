#include "BuilderCommon.as"
#include "MaterialCommon.as"
#include "CustomBlocks.as"

void onInit(CBlob@ this)
{
	this.Tag("stone");
	this.Tag("no throw via action3");
	this.Tag("detach on seat in vehicle");
}

bool isTargetPosBlocked(Vec2f start_pos, Vec2f end_pos)
{
	if (getMap().rayCastSolid(start_pos, end_pos))
	{
		return true;
	}
	return false;
}

void onTick(CBlob@ this)
{
	const bool FLIP = this.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1: 1;
	
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	if(point is null) return;
	CBlob@ holder = point.getOccupied();
	if (holder is null) return;
	CBlob@ blob_tile = getBuildingBlob(holder);
	
	Vec2f start_pos = this.getPosition();
	
	if (holder.isKeyPressed(key_action2)) {
		CMap@ map = getMap();
		Vec2f hit_pos = map.getAlignedWorldPos(holder.getAimPos());
		
		f32 angle = -(hit_pos-start_pos).Angle();
		
		HitInfo@[] hitInfos;
		
		if (!map.getHitInfosFromRay(start_pos, angle, 32, this, @hitInfos)) return;
		
		for (int counter = 0; counter < hitInfos.length; ++counter) {
			CBlob@ doomed = hitInfos[counter].blob;
			if (doomed !is null) continue;
			
			hit_pos = hitInfos[counter].hitpos;
			Tile tile = map.getTile(hit_pos);
			TileType type = tile.type;
			if (isTileSteel(type, true)||map.isTileGroundStuff(type)) return;
			map.server_DestroyTile(hit_pos, 1.0f);
			Material::fromTile(holder, type, 1.0f);
		}
	}
	
	TileType buildtile = holder.get_TileType("buildtile");
	CBlob@ carried = holder.getCarriedBlob();
	if (carried.getName()=="masonhammer" && (blob_tile !is null || carried !is null && buildtile > 0)) {
		point.SetKeysToTake(key_pickup);
	} else {
		point.SetKeysToTake(0);
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @ap)
{
	this.setAngleDegrees(0);
	this.getSprite().ResetTransform();
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return !(blob.hasTag("player") || blob.hasTag("vehicle"));
}