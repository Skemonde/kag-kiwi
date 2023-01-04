#include "Logging.as";

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
	// blobs that have the script get only damage aliquot to 1 heart in vanilla terms or half a heart in KIWI terms(1 HP)
	damage = Maths::Round(damage/1);
	print_damagelog(this, damage);
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
