#include "Hitters"
#include "HittersKIWI"
#include "ParticleSparks"
#include "CommonHitFXs"
#include "FleshHitFXs"
#include "SteelHitFXs"
#include "MakeBangEffect"
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
	
	
	
	bool metal_sound = false;
	bool doFXs = true;
	if (this.hasTag("steel"))
		metal_sound = true;
	f32 headshot = 1.5, sniper_headshot = 3;
	//headshots deal additional damage
	const Vec2f headPoint = this.getPosition() - Vec2f(0, this.getRadius()/2);
	const bool hitHead = (worldPoint - headPoint).Length() < this.getRadius();
	bool headshot_sound = false;
	bool headshot_FXs = false;
	
	if (hitHead && this.hasTag("flesh") && damage >= 1 && !(this.hasTag("bones") || this.hasTag("undead"))) {
		switch(customData)
		{
			case Hitters::arrow:
			case HittersKIWI::bullet_pistol:
			case HittersKIWI::bullet_hmg:
			{
				headshot_sound = true;
				headshot_FXs = true;
				damage *= headshot; break;
			}
			case HittersKIWI::bullet_rifle:
			{
				headshot_sound = true;
				headshot_FXs = true;
				damage *= sniper_headshot; break;
			}
		}
		if (this.hasTag("dead") || this.hasTag("undead"))
			headshot_sound = false;
		
		if(headshot_sound)
			this.getSprite().PlaySound(CFileMatcher("ManArg").getRandom(), 2, 1);
			//this.getSprite().PlaySound("ManArg"+(XORRandom(6)+1)+".ogg", 2, 1);
		
		if(headshot_FXs)
			MakeBangEffect(this, "blam", 1.0f, false, Vec2f((XORRandom(10)-5) * 0.1, -(3/2)), Vec2f(XORRandom(11)-5,-XORRandom(4)-1));
	}
	
	//no damage to drivers
	if (this.hasTag("isInVehicle") || this.hasTag("dummy") || this.hasTag("invincible")) {
		damage *= 0;
		if (this.hasTag("isInVehicle"))
			doFXs = false;
	}
	
	
	damage = Maths::Round(damage/1);
	//ONLY after all calculations we do FXs
	if (doFXs) {
		//print_damagelog(this, damage);
		if (damage > 0) {
			if (this.hasTag("flesh"))
				MakeFleshHitEffects(this, worldPoint, velocity, damage, hitterBlob, customData);
			switch (customData) {
				case Hitters::fire:
				case Hitters::burn:
					metal_sound = false;
			}
			if (metal_sound)
				playMetalSound(this);
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
	if (isServer()) {
		this.set_f32("synced_damage", 0);
		this.Sync("synced_damage", true);
	}
}