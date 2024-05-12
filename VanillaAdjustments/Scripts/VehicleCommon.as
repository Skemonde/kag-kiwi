#include "VehicleAttachmentCommon.as"
#include "KnockedCommon.as"

class AmmoInfo
{
	u8 loaded_ammo;             // next ammunition amount in queue to be shot
	string fire_sound;          // sound of a successful shoot
	string empty_sound;         // sound of an unsuccessful shoot
	string ammo_name;           // name of blob to be shot
	string ammo_inventory_name; // inventory name of blob to be shot
	string bullet_name;         // blob that will be shot
	bool infinite_ammo;         // no ammunition requirement if true
	u16 fire_delay;             // time it takes to shoot again in ticks
	u8 fire_amount;             // amount of entities created in one shot
	u8 fire_cost_per_amount;    // amount of ammunition spent to shoot one bullet
	Vec2f fire_offset;          // offset where blobs are shot from
	u16 ammo_stocked;           // amount of ammunition in stock
	u16 max_charge_time;        // time in ticks it takes to do full charge
}

class VehicleInfo
{
	f32 move_speed;             // base speed for horizontal movement
	f32 turn_speed;             // speed required to change facing direction (left/right)
	Vec2f out_vel;              // velocity at which players detach from the vehicle
	bool inventoryAccess;       // allow inventory access
	f32 fly_speed;              // base speed for vertical movement
	f32 fly_amount;             // variable speed for aerial vehicles
	string ground_sound;        // emit sound name of ground vehicles
	f32 ground_volume;          // emit sound volume of ground vehicles
	f32 ground_pitch;           // emit sound pitch of ground vehicles
	string water_sound;         // emit sound name of boats
	f32 water_volume;           // emit sound volume of boats
	f32 water_pitch;            // emit sound pitch of boats

	///WEAPON
	AmmoInfo[] ammo_types;      // array holding all our ammo info
	u8 current_ammo_index;      // index of the ammunition this is using right now
	u8 last_fired_index;        // index of the ammunition we fired previously with
	s32 fire_time;              // the next gametime we can shoot
	s32 network_fire_time;      // the next gametime we can shoot locally
	f32 wep_angle;              // variable angle of the vehicle's weapon
	u16 charge;                 // variable storing the current weapon charge
	u16 last_charge;            // variable storing the last fired weapon charge
	u16 cooldown_time;          // variable for cooldown after firing

	VehicleInfo(){}

	AmmoInfo@ getCurrentAmmo()
	{
		return ammo_types[current_ammo_index];
	}

	void SetFireDelay(const s32 &in shot_delay)
	{
		fire_time = (getGameTime() + shot_delay);
	}

	bool canFire()
	{
		return (getGameTime() > fire_time);
	}

	bool canFire(CBlob@ blob, AttachmentPoint@ ap)
	{
		// OVERLOAD ME
		return ap.isKeyPressed(key_action1);
	}

	void onFire(CBlob@ blob, CBlob@ bullet, const u16 &in fired_charge)
	{
		// OVERLOAD ME
	}
};

void Vehicle_Setup(CBlob@ this, const f32 &in move_speed, const f32 &in turn_speed = 0.31f, Vec2f &in out_vel = Vec2f_zero, const bool &in inventoryAccess = false,
                   VehicleInfo v = VehicleInfo())
{
	v.move_speed = move_speed;
	v.turn_speed = turn_speed;
	v.out_vel = out_vel;
	v.inventoryAccess = inventoryAccess;
	v.fire_time = 0;
	v.network_fire_time = 0;
	v.charge = 0;
	v.last_charge = 0;
	v.cooldown_time = 0;
	v.current_ammo_index = 0;
	v.last_fired_index = 0;
	v.wep_angle = 0.0f;

	this.addCommandID("fire");
	this.addCommandID("fire blob");
	this.addCommandID("flip_over");
	this.addCommandID("load_ammo");
	this.addCommandID("swap_ammo");
	this.addCommandID("recount ammo");
	this.Tag("vehicle");
	this.getShape().getConsts().collideWhenAttached = false;
	this.set("VehicleInfo", @v);
}

void Vehicle_AddAmmo(CBlob@ this, VehicleInfo@ v, const u16 &in fireDelay, const u8 &in fireAmount, const u8 &in fireCost,
                     const string &in ammoConfigName, const string &in ammoInvName, const string &in bulletConfigName,
                     const string &in fireSound, const string &in emptySound, Vec2f &in fireOffset = Vec2f_zero, const u16 &in chargeTime = 0)
{
	AmmoInfo a;
	a.loaded_ammo = 0;
	a.fire_sound = fireSound;
	a.empty_sound = emptySound;
	a.bullet_name = bulletConfigName;
	a.ammo_name = ammoConfigName;
	a.ammo_inventory_name = ammoInvName;
	a.fire_delay = fireDelay;
	a.fire_amount = fireAmount;
	a.fire_cost_per_amount = fireCost;
	a.max_charge_time = chargeTime;
	a.fire_offset = fireOffset;
	a.ammo_stocked = 0;
	a.infinite_ammo = getRules().hasTag("singleplayer");
	v.ammo_types.push_back(a);
}

