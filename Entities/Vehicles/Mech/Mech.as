#include "Hitters.as";
#include "HittersTC.as";
#include "Explosion.as";

void onInit(CBlob@ this)
{
	this.Tag("usable by anyone");
	this.getShape().SetGravityScale(0);
	// this.Tag("aerial");

	// this.set_f32("map_damage_ratio", 0.5f);
	// this.set_f32("map_damage_radius", 48.0f);
	// this.set_string("custom_explosion_sound", "MithrilBomb_Explode_old.ogg");
		
	// this.set_Vec2f("velocity", Vec2f(0, 0));
	
	// this.getShape().SetRotationsAllowed(true);
	this.Tag("allow guns");
	
	CSprite@ sprite = this.getSprite();
	sprite.SetZ(-5.0f);
	// CSpriteLayer@ back = sprite.addSpriteLayer("back", sprite.getFilename(), 24, 16);
	// if (back !is null)
	// {
		// back.SetRelativeZ(-1.0f);
		// back.SetOffset(Vec2f(0, 0));
		// back.SetFrameIndex(1);
	// }
	
	this.addCommandID("mech_give");

	
	CSpriteLayer@ back = sprite.addSpriteLayer("back", sprite.getFilename(), 24, 24);
	if (back !is null)
	{
		back.SetRelativeZ(-10.0f);
		back.SetOffset(sprite.getOffset()+Vec2f(0, 0));
		back.SetFrameIndex(0);
	}
	
	CSpriteLayer@ leg_l = sprite.addSpriteLayer("leg_l", sprite.getFilename(), 12, 24);
	if (leg_l !is null)
	{
		leg_l.SetRelativeZ(-5.0f);
		leg_l.SetOffset(sprite.getOffset()+leg_l_offset);
		leg_l.SetFrameIndex(5);
	}
	
	CSpriteLayer@ leg_r = sprite.addSpriteLayer("leg_r", sprite.getFilename(), 12, 24);
	if (leg_r !is null)
	{
		leg_r.SetRelativeZ(5.0f);
		leg_r.SetOffset(sprite.getOffset()+leg_r_offset);
		leg_r.SetFrameIndex(4);
	}
	
	AttachmentPoint@ pilot = this.getAttachments().getAttachmentPointByName("PILOT");
	if (pilot !is null)
	{
		pilot.SetKeysToTake(key_left | key_right | key_up | key_down);
		pilot.offset = pilot_offset;
		// pilot.SetMouseTaken(true);
	}
	
	AttachmentPoint@ slot_l = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (slot_l !is null)
	{
		slot_l.SetKeysToTake(key_action1 | key_action2);
		slot_l.SetMouseTaken(true);
	}
	
	// AttachmentPoint@ slot_r = this.getAttachments().getAttachmentPointByName("SLOT_R");
	// if (slot_r !is null)
	// {
		// slot_r.SetKeysToTake(key_action1 | key_action2);
	// }
	
	CShape@ shape = this.getShape();
	//shape.SetGravityScale(1.00);
	shape.SetOffset(Vec2f(1.00f, 4));
	shape.SetRotationsAllowed(false);
	
	//sprite.SetEmitSound("Mech_Loop.ogg");
	sprite.SetEmitSoundVolume(1.25f);
	sprite.SetEmitSoundPaused(false);
	
	
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("mech_give"))
	{
		if (isServer())
		{
			CBlob@ caller = getBlobByNetworkID(params.read_u16());
			
			if (caller !is null)
			{
				CBlob@ carried = caller.getCarriedBlob();
	
				AttachmentPoint@ point = this.getAttachments().getAttachmentPointByID(2);
	
				if (true)
				{
					// this.server_AttachTo(carried, point);
					this.server_AttachTo(carried, point);
					// carried.server_AttachTo(this, "PICKUP");
					// this.server_Pickup(carried);
				}
				// else
				// {
					// this.DropCarried();
				// }
			}
		}
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return forBlob.getTeamNum() == this.getTeamNum();
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.getDistanceTo(caller) > 96.0f) return;
	if (caller is null) return;
	if (caller.getTeamNum() != this.getTeamNum()) return;
	
	// if (caller.getTeamNum() == this.getTeamNum() && caller.isOverlapping(this))
	if ((caller.getPosition() - this.getPosition()).Length() < 24.0f)
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		CButton@ button = caller.CreateGenericButton(11, Vec2f(0, 0), this,  this.getCommandID("mech_give"), "Attach Item", params);
	}
}

