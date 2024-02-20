
#include "SoldatInfo"

const f32 TREATMENT_RADIUS = 32;

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2 )
{
	if (!solid || this.hasTag("dead")) return;
	
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
	this.Tag("dead");
	this.server_Die();
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return blob.getName()!=this.getName();
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint @detachedPoint )
{
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