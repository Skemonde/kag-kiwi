#define SERVER_ONLY

// set "hit dmg modifier" in your blob to modify blob hit damage
// set "map dmg modifier" in your blob to modify map hit damage

#include "Hitters.as"
#include "KIWI_Hitters.as"

void onInit(CBlob@ this)
{
	if (!this.exists("hit dmg modifier"))
	{
		this.set_f32("hit dmg modifier", 1.0f);
	}

	if (!this.exists("map dmg modifier"))
	{
		this.set_f32("map dmg modifier", 1.0f);
	}

	if (!this.exists("hurtoncollide hitter"))
		this.set_u8("hurtoncollide hitter", Hitters::flying);

	// crushing
	//this.getCurrentScript().tickFrequency = 9;
	//this.getCurrentScript().runFlags |= Script::tick_not_sleeping;
	//this.getCurrentScript().runFlags |= Script::tick_overlapping;
	//this.getCurrentScript().runFlags |= Script::tick_not_attached;
	//if (this.getMass() < 500) {
	//  this.getCurrentScript().tickFrequency = 0;
	//}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (this.hasTag("player")) return;
	
	if (solid)
	{
		Vec2f hitvel = this.getOldVelocity();
		Vec2f hitvec = point1 - this.getPosition();
		f32 coef = hitvec * hitvel;

		if (coef < 0.706f) // check we were flying at it
		{
			return;
		}

		f32 vellen = hitvel.Length();

		if (blob is null)
		{
			// map collision
			CMap@ map = this.getMap();
			point1 -= normal;
			TileType tile = map.getTile(point1).type;

			if (vellen > 0.1f &&
			        this.getMass() > 1.0f
					//&&
			        //(map.isTileCastle(tile) ||
			        // map.isTileWood(tile))
				)
			{
				f32 vellen = this.getShape().vellen;
				f32 dmg = this.get_f32("map dmg modifier") * vellen / 10;

				//printf("dmg " + dmg + " m " + this.get_f32("map dmg modifier"));
				// less damage for stone
				// if (map.isTileCastle(tile)) {
				//dmg *= 0.75f;
				// }

				if (dmg > 0.1f && map.getSectorAtPosition(point1, "no build") is null)
				{
					bool left_neighbour = map.isTileSolid(map.getAlignedWorldPos(point1-Vec2f(8, 0)));
					bool right_neighbour = map.isTileSolid(map.getAlignedWorldPos(point1+Vec2f(8, 0)));
					
					bool only_one = (left_neighbour || right_neighbour) && !(left_neighbour && right_neighbour) && XORRandom(1000)<150;
					bool both = left_neighbour && right_neighbour && XORRandom(1000)<25;
					bool none = !(left_neighbour || right_neighbour);
					
					if (map.isTileGroundStuff(tile))
						dmg/=10;
					if (both || only_one || none) {
						for (int hit_i = 0; hit_i < Maths::Min(dmg, 20); ++hit_i)
							map.server_DestroyTile(point1, 1, this);
					}
				}
			}
		}
		else    // blob
			if (blob.getTeamNum() != this.getTeamNum() && !blob.hasTag("no_ram_damage"))
			{
				const f32 mass = Maths::Max(this.getMass(), 10.0f);
				const f32 veryHeavy = 500.0f;
				// no team killingfor not very heavy objects

				CPlayer@ damagePlayer = this.getDamageOwnerPlayer();
				if (mass < veryHeavy &&
				        damagePlayer !is null &&
				        damagePlayer.getBlob() !is null &&
				        damagePlayer.getBlob().getTeamNum() == blob.getTeamNum())
				{
					return;
				}


				// hack:for boats killing ppl on top
				if (mass > veryHeavy &&
				        blob.getPosition().y < this.getPosition().y &&
				        blob.hasTag("flesh"))
				{
					return;
				}

				// check if we had greater velocity
				if (vellen >= blob.getShape().vellen &&
				        vellen > 0.1f &&
				        blob.getMass() > 0.0f)
				{
					hitvel /= vellen;
					hitvec.Normalize();
					coef = hitvec * hitvel;
					coef *= this.get_f32("hit dmg modifier");
					f32 mass = Maths::Min(this.getMass(), 1000.0f);
					f32 mass2 = Maths::Min(blob.getMass(), 200.0f);
					f32 dmg = vellen * coef * (mass / mass2) / 8.0f;

					if (dmg > 0.25f)
					{
						this.server_Hit(blob, point1, hitvel, dmg, this.get_u8("hurtoncollide hitter"), true);
						//  printf("HIOT " + dmg );
						return;
					}
				}
			}
	}
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	if (hitBlob !is null)// && customData == Hitters::flying)
	{
		Vec2f force = velocity * this.getMass() * 0.05f;
		hitBlob.AddForce(force);
	}
}
