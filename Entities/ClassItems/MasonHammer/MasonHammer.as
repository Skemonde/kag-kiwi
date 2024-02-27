#include "BuilderCommon.as"
#include "MaterialCommon.as"
#include "CustomBlocks.as"
#include "Hitters"

void onInit(CBlob@ this)
{
	this.Tag("stone");
	this.Tag("no throw via action3");
	this.Tag("detach on seat in vehicle");
	
	this.set_u32("last_hit", 0);
	this.set_u32("hitting_interval", 10);
}

bool isTileBlockedBySolid(Vec2f start_pos, Vec2f end_pos)
{
	CMap@ map = getMap();
	Vec2f hit_pos;
	Vec2f aligned_end_pos = map.getAlignedWorldPos(end_pos);
	Vec2f aligned_hit_pos;
	if (map.rayCastSolid(start_pos, end_pos, hit_pos))
	{
		aligned_hit_pos = map.getAlignedWorldPos(hit_pos);
		if (aligned_hit_pos!=aligned_end_pos)
			return true;
	}
	return false;
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	
	const bool FLIP = blob.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1: 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	const u32 LAST_HIT = blob.get_u32("last_hit");
	const u32 HITTING_INTERVAL = blob.get_u32("hitting_interval");
	const u32 TIME_FROM_LAST_HIT = getGameTime()-LAST_HIT;
	
	const bool BEING_USED = TIME_FROM_LAST_HIT<=HITTING_INTERVAL;
	const f32 ROT_SPEED = 3;
	const f32 TILT_ANGLE = 30*FLIP_FACTOR/ROT_SPEED;
	this.ResetTransform();
	
	if (!BEING_USED) return;
	this.RotateBy(TILT_ANGLE/HITTING_INTERVAL*((HITTING_INTERVAL-TIME_FROM_LAST_HIT)*ROT_SPEED), Vec2f());
}

void onTick(CBlob@ this)
{
	const bool FLIP = this.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1: 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	if(point is null) return;
	CBlob@ holder = point.getOccupied();
	if (holder is null) return;
	CBlob@ blob_tile = getBuildingBlob(holder);
	
	Vec2f start_pos = this.getPosition();
	
	u32 last_hit = this.get_u32("last_hit");
	u32 hitting_interval = this.get_u32("hitting_interval");
	u32 time_from_last_hit = getGameTime()-last_hit;
	
	bool cooldown_expired = time_from_last_hit>hitting_interval;
	
	if (holder.isKeyPressed(key_action2)&&cooldown_expired) {
		this.set_u32("last_hit", getGameTime());
		CMap@ map = getMap();
		Vec2f hit_pos = map.getAlignedWorldPos(holder.getAimPos());
		//print("damaged "+hit_pos);
		
		f32 angle = this.getAngleDegrees()+ANGLE_FLIP_FACTOR;
		//angle = 180-(start_pos-hit_pos+Vec2f(1,1)*map.tilesize).AngleDegrees();
		
		HitInfo@[] hitInfos;
		
		if (map.getHitInfosFromRay(start_pos, angle, Maths::Min(32, (hit_pos-start_pos).Length()), this, @hitInfos)) {}
		
		bool hitting_exact_tile = false;
		Vec2f hit_info_pos;
		bool tile_on_da_way = false;
		bool hitting_blob = false;
		
		for (int counter = hitInfos.length-1; counter >= 0; --counter) {
			CBlob@ doomed = hitInfos[counter].blob;
			if (doomed !is null) {
				if (doomed is holder) continue;
				if (doomed.hasTag("invincible")) continue;
				if ((doomed.hasTag("player")||doomed.hasTag("vehicle"))&&doomed.getTeamNum()==holder.getTeamNum()) continue;
				this.server_Hit(doomed, hitInfos[counter].hitpos, Vec2f(), 1.0f, Hitters::builder, true);
				Material::fromBlob(this, doomed, 1.2, this);
				hitting_blob = true;
				return;
			};
			tile_on_da_way = true;
			hit_info_pos = map.getAlignedWorldPos(hitInfos[counter].hitpos);
			//print("new damaged "+hit_info_pos);
			
			if (hit_info_pos==hit_pos) {
				hitting_exact_tile = true; break;
			}
			//hit_pos = hitInfos[counter].hitpos;
		}
		if (!hitting_blob)
		{
			if (!hitting_exact_tile&&map.isTileSolid(hit_pos)||tile_on_da_way) {
				hit_pos = hit_info_pos;
			}
			
			Tile tile = map.getTile(hit_pos);
			TileType type = tile.type;
			//if (isTileSteel(type, true)||map.isTileGroundStuff(type)) return;
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