void Vehicle_SetupAirship(CBlob@ this, VehicleInfo@ v, const f32 &in flySpeed)
{
	v.fly_speed = flySpeed;
	v.fly_amount = 0.25f;
	this.Tag("airship");
}

void Vehicle_SetupGroundSound(CBlob@ this, VehicleInfo@ v, const string &in movementSound, const f32 &in movementVolumeMod, const f32 &in movementPitchMod)
{
	v.ground_sound = movementSound;
	v.ground_volume = movementVolumeMod;
	v.ground_pitch = movementPitchMod;
	this.getSprite().SetEmitSoundPaused(true);
}

void Vehicle_SetupWaterSound(CBlob@ this, VehicleInfo@ v, const string &in movementSound, const f32 &in movementVolumeMod, const f32 &in movementPitchMod)
{
	v.water_sound = movementSound;
	v.water_volume = movementVolumeMod;
	v.water_pitch = movementPitchMod;
	this.getSprite().SetEmitSoundPaused(true);
}

void server_LoadAmmo(CBlob@ this, CBlob@ ammo, const u16 &in take, VehicleInfo@ v)
{
	const u16 amount = ammo.getQuantity();
	const u16 available = Maths::Clamp(take, 0, amount);
	v.getCurrentAmmo().loaded_ammo += available;
	ammo.server_SetQuantity(amount - available);

	RecountAmmo(this, v);
}

void RecountAmmo(CBlob@ this, VehicleInfo@ v)
{
	CInventory@ inv = this.getInventory();
	if (inv is null) return;

	for (int i = 0; i < v.ammo_types.size(); ++i)
	{
		AmmoInfo@ ammo = v.ammo_types[i];
		u16 ammoStocked = ammo.loaded_ammo;

		for (int i = 0; i < inv.getItemsCount(); i++)
		{
			CBlob@ item = inv.getItem(i);
			if (item.getName() != ammo.ammo_name) continue;

			ammoStocked += item.getQuantity();
		}

		ammo.ammo_stocked = ammoStocked;

		CBitStream params;
		params.write_u8(i);
		params.write_u16(ammo.ammo_stocked);
		params.write_u8(ammo.loaded_ammo);
		this.SendCommand(this.getCommandID("recount ammo"), params);
	}
}

void Vehicle_LoadAmmoIfEmpty(CBlob@ this, VehicleInfo@ v)
{
	if (!isServer()) return;

	AmmoInfo@ ammo = v.getCurrentAmmo();
	if (ammo.loaded_ammo > 0) return;

	CInventory@ inv = this.getInventory();
	if (inv is null) return;

	CBlob@ toLoad = inv.getItem(ammo.ammo_name);
	if (toLoad !is null)
	{
		server_LoadAmmo(this, toLoad, ammo.fire_amount * ammo.fire_cost_per_amount, v);
	}
	else if (ammo.infinite_ammo)
	{
		ammo.loaded_ammo += ammo.fire_amount * ammo.fire_cost_per_amount;
		RecountAmmo(this, v);
	}
}

bool Vehicle_AddFlipButton(CBlob@ this, CBlob@ caller, Vec2f &in offset = Vec2f(0, -4))
{
	if (isFlipped(this))
	{
		CButton@ button = caller.CreateGenericButton(12, offset, this, this.getCommandID("flip_over"), "Flip back");
		if (button !is null)
		{
			button.deleteAfterClick = false;
			return true;
		}
	}

	return false;
}

bool Vehicle_AddLoadAmmoButton(CBlob@ this, CBlob@ caller, Vec2f &in offset = Vec2f(0, -4))
{
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v)) return false;

	// find ammo in inventory
	CInventory@ inv = caller.getInventory();
	if (inv is null) return false;

	for (int i = 0; i < v.ammo_types.size(); i++)
	{
		const string ammo = v.ammo_types[i].ammo_name;
		CBlob@ ammoBlob = inv.getItem(ammo);

		if (ammoBlob is null)
		{
			CBlob@ carried = caller.getCarriedBlob();
			if (carried !is null && carried.getName() == ammo)
			{
				@ammoBlob = carried;
			}
		}

		if (ammoBlob !is null)
		{
			CBitStream params;
			params.write_netid(caller.getNetworkID());
			const string msg = getTranslatedString("Load {ITEM}").replace("{ITEM}", ammoBlob.getInventoryName());
			caller.CreateGenericButton("$" + ammoBlob.getName() + "$", offset, this, this.getCommandID("load_ammo"), msg, params);
			return true;
		}
	}

	return false;
}

