// Princess brain

#include "Hitters.as";
#include "HittersKIWI.as";
#include "Explosion.as";
#include "FireParticle.as"
#include "FireCommon.as";
#include "RunnerCommon.as";
#include "ThrowCommon.as";
#include "KnightCommon.as";
#include "ShieldCommon.as";
#include "Knocked.as"
#include "Help.as";
#include "Requirements.as"
#include "ParticleSparks.as";

void knight_actorlimit_setup(CBlob@ this)
{
	u16[] networkIDs;
	this.set("LimitedActors", networkIDs);
}

bool knight_has_hit_actor(CBlob@ this, CBlob@ actor)
{
	u16[]@ networkIDs;
	this.get("LimitedActors", @networkIDs);
	return networkIDs.find(actor.getNetworkID()) >= 0;
}

u32 knight_hit_actor_count(CBlob@ this)
{
	u16[]@ networkIDs;
	this.get("LimitedActors", @networkIDs);
	return networkIDs.length;
}

void knight_add_actor_limit(CBlob@ this, CBlob@ actor)
{
	this.push("LimitedActors", actor.getNetworkID());
}

void knight_clear_actor_limits(CBlob@ this)
{
	this.clear("LimitedActors");
}

void onInit(CBlob@ this)
{
	KnightInfo knight;
	knight.state = KnightStates::normal;
	knight.swordTimer = 0;
	knight.slideTime = 0;
	knight.doubleslash = false;
	knight.tileDestructionLimiter = 0;
	this.set("knightInfo", @knight);

	CSprite@ sprite = this.getSprite();

	this.Tag("player");
	this.Tag("flesh");
	this.Tag("human");
	
	u8 type = XORRandom(2);
	switch (type)
	{
		case 0: this.Tag("grunt"); break;
		case 1: this.Tag("commander"); break;
	}
	
	this.push("names to activate", "keg");
	
	this.getCurrentScript().tickFrequency = 1;

	this.getShape().SetRotationsAllowed(false);
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;
	this.set_Vec2f("inventory offset", Vec2f(0.0f, 0.0f));
	this.set_f32("gib health", -1.5f);

	this.getCurrentScript().runFlags |= Script::tick_not_attached;

	this.SetLight(false);
	this.SetLightRadius(64.0f);
	this.SetLightColor(SColor(255, 10, 250, 200));

	this.set_u32("timer", 0);
	
	/*
	if (this.getTeamNum() > 6 && this.getTeamNum() != 250)
	{
		if (isClient())
			{
				ShakeScreen(48.0f, 32.0f, this.getPosition());
			
				this.getSprite().PlaySound("Gore.ogg", 2.00f, 1.00f);
				
				Explode(this, 32.0f, 0.2f);
				this.getSprite().Gib();
				
				ParticleBloodSplat(this.getPosition(), true);
			}
			
			if (isServer())
			{
				this.server_Die();
			}
	}
	else
	{
		if (isServer())
		{		
			string gun_config;
			string ammo_config;
	
			gun_config = "carbine";
			ammo_config = "mat_rifleammo";
	
			for (int i = 0; i < 2; i++)
			{
				CBlob@ ammo = server_CreateBlob(ammo_config, this.getTeamNum(), this.getPosition());
				ammo.server_SetQuantity(150);
				this.server_PutInInventory(ammo);
			}
	
			CBlob@ gun = server_CreateBlob(gun_config, this.getTeamNum(), this.getPosition());
			if(gun !is null)
			{
				this.server_Pickup(gun);
	
				if (gun.hasCommandID("cmd_gunReload"))
				{
					CBitStream stream;
					gun.SendCommand(gun.getCommandID("cmd_gunReload"), stream);
				}
			}
		}
	}
	*/
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null) player.SetScoreboardVars("ScoreboardIcons.png", 15, Vec2f(16, 16));
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return this.hasTag("dead");
}

void onTick(CBlob@ this)
{
	if (this.get_u32("timer") > 1) this.set_u32("timer", this.get_u32("timer") - 1);

	RunnerMoveVars@ moveVars;
	if (!this.get("moveVars", @moveVars))
	{
		return;
	}

	if (this.hasTag("glued") && this.get_u32("timer") > 1)
	{
		moveVars.walkFactor *= 0.4f;
		moveVars.jumpFactor *= 0.5f;
	}

	u8 knocked = getKnocked(this);
	
	if (this.isInInventory())
		return;

	if (!this.get("moveVars", @moveVars))
	{
		return;
	}

	Vec2f pos = this.getPosition();
	Vec2f aimpos = this.getAimPos();
	const bool inair = (!this.isOnGround() && !this.isOnLadder());

	CMap@ map = getMap();

	bool pressed_a1 = this.isKeyPressed(key_action1) && !this.hasTag("noLMB");
	bool pressed_a2 = this.isKeyPressed(key_action2);
	bool walking = (this.isKeyPressed(key_left) || this.isKeyPressed(key_right));

	const bool myplayer = this.isMyPlayer();

	if (myplayer)
	{
		if (this.isKeyJustPressed(key_action3))
		{
			client_SendThrowOrActivateCommand(this);
		}
	}

	moveVars.walkFactor *= 1.000f;
	moveVars.jumpFactor *= 1.150f;

	if (knocked > 0)
	{
		pressed_a1 = false;
		pressed_a2 = false;
		walking = false;
		
		return;
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	CPlayer@ player = this.getPlayer();

	if (this.hasTag("invincible") || (player !is null && player.freeze)) 
	{
		return 0;
	}

	switch (customData)
	{
		case Hitters::suicide:
			damage *= 10.000f;
			break;
			
		case HittersKIWI::boom:
			damage *= 1.000f;
			break;
			
		default:
			damage *= 1.000f;
			break;
	}

	return damage;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return this.getTeamNum() != blob.getTeamNum();
}

void onDie(CBlob@ this)
{
	//if (isServer()) server_CreateBlob("suitofarmor", this.getTeamNum(), this.getPosition());
}