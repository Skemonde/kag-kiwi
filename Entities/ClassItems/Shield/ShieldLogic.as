#include "Hitters"
#include "KIWI_Hitters"
#include "FirearmVars"
#include "Knocked"

//const u16 BASH_INTERVAL = 90;

enum ShieldState
{
	NONE = 0,
	SHIELDING
};

void onInit(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	sprite.SetRelativeZ(10.0f);

	this.Tag("shield");
	this.Tag("no throw via action3");
	this.Tag("locking action1");
	this.Tag("locking action2");
	
	this.set_u32("next_bash", 0);
	this.set_u8("shield_state", ShieldState::NONE);
	this.set_u32("last_shielding", 0);
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	
	AttachmentPoint@ point = blob.getAttachments().getAttachmentPointByName("PICKUP");
	if(point is null) return;
	CBlob@ holder = point.getOccupied();
	if(holder is null) return;
	
	const bool FLIP = holder.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1: 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	bool shielding = blob.get_u8("shield_state")==ShieldState::SHIELDING;
	f32 shield_dist = 6;
	f32 snapped_angle = getSnappedAngle(holder) - holder.getAngleDegrees();
	this.ResetTransform();
	this.ScaleBy(1.0f, 1.0f);
	
	if (!shielding) {
		this.SetRelativeZ(-70.0f);
		this.SetAnimation("hidden");
		shield_dist = 5;
	} else {
		this.SetRelativeZ(10.0f);
		this.SetAnimation("destruction");
		this.getAnimation("destruction").SetFrameIndex(blob.inventoryIconFrame-1);
		
		this.RotateBy(snapped_angle, Vec2f(shield_dist*FLIP_FACTOR, 0));
	}
	Vec2f sitting_offset = Vec2f(1,-1);
	Vec2f sitting_rotoff = Vec2f(2*sitting_offset.x, sitting_offset.y);
	
	this.SetOffset(Vec2f(-shield_dist, 2+blob.getVelocity().y)+blob.get_Vec2f("gun_trans_from_carrier")+(gunCrouching(holder)&&shielding?sitting_offset.RotateBy(-snapped_angle*FLIP_FACTOR, Vec2f()):Vec2f())+(shielding?Vec2f(0, -1):Vec2f()));
	
	if (getGameTime()<(blob.get_u32("next_bash")-10)) {
		//this.RotateBy(30*FLIP_FACTOR, Vec2f());
	}
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	this.set_u32("next_bash", getGameTime()+5);
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	const bool FLIP = detached.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1: 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	CSprite@ sprite = this.getSprite();
	sprite.SetAnimation("destruction");
	sprite.getAnimation("destruction").SetFrameIndex(this.inventoryIconFrame-1);
	sprite.SetRelativeZ(10.0f);
	sprite.ResetTransform();
	sprite.SetOffset(Vec2f());
	sprite.RotateBy(-90*FLIP_FACTOR, Vec2f());
}

bool checkIfHolderCanBash(CBlob@ this, CBlob@ holder)
{
	if (holder is null) return false;
	const bool FLIP = holder.isFacingLeft();
	if (holder.hasTag("dead")||holder.hasTag("halfdead")) return false;
	if (getGameTime()<this.get_u32("next_bash")) return false;
	if (!holder.isOnGround()) return false;
	if (Maths::Abs(holder.getVelocity().y)>1.0f) return false;
	if (isKnocked(holder)) return false;
	bool shielding = this.get_u8("shield_state")==ShieldState::SHIELDING;
	if (!shielding) return false;
	if (!holder.isKeyPressed(key_action1)) return false;
	
	f32 shield_angle = getShieldAngle(holder);
	bool right_bash_angle = (shield_angle > -50 && shield_angle < 50 && FLIP) || (shield_angle < 50 && shield_angle > -50 && !FLIP);
	
	if (!right_bash_angle) return false;
	
	return true;
}