const Vec2f leg_l_offset = Vec2f(-7, 9);
const Vec2f leg_r_offset = Vec2f(6, 9);
const Vec2f pilot_offset = Vec2f(3, -1);

void onTick(CSprite@ this)
{
	// this.SetZ(0.0f);
	
	CSpriteLayer@ back = this.getSpriteLayer("back");
	if (back !is null)
	{	
		back.SetRelativeZ(-20);
	}
	
	CBlob@ blob = this.getBlob();
	Vec2f vel = blob.getVelocity();
	
	// f32 vellen = Maths::Min(vel.getLength() * 0.40f, 1.00f);
	
	

	//ShakeScreen(8, 1, blob.getPosition());
	// MakeParticle(blob, "LargeSmoke");
}

// Vec2f smokeOffset = Vec2f(0, 0);
// void MakeParticle(CBlob@ this, const string filename = "SmallSteam")
// {
	// ParticleAnimated(CFileMatcher(filename).getFirst(), this.getPosition() + smokeOffset, Vec2f(2, -1), float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.2f, false);
// }

void onAttach(CBlob@ this,CBlob@ attached,AttachmentPoint @attachedPoint)
{
	attached.Tag("invincible");
	attached.Tag("invincibilityByVehicle");
}

void onDetach(CBlob@ this,CBlob@ detached,AttachmentPoint@ attachedPoint)
{
	detached.Untag("invincible");
	detached.Untag("invincibilityByVehicle");
}