void Fire(CBlob@ this, VehicleInfo@ v, CBlob@ caller, const u8 &in fired_charge)
{
	if (!v.canFire() || caller is null) return;

	AmmoInfo@ ammo = v.getCurrentAmmo();
	if (ammo.loaded_ammo > 0)
	{
		// shoot if ammo loaded
		if (isServer())
		{
			const f32 sign = this.isFacingLeft() ? 1.0f : -1.0f;
			Vec2f bulletPos = ammo.fire_offset;
			bulletPos.RotateBy(this.getAngleDegrees() * sign);
			bulletPos.x *= sign;
			bulletPos += this.getPosition();
			getMap().rayCastSolid(this.getPosition(), bulletPos, bulletPos); //don't clip through walls

			const int team = caller.getTeamNum();
			for (u8 i = 0; i < ammo.loaded_ammo; i += ammo.fire_cost_per_amount)
			{
				CBlob@ bullet = server_CreateBlobNoInit(ammo.bullet_name);
				if (bullet is null) continue;

				bullet.setPosition(bulletPos);
				bullet.server_setTeamNum(team);
				bullet.SetDamageOwnerPlayer(caller.getPlayer());
				bullet.Init();
				bullet.SetDamageOwnerPlayer(caller.getPlayer());
				server_FireBlob(this, bullet, fired_charge);
			}
		}
		this.getSprite().PlayRandomSound(ammo.fire_sound);
		v.last_fired_index = v.current_ammo_index;
		ammo.ammo_stocked -= ammo.loaded_ammo;
		ammo.loaded_ammo = 0;
	}
	else
	{
		// empty shot
		this.getSprite().PlayRandomSound(ammo.empty_sound);
	}

	// finally set the delay
	v.SetFireDelay(ammo.fire_delay);
}

void server_FireBlob(CBlob@ this, CBlob@ blob, const u8 &in charge)
{
	CBitStream params;
	params.write_netid(blob.getNetworkID());
	params.write_u8(charge);
	this.SendCommand(this.getCommandID("fire blob"), params);
}

void client_Fire(CBlob@ this, CBlob@ caller, const u8 &in charge)
{
	CBitStream params;
	params.write_netid(caller.getNetworkID());
	params.write_u8(charge);
	this.SendCommand(this.getCommandID("fire"), params);
}

