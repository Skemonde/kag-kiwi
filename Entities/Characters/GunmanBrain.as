// Soldat brain

#define SERVER_ONLY

#include "BrainCommon.as"
#include "Knock.as"
#include "FirearmVars.as"

void onInit(CBrain@ this)
{
	InitBrain(this);
	
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	blob.set_string("backup_name", "knightshield");
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
	//this.SetTarget(null);
	SearchTarget(this, false, true);

	CBlob @blob = this.getBlob();
	CBlob @target = this.getTarget();

	// logic for target
	
	CBlob@ last_hitter = getBlobByNetworkID(blob.get_u16("last_hitter_id"));
	if (last_hitter !is null && last_hitter !is target)
		this.SetTarget(last_hitter);

	this.getCurrentScript().tickFrequency = 29;
	if (target !is null)
	{
		this.getCurrentScript().tickFrequency = 1;
		
		if (target.hasTag("dead"))
			set_emoteByCommand(blob, "rock");

		u8 strategy = blob.get_u8("strategy");
		
		CBlob@ carried = blob.getCarriedBlob();

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
		
		if (carried is null) {
			//strategy = Strategy::retreating;
			if (getGameTime()%150==0)
				set_emoteByCommand(blob, "cry");
		}

		UpdateBlob(blob, target, strategy);

		// lose target if its killed (with random cooldown)

		if (LoseTarget(this, target))
		{
			strategy = Strategy::idle;
		}

		blob.set_u8("strategy", strategy);
		
		CBlob@[] grenades;
		CBlob@ important_target = null;
		if (getBlobsByName("froggy", @grenades)) {
			f32 min_len = 999999;
			int most_dangerous_nade = -1;
			f32 explo_radius = -1;
			for (int counter = 0; counter < grenades.size(); ++counter) {
				CBlob@ nade = grenades[counter];
				if (nade is null) continue;
				if (!nade.exists("death_date")) continue;
				
				f32 nade_dist = (nade.getPosition()-blob.getPosition()).Length();
				if (nade_dist<100&&nade_dist<min_len) {
					min_len = nade_dist;
					most_dangerous_nade = counter;
				}
				if (explo_radius < 0)
					explo_radius = nade.get_f32("explosion blob radius");
			}
			if (most_dangerous_nade > -1 && min_len < (explo_radius+12))
				@important_target = grenades[most_dangerous_nade];
		}
		if (important_target !is null) {
			blob.set_u16("danger_id", important_target.getNetworkID());
			strategy = Strategy::attacking;
		}
	}
	else
	{
		RandomTurn(blob);
	}

	FloatInWater(blob);

	getYourselfABackupItem(blob);
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
	
	CBlob@ important_target = getBlobByNetworkID(blob.get_u16("danger_id"));

	const u32 gametime = getGameTime();

	// fire
	string backup_name = blob.get_string("backup_name");;
	string gun_name = blob.get_string("main gun");
	CBlob@ gun = blob.getInventory().getItem(gun_name);
	CBlob@ carried = blob.getCarriedBlob();
		
	f32 distance;
	const bool visibleTarget = isVisible(blob, target, distance);
	CBlob@ enemy_carried = target.getCarriedBlob();
	bool enemy_wields_something = enemy_carried !is null;
	bool enemy_has_firearm = enemy_wields_something && enemy_carried.hasTag("firearm");
	bool enemy_just_shoot = enemy_has_firearm && (getGameTime()-enemy_carried.get_u32("last_shot_time"))<25;
	//it faces us and shoots
	bool enemy_shot_our_direction = enemy_just_shoot && target.isFacingLeft()!=blob.isFacingLeft();
	//we can stop shielding and should start firing back immediately
	bool enemy_got_no_ammo = enemy_has_firearm && enemy_carried.get_u8("clip")<1;
	
	bool enemy_vulnerable = isKnocked(target);
	
	bool we_strong = blob.getHealth()>blob.getInitialHealth()*(2.0f/3)*difficulty;
	
	bool danger_nearby = important_target !is null;
	//print(blob.getHealth()+" AAA "+blob.getInitialHealth()*(2.0f/3));
	
	bool should_shield = !enemy_got_no_ammo && enemy_shot_our_direction && visibleTarget && !we_strong || danger_nearby;
	
	if (getGameTime()%150==0 && should_shield && gotItem(blob, backup_name))
		set_emoteByCommand(blob, "smile");
		
	if (enemy_vulnerable)
		set_emoteByCommand(blob, "troll");
		
	if ((targetDistance > 50.0f || enemy_vulnerable) && !should_shield || we_strong)
	{
		if (carried is null) return;
		if (carried.getName()==backup_name) {
			blob.server_PutInInventory(carried);
		}
		blob.server_Pickup(gun);
		@gun = carried;
		if (gun is null) return;
		
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
		if (we_strong)
			DefaultChaseBlob(blob, target);
	}
	else
	{
		if (danger_nearby)
			blob.setAimPos(important_target.getPosition());
		else
			blob.setAimPos(targetPos);
		
		CBlob@ carried = blob.getCarriedBlob();
		CBlob@ backup_item = blob.getInventory().getItem(backup_name);
		
		bool got_carried = carried !is null;
		
		//change carried to backup item
		if (got_carried) {
			if (carried.getName()!=backup_name) {
				blob.server_PutInInventory(carried);
			}
		}
		if (backup_item !is null) {
			blob.server_Pickup(backup_item);
		}
		
		blob.setKeyPressed(key_action2, should_shield || (targetDistance<=50&&enemy_wields_something));
		
		if (danger_nearby) {
			DefaultRetreatBlob(blob, important_target);
			return;
		}
		
		bool we_on_ground = blob.isOnGround();
		bool target_can_be_hit = Maths::Abs(targetPos.y-mypos.y)<blob.getRadius()*1.2f&&Maths::Abs(targetPos.x-mypos.x)<=50.0f;
		if (target_can_be_hit && we_on_ground) {
			blob.setKeyPressed(key_action1, true);
			blob.set_u32("last_bash", getGameTime());
		} else if (got_carried && (getGameTime()-blob.get_u32("last_bash"))>carried.get_s32("bash_interval")) {
			blob.setKeyPressed(key_action1, false);
		}
		
		if (!target_can_be_hit && got_carried && carried.getName()==backup_name) {
			DefaultChaseBlob(blob, target);
		}
	}
}

void getYourselfABackupItem(CBlob@ this)
{
	if (!isServer()) return;
	if (this.hasTag("got shield")) return;
	
	CPlayer@ player = this.getPlayer();
	if (player is null) return;
	//print("got a shield");
	
	const u8 TEAMNUM = this.getTeamNum();
	
	CBlob@ backup_item = server_CreateBlob(this.get_string("backup_name"), TEAMNUM, this.getPosition());
	this.server_PutInInventory(backup_item);
	backup_item.AddScript("DieUponOwnerDeath.as");
	backup_item.AddScript("DoTicksInInventory.as");
	backup_item.SetDamageOwnerPlayer(player);
	
	this.Tag("got shield");
}