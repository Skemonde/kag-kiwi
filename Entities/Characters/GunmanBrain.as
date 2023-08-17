// Soldat brain

#define SERVER_ONLY

#include "BrainCommon.as"
#include "Knock.as"
#include "FirearmVars.as"

void onInit(CBrain@ this)
{
	InitBrain(this);
}

bool gotItem(CBlob@ blob, string item_name)
{
	if (blob is null) return false;
	CInventory@ inv = blob.getInventory();
	if (inv is null) return false;
	for (int counter = 0; counter < inv.getItemsCount(); ++counter) {
		CBlob@ current_item = inv.getItem(counter);
		if (current_item is null) continue;
		if (current_item.getName()==item_name) return true;
	}
	CBlob@ carried = blob.getCarriedBlob();
	if (carried is null) return false;
	if (carried.getName()==item_name) return true;
	
	return false;
}

void onTick(CBrain@ this)
{
	SearchTarget(this, false, true);

	CBlob @blob = this.getBlob();
	CBlob @target = this.getTarget();

	// logic for target

	this.getCurrentScript().tickFrequency = 29;
	if (target !is null)
	{
		this.getCurrentScript().tickFrequency = 1;

		u8 strategy = blob.get_u8("strategy");

		f32 distance;
		const bool visibleTarget = isVisible(blob, target, distance);
		if (visibleTarget)
		{
			const s32 difficulty = blob.get_s32("difficulty");
			//if (distance < 50.0f && !gotItem(this.getBlob(), "combatknife"))
			//	strategy = Strategy::retreating;
			//else// if (gotarrows)
			{
				strategy = Strategy::attacking;
			}
		} else {
			strategy = Strategy::chasing;
		}

		UpdateBlob(blob, target, strategy);

		// lose target if its killed (with random cooldown)

		if (LoseTarget(this, target))
		{
			strategy = Strategy::idle;
		}

		blob.set_u8("strategy", strategy);
	}
	else
	{
		RandomTurn(blob);
	}

	FloatInWater(blob);
}

void UpdateBlob(CBlob@ blob, CBlob@ target, const u8 strategy)
{
	Vec2f targetPos = target.getPosition();
	Vec2f myPos = blob.getPosition();
	if (strategy == Strategy::chasing)
	{
		GunmanChaseBlob(blob, target);
		DefaultChaseBlob(blob, target);
	}
	else if (strategy == Strategy::retreating)
	{
		DefaultRetreatBlob(blob, target);
	}
	else if (strategy == Strategy::attacking)
	{
		AttackBlob(blob, target);
	}
}

void GunmanChaseBlob(CBlob@ blob, CBlob @target)
{
	f32 distance;
	const bool visibleTarget = isVisible(blob, target, distance);
	if (visibleTarget) return;
	
	CBlob@ carried = blob.getCarriedBlob();
	string gun_name = blob.get_string("main gun");
	CBlob@ gun = blob.getInventory().getItem(gun_name);
	if (gun is null && carried !is null && carried.getName()!=gun_name) return;
	if (gun is null && carried !is null && carried.getName()==gun_name)
		@gun = carried;
	
	if (gun is null) return;
	
	FirearmVars@ vars;
	if (!gun.get("firearm_vars", @vars)) return;
	
	if (carried !is null && gun !is carried) {
		blob.server_PutInInventory(carried);
		blob.server_Pickup(gun);
	}
	
	if (gun.get_u8("clip")<vars.CLIP && gun.hasCommandID("start_reload") && gun.get_u8("actionInterval")<1 && !gun.get_bool("doReload"))
	{
		CBitStream stream;
		gun.SendCommand(gun.getCommandID("start_reload"), stream);
	}
}

