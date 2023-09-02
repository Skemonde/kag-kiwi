#include "DoorCommon"
#include "CustomBlocks"

void onInit(CBlob@ this)
{
	this.addCommandID("static_off");
	this.addCommandID("static_on");
	this.addCommandID("security_set_state");

	this.getShape().SetRotationsAllowed(false);
	//this.set_TileType("background tile", CMap::tile_castle_back);
	
	this.Tag("blocks sword");
	this.Tag("door");
	this.Tag("blocks water");

	this.addCommandID("sync_state");
	server_Sync(this);
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;

	sprite.getConsts().accurateLighting = true;

	if (!isStatic) return;

	this.getSprite().PlaySound("/build_door.ogg");
}

void onTick(CBlob@ this)
{
	if (this.getTickSinceCreated() == 10) {
		CSprite@ sprite = this.getSprite();
		if (!this.exists("security_state")) {
			setOpen(this, true);
		} else
			setOpen(this, false);
	}
}

void server_Sync(CBlob@ this)
{
	if (isServer())
	{
		CBitStream stream;
		stream.write_bool(this.get_bool("security_state"));
		
		this.SendCommand(this.getCommandID("sync_state"), stream);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	return;
	CBitStream params;
	params.write_bool(!this.get_bool("security_state"));
	CButton@ button = caller.CreateGenericButton("$lock$", Vec2f(0, 0), this, this.getCommandID("security_set_state"), "door", params);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("security_set_state"))
	{
		bool state = params.read_bool();
		this.set_bool("security_state", state);
		setOpen(this, state);
	}
	else if (cmd == this.getCommandID("sync_state"))
	{
		if (isClient())
		{
			bool ss = params.read_bool();
			
			this.set_bool("security_state", ss);
		}
	}
}

void setOpen(CBlob@ this, bool open)
{
	CSprite@ sprite = this.getSprite();
	if (open)
	{
		sprite.SetZ(-100.0f);
		sprite.SetAnimation("open");
		this.Untag("bullet_hits");
		this.getShape().getConsts().collidable = false;
		this.getShape().getConsts().lightPasses = true;
		CMap@ map = this.getMap();
		Vec2f pos = this.getPosition();
		for (u8 i = 0; i < 8; ++i) {
			map.server_SetTile(Vec2f((pos.x - this.getRadius()/2-8) + i * 8, pos.y+4), CMap::tile_bgsteelbeam);
		}
		this.getCurrentScript().tickFrequency = 3;
	}
	else
	{
		sprite.SetZ(100.0f);
		sprite.SetAnimation("close");
		this.Tag("bullet_hits");
		this.getShape().getConsts().collidable = true;
		this.getShape().getConsts().lightPasses = false;
		CMap@ map = this.getMap();
		Vec2f pos = this.getPosition();
		for (u8 i = 0; i < 8; ++i) {
			map.server_SetTile(Vec2f((pos.x - this.getRadius()/2-8) + i * 8, pos.y+4), CMap::tile_lightabsorber);
		}
		this.getCurrentScript().tickFrequency = 0;
	}
	
	const uint count = this.getTouchingCount();
	uint collided = 0;
	for (uint step = 0; step < count; ++step)
	{
		CBlob@ blob = this.getTouchingByIndex(step);
		if (blob.isCollidable())
		{
			blob.AddForce(Vec2f(0, 0)); // Hack to awake sleeping blobs' physics
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	return 0;
}

bool canClose(CBlob@ this)
{
	const uint count = this.getTouchingCount();
	uint collided = 0;
	for (uint step = 0; step < count; ++step)
	{
		CBlob@ blob = this.getTouchingByIndex(step);
		if (blob.isCollidable())
		{
			collided++;
		}
	}
	return collided == 0;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return !isOpen(this);
}