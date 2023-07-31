#include "Hitters.as";
#include "HittersKIWI.as";
#include "CommonHitFXs.as";
#include "FleshHitFXs.as";
#include "MakeBangEffect"
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
	f32 headshot = 1.5, sniper_headshot = 3;
	//headshots deal additional damage
	const Vec2f headPoint = this.getPosition() - Vec2f(0, this.getRadius()/2);
	const bool hitHead = (worldPoint - headPoint).Length() < this.getRadius();
	bool headshot_sound = false;
	bool headshot_FXs = false;
	//headshot logic
	bool get_headshot = true;
	//don't get headshot damage when you have a halmet
	bool has_helm = false;
	if (player !is null) {
		string player_name = player.getUsername();
		has_helm = getRules().get_bool(player_name + "helm");
		get_headshot = !has_helm;
	}
	
	CBlob@[] blobs_around;
	getMap().getBlobsInRadius(this.getPosition(), this.getRadius()*1.5, blobs_around);
	
	//don't get headshot damage when you're near a sandbag
	bool near_a_sandbag = false;
	for(int counter = 0; counter<blobs_around.size(); ++counter){
		CBlob@ current_blob = blobs_around[counter];
		if (current_blob.getName()=="sandbag") {
			near_a_sandbag = true;
			break;
		}
	}
	get_headshot = get_headshot && !near_a_sandbag;
	
	if (this.hasTag("flesh")&&(has_helm||near_a_sandbag)) {
		damage = Maths::Max(damage-0.5f, 0.1f);
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
		
		if (this.isAttached()) {
			headshot_sound = false;
			headshot_FXs = false;
		}
		
		if (this.hasTag("dead") || this.hasTag("undead"))
			headshot_sound = false;
		
		if(headshot_sound)
			this.getSprite().PlaySound("ManArg"+(XORRandom(6)+1), 2, 1);
			//this.getSprite().PlaySound("ManArg"+(XORRandom(6)+1)+".ogg", 2, 1);
		
		if(headshot_FXs)
			MakeBangEffect(this, "crit", 1.0f, false, Vec2f((XORRandom(10)-5) * 0.1, -(3/2)), Vec2f(XORRandom(11)-5,-XORRandom(4)-1));
	}
	
	return damage;
}