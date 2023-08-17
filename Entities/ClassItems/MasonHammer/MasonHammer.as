#include "BuilderCommon.as"
#include "MaterialCommon.as"
#include "CustomBlocks.as"

void onInit(CBlob@ this)
{
	this.Tag("stone");
	this.Tag("no throw via action3");
	this.Tag("detach on seat in vehicle");
}

void onTick(CBlob@ this)
{
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	if(point is null) return;
	CBlob@ holder = point.getOccupied();
	if (holder is null) return;
	CBlob@ blob_tile = getBuildingBlob(holder);
	
	if (holder.isKeyJustPressed(key_action2)) {
		CMap@ map = getMap();
		Vec2f hit_pos = holder.getAimPos();
		TileType type = map.getTile(hit_pos).type;
		
		if (isTileSteel(type, true)||map.isTileGroundStuff(type)) return;
		
		map.server_DestroyTile(hit_pos, 1.0f);
		Material::fromTile(holder, type, 1.0f);
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