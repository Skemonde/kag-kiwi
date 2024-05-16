
#include "SoldatInfo"
#include "GenericGibsEnum"

const f32 TREATMENT_RADIUS = 32;

void onInit(CBlob@ this)
{
	//this.Tag("no throw via action3");
}

void onTick(CBlob@ this)
{
	doPickupHack(this);
}

void doPickupHack(CBlob@ this)
{
	if (this.getTickSinceCreated()>1) return;
	CPlayer@ owner = this.getDamageOwnerPlayer();
	if (owner is null) return;
	CBlob@ blob = owner.getBlob();
	if (blob is null) return;
	
	blob.server_Pickup(this);
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2 )
{
	if (!solid || this.hasTag("dead")) return;
	
	Vec2f vel = this.getVelocity();
	
	if (blob is null && Maths::Abs(vel.x)>=2) {
		Vec2f new_vel = Vec2f(vel.Length(), 0).RotateBy(-vel.getAngle());
		this.setVelocity(Vec2f(new_vel.x*0.5, Maths::Clamp(new_vel.y*3, -10, 10)));
		Sound::Play("bottle_bounce.ogg", this.getPosition(), 0.6f, 0.76f + XORRandom(10)*0.01);
		return;
	}
	
	CBlob@[] blobs;
	if (getMap().getBlobsInRadius(point1, TREATMENT_RADIUS, blobs)) {
		for (int idx = 0; idx < blobs.size(); ++idx) {
			CBlob@ current_blob = blobs[idx];
			if (current_blob is null) continue;
			CPlayer@ my_player = this.getDamageOwnerPlayer();
			CPlayer@ player = current_blob.getPlayer();
			bool target_is_medic = false;
			//can heal themselves and other NON medic players
			if (player !is null) {
				SoldatInfo@ info = getSoldatInfoFromUsername(player.getUsername());
				if (info is null) return;
				if (info.hat_name=="medhelm")
					target_is_medic = true;
			}
			
			bool needs_treatment = current_blob.getHealth()<current_blob.getInitialHealth();
			if (!current_blob.hasTag("player")||(target_is_medic && player !is null && my_player !is null && !(player is my_player))) continue;
			
			u32 last_hit_time = current_blob.get_u32("last_hit_time");
			u32 ticks_from_last_hit = getGameTime()-last_hit_time;
			f32 seconds_from_last_hit = Maths::Max(1.0f, ticks_from_last_hit/getTicksASecond());
			// 1/16 * seconds from last hit
			
			f32 heal_amount = seconds_from_last_hit*(current_blob.getInitialHealth()/8); //aplies only to non-medic teammates
			
			if (target_is_medic)//to heal yourself up completely you'll need 8 bombs
				heal_amount = current_blob.getInitialHealth()/4;
			
			CParticle@ p = ParticleAnimated(
			"HealParticle1.png",                   		// file name
			current_blob.getPosition() + Vec2f(0,-3) + Vec2f(-XORRandom(Maths::Floor(current_blob.getVelocity().x)), 0),       // position
			Vec2f((XORRandom(60)-30)*0.01, 0),      // velocity
			0,                              		// rotation
			2.0f,                               	// scale
			3,                                  	// ticks per frame
			(XORRandom(3)+1)*-0.03f,                // gravity
			true);
			if (p !is null) {
				//p.setRenderStyle(RenderStyle::additive);
				p.Z=1500+XORRandom(30)*0.01;
				//p.growth = 0.015;
			}
			if (!needs_treatment) continue;
			Sound::Play("Heal", this.getPosition(), 1.0, 1.0f + XORRandom(3)*0.1);
			
			if (current_blob.getHealth()<0)
				current_blob.server_Heal(Maths::Abs(current_blob.getHealth())*2);
			current_blob.server_Heal(heal_amount);
		}
	}
	Sound::Play("GlassBreak1", this.getPosition(), 1.0, 1.0f + XORRandom(3)*0.1);
	for (int idx = 0; idx < 3; ++idx) {
		makeGibParticle(
			this.getSprite().getFilename(),
			point2, -this.getVelocity(),// + getRandomVelocity(idx==0?0:180, 2 , 30),
			0, idx, Vec2f(5, 5),
			2.0f, 20, "GlassShattering", this.getTeamNum()
		);
	}
	
	for (int idx = 0; idx < 6; ++idx) {
		makeGibParticle("GenericGibs", point2, getRandomVelocity(-(point2 - this.getPosition()).getAngle(), 2.0f+XORRandom(200)/100, 90.0f) + Vec2f(0.0f, -2.0f),
			Gibs::steel, 7, Vec2f(8, 8), 2.0f, 0, "GlassShattering", 0);
	}
	
	this.Tag("dead");
	this.server_Die();
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return blob.getName()!=this.getName();
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint @detachedPoint )
{
	if (detached.getHealth()<=0) {
		this.server_Die();
		return;
	}
	Sound::Play("GrenadeThrow", this.getPosition(), 2.0, 1.0f + XORRandom(3)*0.1);
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return false;
}

bool canBePutInInventory( CBlob@ this, CBlob@ inventoryBlob )
{
	return false;
}