void Vehicle_StandardControls(CBlob@ this, VehicleInfo@ v)
{
	if (!(isClient() && isServer()) && !this.hasTag("aerial") && !sv_test && getGameTime() < 60*30 && !this.hasTag("pass_60sec"))
	{
		return; // turn engines off!
	}
	bool hascrew = false;

	if (this.isOnGround() || this.wasOnGround())
	{
		this.AddForce(Vec2f(0.0f, this.getMass()*-0.25f)); // this is nice
	}

	//v.move_direction = 0;
	AttachmentPoint@[] aps;
	if (this.getAttachmentPoints(@aps))
	{
		for (uint i = 0; i < aps.length; i++)
		{
			AttachmentPoint@ ap = aps[i];
			CBlob@ blob = ap.getOccupied();

			if (blob !is null && ap.socket)
			{
				// GET OUT
				if (blob.isMyPlayer() && ap.isKeyJustPressed(key_up))
				{
					CBitStream params;
					params.write_u16(blob.getNetworkID());
					this.SendCommand(this.getCommandID("vehicle getout"), params);
					return;
				} // get out

				// DRIVER
				if (ap.name == "DRIVER" && !this.hasTag("immobile"))
				{
					hascrew = true;
					bool moveUp = false;
					const f32 angle = this.getAngleDegrees();
					// set facing
					blob.SetFacingLeft(this.isFacingLeft());
					bool left = ap.isKeyPressed(key_left);
					bool right = ap.isKeyPressed(key_right);
					bool space = ap.isKeyJustPressed(key_action3);
					const bool onground = this.isOnGround();
					const bool onwall = this.isOnWall();
					if (this.get_bool("engine_stuck"))
					{
						left = false;
						right = false;
					}

					// left / right
					if (angle < 80 || angle > 290)
					{
						f32 moveForce = v.move_speed/32;
						f32 turnSpeed = v.turn_speed/32;
						Vec2f groundNormal = this.getGroundNormal();

						Vec2f vel = this.getVelocity();
						Vec2f force;

						// more force when starting
						if (this.getShape().vellen < 1.75f)
						{
							moveForce *= 1.6f; // gear 1
						}

						CPlayer@ p = blob.getPlayer();
						//PerkStats@ stats;

						// operators are better drivers
						if (p !is null/*  && p.get("PerkStats", @stats) && stats.id == Perks::operator */)
						{
							// braking or reversing
							if ((this.isFacingLeft() && right) || (!this.isFacingLeft() && left))
							{
								moveForce *= 1.35f;
							}
							moveForce *= 1.45f - Maths::Clamp(vel.Length()*0.1f, 0.0f, 0.3f);
						}

						const f32 engine_topspeed = v.move_speed;
						const f32 engine_topspeed_reverse = v.turn_speed;

						moveForce *= Maths::Clamp(this.get_f32("engine_RPM"), 0, engine_topspeed) / 4500;
						bool slopeangle = (angle > 15 && angle < 345 && this.isOnMap());
						Vec2f pos = this.getPosition();

						if (!left && !right) //no input
						{
							this.set_f32("engine_throttle", Maths::Lerp(this.get_f32("engine_throttle"), 0.0f, 0.1f));

							// brake!
							this.getShape().setFriction(0.46);// todo: find a new way 
						}
						else{
							// release brakes
							this.getShape().setFriction(0.02);
						}
						
						moveForce = engine_topspeed;

						if (this.isFacingLeft())
						{
							if ((this.getShape().vellen > 1.0f || this.get_f32("engine_RPM") > 2550) && (this.getShape().getFriction() == 0.02f))
							{
								if (ap.isKeyPressed(key_action2))
								{
									this.add_f32("wheelsTurnAmount", (this.getVelocity().x >= 0 ? 1 : -1) * 1 * (this.get_f32("engine_RPM")- 1900)/30000);
								}	
								else
								{
									this.add_f32("wheelsTurnAmount", -1 * (this.get_f32("engine_RPM") - 1900)/30000);
								}
							}

							if (ap.isKeyJustPressed(key_left) && this.hasTag("tank"))
							{
								if (this.get_u32("next_engine_turnon") <= getGameTime())
								{
									//this.getSprite().PlayRandomSound("/EngineThrottle", 1.2f, 0.90f + XORRandom(11)*0.01f);
									this.set_u32("next_engine_turnon", getGameTime() + 40);
								}

								if (isClient())
								{	
									for(int i = 0; i < 9; ++i)
									{
										Vec2f velocity = Vec2f(7, 0);
										velocity *= this.isFacingLeft() ? 0.5 : -0.5;
										velocity += Vec2f(0, -0.15) + this.getVelocity()*0.35f;
										ParticleAnimated("Smoke", this.getPosition() + Vec2f_lengthdir(this.isFacingLeft() ? 35 : -35, this.getAngleDegrees()), velocity.RotateBy(this.getAngleDegrees()) + getRandomVelocity(0.0f, XORRandom(125) * 0.01f, 360), 45 + float(XORRandom(90)), 0.3f + XORRandom(50) * 0.01f, 1 + XORRandom(2), -0.02 - XORRandom(30) * -0.0005f, false );
									}
								}

								ShakeScreen(32.0f, 32, this.getPosition());
							}
							this.set_f32("engine_throttle", Maths::Lerp(this.get_f32("engine_throttle"), 0.5f, 0.9f));

							if (onground && groundNormal.y < -0.4f && groundNormal.x > 0.05f && vel.x < 1.0f && slopeangle)   // put more force when going up
							{
								force.x -= 4.5f * moveForce;
							}
							else
							{
								force.x -= moveForce;
							}


							if (ap.isKeyPressed(key_action2))
							{
								// reverse
								if (right)
								{
									this.set_f32("engine_RPM", Maths::Lerp(this.get_f32("engine_RPM"), 6200.0f, 0.001f));
									force.x *= 0.5f;
								}
							}
							else 
							{
								if (vel.x < -turnSpeed)
								{
									this.SetFacingLeft(true);
								}

								if (right && vel.x > turnSpeed && getGameTime() % 4 == 0)
								{
									this.SetFacingLeft(false);
								}
							}
						}

						if (!this.isFacingLeft())
						{ //spamable and has no effect

							if ((this.getShape().vellen > 1.0f || this.get_f32("engine_RPM") > 2550) && (this.getShape().getFriction() == 0.02f))
							{				
								if (ap.isKeyPressed(key_action2))
								{
									this.add_f32("wheelsTurnAmount", (this.getVelocity().x >= 0 ? -1 : 1) * -1 * (this.get_f32("engine_RPM")- 1900)/30000);
								}	
								else
								{
									this.add_f32("wheelsTurnAmount", 1 * (this.get_f32("engine_RPM")- 1900)/30000);
								}
							}

							if (ap.isKeyJustPressed(key_right) && this.hasTag("tank"))
							{
								if (this.get_u32("next_engine_turnon") <= getGameTime())
								{
									//this.getSprite().PlayRandomSound("/EngineThrottle", 1.2f, 0.90f + XORRandom(11)*0.01f);
									this.set_u32("next_engine_turnon", getGameTime() + 40);
								}

								if (isClient())
								{	
									for(int i = 0; i < 9; ++i)
									{
										Vec2f velocity = Vec2f(7, 0);
										velocity *= this.isFacingLeft() ? 0.5 : -0.5;
										velocity += Vec2f(0, -0.15) + this.getVelocity()*0.35f;
										ParticleAnimated("Smoke", this.getPosition() + Vec2f_lengthdir(this.isFacingLeft() ? 35 : -35, this.getAngleDegrees()), velocity.RotateBy(this.getAngleDegrees()) + getRandomVelocity(0.0f, XORRandom(125) * 0.01f, 360), 45 + float(XORRandom(90)), 0.3f + XORRandom(50) * 0.01f, 1 + XORRandom(2), -0.02 - XORRandom(30) * -0.0005f, false );
									}
								}

								ShakeScreen(32.0f, 32, this.getPosition());
							}
							this.set_f32("engine_throttle", Maths::Lerp(this.get_f32("engine_throttle"), 0.5f, 0.9f));

							
							
							if (onground && groundNormal.y < -0.4f && groundNormal.x < -0.05f && vel.x > -1.0f && slopeangle)   // put more force when going up
							{
								force.x += 4.5f * moveForce;
								
							}
							else
							{
								force.x += moveForce;
							}

							if (ap.isKeyPressed(key_action2))
							{
								if (left)
								{
									this.set_f32("engine_RPM", Maths::Lerp(this.get_f32("engine_RPM"), 6200.0f, 0.001f));
									force.x *= 0.5f;
								} // reverse
							}
							else
							{
								if (vel.x > turnSpeed)
								{
									this.SetFacingLeft(false);
								}

								if (left && vel.x < -turnSpeed && getGameTime() % 4 == 0)
								{
									this.SetFacingLeft(true);
								}
							}
						}

						bool faceleft = this.isFacingLeft();
						if (left)
							this.AddForce(force * (faceleft ? 1.0f : -1.0f));
						else if (right)
							this.AddForce(force * (faceleft ? -1.0f : 1.0f));
						force.RotateBy(this.getShape().getAngleDegrees());
					}
					
					// tilt 
					const bool down = ap.isKeyPressed(key_down);
					
					if (down && !this.hasTag("artillery"))
					{
						this.Tag("holding_down");
						
						f32 angle = this.getAngleDegrees();
						if (this.isOnGround())
						{
							f32 rotvel = 0;

							this.AddTorque(this.isFacingLeft() ? 275.0f : -275.0f);

							this.setAngleDegrees(this.getAngleDegrees() + rotvel);
						}
					}
					else{
						this.Untag("holding_down");
					}
					

					if (onground)
					{
						const bool faceleft = this.isFacingLeft();
						if (angle > 330 || angle < 30)
						{
							f32 wallMultiplier = (this.isOnWall() && (angle > 350 || angle < 10)) ? 4.0f : 1.0f;
							f32 torque = 420.0f * wallMultiplier;

							if (down)
							{
								f32 mod = 1.0f;
								if (isFlipped(this)) mod = 6.0f;
								{
									this.AddTorque(faceleft ? torque*mod : -torque*mod);
								}
							}

							this.AddForce(Vec2f(0.0f, -100.0f * wallMultiplier));
						}

						if (isFlipped(this) && this.hasTag("autoflip"))
						{
							f32 angle = this.getAngleDegrees();
							if (!left && !right)
								this.AddTorque(angle < 180 ? -1450 : 1450);
							else
								this.AddTorque(((faceleft && left) || (!faceleft && right)) ? 1500 : -1500);
							this.AddForce(Vec2f(0, this.getMass()*-0.6f));
						}
					}

					if (isFlipped(this))
					{
						this.set_f32("engine_RPMtarget", 1500);
					}
					else if (this.get_f32("engine_throttle") >= 0.5f) // make this an equation
					{
						this.set_f32("engine_RPMtarget", 8000); // gas gas gas
					}
					else
					{
						this.set_f32("engine_RPMtarget", 2000); // let engine idle
					}
					
				}  // driver

				if (ap.name == "GUNNER")
				{
					hascrew = true;
					// set facing
					blob.SetFacingLeft(this.isFacingLeft());

					if (blob.isMyPlayer())
					{
						if (ap.isKeyJustPressed(key_inventory) && v.charge == 0)
						{
							this.SendCommand(this.getCommandID("swap_ammo"));
						}

						if (this.hasTag("tank") && v.cooldown_time == 110)
						{
							Sound::Play("TankReload.ogg", this.getPosition(), 0.7f, 0.9f + (0.01f * XORRandom(30)));
						}
					}
/* 
					u8 style = v.getCurrentAmmo().fire_style;
					switch (style)
					{
						case Vehicle_Fire_Style::normal:
							//normal firing
							v.firing = false;
							if (ap.isKeyPressed(key_action1))
							{
								v.firing = true;
								if (canFire(this, v) && blob.isMyPlayer())
								{
									CBitStream fireParams;
									fireParams.write_u16(blob.getNetworkID());
									fireParams.write_u8(0);
									this.SendCommand(this.getCommandID("fire"), fireParams);
								}
							}
							break;

						case Vehicle_Fire_Style::custom:
							//custom firing requirements
						{
							u8 charge = 0;
							if (ap.isKeyPressed(key_action1))
							{
								v.firing = true;
								CBlob@ b = ap.getOccupied();
							}
							if (Vehicle_canFire(this, v, ap.isKeyPressed(key_action1), ap.isKeyPressed(key_action1), charge) && canFire(this, v) && (blob.isMyPlayer() || (isServer() && blob.isBot())))
							{
								Vec2f aimPos = ap.getAimPos();

								f32 bulletSpread = 35.0f;
								f32 angle;
								angle = getWeaponAngle(this, v);

								bool has_owner = false;
								AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("GUNNER");
								if (ap !is null && ap.getOccupied() !is null && ap.getOccupied().getPlayer() !is null)
									has_owner = true;

								// shoot machineguns
								if (this.hasTag("machinegun") && !this.hasTag("firethrower") && this.get_u32("no_more_proj") < getGameTime() && this.hasBlob("ammo", 1))
								{
									this.set_u32("no_more_proj", getGameTime()+v.getCurrentAmmo().fire_delay);

									angle += XORRandom(bulletSpread+1)/10-bulletSpread/25;
									f32 true_angle = this.isFacingLeft() ? -angle + 180 : angle;

									shootVehicleGun(has_owner ? ap.getOccupied().getNetworkID() : this.getNetworkID(), this.getNetworkID(),
										true_angle, this.getPosition()-Vec2f(0,2),
										aimPos, bulletSpread, 1, 3, 0.4f, 0.65f, 2,
											this.get_u8("TTL"), this.get_u8("speed"), this.get_s32("custom_hitter"));	
								}
								
								CBitStream fireParams;
								fireParams.write_u16(blob.getNetworkID());
								fireParams.write_u8(charge);
								this.SendCommand(this.getCommandID("fire"), fireParams);
							}
						}

						break;
					} */

				} // gunner

				// ROWER
				if ((ap.name == "ROWER" && this.isInWater()) || (ap.name == "SAIL" && !this.hasTag("no sail")))
				{
					hascrew = true;
					const f32 moveForce = v.move_speed;
					const f32 turnSpeed = v.turn_speed;
					Vec2f force;
					bool moving = false;
					const bool left = ap.isKeyPressed(key_left);
					const bool right = ap.isKeyPressed(key_right);
					const Vec2f vel = this.getVelocity();
					bool backwards = false;

					bool a1 = false;
					bool a2 = false;

					//CBlob@ rower = ap.getOccupied();
					//if (rower !is null)
					{
						a1 = ap.isKeyPressed(key_action1);
						a2 = ap.isKeyPressed(key_action2);
					}

					// row left/right

					if (left)
					{
						force.x -= moveForce;

						if (vel.x < -turnSpeed && !a2)
						{
							this.SetFacingLeft(true);
						}
						else if (!a2)
						{
							backwards = true;
						}

						moving = true;
					}

					if (right)
					{
						force.x += moveForce;

						if (vel.x > turnSpeed && !a2)
						{
							this.SetFacingLeft(false);
						}
						else if (!a2)
						{
							backwards = true;
						}

						moving = true;
					}

					if (moving)
					{
						this.AddForce(force);
					}
				}
			}
		}
	}

	if (this.hasTag("airship"))
	{
		f32 flyForce = v.fly_speed;
		f32 flyAmount = v.fly_amount;
		this.AddForce(Vec2f(0, flyForce * flyAmount));
	}

	if (!hascrew)
	{
		this.set_f32("engine_RPMtarget", 0); // shut off the engine (longer idle time?)
	}
}

