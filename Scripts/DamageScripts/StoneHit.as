#include "Hitters.as";
#include "HittersKIWI.as";
#include "CommonHitFXs.as";
#include "FleshHitFXs.as";

//don't forget to put a DamageProcessing.as right after this script in blob's cfg!!!

void onInit(CBlob@ this)
{
	this.Tag("stone");
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	switch (customData)
	{
		case Hitters::builder:
			damage *= 2.0f; //builder is great at smashing stuff
			break;

		case Hitters::sword:
		case Hitters::arrow:
		case Hitters::stab:
			damage = 0.0f;
			break;
			
		case HittersKIWI::zomb:
			damage *= 0.2f;
			break;

		case Hitters::bomb:
			damage *= 0.5f;
			break;

		case Hitters::keg:
		case Hitters::explosion:
			damage *= 2.5f;
			break;

		case Hitters::bomb_arrow:
			damage *= 8.0f;
			break;

		case Hitters::cata_stones:
			damage *= 5.0f;
			break;
		case Hitters::crush:
			damage *= 4.0f;
			break;

		case Hitters::flying: // boat ram
			damage *= 7.0f;
			break;
	}

	// blobs that have the script get only damage multiple to 1 heart in vanilla terms or half a heart in KIWI terms(1 HP)
	return Maths::Round(damage/1);
}
