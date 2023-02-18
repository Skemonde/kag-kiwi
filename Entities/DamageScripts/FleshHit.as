#include "Hitters.as";
#include "HittersKIWI.as";
#include "CommonHitFXs.as";
#include "FleshHitFXs.as";

#include "Logging.as";

//don't forget to put a DamageProcessing.as right after this script in blob's cfg!!!

void onInit(CBlob@ this)
{
	this.Tag("flesh");
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	//print_damagelog(this, damage);
	
	// blobs that have the script get only damage aliquot to 1 heart in vanilla terms or half a heart in KIWI terms(1 HP)
	return Maths::Round(damage/1);
}