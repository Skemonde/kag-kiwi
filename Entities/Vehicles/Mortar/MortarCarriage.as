#include "Skemlib"

void onInit(CBlob@ this)
{
	this.set_f32("important-pickup", 0.0f);
	this.set_f32("relative cannon angle", -50);
	this.Tag("heavy weight");
	this.Tag("bullet_hits");
	this.Tag("no team lock");
	
	if (this.getAttachments().getAttachmentPointByName("MORTAR") !is null) {
		CBlob@ blob = server_CreateBlobNoInit("mortar");
		if (blob !is null)
		{
			blob.server_setTeamNum(this.getTeamNum());
			this.set_u16("mortar_id", blob.getNetworkID());
			blob.set_u16("carriage_id", this.getNetworkID());
			blob.Init();
			blob.getSprite().SetRelativeZ(-5);
			this.server_AttachTo(blob, "MORTAR");
		}
	}
	
	AttachmentPoint@ gunner_point = this.getAttachments().getAttachmentPointByName("GOONNER");
	if (gunner_point is null) return;
	
	gunner_point.offsetZ = 10;
	
	CSpriteLayer@ carriage = this.getSprite().addSpriteLayer("carriage", "MortarCarriage.png", 24, 24, this.getTeamNum(), 0);
	if (carriage !is null) {
		carriage.SetFrame(0);
		carriage.SetRelativeZ(-2);
		carriage.RotateBy(-45, Vec2f());
		carriage.SetOffset(Vec2f(0,5));
	}
	CSpriteLayer@ plank = this.getSprite().addSpriteLayer("plank", "MortarCarriage.png", 32, 8, this.getTeamNum(), 0);
	if (plank !is null) {
		plank.SetFrame(3);
		plank.SetRelativeZ(-1);
		plank.SetOffset(Vec2f(0,6.5f));
	}
}

void ReadGunnerActions(CBlob@ this)
{
	const bool FLIP = this.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	
	AttachmentPoint@ gunner_point = this.getAttachments().getAttachmentPointByName("GOONNER");
	if (gunner_point is null) return;
	
	CBlob@ gunner = gunner_point.getOccupied();
	if (gunner is null) return;
	
	if (gunner.isKeyPressed(key_down))
		this.add_f32("relative cannon angle", 1);
	if (gunner.isKeyPressed(key_right))
		this.add_f32("relative cannon angle", 1*FLIP_FACTOR);
	if (gunner.isKeyPressed(key_up))
		this.add_f32("relative cannon angle", -1);
	if (gunner.isKeyPressed(key_left))
		this.add_f32("relative cannon angle", -1*FLIP_FACTOR);
	
	this.set_f32("relative cannon angle", Maths::Clamp(this.get_f32("relative cannon angle"), -65, -30));
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return false;
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return !byBlob.isAttached();
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	if (!attached.hasTag("player")) return;
	if (attached.isAttached())
	{
		this.server_DetachFrom(attached);
		return;
	}
	if (attachedPoint.name == "PICKUP")
	{
		this.getShape().SetRotationsAllowed(false);
		this.setAngleDegrees(0);
	}
	
	attached.Tag("can change facing");
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{
	if (!detached.hasTag("player")) return;
	if (attachedPoint.name == "PICKUP")
	{
		this.getShape().SetRotationsAllowed(true);
	}
	
	detached.Untag("can change facing");
}

void onDie(CBlob@ this)
{
	if (this.exists("mortar_id")) {
		CBlob@ mortar = getBlobByNetworkID(this.get_u16("mortar_id"));
		if (mortar !is null) {
			mortar.server_Die();
		}
	}
}

void onTick(CBlob@ this)
{
	ReadGunnerActions(this);
	
	const bool FLIP = this.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	AttachmentPoint@ mortar_point = this.getAttachments().getAttachmentPointByName("MORTAR");
	if (mortar_point is null) return;
	
	CBlob@ mortar = mortar_point.getOccupied();
	if (mortar is null) return;
		
	mortar_point.occupied_offset = Vec2f(-2, 5.5).RotateBy(this.getAngleDegrees()+this.get_f32("relative cannon angle"));
	
	mortar.SetFacingLeft(this.isFacingLeft());
	mortar.setAngleDegrees(this.getAngleDegrees()+this.get_f32("relative cannon angle")*FLIP_FACTOR);
	
	CSprite@ sprite = this.getSprite();
	
	CSpriteLayer@ carriage = sprite.getSpriteLayer("carriage");
	if (carriage is null) return;
	
	carriage.ResetTransform();
	carriage.RotateBy(45*FLIP_FACTOR, Vec2f());
	carriage.SetOffset(Vec2f(0,5));
}