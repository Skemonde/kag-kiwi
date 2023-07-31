#include "Hitters"
#include "HittersKIWI"
#include "ParticleSparks"
#include "CommonHitFXs"
#include "FleshHitFXs"
#include "StoneHitFXs"
#include "SteelHitFXs"
#include "Logging"

//unlike SteelHit, StoneHit and WoodenHit this script actually deals the damage to a blob after those scripts have calculated the damage amount
//add this at the very end of blob config so it dies properly after SteelHit or other hitting scripts

f32 getGibHealth(CBlob@ this)
{
	if (this.exists("gib health"))
	{
		return this.get_f32("gib health");
	}

	return 0.0f;
}

void onInit(CBlob@ this)
{
	this.set_u16("endured_damage", 0);
}

void onTick(CBlob@ this)
{
	this.Sync("endured_damage", true);
	int endured_damage = this.get_u16("endured_damage");
	
	if (getGameTime()-this.get_u32("last_hit") > 1 && endured_damage != 0 && endured_damage < 10) {
		//print("end damage " + endured_damage);
		makeDamageIndicator(this,endured_damage);
	}
}

void onDie(CBlob@ this)
{
	int endured_damage = this.get_u16("endured_damage");
	//print("death damage " + endured_damage);
	
	if (endured_damage != 0 && endured_damage < 10) {
		makeDamageIndicator(this,endured_damage);
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	//shittest thing i've ever done about syncing
	if (isServer()) {
		this.set_f32("synced_damage", damage);
		this.Sync("synced_damage", true);
	} else if (isClient()) {
		damage = this.get_f32("synced_damage");
	}
	
	switch (customData)
	{
		case Hitters::suicide:
			if (this.hasTag("no suicide")) break;
			this.server_Die();
			this.getSprite().Gib();
			this.Tag("do gib");
			print("suicided! HA");
			return 0;
	}
	
	bool metal_hit_fx = false;
	bool doFXs = true;
	if (this.hasTag("steel")) {
		metal_hit_fx = true;
	}
	
	//no damage to drivers
	if (this.hasTag("isInVehicle") || this.hasTag("dummy") || this.hasTag("invincible")) {
		damage *= 0;
		if (this.hasTag("isInVehicle") || this.hasTag("dummy"))
			doFXs = false;
	}
	
	//ONLY after all calculations we do FXs
	if (doFXs) {
		//print_damagelog(this, damage);
		if (damage > 0) {
			if (this.hasTag("flesh")) {
				MakeFleshHitEffects(this, worldPoint, velocity, damage, hitterBlob, customData);
				makeFleshGib(this.getPosition(), worldPoint, damage);
			}
			if (this.hasTag("stone"))
				makeStoneGib(this.getPosition(), worldPoint, damage);
			switch (customData) {
				case Hitters::fire:
				case Hitters::burn:
					metal_hit_fx = false;
			}
			if (metal_hit_fx) {
				playMetalSound(this);
				makeSteelGib(this.getPosition(), worldPoint, damage);
			}
		} else {
			shieldHit(damage, this.getVelocity(), worldPoint);
		}
	}
	
	int endured_damage = this.get_u16("endured_damage");
	if (getGameTime()-this.get_u32("last_hit") > 1 && endured_damage != 0 && endured_damage < 10) {
		makeDamageIndicator(this,endured_damage);
	}else
		this.add_u16("endured_damage", damage);
	
	this.set_Vec2f("hitpoint", worldPoint);
	this.set_u32("last_hit", getGameTime());
	
	this.Damage(damage, hitterBlob);
	
	// gib if health below gibHealth
	f32 gibHealth = getGibHealth(this);
	// kill the blob if it should
	if (this.getHealth() <= gibHealth)
	{
		this.getSprite().Gib();
		this.server_Die();
	}
	
	return 0;
}