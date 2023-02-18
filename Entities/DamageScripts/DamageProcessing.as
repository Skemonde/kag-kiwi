#include "HittersKIWI.as";
#include "ParticleSparks.as";
#include "CommonHitFXs.as";

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

void onTick(CBlob@ this)
{
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
	
	if (endured_damage != 0 && endured_damage < 10){//getGameTime()-this.get_u32("last_hit") > 3 && endured_damage != 0) {
		makeDamageIndicator(this,endured_damage);
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	int endured_damage = this.get_u16("endured_damage");
	if (getGameTime()-this.get_u32("last_hit") > 1 && endured_damage != 0 && endured_damage < 10) {
		makeDamageIndicator(this,endured_damage);
	}else
		this.add_u16("endured_damage", damage);
	
	this.set_Vec2f("hitpoint", worldPoint);
	this.set_u32("last_hit", getGameTime());
	
	// do damage to the blob with a certain hitter
	if (!this.hasTag("dummy")) {
		this.Damage(damage, hitterBlob);
	}
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