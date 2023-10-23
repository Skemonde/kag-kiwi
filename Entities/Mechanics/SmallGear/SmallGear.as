void onInit(CSprite@ this)
{
	this.addSpriteLayer("gear", "small_gear.png", 16, 16);
	CSpriteLayer@ gear = this.getSpriteLayer("gear");
	if (gear !is null) {
		//gear.SetOffset(Vec2f(-4,8));
		gear.SetRelativeZ(170);
	}
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	if (!blob.getShape().isStatic()) return;
	
	const bool FLIP = blob.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	CSpriteLayer@ gear = this.getSpriteLayer("gear");
	if (gear is null) return;
	
	f32 speed_mod = 7;
	gear.ResetTransform();
	gear.RotateBy((getGameTime()%(360/speed_mod))*FLIP_FACTOR*speed_mod+(FLIP?45:0), Vec2f_zero);
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return false;
}

void onSetStatic( CBlob@ this, const bool isStatic )
{
	if (!isStatic) return;
	const bool FLIP = this.isFacingLeft();
	
	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;
	
	CSpriteLayer@ gear = sprite.getSpriteLayer("gear");
	if (gear is null) return;
	
	Vec2f tile_pos = getMap().getTileSpacePosition(this.getPosition());
	
	//this one is cool
	this.SetFacingLeft(tile_pos.x%2==tile_pos.y%2);
	
	CBlob@[] blobs;
	getMap().getBlobsInRadius(this.getPosition(), 5, @blobs);
	for (int eee = 0; eee < blobs.size(); ++eee) {
		CBlob@ current_blob = blobs[eee];
		if (current_blob is null) continue;
		if (current_blob.getName()!=this.getName()) continue;
	}
}