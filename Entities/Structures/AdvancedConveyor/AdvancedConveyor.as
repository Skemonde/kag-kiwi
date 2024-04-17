// TrapBlock.as

#include "Hitters.as";
#include "MapFlags.as";

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(10);
	//this.getSprite().SetOffset(Vec2f(-4,0));
	//this.getShape().SetOffset(Vec2f(4,0));
	this.getShape().SetRotationsAllowed(false);
	this.getSprite().getConsts().accurateLighting = false;

	this.Tag("place norotate");
	this.Tag("non_pierceable");
	this.Tag("blocks sword");
	this.Tag("blocks water");
	this.Tag("door");

	this.getCurrentScript().runFlags |= Script::tick_not_attached;

	this.Tag("builder always hit");
	
	this.set_Vec2f("snap offset", Vec2f(0, 0));
	
	// set up tracks (positions are relative to this blob's sprite texture)
	Vec2f[] tracks_points = {
		Vec2f(-11.5,  3.5),
		Vec2f(  0.0,  4.8),
		Vec2f( 11.5,  3.5),
		Vec2f( 11.5, -3.5),
		Vec2f(  0.0, -4.8),
		Vec2f(-11.5, -3.5)
	};
	this.set("tracks_points", tracks_points);
	this.set_f32("tracks_distanced", 6.0f);
	this.set_f32("tracks_const_speed", 0.1f);
	this.set_Vec2f("tracks_rotation_center", Vec2f(0, 0)+this.getSprite().getOffset());
	this.set_Vec2f("tracks_rotation_offset", Vec2f(0, 0));
	this.set_string("tracks_texture", "tank_track.png");
}

void onInit(CSprite@ this)
{
	//this.SetEmitSound("assembler_loop.ogg");
	this.SetEmitSoundVolume(0.3f);
	this.SetEmitSoundSpeed(0.9f);
	this.SetEmitSoundPaused(false);
	
	if (this.getBlob().hasTag("filter")) {
		CSpriteLayer@ funnel = this.addSpriteLayer("funnel", "FilteredConveyor.png" , 40, 24, this.getBlob().getTeamNum(), 0);
		{
			//funnel.SetOffset(Vec2f(0.5,3));
			funnel.SetRelativeZ(1);
			funnel.SetVisible(false);
			//funnel.SetFrameIndex(2);
		}
	}
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;
	sprite.SetZ(1);

	//sprite.getConsts().accurateLighting = true;

	if (!isStatic) return;
	for (int counter = 0; counter<3; ++counter) {
		Vec2f target_pos = this.getPosition()+Vec2f(-1+counter,0)*getMap().tilesize;
		if (!getMap().isTileSolid(target_pos))
			getMap().server_SetTile(target_pos, CMap::tile_castle_back);
		//print("tile dirt id "+(getMap().getTileDirt(getMap().getTileOffset(target_pos))));
	}
	this.getSprite().PlaySound("/build_door.ogg");
	if (this.hasTag("filter")) {
		this.getSprite().getSpriteLayer("funnel").SetVisible(true);
		this.getSprite().getSpriteLayer("funnel").SetRelativeZ(501);	
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return true;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null || blob.hasTag("player")) return;
	if (blob.getPosition().y > this.getPosition().y) return;
	if (blob.getShape().isStatic() || blob.hasTag("building"))return;
	if (blob.isAttached() || blob.isInWater())return;
	
	if(/* server_isItemAccepted(this, blob.getName())&&this.hasTag("filter") */false){
		blob.setVelocity(Vec2f(0.0f, 0.0f));
		blob.setPosition(this.getPosition()+Vec2f(0,4));
		this.getSprite().PlaySound("bridge_open.ogg");
	} else {
		if (Maths::Abs(blob.getVelocity().y) < 2.0f){
			blob.setVelocity(Vec2f(this.isFacingLeft() ? -0.6f : 0.6f, -1.0f));
		}
	}	
	
	//f32 speed = 1.5f;
	//if (Maths::Abs(blob.getVelocity().y) < 2.0f) blob.setVelocity(Vec2f((this.isFacingLeft() ? -1 : 1)*speed, -1.0f));
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::builder)
		damage == this.getInitialHealth();
	return damage;
}