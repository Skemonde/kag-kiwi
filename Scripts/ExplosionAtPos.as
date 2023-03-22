#include "Explosion"

void ExplosionAtPos(
	Vec2f pos,
	CMap@ map,
	f32 radius,
	f32 damage,
	f32 map_damage_radius,
	f32 map_damage_ratio,
	bool map_damage_raycast,
	bool should_teamkill,
	CBlob@ attacker,
	u8 hitter = Hitters::explosion
) {
	Sound::Play("Bomb.ogg", pos);

	const int r = (radius * (2.0 / 3.0));

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
                            if (tile == CMap::tile_empty || isTileBGSteelBeam(tile))
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
                                if(map.getHitInfosFromRay(m_pos, v.Angle(), v.Length(), attacker, hitInfos))
                                {
                                    for (int i = 0; i < hitInfos.length; i++)
                                    {
                                        HitInfo@ hi = hitInfos[i];
                                        CBlob@ b = hi.blob;
                                        // m_pos == position ignores blobs that are tiles when the explosion starts in the same tile
                                        if (b !is null && b !is attacker && b.isCollidable() && b.getShape().isStatic() && m_pos != b.getPosition())
                                        {
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
								if (!map.isTileBedrock(tile))
								{
									int block_health = 10;
									if (map.isTileSolid(tile)) {
										block_health = 7;
									} else {
										block_health = 5;
									}
									int something = map_damage_radius/block_health;
									f32 damage = Maths::Ceil((map_damage_radius-dist)/something);
									if(map.isTileGround(tile))
										damage = 1;
									//print("damage no clamp " + (damage));
									//print("damage " + Maths::Clamp(damage, 1, block_health));
									for (int times_we_hit_block = 0;
										times_we_hit_block<Maths::Clamp(damage, 1, block_health);
										++times_we_hit_block) {
										if (tile != CMap::tile_ground_d0)
											map.server_DestroyTile(tpos, 1.0f);
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
			if (hit_blob is attacker)
				continue;

			HitBlob(attacker, m_pos, hit_blob, radius, damage*2, hitter, true, should_teamkill);
		}
	}
}