void doShieldBash(CBlob@ this, CBlob@ holder, f32 shield_angle)
{
	const bool FLIP = holder.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1: 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	f32 bash_force = this.get_f32("bash_force");
	
	holder.AddForce(Vec2f(bash_force, -180*FLIP_FACTOR).RotateBy(ANGLE_FLIP_FACTOR));
	holder.getSprite().PlaySound("shield_hmm0.ogg", 1.0f, holder.getSexNum() == 0 ? 1.0f : 1.5f);
	int bash_interval = this.get_s32("bash_interval");
	this.set_u32("next_bash", getGameTime()+bash_interval);
}

void checkForBlobsToHit(CBlob@ this, CBlob@ holder)
{
	if (holder is null) return;
	const bool FLIP = holder.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1: 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	//tick period
	int bash_moment = this.get_s32("bash_moment");
	int bash_interval = this.get_s32("bash_interval");
	//checking for the period
	bool can_bash = ((this.get_u32("next_bash")-getGameTime())>bash_interval-bash_moment)&&((this.get_u32("next_bash")-getGameTime())<bash_interval);
	if (!can_bash) return;
	
	HitInfo@[] hit_infos;
	
	getMap().getHitInfosFromArc(this.getPosition()+Vec2f(-6*FLIP_FACTOR,0), ANGLE_FLIP_FACTOR, this.get_f32("shielding_angle_max"), 16.0f, this, @hit_infos);
	
	for (int count = 0; count < hit_infos.length; ++count) {
		CBlob@ touching_blob = hit_infos[count].blob;
		if (touching_blob is null) continue;
		//you can't just move away your shield and bash an enemy
		bool has_right_direction = holder.getVelocity().x>0&&touching_blob.getPosition().x>holder.getPosition().x ||
			holder.getVelocity().x<0&&touching_blob.getPosition().x<holder.getPosition().x;
		bool knock_state = !isKnockable(touching_blob) || isKnockable(touching_blob) && !isKnocked(touching_blob);
		bool target_should_be_touched = !touching_blob.hasTag("invincible") && !(touching_blob.hasTag("dead")||touching_blob.hasTag("halfdead"));
		bool target_accepted = target_should_be_touched && knock_state && (touching_blob.hasTag("player") || touching_blob.hasTag("undead"));
		bool frend = touching_blob.getTeamNum() == holder.getTeamNum();
		
		if (//touching_blob.isCollidable() && holder.doesCollideWithBlob(touching_blob) &&
			target_accepted &&
			has_right_direction &&
			!frend)
		{
			f32 bash_damage = this.get_f32("bash_damage");
			holder.server_Hit(touching_blob, holder.getPosition(), Vec2f(), bash_damage, Hitters::shield);
			holder.getSprite().PlaySound(this.hasTag("steel")?"BaseHitSound.ogg":"catapult_hit.ogg", 2.0f, 1.0f);
			this.sub_u32("next_bash", bash_moment+2);
		}
		
		if (touching_blob.hasTag("vehicle")||!target_accepted||frend) continue;
		
		if (touching_blob.getPlayer() !is null) {
			if (isServer() && touching_blob.hasCommandID("set vel") && holder.getVelocity().Length()>1)
			{
				//print("hey");
				CBitStream params;
				params.write_Vec2f(touching_blob.getVelocity()+holder.getVelocity());
				touching_blob.SendCommand(touching_blob.getCommandID("set vel"), params);
			}
		} else
			touching_blob.setVelocity(touching_blob.getVelocity()+holder.getVelocity());
		holder.setVelocity(Vec2f());
		return;
	}
}