void Vehicle_DriverControls(CBlob@ this, CBlob@ blob, AttachmentPoint@ ap, VehicleInfo@ v)
{
	bool moveUp = false;
	const f32 angle = this.getAngleDegrees();
	const bool left = ap.isKeyPressed(key_left);
	const bool right = ap.isKeyPressed(key_right);
	const bool onground = this.isOnGround();
	const bool onwall = this.isOnWall();
	const bool no_turning = ap.isKeyPressed(key_action2);
	
	if ((left || right) && onwall)
		this.getShape().checkCollisionsAgain = true;
		
	if (onground && ap.isKeyPressed(key_down) && left && right) {
		//this.AddForce(Vec2f(0, this.getMass()*-3).RotateBy(angle));
	}
	
	// left / right
	if (angle < 80 || angle > 290)
	{
		f32 moveForce = v.move_speed;
		const f32 turnSpeed = v.turn_speed;
		const bool slopeangle = (angle > 15 && angle < 345);
		Vec2f groundNormal = this.getGroundNormal();
		Vec2f pos = this.getPosition();
		Vec2f vel = this.getVelocity();
		Vec2f force;

		// more force when starting
		if (this.getShape().vellen < 0.1f)
		{
			moveForce *= 10.0f;
		}

		if (left)
		{
			if (onground && groundNormal.y < -0.4f && groundNormal.x > 0.05f && vel.x < 1.0f && slopeangle)
			{
				force.x -= 6.0f * moveForce;  // put more force when going up
			}
			else
			{
				force.x -= moveForce;
			}

			if (vel.x < -turnSpeed && !no_turning)
			{
				this.SetFacingLeft(true);
			}
			moveUp = onwall;
		}

		if (right)
		{
			if (onground && groundNormal.y < -0.4f && groundNormal.x < -0.05f && vel.x > -1.0f && slopeangle)
			{
				force.x += 6.0f * moveForce;  // put more force when going up
			}
			else
			{
				force.x += moveForce;
			}

			if (vel.x > turnSpeed && !no_turning)
			{
				this.SetFacingLeft(false);
			}
			moveUp = onwall;
		}

		force.RotateBy(this.getAngleDegrees());

		if ((onwall /*|| (angle < 351 && angle > 9)*/) && (right || left))
		{
			Vec2f end;
			Vec2f forceoffset(this.getRadius() * (this.isFacingLeft() ? 1 : -1) * 0.5f, 0.0f);
			Vec2f forcepos = pos + forceoffset;
			const bool rearHasGround = getMap().rayCastSolid(pos, forcepos + Vec2f(0.0f, getMap().tilesize * 3.0f), end);
			if (rearHasGround)
			{
				this.AddForceAtPosition(Vec2f(0.0f, -290.0f), pos + Vec2f(-forceoffset.x, forceoffset.y) * 0.2f);
			}
		}

		this.AddForce(force);
	}
	else if (left || right)
	{
		moveUp = true;
	}

	// climb uphills

	const bool down = ap.isKeyPressed(key_down) || ap.isKeyPressed(key_action3);
	if (onground && (down || moveUp))
	{
		const bool faceleft = this.isFacingLeft();
		if (angle > 330 || angle < 30)
		{
			const f32 wallMultiplier = (onwall && (angle > 350 || angle < 10)) ? 1.5f : 1.0f;
			const f32 torque = 150.0f * wallMultiplier;
			if (down)
				this.AddTorque(faceleft ? torque : -torque);
			else
				this.AddTorque(((faceleft && left) || (!faceleft && right)) ? torque : -torque);
			this.AddForce(Vec2f(0.0f, -200.0f * wallMultiplier));
		}

		if (isFlipped(this))
		{
			if (!left && !right)
				this.AddTorque(angle < 180 ? -500 : 500);
			else
				this.AddTorque(((faceleft && left) || (!faceleft && right)) ? 500 : -500);
			this.AddForce(Vec2f(0, -400));
		}
	}
}