void onTick(CBlob@ this)
{
	AttachmentPoint@ seat = this.getAttachments().getAttachmentPointByName("PILOT");
	if (seat is null) return;
	CSprite@ sprite = this.getSprite();
	
	const bool left = seat.isKeyPressed(key_left);
	const bool right = seat.isKeyPressed(key_right);
	const bool up = seat.isKeyPressed(key_up)&&false;
	const bool down = seat.isKeyPressed(key_down)&&false;

	f32 h = (left ? -0.2 : 0) + (right ? 0.2 : 0); 
	f32 v = (up ? -1 : 0) + (down ? 1 : 0); 
	
	Vec2f vel = Vec2f(h, v * 2);
	
	f32 vellen = Maths::Min(Maths::Abs(vel.x) * 0.40f, 1.00f);
	
	HitInfo@[] hitInfos;
	Vec2f hitpos1;
	bool hashit1 = false;
	if (getMap().rayCastSolid(this.getPosition(), this.getPosition()+Vec2f(0, 4800), hitpos1))
	{
		hashit1 = true;
	}
	
	f32 ground_dist = (hitpos1-this.getPosition()).Length();
	int dist_correction = Maths::Floor(ground_dist/20);
	
		
	CBlob@ pilot = seat.getOccupied();
	
	// f32 vellen = 0.5f;
	// print("" + vellen);
	
	// blob.setAngleDegrees((10 * (blob.isFacingLeft() ? 1 : -1)) + (blob.getVelocity().x * 2.00f));
	
	// this.SetEmitSoundVolume(1.25f);
	// this.SetEmitSoundSpeed(0.50f + (Maths::Clamp(blob.getVelocity().getLength() / 15.00f, 0.00f, 1.00f) * 2.00f));
	
	const bool FLIP = this.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	CSpriteLayer@ leg_l = sprite.getSpriteLayer("leg_l");
	CSpriteLayer@ leg_r = sprite.getSpriteLayer("leg_r");
	
	bool leg_l_can_step = false;
	bool leg_r_can_step = false;
	HitInfo@[] hitInfos_l;
	HitInfo@[] hitInfos_r;
	if (getMap().getHitInfosFromRay(this.getPosition()+Vec2f(-leg_l.getOffset().x*FLIP_FACTOR, leg_l.getOffset().y), 90, 8, this, @hitInfos_l))
	{
		for (int counter = 0; counter < hitInfos_l.length; ++counter)
		{
			CBlob@ doomed = hitInfos_l[counter].blob;
			if (doomed !is null) {
				if (doomed.getShape().isStatic()&&doomed.getShape().getConsts().collidable) {
					leg_l_can_step = true;
					break;
				}
				continue;
			}
			
			leg_l_can_step = true;
			break;
		}
	}
	if (getMap().getHitInfosFromRay(this.getPosition()+Vec2f(-leg_r.getOffset().x*FLIP_FACTOR, leg_r.getOffset().y), 90, 8, this, @hitInfos_r))
	{
		for (int counter = 0; counter < hitInfos_r.length; ++counter)
		{
			CBlob@ doomed = hitInfos_r[counter].blob;
			if (doomed !is null) {
				if (doomed.getShape().isStatic()&&doomed.getShape().getConsts().collidable) {
					leg_r_can_step = true;
					break;
				}
				continue;
			}
			
			leg_r_can_step = true;
			break;
		}
	}
	vellen = 2;
	if (((right || left) && leg_l_can_step) || !leg_l_can_step)
	{
		this.add_u32("moving_ticks", 1);
	}
	
	leg_l_can_step = leg_l_can_step && ((4+leg_l.getOffset().y)<=leg_l_offset.y);
	
	Vec2f moving_vector = ( (leg_l_can_step && left) || (right && leg_r_can_step))?Vec2f(4*FLIP_FACTOR, -9):Vec2f();
	
	if (hashit1)
		this.setPosition(this.getPosition()+Vec2f(0, ground_dist>17?dist_correction*2:-dist_correction)+moving_vector);
	
	f32 sin = Maths::Sin(1.0f*this.get_u32("moving_ticks") * 0.60f) * vellen;
	f32 cos = Maths::Cos(1.0f*this.get_u32("moving_ticks") * 0.60f) * vellen;
	
	if (leg_l !is null)
	{
		// leg_l.ResetTransform();
	
		Vec2f jitter = Vec2f((XORRandom(100) - 50) * 0.015f, 0);
		Vec2f velOffset = Vec2f(-cos, sin) * 2;
		//velOffset.x *= 0.5f;
		velOffset.y *= 2;
		velOffset.y = Maths::Min(0, velOffset.y);
		leg_l.SetOffset(sprite.getOffset()+velOffset + leg_l_offset);
		// leg_l.RotateBy(Maths::Clamp(cos * vellen * 15, -35, 35), Vec2f());
	}
	
	if (leg_r !is null)
	{
		// leg_r.ResetTransform();
	
		Vec2f jitter = Vec2f((XORRandom(100) - 50) * 0.015f, 0);
		Vec2f velOffset = Vec2f(sin, cos) * 2;
		velOffset.x *= 0.5f;
		velOffset.y *= 2;
		velOffset.y = Maths::Min(0, velOffset.y);
		leg_r.SetOffset(sprite.getOffset()+velOffset + leg_r_offset);
		// leg_r.RotateBy(Maths::Clamp(sin * vellen * 15, -35, 35), Vec2f());
	}
	
	if (pilot is null) return;
	
	if (seat !is null)
	{
		Vec2f jitter = Vec2f((XORRandom(100) - 50) * 0.010f, (XORRandom(100) - 50) * 0.010f);
		seat.offset = jitter + pilot_offset;
		if (pilot !is null)
			pilot.SetFacingLeft(this.isFacingLeft());
		// pilot.SetMouseTaken(true);
	}
	
	this.AddForce(vel * this.getMass() * 0.40f);
	this.SetFacingLeft(pilot.getAimPos().x < this.getPosition().x);
	
	this.setAimPos(pilot.getAimPos());
	
	// AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("GUN");
	// if (point !is null)
	// {
		// point.
	// }
	
	// print("vel: " + this.getVelocity().Length());
	
}

void onDie(CBlob@ this)
{
	this.getSprite().Gib();
	return;
	if (isServer())
	{
		CBlob@ boom = server_CreateBlobNoInit("nukeexplosion");
		boom.setPosition(this.getPosition());
		boom.set_u8("boom_start", 3);
		boom.set_u8("boom_end", 5);
		boom.set_f32("mithril_amount", 50);
		boom.set_f32("flash_distance", 256);
		boom.set_u32("boom_delay", 0);
		boom.set_u32("flash_delay", 5);
		boom.Tag("no fallout");
		// boom.Tag("no flash");
		boom.Init();
	}
	
}

// void onCollision(CBlob@ this, CBlob@ blob, bool solid)
// {
	// if (isServer())
	// {
		// if (blob !is null ? !blob.isCollidable() : !solid) return;

		// f32 vellen = this.getOldVelocity().Length();

		// if (vellen > 5.0f)
		// {
			// this.server_Hit(this, this.getPosition(), this.getOldVelocity(), vellen * 0.10f, Hitters::fall, true);
		// }
	// }
// }

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PILOT");
	if (point is null) return true;
		
	CBlob@ holder = point.getOccupied();
	if (holder is null) return true;
	else return false;
}

bool canBePutInInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	return false;
}





			
