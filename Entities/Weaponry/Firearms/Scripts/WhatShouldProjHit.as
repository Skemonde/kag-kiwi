/*
bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return !blob.hasTag("projectile")
		&& !blob.hasTag("firearm")
		&& !blob.hasTag("ignore_saw")
		&& !(blob.getTeamNum() == this.getTeamNum());
}
*/
#include "FirearmVars"
#include "KIWI_Hitters"

bool shouldRaycastHit(CBlob@ target, f32 ANGLE_TO_GET, bool FACING_LEFT, u8 OUR_TEAM, u8 HITTER, Vec2f HIT_POS, Vec2f START_POS = Vec2f())
{
	if(!((target.hasTag("builder always hit")
		|| 	target.hasTag("bullet_hits"))
		|| 	target.hasTag("explosive")
		|| 	target.hasTag("player")
		|| 	target.hasTag("flesh")
		|| 	target.hasTag("door")
		|| 	target.hasTag("teamkilling gunfire")
		||  target.getName() == "trap_block"
		||  target.getName() == "bridge"
		))
		return false;
		
	bool skip_bones = target.hasTag("bones") && !(XORRandom(3)==0);
	bool skip_platform = (target.getName()=="wooden_platform"||target.getName()=="bridge") && !CollidesWithPlatform(target, ANGLE_TO_GET, FACING_LEFT);
	//bool player_crouching = gunCrouching(target);
	bool pron = lyingProne(target);
	f32 speed_angle = ANGLE_TO_GET;
	bool hitting_crouching = (FACING_LEFT && speed_angle < -225 && speed_angle > -280) || (!FACING_LEFT && speed_angle < -260 && speed_angle > -315);
	
	bool frend_team = target.getTeamNum() == OUR_TEAM;
	
	bool target_got_no_shield = (target.getCarriedBlob() !is null && !target.getCarriedBlob().hasTag("shield")||target.getCarriedBlob() is null);
	
	bool hitting_upper_body = HIT_POS.y<target.getPosition().y;
	
	bool skip_near_obstacle = (target.getName()=="sandbag" || target.hasTag("vehicle")) && HITTER!=HittersKIWI::tankshell && (target.getPosition()-START_POS).Length()<(16.0f+target.getRadius());
	
	bool proning = (pron && !hitting_crouching && hitting_upper_body && target_got_no_shield);
	
	bool unskippable =
		//if commander offcier decides to kill an ally - no one shall stop them
		HITTER == HittersKIWI::cos_will && target.hasTag("flesh") && !proning
		//doors get hit regardless of team
		|| ((target.hasTag("door") || target.hasTag("teamkilling gunfire")) && target.getShape().getConsts().collidable)
		//can collect grains
		|| target.hasTag("scenary")
		//dummies too
		|| target.hasTag("turret") && !frend_team
		//dummies too
		|| target.hasTag("dummy")
		//trap blocks
		|| target.getName()=="trap_block"
		//other tiles
		|| target.getName()=="wooden_platform"||target.getName()=="bridge"
		;
	
	//print("proning is "+(proning?"true":"false")+" | pron is "+(pron?"true":"false"));
	
    if(
		(
		frend_team
		//only with a 33% chance we can hit a skeleton
		|| skip_bones
		//we shoot from behind a platform
		|| skip_platform
		// don't hit sandbags or enemy tanks if it's too close to us
		|| skip_near_obstacle
		//don't even think of hitting them
		|| target.hasTag("isInVehicle")
		|| target.hasTag("invincible")
		//don't shoot corpses of fresh soldiers
		|| target.hasTag("halfdead") && target.getTickSinceCreated()<(25.0f*getTicksASecond())
		//don't shoot NPCs <3
		|| target.hasTag("migrant")
		//why would you shoot a mining rig
		|| !target.isCollidable()
		//if player is crouching and item isn't shield (so it works properly) we allow bullets to come through head :P
		|| proning
		//no shooting halfdeads
		//actually... no - if i'm adding capturing players alive it should be hard
		//|| target.hasTag("halfdead")
		)
		&& !unskippable
		
		) return false;
		
	return true;
}/* 

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	//return ((blob.hasTag("player") || blob.hasTag("flesh") || blob.hasTag("bullet_hits") || blob.getShape().isStatic())
	//	&& (blob.getTeamNum() != this.getTeamNum()));
	bool check = ((blob.hasTag("player") || blob.hasTag("flesh") || blob.hasTag("bullet_hits"))
			&& (blob.getTeamNum() != this.getTeamNum())
			&& !blob.isAttached());
		
	//maybe collide with team structures
	//if (!check)
	//{
	//	CShape@ shape = blob.getShape();
	//	check = (shape.isStatic() && !shape.getConsts().platform);
	//}

	if (check)
	{
		if (
			//we've collided
			this.getShape().isStatic()
			|| this.hasTag("collided")
			//or they ignore us
			|| blob.hasTag("ignore_proj")
			//of they're dead and bullet doesn't have a right to damage them
			|| ( !this.get_bool("hit_dead_bodies") && blob.hasTag("dead"))
		)
		{
			return false;
		}
		else
		{
			return true;
		}
	}

	return false;
} */