void Vehicle_GunnerControls(CBlob@ this, CBlob@ blob, AttachmentPoint@ ap, VehicleInfo@ v)
{
	if (blob.isMyPlayer() && ap.isKeyJustPressed(key_inventory) && v.ammo_types.size() > 1 && v.charge == 0)
	{
		this.SendCommand(this.getCommandID("swap_ammo"));
	}

	const bool canFireLocally = blob.isMyPlayer() && v.canFire() && getGameTime() > v.network_fire_time;
	if (v.canFire(this, ap) && canFireLocally)
	{
		v.network_fire_time = getGameTime() + v.getCurrentAmmo().fire_delay;
		client_Fire(this, blob, v.charge);
	}
}

void Vehicle_FlyerControls(CBlob@ this, CBlob@ blob, AttachmentPoint@ ap, VehicleInfo@ v)
{
	const f32 moveForce = v.move_speed;
	const f32 turnSpeed = v.turn_speed;
	const Vec2f vel = this.getVelocity();
	f32 flyAmount = v.fly_amount;
	Vec2f force;

	// fly up/down
	const bool up = ap.isKeyPressed(key_action1);
	const bool down = ap.isKeyPressed(key_action2) || ap.isKeyPressed(key_down);
	if (up || down)
	{
		if (up)
		{
			flyAmount = Maths::Min(flyAmount + 0.3f / getTicksASecond(), 1.0f);
		}
		else
		{
			flyAmount = Maths::Max(flyAmount - 0.3f / getTicksASecond(), 0.5f);
		}
		v.fly_amount = flyAmount;
	}

	// fly left/right
	const bool left = ap.isKeyPressed(key_left);
	const bool right = ap.isKeyPressed(key_right);
	if (left)
	{
		force.x -= moveForce;
		if (vel.x < -turnSpeed)
		{
			this.SetFacingLeft(true);
		}
	}

	if (right)
	{
		force.x += moveForce;
		if (vel.x > turnSpeed)
		{
			this.SetFacingLeft(false);
		}
	}

	if (left || right)
	{
		this.AddForce(force);
	}
}

