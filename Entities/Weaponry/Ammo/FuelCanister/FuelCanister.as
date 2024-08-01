#include "Hitters"
#include "MetroBoomin"
#include "KIWI_Locales"

void onInit(CBlob@ this)
{  
	this.setInventoryName(Names::fuel_canister);
	this.Tag("ammo");
	this.Tag("crate pickup");
	this.Tag("bullet_hits");
	
	this.maxQuantity = 50;
	
	if (this.getQuantity()==1)
		this.server_SetQuantity(this.getMaxQuantity());
		
	this.set_string("custom_explosion_sound", "");
	//this.getCurrentScript().runFlags |= Script::remove_after_this;
}

void onTick(CBlob@ this)
{
	return;
	if (!isServer()) return;
	
	if ((getGameTime()-this.get_u32("last_spread")) < 8) return;
	
	AttachmentPoint@ pickup_point = this.getAttachments().getAttachmentPointByName("PICKUP");
	CBlob@ holder = pickup_point.getOccupied();
	if (holder is null) return;
	
	if (!holder.isKeyPressed(key_action1)) return;
	
	CBlob@ small_bit = server_CreateBlob(this.getName(), this.getTeamNum(), this.getPosition()+Vec2f(16, 0));
	small_bit.server_SetQuantity(5);
	
	this.server_SetQuantity(Maths::Max(0, this.getQuantity()-5));
	
	if (this.getQuantity()<=0) this.server_Die();
	
	this.set_u32("last_spread", getGameTime());
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2 )
{
	const f32 vellen = this.getOldVelocity().Length();
	if (solid && false) {			
		if (vellen > 1.7f)
		{
			Sound::Play("BombBounce", this.getPosition(), 1, 1.3f + XORRandom(2)*0.1);
		}
	}
	
	if (vellen >= 8.0f && solid)
	{
		//print("vellen "+vellen);
		this.server_Hit(this, this.getPosition(), Vec2f(), 2.0f, 0);
	}
}

void onDie( CBlob@ this )
{
	if (!this.hasTag("died naturally")) return;
	
	if (this.getTickSinceCreated()>=3) {
		this.set_u8("custom_hitter", Hitters::fire);
		this.set_string("custom_explosion_sound", "explosion2.ogg");
		MakeItBoom(this, 16, 5.0f);
	}
	
	CParticle@ p = ParticleAnimated(
	"kiwi_fire_v2.png", // file name
	this.getPosition(), // position
	Vec2f(),      		// velocity
	0,                  // rotation
	4.0f,               // scale
	1,                  // ticks per frame
	0,                	// gravity
	true);
	if (p !is null) {
		p.setRenderStyle(RenderStyle::additive);
		p.Z=1500+XORRandom(30)*0.01;
	}
}