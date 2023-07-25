#include "Hitters"
#include "HittersKIWI"
#include "ParticleSparks"
#include "CommonHitFXs"
#include "FleshHitFXs"
#include "StoneHitFXs"
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
		if (gunfireHitter(customData))
			damage *= 0.1f;
	}
	f32 headshot = 1.5, sniper_headshot = 3;
	//headshots deal additional damage
	const Vec2f headPoint = this.getPosition() - Vec2f(0, this.getRadius()/2);
	const bool hitHead = (worldPoint - headPoint).Length() < this.getRadius();
	bool headshot_sound = false;
	bool headshot_FXs = false;
	
	//headshot logic
	bool get_headshot = true;
	//don't get headshot damage when you have a halmet
	CPlayer@ player = this.getPlayer();
	bool has_helm = false;
	if (player !is null) {
		string player_name = player.getUsername();
		has_helm = getRules().get_bool(player_name + "helm");
		get_headshot = !has_helm;
	}
	
	if (this.hasTag("flesh")&&has_helm) {
		damage = Maths::Max(damage-0.5f, 0.1f);
	}
	
	CBlob@[] blobs_around;
	getMap().getBlobsInRadius(this.getPosition(), this.getRadius()*1.5, blobs_around);
	//don't get headshot damage when you're near a sandbag
	for(int counter = 0; counter<blobs_around.size(); ++counter){
		CBlob@ current_blob = blobs_around[counter];
		if (current_blob.getName()=="sandbag") {
			get_headshot = false;
			break;
		}
	}
	
	if (hitHead && this.hasTag("flesh") && damage >= 1 && !(this.hasTag("bones") || this.hasTag("undead")) && get_headshot) {
		switch(customData)
		{
			case Hitters::arrow:
			{
				headshot_sound = true;
				headshot_FXs = true;
				damage *= headshot; break;
			}
		}
		if (gunfireHitter(customData)) {
			headshot_sound = true;
			headshot_FXs = true;
			damage *= headshot;
		}
		if (this.hasTag("dead") || this.hasTag("undead"))
			headshot_sound = false;
		
		if(headshot_sound)
			this.getSprite().PlaySound(CFileMatcher("ManArg").getRandom(), 2, 1);
			//this.getSprite().PlaySound("ManArg"+(XORRandom(6)+1)+".ogg", 2, 1);
		
		if(headshot_FXs&&!this.isAttached())
			MakeBangEffect(this, "crit", 1.0f, false, Vec2f((XORRandom(10)-5) * 0.1, -(3/2)), Vec2f(XORRandom(11)-5,-XORRandom(4)-1));
	}
	
	//no damage to drivers
	if (this.hasTag("isInVehicle") || this.hasTag("dummy") || this.hasTag("invincible")) {
		damage *= 0;
		if (this.hasTag("isInVehicle") || this.hasTag("dummy"))
			doFXs = false;
	}
	
	
	//damage = Maths::Round(damage/1);
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
	if (isServer()) {
		this.set_f32("synced_damage", 0);
		this.Sync("synced_damage", true);
	}
}