void AttackBlob(CBlob@ blob, CBlob @target)
{
	Vec2f mypos = blob.getPosition();
	Vec2f targetPos = target.getPosition();
	Vec2f targetVector = targetPos - mypos;
	f32 targetDistance = targetVector.Length();
	const s32 difficulty = blob.get_s32("difficulty");

	JumpOverObstacles(blob);
	
	CBlob@[] grenades;
	CBlob@ important_target;
	if (getBlobsByName("froggy", @grenades)) {
		f32 min_len = 999999;
		int most_dangerous_nade = -1;
		for (int counter = 0; counter < grenades.size(); ++counter) {
			CBlob@ nade = grenades[counter];
			if (nade is null) continue;
			if (!nade.exists("death_date")) continue;
			
			f32 nade_dist = (nade.getPosition()-blob.getPosition()).Length();
			if (nade_dist<100&&nade_dist<min_len) {
				min_len = nade_dist;
				most_dangerous_nade = counter;
			}
		}
		if (most_dangerous_nade > -1)
			@important_target = grenades[most_dangerous_nade];
	}

	const u32 gametime = getGameTime();

	// fire
	string knife_name = "riotshield";
	string gun_name = blob.get_string("main gun");
	CBlob@ gun = blob.getInventory().getItem(gun_name);
	CBlob@ carried = blob.getCarriedBlob();
		
	f32 distance;
	const bool visibleTarget = isVisible(blob, target, distance);
	CBlob@ enemy_carried = target.getCarriedBlob();
	bool should_shield = enemy_carried !is null && enemy_carried.hasTag("firearm") && (getGameTime()-enemy_carried.get_u32("last_shot_time"))<15 && visibleTarget && target.isFacingLeft()!=blob.isFacingLeft();

	if ((targetDistance > 50.0f || isKnocked(target))&&!should_shield)
	{
		if (carried is null) return;
		if (carried.getName()==knife_name) {
			if (gun is null) return;
			blob.server_PutInInventory(carried);
			blob.server_Pickup(gun);
		}
		@gun = carried;
		FirearmVars@ vars;
		if (!gun.get("firearm_vars", @vars)) return;

		bool worthShooting;
		//bool hardShot = targetDistance > 30.0f * 8.0f || target.getShape().vellen > 5.0f;
		//f32 aimFactor = 0.45f - XORRandom(100) * 0.003f;
		//aimFactor += (-0.2f + XORRandom(100) * 0.004f) / float(difficulty > 0 ? difficulty : 1.0f);
		//blob.setAimPos(blob.getBrain().getShootAimPosition(targetPos, hardShot, worthShooting, aimFactor));
		worthShooting = true;
		if (worthShooting)
		{
			blob.setAimPos(targetPos);
			if (vars.FIRE_AUTOMATIC) {
				blob.setKeyPressed(key_action1, true);
			} else {
				blob.setKeyPressed(key_action1, gun.get_u8("actionInterval")==0&&!blob.isKeyJustPressed(key_action1));
			}
		}
	}
	else
	{
		blob.setAimPos(targetPos);
		if (important_target !is null)
			blob.setAimPos(important_target.getPosition());
		
		CBlob@ carried = blob.getCarriedBlob();
		if (carried is null) return;
		if (carried.getName()!=knife_name) {
			CBlob@ knife = blob.getInventory().getItem(knife_name);
			if (knife is null) {
				@knife = server_CreateBlob(knife_name, blob.getTeamNum(), blob.getPosition());
			}
			blob.server_PutInInventory(carried);
			blob.server_Pickup(knife);
		}
		
		bool we_on_ground = blob.isOnGround();
		bool target_can_be_hit = Maths::Abs(targetPos.y-mypos.y)<blob.getRadius()&&Maths::Abs(targetPos.x-mypos.x)<50.0f;
		if (target_can_be_hit && we_on_ground) {
			blob.setKeyPressed(key_action1, true);
		} else {
			blob.setKeyPressed(key_action1, false);
		}
		
		if (!target_can_be_hit && carried !is null && carried.getName()==knife_name) {
			DefaultChaseBlob(blob, target);
		}
		
		blob.setKeyPressed(key_action2, should_shield || targetDistance<30);
	}
}

