#include "HittersKIWI.as";
#include "ParticleSparks.as";

void onInit(CBlob@ this)
{
	this.Tag("steel");
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
	// blobs that have the script get only damage multiple to 1 heart in vanilla terms or half a heart in KIWI terms(1 HP)
	damage = Maths::Round(damage/1);
	// steel guys don't get more than 1 HP of damage from gunfire
	switch (customData)
	{
		case HittersKIWI::bullet_pistol:
		case HittersKIWI::bullet_rifle:
		case HittersKIWI::bullet_hmg:
		//case HittersKIWI::boom:
			damage = 1;
			break;
		//case HittersKIWI::pellet:
		//	damage = 0;
		//	break;
			
		default:
			damage *= 1;
	}
	// printing amount of damage dealt to a blob
	// if blob is player - display character name(cl_name) and username
	// if blob is dead(is a corpse) - display "dead" before blobname
	print("dealt " + damage + " HP of damage (it's " + damage/2 + " hearts of damage) to "
			+ (this.getPlayer() is null ? "the "
			: this.getPlayer().getCharacterName() + " (username: " + this.getPlayer().getUsername() + ") the ")
			+ (this.hasTag("dead") ? "dead " : "")
			+ this.getName());
	if (damage > 0.001)
		playMetalSound(this);
	else {
		playNoDamage(this);
		sparks(worldPoint, 1, 0.1f);
	}
	// do damage to the blob with a certain hitter
	this.Damage(damage, hitterBlob);
	
	int endured_damage = this.get_u16("endured_damage");
	if (getGameTime()-this.get_u32("last_hit") > 1 && endured_damage != 0 && endured_damage < 10) {
		makeDamageIndicator(this,endured_damage);
	}else
		this.add_u16("endured_damage", damage);
	
	this.set_Vec2f("hitpoint", worldPoint);
	this.set_u32("last_hit", getGameTime());
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

void playMetalSound(CBlob@ this)
{
	this.getSprite().PlaySound("dig_stone.ogg", 2.0f, 0.5f + (XORRandom(100) / 1000.0f));
}

void playNoDamage(CBlob@ this)
{
	this.getSprite().PlaySound("nodamage.ogg", 4.0f, 1 + (XORRandom(100) / 1000.0f));
}