void Vehicle_RowerControls(CBlob@ this, CBlob@ blob, AttachmentPoint@ ap, VehicleInfo@ v)
{
	const f32 moveForce = v.move_speed;
	const f32 turnSpeed = v.turn_speed;
	const Vec2f vel = this.getVelocity();
	Vec2f force;

	// row left/right
	const bool left = ap.isKeyPressed(key_left);
	const bool right = ap.isKeyPressed(key_right);
	if (left)
	{
		force.x -= moveForce;
		if (vel.x < -turnSpeed)
		{
			this.SetFacingLeft(true);
		}
	}

	if (right)
	{
		force.x += moveForce;
		if (vel.x > turnSpeed)
		{
			this.SetFacingLeft(false);
		}
	}

	if (left || right)
	{
		this.AddForce(force);
	}
}

CSpriteLayer@ Vehicle_addWheel(CBlob@ this, VehicleInfo@ v, const string &in textureName, const int &in frameWidth, const int &in frameHeight,
                               const int &in frame, Vec2f &in offset, const f32 relativeZ = 0.1f)
{
	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ wheel = sprite.addSpriteLayer("!w " + sprite.getSpriteLayerCount(), textureName, frameWidth, frameHeight);
	if (wheel !is null)
	{
		Animation@ anim = wheel.addAnimation("default", 0, false);
		anim.AddFrame(frame);
		wheel.SetOffset(offset);
		wheel.SetRelativeZ(relativeZ);
	}

	return wheel;
}

