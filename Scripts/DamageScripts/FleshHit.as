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
	CPlayer@ player = this.getPlayer();
	bool gets_halved_damage = false;
	if (player !is null) {
		string player_name = player.getUsername();
		CRules@ rules = getRules();
		gets_halved_damage = rules.get_bool(player_name + "helm");
	}
	return damage;
}