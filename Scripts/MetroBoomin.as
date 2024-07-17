//MetroBooming.as - Explosions
//copied from Explosion.as

/**
 *
 * used mainly for void Explode ( CBlob@ this, f32 radius, f32 damage )
 *
 * the effect of the explosion can be customised with properties:
 *
 * f32 map_damage_radius        - the radius to damage the map in
 * f32 map_damage_ratio         - the ratio of part-damage to full-damage of the map
 *                                  0.0 is all part-damage, 1.0 is all full-damage
 * bool map_damage_raycast      - whether to damage through terrain, or just the surface blocks;
 *
 * string custom_explosion_sound - the sound played when the explosion happens
 *
 * u8 custom_hitter             - the hitter from Hitters.as to use
 */


#include "Hitters.as";
#include "KIWI_Hitters.as";
#include "ShieldCommon.as";
#include "SplashWater.as";
#include "FirearmVars.as";
#include "CustomBlocks.as";
#include "MaterialCommon.as";

bool isOwnerBlob(CBlob@ this, CBlob@ that)
{
	//easy check
	if (this.getDamageOwnerPlayer() is that.getPlayer())
		return true;

	if (!this.exists("explosive_parent")) { return false; }

	return (that.getNetworkID() == this.get_u16("explosive_parent"));
}

void makeSmallExplosionParticle(Vec2f pos)
{
	ParticleAnimated("Entities/Effects/Sprites/SmallExplosion" + (XORRandom(3) + 1) + ".png",
	                 pos, Vec2f(0, 0.5f), 0.0f, 1.0f,
	                 3 + XORRandom(3),
	                 -0.1f, true);
}

void makeLargeExplosionParticle(Vec2f pos)
{
	ParticleAnimated("Entities/Effects/Sprites/Explosion.png",
	                 pos, Vec2f(0, 0.5f), 0.0f, 1.0f,
	                 3 + XORRandom(3),
	                 -0.1f, true);
}

