// Princess brain

#include "Hitters"
#include "Explosion"
#include "FireParticle"
#include "FireCommon"
#include "RunnerCommon"
#include "ThrowCommon"
#include "Gunlist"

void onInit(CBlob@ this)
{
	this.set_u32("nextAttack", 0);
	this.set_u32("nextBomb", 0);

	this.set_f32("minDistance", 32);
	this.set_f32("chaseDistance", 200);
	this.set_f32("maxDistance", 400);

	this.set_f32("inaccuracy", 0.01f);
	this.set_u8("reactionTime", 15);
	this.set_u8("attackDelay", 0);
	this.set_bool("bomber", true);
	this.set_bool("raider", true);

	this.SetDamageOwnerPlayer(null);

	this.Tag("can open door");
	this.Tag("combat chicken");
	this.Tag("npc");
	this.Tag("flesh");
	this.Tag("player");
	this.Tag("bot");

	this.getCurrentScript().tickFrequency = 1;

	this.set_f32("voice pitch", 1.50f);
	this.getSprite().addSpriteLayer("isOnScreen","NoTexture.png",1,1);
	if (isServer())
	{
		this.set_u16("stolen coins", 250);

		this.server_setTeamNum(250);

		string gun_config;
		string ammo_config;

		u8 gunid = XORRandom(4)+4;
		if (this.exists("customData"))
			gunid = Maths::Clamp(this.get_u32("customData"), 0, 4)+4;
		gun_config = gunids[gunid];

		this.set_f32("minDistance", 192);
		this.set_f32("maxDistance", 640);
		this.set_f32("inaccuracy", 0.025f);
		this.set_bool("bomber", true);

		// gun and ammo
		if (!ammo_config.empty()) {
			CBlob@ ammo = server_CreateBlob(ammo_config, this.getTeamNum(), this.getPosition());
			ammo.server_SetQuantity(ammo.maxQuantity * 2);
			this.server_PutInInventory(ammo);
		}

		CBlob@ gun = server_CreateBlob(gun_config, this.getTeamNum(), this.getPosition());
		if (gun !is null)
		{
			this.server_Pickup(gun);
			
			if (gun.hasCommandID("reload"))
			{
				CBitStream stream;
				gun.SendCommand(gun.getCommandID("reload"), stream);
			}
		}
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return this.hasTag("dead");
}

void onTick(CBlob@ this)
{
	/* if (this.getName() == "soldierchicken")
	{
		if (this.getCarriedBlob() !is null && this !is null && this.getPlayer() is null) this.getCarriedBlob().Tag("fakeweapon");
	} */
	
	//this.getSprite().ReloadSprite("HeavyChicken.png", 128, 64);
	//this.getSprite().SetTexture("HeavyChicken.png");

	/* CBlob@[] fakeweapons;
	getBlobsByTag("fakeweapon", fakeweapons);

	for (int i = 0; i < fakeweapons.length; i++)
	{
		if (!fakeweapons[i].isAttached() && fakeweapons[i] !is null) fakeweapons[i].server_Die();
	} */

	RunnerMoveVars@ moveVars;
	if (this.get("moveVars", @moveVars))
	{
		moveVars.walkFactor *= 1.10f;
		moveVars.jumpFactor *= 1.30f;
	}

	if (this.getHealth() < 3.0 && this.hasTag("dead"))
	{
		this.getSprite().PlaySound("Wilhelm.ogg", 1.8f, 1.8f);

		if (isServer())
		{
			this.server_SetPlayer(null);
			//server_DropCoins(this.getPosition(), Maths::Max(0, Maths::Min(this.get_u16("stolen coins"), 5000)));
			CBlob@ carried = this.getCarriedBlob();

			if (carried !is null)
			{
				carried.server_DetachFrom(this);
			}
			//this.server_SetHealth(20.0f);
		}

		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}

	if (isClient())
	{
		if (getGameTime() > this.get_u32("next sound") && XORRandom(100) < 5)
		{
			// this.getSprite().PlaySound("scoutchicken_vo_perish.ogg", 0.8f, 1.5f);
			this.set_u32("next sound", getGameTime() + 100);
		}
	}
	
	if (this.isMyPlayer())
	{
		if (this.isKeyJustPressed(key_action3))
		{
			client_SendThrowOrActivateCommand(this);
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (isClient())
	{
		if (getGameTime() > this.get_u32("next sound") - 50)
		{
			this.getSprite().PlaySound("scoutchicken_vo_hit" + (1 + XORRandom(3)) + ".ogg", 1, 0.8f);
			this.set_u32("next sound", getGameTime() + 60);
		}
	}

	if (customData == Hitters::explosion) return damage * 0.175f;

	return damage;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if (this.getPlayer() is null)
		return this.getTeamNum() != blob.getTeamNum();
	else return true;
}