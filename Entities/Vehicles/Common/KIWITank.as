#include "Knocked"
#include "KIWI_Hitters"
#include "MakeBangEffect"

void onInit(CBlob@ this)
{
	setKnockable(this);
}

void onTick(CBlob@ this)
{
	KIWITankControls(this);
	ManageSounds(this);
	DoKnockedUpdate(this);
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{	
	switch (customData)
	{
		case HittersKIWI::anti_tank_rifle:
			if (isKnockable(this)&&damage>0) {
				SetKnocked(this, getTicksASecond()*6);
				if (isClient()) {
					MakeBangEffect(this, "stun", 2.0f, false, Vec2f((XORRandom(10)-5) * 0.1, -(3/2)), -this.getPosition()+worldPoint);
				}
			}
			break;

		default:
			damage *= 1;
	}
	return damage;
}

void ManageSounds(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	// movement sounds
	const f32 velx = Maths::Abs(this.getVelocity().x);
	if (velx < 0.02f || (!this.isOnGround()/*  && !this.isInWater() */))
	{
		const f32 vol = sprite.getEmitSoundVolume();
		sprite.SetEmitSoundVolume(vol * 0.9f);
		if (vol < 0.1f)
		{
			sprite.SetEmitSoundPaused(true);
			sprite.SetEmitSoundVolume(1.0f);
		}
	}
	else
	{
		string emitSound = "";
		f32 volMod = 0;
		f32 pitchMod = 0;
		if (this.isOnGround())
		{
			emitSound = this.get_string("movement_sound");
			volMod = 2;
			pitchMod = 1.4;
		}
		else if (!this.isOnGround())
		{
			emitSound = this.get_string("movement_sound");
			volMod = 2;
			pitchMod =  0;
		}

		if (sprite.getEmitSoundPaused() && !emitSound.isEmpty())
		{
			sprite.SetEmitSound(emitSound);
			sprite.SetEmitSoundPaused(false);
		}

		if (volMod > 0.0f)
		{
			sprite.SetEmitSoundVolume(Maths::Min(velx * 0.565f * volMod, 1.0f));
		}

		if (pitchMod > 0.0f)
		{
			sprite.SetEmitSoundSpeed(Maths::Max(Maths::Min(Maths::Sqrt(0.5f * velx * pitchMod), 1.5f), 0.75f));
		}
	}
}

bool isFlipped(CBlob@ this)
{
	const f32 angle = this.getAngleDegrees();
	return (angle > 80 && angle < 290);
	return false;
}

void onChangeTeam( CBlob@ this, const int oldTeam )
{
	if (this.hasAttached())
	{
		AttachmentPoint@[] aps;
		if (this.getAttachmentPoints(@aps))
		{
			for (uint i = 0; i < aps.length; i++)
			{
				AttachmentPoint@ ap = aps[i];
				if (ap.socket && ap.getOccupied() !is null)
				{
					ap.getOccupied().server_setTeamNum(this.getTeamNum());
				}
			}
		}
	}
}

void KIWITankControls(CBlob@ this)
{
	//if (!(isClient() && isServer()) && !this.hasTag("aerial") && !sv_test && getGameTime() < 60*30 && !this.hasTag("pass_60sec"))
	if (isKnocked(this))
	{
		return; // turn engines off!
	}
	bool hascrew = false;

	if (this.isOnGround() || this.wasOnGround())
	{
		this.AddForce(Vec2f(0.0f, this.getMass()*-0.25f)); // this is nice
	}
	
	f32 min_move_factor_speed = 0.5f;
	f32 MOVE_FACTOR = this.getVelocity().x>min_move_factor_speed?1:(this.getVelocity().x<-min_move_factor_speed?-1:0);
	
	f32 move_speed = this.get_f32("move_speed");
	f32 turn_speed = this.get_f32("turn_speed");

	AttachmentPoint@[] aps;
	if (!this.getAttachmentPoints(@aps)) return;
	
	for (uint i = 0; i < aps.length; i++)
	{
		AttachmentPoint@ ap = aps[i];
		CBlob@ blob = ap.getOccupied();

		if (blob is null || !ap.socket) return;
		
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
				f32 moveForce = move_speed/32;
				f32 turnSpeed = turn_speed/32;
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

				const f32 engine_topspeed = move_speed;
				const f32 engine_topspeed_reverse = turn_speed;

				moveForce *= Maths::Clamp(this.get_f32("engine_RPM"), 0, engine_topspeed) / 4500;
				bool slopeangle = (angle > 15 && angle < 345 && this.isOnMap());
				Vec2f pos = this.getPosition();

				if (!left && !right) //no input
				{
					this.set_f32("engine_throttle", Maths::Lerp(this.get_f32("engine_throttle"), 0.0f, 0.1f));

					// brake!
					this.getShape().setFriction(0.86);// todo: find a new way 
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
							this.AddTorque(-torque*mod*MOVE_FACTOR);
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
			
			Vec2f vel = this.getOldVelocity();
			//if (Maths::Abs(vel.x)>1)
			//	this.setVelocity(Vec2f(Maths::Round(vel.x), vel.y));
		}  // driver
	}

	if (!hascrew)
	{
		this.set_f32("engine_RPMtarget", 0); // shut off the engine (longer idle time?)
	}
}