void MakeItBoom(CBlob@ this, f32 radius, f32 damage, Vec2f custom_pos = Vec2f())
{
	Vec2f pos = this.getPosition();
	CMap@ map = this.getMap();

	if (!this.exists("custom_explosion_sound"))
	{
		Sound::Play("Bomb.ogg", this.getPosition());
	}
	else
	{
		Sound::Play(this.get_string("custom_explosion_sound"), this.getPosition());
	}
	
	if (this.exists("custom_explosion_pos"))
	{
		pos = this.get_Vec2f("custom_explosion_pos");
	}
	
	if (custom_pos != Vec2f())
	{
		pos = custom_pos;
	}

	if (this.isInInventory() && false)
	{
		CBlob@ doomed = this.getInventoryBlob();
		if (doomed !is null)
		{
			//copy position, explode from centre of carrier
			pos = doomed.getPosition();
			//kill or stun players if we're in their inventory
			if ((doomed.hasTag("player") || doomed.getName() == "crate") && !doomed.hasTag("invincible"))
			{
				if (this.getName() == "bomb") //kill player
				{
					this.server_Hit(doomed, pos, Vec2f(), 100.0f, Hitters::explosion, true);
				}
				else if (this.getName() == "waterbomb") //stun player
				{
					this.server_Hit(doomed, pos, Vec2f(), 0.0f, Hitters::water_stun_force, true);
				}
			}
		}
	}

	//load custom properties
	//map damage
	f32 map_damage_radius = 0.0f;

	if (this.exists("map_damage_radius"))
	{
		map_damage_radius = this.get_f32("map_damage_radius");
	}

	f32 map_damage_ratio = 0.5f;

	if (this.exists("map_damage_ratio"))
	{
		map_damage_ratio = this.get_f32("map_damage_ratio");
	}

	bool map_damage_raycast = true;

	if (this.exists("map_damage_raycast"))
	{
		map_damage_raycast = this.get_bool("map_damage_raycast");
	}

	//actor damage
	u8 hitter = HittersKIWI::boom;

	if (this.exists("custom_hitter"))
	{
		hitter = this.get_u8("custom_hitter");
	}

	bool should_teamkill = this.exists("explosive_teamkill") && this.get_bool("explosive_teamkill");

	const int r = (radius * (2.0 / 3.0));

	if (hitter == Hitters::water)
	{
		int tilesr = (r / map.tilesize) * 0.5f;
		Splash(this, tilesr, tilesr, 0.0f);
		return;
	}

	//

	makeLargeExplosionParticle(pos);

	for (int i = 0; i < radius * 0.16; i++)
	{
		Vec2f partpos = pos + Vec2f(XORRandom(r * 2) - r, XORRandom(r * 2) - r);
		Vec2f endpos = partpos;

		if (map !is null)
		{
			if (!map.rayCastSolid(pos, partpos, endpos))
				makeSmallExplosionParticle(endpos);
		}
	}

	if (getNet().isServer())
	{
        Vec2f m_pos = (pos / map.tilesize);
        m_pos.x = Maths::Floor(m_pos.x);
        m_pos.y = Maths::Floor(m_pos.y);
        m_pos = (m_pos * map.tilesize) + Vec2f(map.tilesize / 2, map.tilesize / 2);

		//hit map if we're meant to
		if (map_damage_radius > 0.1f)
		{
			int tile_rad = int(map_damage_radius / map.tilesize) + 1;
			f32 rad_thresh = map_damage_radius * map_damage_ratio;

			//explode outwards
			for (int x_step = 0; x_step <= tile_rad; ++x_step)
			{
				for (int y_step = 0; y_step <= tile_rad; ++y_step)
				{
					Vec2f offset = (Vec2f(x_step, y_step) * map.tilesize);

					for (int i = 0; i < 4; i++)
					{
						if (i == 1)
						{
							if (x_step == 0) { continue; }

							offset.x = -offset.x;
						}

						if (i == 2)
						{
							if (y_step == 0) { continue; }

							offset.y = -offset.y;
						}

						if (i == 3)
						{
							if (x_step == 0) { continue; }

							offset.x = -offset.x;
						}

						f32 dist = offset.Length();

						if (dist < map_damage_radius)
						{
                            Vec2f tpos = m_pos + offset;

                            TileType tile = map.getTile(tpos).type;
                            if (tile == CMap::tile_empty)
                                continue;

							//do we need to raycast?
							bool canHit = !map_damage_raycast || (dist < 0.1f);

							if (!canHit)
							{
								Vec2f v = offset;
								v.Normalize();
								v = v * (dist - map.tilesize);
                                canHit = true;
                                HitInfo@[] hitInfos;
                                if(map.getHitInfosFromRay(m_pos, v.Angle(), v.Length(), this, hitInfos))
                                {
                                    for (int i = 0; i < hitInfos.length; i++)
                                    {
                                        HitInfo@ hi = hitInfos[i];
                                        CBlob@ b = hi.blob;
                                        // m_pos == position ignores blobs that are tiles when the explosion starts in the same tile
                                        if (b !is null && b !is this && b.isCollidable() && b.getShape().isStatic() && m_pos != b.getPosition())
                                        {
                                            /*if (b.isPlatform())
                                            {
                                                // bad but only handle one platform
                                                ShapePlatformDirection@ plat = b.getShape().getPlatformDirection(0);
                                                Vec2f dir = plat.direction;
                                                if (!plat.ignore_rotations)
                                                {
                                                    dir.RotateBy(b.getAngleDegrees());
                                                }

                                                // Does the platform block damage?
                                                if(Maths::Abs(dir.AngleWith(v)) < plat.angleLimit)
                                                {
                                                    canHit = false;
                                                    break;
                                                }
                                                continue;

                                            }*/

                                            canHit = false;
                                            break;
                                        }

                                        if(map.isTileSolid(hi.tile))
                                        {
                                            canHit = false;
                                            break;
                                        }
                                    }

                                }
							}

							if (canHit)
							{
								if (canExplosionDamage(map, tpos, tile))
								{
									if (!map.isTileBedrock(tile))
									{
										//if (dist >= rad_thresh ||
										//        !canExplosionDestroy(map, tpos, tile))
										
										if (false)
										{
											map.server_DestroyTile(tpos, 1.0f, this);
											Material::fromTile(this, tile, 1.0f);
										}
										else
										{
											int steel_account = (isTileSteel(tile, true)?-5:0);
											int castle_account = (map.isTileCastle(tile)?-2:0);
											int	tile_type_account = steel_account+castle_account;
											f32 max_hits = Maths::Max(0, (this.get_f32("map_damage_radius")/8-(tpos-pos).Length()/8)+2+tile_type_account);
											for (int idx = 0; idx < max_hits; ++idx)
											{
												if (!canExplosionDamage(map, tpos, map.getTile(tpos).type)) break;
												
												//do the check BEFORE hitting
												bool was_solid = map.isTileSolid(tpos);
												//
												map.server_DestroyTile(tpos, 1.0f, this);
												//
												bool has_destroyed_solid_tile = !map.isTileSolid(tpos);
												//need at least one hit
												//so if we killed an almost killed tile - nothing will happen
												bool damaged_enough = idx > 0;
												
												//breaking the cycle
												if (has_destroyed_solid_tile)
												{
													//creation of a tile entity
													if (was_solid && damaged_enough)
													{
														CBlob@ tileblob = server_CreateBlob("tileentity", -3, tpos);
														if (tileblob is null) break;
														
														//tileblob.AddScript("MortarLaunched.as");
														f32 flip_factor = (tpos.y>pos.y?-1:1);
														f32 angle_flip_factor = (tpos.y>pos.y?0:0);
														tileblob.setVelocity(Vec2f(-damage/2*flip_factor, 0).RotateBy(-(pos-tpos).getAngle()+angle_flip_factor));
														tileblob.set_s32("tile_frame", tile);
													}
													break;
												}
												//Material::fromTile(this, tile, 1.0f);
											}
										}
									}
								}
							}
						}
					}
				}
			}

			//end loops
		}

		//hit blobs
		CBlob@[] blobs;
		map.getBlobsInRadius(pos, radius, @blobs);

		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ hit_blob = blobs[i];
			CPlayer@ attacker = this.getDamageOwnerPlayer();
			CPlayer@ owner = hit_blob.getPlayer();
			CBlob@ attacker_blob = this;
			
			if (hit_blob is this || (hit_blob.hasTag("self explosion immune")&&(this.getName()==hit_blob.getName()))) continue;
			
			CMap@ map = getMap();
			Vec2f ray_hitpos;
				
			const bool flip = this.getPosition().x<hit_blob.getPosition().x;
			const f32 flip_factor = flip ? -1 : 1;
			bool hitting_myself = attacker !is null && owner !is null && attacker is owner;
			
			//for when a rocket hits the ground below us right after creation
			bool rocket_jump = hitting_myself && this.getTickSinceCreated()<5;
			
			bool proning = lyingProne(hit_blob);
			
			f32 angle = (hit_blob.getPosition()-this.getPosition()).Angle();
			Vec2f dir = Vec2f(1, 0).RotateBy(-angle);
			
			if (hit_blob.hasTag("vehicle")||hit_blob.hasTag("tank"))
			{
				damage *= 2;
			}

			//(proning?damage/3:hitting_myself?damage*0.8f:damage)
			//if (!map.rayCastSolid(pos, hit_blob.getPosition(), ray_hitpos))
			//hit_blob.getPosition()-dir*hit_blob.getRadius()
			if (!HitBlob(attacker_blob, pos, hit_blob, radius, (proning?damage/3:(hitting_myself?(rocket_jump?0:damage):damage)), hitter, true, should_teamkill))
			{
				//continue;
			}
			
			if (!(hit_blob.hasTag("player"))) {
				if (!(hit_blob.hasTag("vehicle")||hit_blob.hasTag("tank")))
					hit_blob.AddForce(dir*hit_blob.getMass()*damage*0.5f);
				else
					hit_blob.setVelocity(dir*damage*0.05f);
			} else if (hitting_myself) {
				CBitStream params;
				params.write_Vec2f(dir*hit_blob.getMass()*damage*0.75f);
				
				if (isServer() && hit_blob.hasCommandID("add force"))
				{
					hit_blob.SendCommand(hit_blob.getCommandID("add force"), params);
				}
			}

			//HitBlob(this, m_pos, hit_blob, radius, damage, hitter, true, should_teamkill);
		}
	}
}

