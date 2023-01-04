#include "HittersKIWI.as";

f32 getGibHealth(CBlob@ this)
{
	if (this.exists("gib health"))
	{
		return this.get_f32("gib health");
	}

	return 0.0f;
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
		//case HittersKIWI::bullet_hmg:
		case HittersKIWI::pellet:
		//case HittersKIWI::boom:
			damage = 1;
			break;
			
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
	// do damage to the blob with a certain hitter
	this.Damage(damage, hitterBlob);
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

void playMetalSound(CBlob@ this)
{
	this.getSprite().PlaySound("dig_stone.ogg", 1.0f, 0.8f + (XORRandom(100) / 1000.0f));
}