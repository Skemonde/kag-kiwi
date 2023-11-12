#include "Hitters.as";
#include "KIWI_Hitters.as";
#include "CommonHitFXs.as";
#include "FleshHitFXs.as";
#include "MakeBangEffect"
#include "Logging.as";
#include "Knocked.as";

//don't forget to put a DamageProcessing.as right after this script in blob's cfg!!!

void onInit(CBlob@ this)
{
	this.Tag("flesh");
	this.addCommandID("make_flesh_hit_fxs");
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	const bool FLIP = this.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1: 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
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
	bool get_headshot = this.hasTag("player");
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
	
	if (this.hasTag("flesh")&&(has_helm||near_a_sandbag)&&gunfireHitter(customData)) {
		damage = Maths::Max(damage-0.5f, 0.1f);
	}
	
	CBlob@ carried = this.getCarriedBlob();
	if (carried !is null && carried.hasTag("shield") && carried.get_u8("shield_state")==1) {
		Vec2f blob_pos = this.getPosition();
		f32 shield_angle = (blob_pos+Vec2f(-30,0).RotateBy(carried.get_f32("shield_angle"), Vec2f())-blob_pos).Angle();
		//shield_angle = carried.get_f32("shield_angle");
		if (FLIP)
			shield_angle += 180;
		else
			shield_angle -= 180;
		if (worldPoint.x>blob_pos.x&&worldPoint.y>blob_pos.y&&!FLIP) {
			shield_angle += 360;
		}
		if (worldPoint.x<blob_pos.x&&worldPoint.y>blob_pos.y&&!FLIP) {
			shield_angle *= -1;
			shield_angle += 100;
		}
		//print("world "+worldPoint+" blobpos "+this.getPosition());
		f32 hit_angle = (worldPoint-blob_pos).Angle()+ANGLE_FLIP_FACTOR;
		//print("hit angle "+hit_angle+" shield angle "+shield_angle);
		f32 shielding_angle = carried.get_f32("shielding_angle_min");
		if (this.isKeyPressed(key_down))
			shielding_angle = carried.get_f32("shielding_angle_max");
		if (Maths::Abs(hit_angle-shield_angle)<shielding_angle&&hit_angle!=0) {
			hitterBlob.server_Hit(carried, carried.getPosition(), Vec2f(), damage, customData);
			if (damage >= 4.0f) {
				SetDazzled(this, damage*3);
			}
			bool fall_damage = customData==Hitters::fall;
			bool standing_still = Maths::Abs(this.getVelocity().x)<=0.3f;
			
			this.AddForce(Vec2f((standing_still?0.1f:1)*((fall_damage?Maths::Min(6, damage):damage)*50), 0).RotateBy(-(hit_angle-ANGLE_FLIP_FACTOR+180)));
			damage *= 0;
			if (fall_damage) {
				this.getSprite().PlaySound("launcher_boing1", 2, 1);
			}
			//print("HAHA SHIELDED");
		}
	}
	CBlob@ hitter_carried = hitterBlob.getCarriedBlob();
	if (hitter_carried !is null) {
		int bash_stun = hitter_carried.get_s32("bash_stun");
		if (customData==Hitters::shield&&damage>0&&bash_stun>0) {
			SetDazzled(this, bash_stun);
		}
	}
	
	if (hitHead && this.hasTag("flesh") && damage >= 1 && !(this.hasTag("bones") || this.hasTag("undead")) && get_headshot && !this.isAttached()) {
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
		
		if (this.hasTag("dead") || this.hasTag("undead"))
			headshot_sound = false;
		
		if(headshot_sound)
			this.getSprite().PlaySound("ManArg"+(XORRandom(6)+1), 2, 1);
		
		if(headshot_FXs&&!v_fastrender)
			MakeBangEffect(this, "crit", 1.0f, false, Vec2f((XORRandom(10)-5) * 0.1, -(3/2)), Vec2f(XORRandom(11)-5,-XORRandom(4)-1));
	}
	
	if (damage > 0 && !this.hasTag("isInVehicle")) {
		if (gunfireHitter(customData)&&this.isMyPlayer()) {
			Sound::Play("ManHit"+(XORRandom(3)+1));
		}
		//if (this.hasTag("flesh")) {
		CBitStream params;
		params.write_Vec2f(worldPoint);
		params.write_Vec2f(velocity);
		params.write_f32(damage);
		params.write_u16(hitterBlob.getNetworkID());
		params.write_u8(customData);
		
		if (isServer()) {
			this.SendCommand(this.getCommandID("make_flesh_hit_fxs"), params);
			//used only to determine how effective medical treatment should be which is server only
			this.set_u32("last_hit_time", getGameTime());
		}
	}
	
	
	return damage;
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("make_flesh_hit_fxs")) {
		if (!isClient()) return;
		
		Vec2f worldPoint; if (!params.saferead_Vec2f(worldPoint)) return;
		Vec2f velocity; if (!params.saferead_Vec2f(velocity)) return;
		f32 damage; if (!params.saferead_f32(damage)) return;
		u16 hitterBlob_ID; if (!params.saferead_u16(hitterBlob_ID)) return;
		CBlob@ hitterBlob = getBlobByNetworkID(hitterBlob_ID);
		if (hitterBlob is null) return;
		u8 customData; if (!params.saferead_u8(customData)) return;
		
		
		
		MakeFleshHitEffects(this, worldPoint, velocity, damage, hitterBlob, customData);
		makeFleshGib(this.getPosition(), worldPoint, damage);
	}
}