CSpriteLayer@ Vehicle_addWoodenWheel(CBlob@ this, VehicleInfo@ v, const int &in frame, Vec2f &in offset, const f32 relativeZ = 0.1f)
{
	return Vehicle_addWheel(this, v, "Entities/Vehicles/Common/WoodenWheels.png", 16, 16, frame, offset, relativeZ);
}

void UpdateWheels(CSprite@ sprite)
{
	//rotate wheels
	const uint sprites = sprite.getSpriteLayerCount();
	for (uint i = 0; i < sprites; i++)
	{
		CSpriteLayer@ wheel = sprite.getSpriteLayer(i);
		if (wheel.name.substr(0, 2) == "!w") // this is a wheel
		{
			const f32 wheels_angle = (Maths::Round(wheel.getWorldTranslation().x * 10) % 360) / 1.0f;
			wheel.ResetTransform();
			wheel.RotateBy(wheels_angle + i * i * 16.0f, Vec2f_zero);
		}
	}
}

void Vehicle_DontRotateInWater(CBlob@ this)
{
	if (getMap().isInWater(this.getPosition() + Vec2f(0.0f, this.getHeight() * 0.5f)))
	{
		const f32 thresh = 15.0f;
		const f32 angle = this.getAngleDegrees();
		if ((angle < thresh || angle > 360.0f - thresh) && !this.hasTag("sinking"))
		{
			this.setAngleDegrees(0.0f);
			this.getShape().SetRotationsAllowed(false);
			return;
		}
	}

	this.getShape().SetRotationsAllowed(true);
}

bool Vehicle_doesCollideWithBlob_ground(CBlob@ this, CBlob@ blob)
{
	if (!blob.isCollidable() || blob.isAttached()) // no colliding against people inside vehicles
		return false;
	if (blob.getRadius() > this.getRadius() ||
	        (blob.getTeamNum() != this.getTeamNum() && blob.hasTag("player") && this.getShape().vellen > 1.0f) ||
	        (blob.getShape().isStatic()) || blob.hasTag("projectile"))
	{
		return true;
	}
	return false;
}

bool Vehicle_doesCollideWithBlob_boat(CBlob@ this, CBlob@ blob)
{
	if (!blob.isCollidable() || blob.isAttached()) // no colliding against people inside vehicles
		return false;
	// no colliding with shit underwater
	if (blob.hasTag("material") || (blob.isInWater() && (blob.getName() == "heart" || blob.getName() == "log" || blob.hasTag("dead"))))
		return false;

	return true;
	//return ((!blob.hasTag("vehicle") || this.getTeamNum() != blob.getTeamNum())); // don't collide with team boats (other vehicles will attach)
}

bool isFlipped(CBlob@ this)
{
	const f32 angle = this.getAngleDegrees();
	return (angle > 80 && angle < 290);
}
