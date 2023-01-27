#include "Logging.as";
#include "HittersKIWI.as";

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
		print("end damage " + endured_damage);
		makeDamageIndicator(this,endured_damage);
	}
}

void onDie(CBlob@ this)
{
	int endured_damage = this.get_u16("endured_damage");
	print("death damage " + endured_damage);
	
	if (endured_damage != 0 && endured_damage < 10){//getGameTime()-this.get_u32("last_hit") > 3 && endured_damage != 0) {
		makeDamageIndicator(this,endured_damage);
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	// blobs that have the script get only damage aliquot to 1 heart in vanilla terms or half a heart in KIWI terms(1 HP)
	damage = Maths::Round(damage/1);
	print_damagelog(this, damage);
	// do damage to the blob with a certain hitter
	this.Damage(damage, hitterBlob);
	
	int endured_damage = this.get_u16("endured_damage");
	if (getGameTime()-this.get_u32("last_hit") > 1 && endured_damage != 0 && endured_damage < 10) {
		makeDamageIndicator(this,endured_damage);
	}else
		this.add_u16("endured_damage", damage);
	
	this.set_Vec2f("hitpoint", worldPoint);
	this.set_u32("last_hit", getGameTime());
	
	// gib if health below gibHealth
	f32 gibHealth = getGibHealth(this);
	// kill the blob if it should
	if (this.getHealth() <= gibHealth)
	{
		this.getSprite().Gib();
		this.server_Die();
	}
	// done, we've used all the damage
	return 0.0f;
}

void makeDamageIndicator(CBlob@ this, int damage)
{
	this.set_u16("endured_damage", 0);
	
	CParticle@ damage_thing = ParticleAnimated(
	"digit"+damage,                   					// file name
	this.get_Vec2f("hitpoint"),            								// position
	Vec2f((XORRandom(4)-2) * 0.1, -(0.5)),              // velocity
	0,                              		// rotation
	1.0f + (XORRandom(4*2)-4)*0.01,                		// scale
	16 + XORRandom(2),                              	// ticks per frame
	0.0f,                               				// gravity
	true);		                          				// self lit
	
	if (damage_thing !is null) {
		damage_thing.collides = false;
		damage_thing.deadeffect = 0;
		damage_thing.setRenderStyle(RenderStyle::additive);
		damage_thing.Z = 1000;
	}
}