void onTick(CBlob@ this)
{
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	if(point is null) return;
	CBlob@ holder = point.getOccupied();
	if(holder is null) return;
	const bool FLIP = this.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	const bool SHIELDING = this.get_u8("shield_state")==ShieldState::SHIELDING;
	
	f32 shield_angle = getShieldAngle(holder);
	f32 snapped_angle = getSnappedAngle(holder);
	//print("snapped_angle "+snapped_angle);
	//print("shield_angle "+shield_angle);
	if (snapped_angle == (FLIP?450:270)) {
		//holder.AddForce(Vec2f(0, -20));
	}
	bool right_sliding_angle = (shield_angle > 50 && shield_angle < 100 && !FLIP) || (shield_angle < -50 && shield_angle > -100 && FLIP);
	bool right_soar_angle = (shield_angle > 50 && shield_angle < 100 && FLIP) || (shield_angle < -50 && shield_angle > -100 && !FLIP);
	
	f32 holder_velx = holder.getVelocity().x;
	bool small_velx = Maths::Abs(holder_velx)<1;
	f32 max_velx = 60;
	
	if (holder.isKeyPressed(key_up) && !small_velx && holder.isOnGround() && SHIELDING && right_sliding_angle) {
		Vec2f vel = holder.getVelocity();
		holder.setVelocity(Vec2f(vel.x, Maths::Max(vel.y, 0)));
		holder.AddForce(Vec2f(Maths::Clamp(15*holder_velx, -max_velx, max_velx), 20));
		//print("SUS "+(15*holder_velx));
		
		if (isClient()) {
			this.getSprite().PlayRandomSound("/Scrape");
			Vec2f velr = getRandomVelocity(!FLIP ? 70 : 110, 4.3f, 40.0f);
			ParticlePixel(holder.getPosition(), velr, SColor(255, 255, 255, 0), true);
		}
	}
	else
	if (SHIELDING && right_soar_angle && holder.getAirTime()>5)
	{
		Vec2f vel = holder.getVelocity();
		//holder.setVelocity(Vec2f(vel.x, Maths::Max(vel.y, -4.5f)));
		holder.AddForce(Vec2f(0, -20.0f + 0.3f*Maths::Min(15, holder.getAirTime())));
	}
	
	this.set_f32("shield_angle", shield_angle);
	this.setAngleDegrees(0);
	
	if (checkIfHolderCanBash(this, holder)) {
		doShieldBash(this, holder, shield_angle);
	}
	checkForBlobsToHit(this, holder);
	
	if (holder.isKeyPressed(key_action2)&&(this.get_u32("last_shielding")+7)<getGameTime()) {
		this.set_u8("shield_state", ShieldState::SHIELDING);
	} else {
		this.set_u8("shield_state", ShieldState::NONE);
		
		if (SHIELDING)
			this.set_u32("last_shielding", getGameTime());
	}
	this.Sync("shield_state", true);
}

void onRender(CSprite@ this)
{
	return; //disabled as we've got destruction animation
	
	if (this is null) return;
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	CBlob@ localblob = getLocalPlayerBlob();
	if (localblob is null) return;
	AttachmentPoint@ point = blob.getAttachments().getAttachmentPointByName("PICKUP");
	if(point is null) return;
	CBlob@ holder = point.getOccupied();
	if(holder is null) return;
	if(holder !is localblob) return;
	CBlob@ carried = holder.getCarriedBlob();
	if(carried is null) return;
	if (!isClient()) return;
	
	const f32 SCALEX = getDriver().getResolutionScaleFactor();
	const f32 ZOOM = getCamera().targetDistance * SCALEX;
	CMap@ map = getMap();
	const bool FLIP = blob.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	Vec2f pos = blob.getInterpolatedScreenPos();
	GUI::DrawTextCentered("Shield "+int(carried.getHealth()*20)+" HP", Vec2f(pos.x, pos.y + 24*ZOOM + Maths::Sin(getGameTime() / 10.0f) * 10.0f), SColor(0xfffffcf0));
	
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return !(blob.hasTag("flesh") || blob.hasTag("vehicle"));
}

f32 getSnappedAngle(CBlob@ holder, f32 angle_step = 45)
{
	if (holder is null) return 0;
	f32 shield_angle = getShieldAngle(holder);
	f32 snapped_angle = Maths::Floor((shield_angle+holder.getAngleDegrees())/angle_step+0.5f)*angle_step;
	return snapped_angle;
}

f32 getShieldAngle(CBlob@ this)
{
	const bool flip = this.isFacingLeft();
	const f32 flip_factor = flip ? -1: 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	
	Vec2f pos = this.getPosition();
 	Vec2f aimvector = this.getAimPos() - pos;
	f32 angle = aimvector.Angle();// + this.getAngleDegrees();
	//return angle_flip_factor-angle;
    return constrainAngle(angle_flip_factor-(angle+flip_factor));
}