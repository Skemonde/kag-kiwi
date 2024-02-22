#include "Hitters.as";
#include "Explosion"
#include "MakeBangEffect"
#include "MakeExplodeParticles"

void onInit(CBlob@ this)
{
	this.Tag("usable by anyone");
	this.Tag("aerial");
	this.Tag("bullet_hits");
	this.Tag("non_pierceable");
	this.Tag("vehicle");
	this.Tag("no team lock");

	// this.set_f32("map_damage_ratio", 0.5f);
	// this.set_f32("map_damage_radius", 48.0f);
	// this.set_string("custom_explosion_sound", "MithrilBomb_Explode_old.ogg");
		
	// this.set_Vec2f("velocity", Vec2f(0, 0));
	
	this.getShape().SetRotationsAllowed(true);
	this.Tag("allow guns");
	
	CSprite@ sprite = this.getSprite();
	//CSpriteLayer@ back = sprite.addSpriteLayer("back", sprite.getFilename(), 24, 16);
	//if (back !is null)
	//{
	//	back.SetRelativeZ(-1.0f);
	//	back.SetOffset(Vec2f(0, 0));
	//	back.SetFrameIndex(1);
	//}
	
	AttachmentPoint@ pilot = this.getAttachments().getAttachmentPointByName("PILOT");
	if (pilot !is null)
	{
		pilot.SetKeysToTake(key_left | key_right | key_up | key_down);
		// pilot.SetMouseTaken(true);
	}
	
	CShape@ shape = this.getShape();
	shape.SetGravityScale(0.1f);
	
	sprite.SetEmitSound("EngineIdle.ogg");
	sprite.SetEmitSoundVolume(1.25f);
	sprite.SetEmitSoundPaused(false);
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	this.SetZ(0.0f);
	
	CSpriteLayer@ back = this.getSpriteLayer("back");
	if (back !is null)
	{	
		back.SetRelativeZ(-20);
	}
	
	this.SetEmitSoundVolume(1.25f);
	this.SetEmitSoundSpeed(0.50f + (Maths::Clamp(blob.getVelocity().getLength() / 15.00f, 0.00f, 1.00f) * 2.00f));
}

void onTick(CBlob@ this)
{
	this.setAngleDegrees((-10 * (this.isFacingLeft() ? 1 : -1)) + (this.getVelocity().x * 2.00f));
	AttachmentPoint@ seat = this.getAttachments().getAttachmentPointByName("PILOT");
	if (seat !is null)
	{
		CBlob@ pilot = seat.getOccupied();
		if (pilot !is null)
		{
			const bool left = seat.isKeyPressed(key_left);
			const bool right = seat.isKeyPressed(key_right);
			const bool up = seat.isKeyPressed(key_up);
			const bool down = seat.isKeyPressed(key_down);

			f32 h = (left ? -1 : 0) + (right ? 1 : 0); 
			f32 v = (up ? -1 : 0) + (down ? 1 : 0); 
			
			Vec2f vel = Vec2f(h, v);
			
			if (this.exists("gyromat_acceleration"))
			{
				vel *= Maths::Sqrt(this.get_f32("gyromat_acceleration"));
			}

			this.AddForce(vel * this.getMass() * 0.50f);
			bool facing = pilot.getAimPos().x < this.getPosition().x-this.getVelocity().x;
			CBlob@ carried = pilot.getCarriedBlob();
			this.SetFacingLeft(facing);
			
			pilot.setAngleDegrees(this.getAngleDegrees());
			
			//if (carried !is null)
			//	carried.SetFacingLeft(facing);
			
			// print("vel: " + this.getVelocity().Length());
		}
	}
}

void onDie(CBlob@ this)
{
	if (!this.hasTag("died naturally")) return;
	
	if (isServer())
	for (int idx = 0; idx < 6; ++idx) {
		CBlob@ flare = server_CreateBlob("napalm", this.getTeamNum(), this.getPosition());
		if (flare is null) continue;
		flare.setVelocity(getRandomVelocity(90+this.getAngleDegrees(), 12+XORRandom(6), 40));
	}
	
	if (isClient())
	{
		Vec2f pos = this.getPosition();
		CMap@ map = getMap();
		
		MakeBangEffect(this, "bakoom", 4.0);
		Sound::Play("tank_death", this.getPosition(), 2, 1.0f + XORRandom(2)*0.1);
		u8 particle_amount = 6;
		for (int i = 0; i < particle_amount; i++)
		{
			MakeExplodeParticles(this, Vec2f( XORRandom(64) - 32, XORRandom(64) - 32), getRandomVelocity(360/particle_amount*i, XORRandom(220) * 0.01f, 90));
		}
		
		u8 team = this.getTeamNum();
		Vec2f vel = this.getVelocity();
		vel.y -= 3.0f;
		f32 hp = Maths::Min(Maths::Abs(this.getHealth()), 2.0f) + 1.0f;
		for (int i = 0; i < 7; ++i) {
			//CParticle@ tank_part = makeGibParticle("bt_gibs.png", pos, vel + getRandomVelocity(90+(-3.5+i)*(180/7), XORRandom(3), 0)*2, 0, 7-i, Vec2f(24, 24), 2.0f, 20, "tank_death", team);
		}
	}
	
	this.getSprite().Gib();
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (isServer())
	{
		if (blob !is null ? !blob.isCollidable() : !solid) return;

		f32 vellen = this.getOldVelocity().Length();

		if (vellen > 5.0f)
		{
			this.server_Hit(this, this.getPosition(), this.getOldVelocity(), vellen * 0.05f, Hitters::fall, true);
		}
	}
}

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