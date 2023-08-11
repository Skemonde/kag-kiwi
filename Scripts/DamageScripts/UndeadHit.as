#include "Hitters.as";
#include "KIWI_Hitters.as";
#include "CommonHitFXs.as";
#include "FleshHitFXs.as";

//don't forget to put a DamageProcessing.as right after this script in blob's cfg!!!

void onInit(CBlob@ this)
{
	this.Tag("undead");
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	//compensate for some damage hitters
	switch(customData)
	{
		case Hitters::ballista:
			damage *= 2.5;
			break;
		case Hitters::cata_boulder:
			damage *= 2;
			break;
		case Hitters::saw:
		{
			//damage saw if we were killed by one
			this.server_Hit(hitterBlob, hitterBlob.getPosition(), -velocity, Maths::Clamp(this.getHealth() / 3, 0.25f, 0.5f), Hitters::muscles, true);
			ParticleBloodSplat(worldPoint, true);
			break;
		}
	}
	
	if (this.hasTag("flesh"))
		MakeFleshHitEffects(this, worldPoint, velocity, damage, hitterBlob, customData);
	
	// blobs that have the script get only damage multiple to 1 heart in vanilla terms or half a heart in KIWI terms(1 HP)
	return Maths::Round(damage/1);
}