bool canExplosionDamage(CMap@ map, Vec2f tpos, TileType t)
{
	CBlob@ blob = map.getBlobAtPosition(tpos); // TODO: make platform get detected
	bool hasValidFrontBlob = false;
	bool isBackwall = (t == CMap::tile_castle_back || t == CMap::tile_castle_back_moss || t == CMap::tile_wood_back);
	if (blob !is null)
	{
		string name = blob.getName();
		hasValidFrontBlob = (name == "wooden_door" || name == "stone_door" || name == "trap_block" || name == "wooden_platform" || name == "bridge");
	}
	return map.getSectorAtPosition(tpos, "no build") is null &&
	       (t != CMap::tile_ground_d0 && t != CMap::tile_stone_d0) && //don't _destroy_ ground, hit until its almost dead tho
		   !(hasValidFrontBlob && isBackwall) && // don't destroy backwall if there is a door or trap block
		   (!isTileSteelBeam(t));
}

bool canExplosionDestroy(CMap@ map, Vec2f tpos, TileType t)
{
	return !(map.isTileGroundStuff(t));
}

bool HitBlob(CBlob@ this, Vec2f mapPos, CBlob@ hit_blob, f32 radius, f32 damage, const u8 hitter,
             const bool bother_raycasting = true, const bool should_teamkill = false)
{
	if (this is null) return false;
	Vec2f pos = this.getPosition();
	CMap@ map = this.getMap();
	Vec2f hit_blob_pos = hit_blob.getPosition();
	Vec2f wall_hit;
	Vec2f hitvec = hit_blob_pos - pos;

	if (bother_raycasting) // have we already checked the rays?
	{
		// no wall in front
		bool tiles_block_damage = true;

		if (map.rayCastSolid(mapPos, hit_blob_pos, wall_hit))
		{
			CBlob@[] wall_blobs; 
			if (map.getBlobsAtPosition(wall_hit, wall_blobs))
			{
				for (int idx = 0; idx < wall_blobs.size(); ++idx)
				{
					CBlob@ cur_blob = wall_blobs[idx];
					if (cur_blob is null) continue;
					if (cur_blob is hit_blob) continue;
					
					return false;
				}
			}
			else if (tiles_block_damage)
			{
				return false;
			}
		}
		
		//print("hello "+hit_blob.getName());

		// no blobs in front

		HitInfo@[] hitInfos;
		if (map.getHitInfosFromRay(pos, -hitvec.getAngle(), hitvec.getLength(), this, @hitInfos))
		{
			for (uint i = 0; i < hitInfos.length; i++)
			{
				HitInfo@ hi = hitInfos[i];

				if (hi.blob !is null) // blob
				{
                    // mapPos == position ignores blobs that are tiles when the explosion starts in the same tile
					if (hi.blob is this || hi.blob is hit_blob || !hi.blob.isCollidable() || mapPos == hi.blob.getPosition())
					{
						continue;
					}

                    CBlob@ b = hi.blob;
                    if (b.isPlatform())
                    {
                        ShapePlatformDirection@ plat = b.getShape().getPlatformDirection(0);
                        Vec2f dir = plat.direction;
                        if (!plat.ignore_rotations)
                        {
                            dir.RotateBy(b.getAngleDegrees());
                        }

                        // Does the platform block damage
                        Vec2f hitvec_dir = -hitvec;
                        if (hit_blob.isPlatform())
                        {
                            hitvec_dir = hitvec;
                        }

                        if(Maths::Abs(dir.AngleWith(hitvec_dir)) < plat.angleLimit)
                        {
                            return false;
                        }
                        continue;
                    }

					// only shield and heavy things block explosions
					if ((hi.blob.hasTag("heavy weight") ||
					        hi.blob.getMass() > 200 ||
							(hi.blob.getShape().isStatic() && (hi.blob.getShape().getConsts().collidable)))
							&& hi.blob.getPlayer() is null
						)
					{
						//print(""+hi.blob.getName()+" -- "+hit_blob.getName());
						return false;
					}
				}
			}
		}
	}
	
	f32 angle = (hit_blob.getPosition()-this.getPosition()).Angle();
	Vec2f dir = Vec2f(1, 0).RotateBy(-angle);
	Vec2f world_hitpos = hit_blob.getPosition()-dir*hit_blob.getRadius();

	//f32 scale;
	//Vec2f bombforce = hit_blob.hasTag("invincible") ? Vec2f_zero : getBombForce(this, radius, hit_blob_pos, pos, hit_blob.getMass(), scale);
	//f32 dam = damage * scale;

	//explosion particle
	makeSmallExplosionParticle(hit_blob_pos);

	//hit the object
	this.server_Hit(hit_blob, world_hitpos,
	                Vec2f(), damage,
	                hitter, hitter == Hitters::water || //hit with water
	                isOwnerBlob(this, hit_blob) ||	//allow selfkill with bombs
	                should_teamkill || hit_blob.hasTag("dead") || //hit all corpses ("dead" tag)
					hit_blob.hasTag("explosion always teamkill") || // check for override with tag
					(this.isInInventory() && this.getInventoryBlob() is hit_blob) //is the inventory container
	               );
	return true;
}
