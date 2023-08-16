// Soldat brain

#define SERVER_ONLY

#include "BrainCommon.as"
#include "Knock.as"

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


void AttackBlob(CBlob@ blob, CBlob @target)
{
	Vec2f mypos = blob.getPosition();
	Vec2f targetPos = target.getPosition();
	Vec2f targetVector = targetPos - mypos;
	f32 targetDistance = targetVector.Length();
	const s32 difficulty = blob.get_s32("difficulty");

	JumpOverObstacles(blob);

	const u32 gametime = getGameTime();

	// fire

	if (targetDistance > 50.0f && !isKnocked(target))
	{
		CBlob@ carried = blob.getCarriedBlob();
		if (carried is null) return;
		if (carried.getName()=="combatknife") {
			CBlob@ gun = blob.getInventory().getItem(blob.get_string("main gun"));
			if (gun is null) return;
			blob.server_PutInInventory(carried);
			blob.server_Pickup(gun);
		}

		if (true)
		{
			bool worthShooting;
			bool hardShot = targetDistance > 30.0f * 8.0f || target.getShape().vellen > 5.0f;
			f32 aimFactor = 0.45f - XORRandom(100) * 0.003f;
			aimFactor += (-0.2f + XORRandom(100) * 0.004f) / float(difficulty > 0 ? difficulty : 1.0f);
			blob.setAimPos(blob.getBrain().getShootAimPosition(targetPos, hardShot, worthShooting, aimFactor));
			worthShooting = true;
			if (worthShooting)
			{
				blob.setAimPos(targetPos);
				blob.setKeyPressed(key_action1, true);
			}
		}
	}
	else
	{
		blob.setAimPos(targetPos);
		CBlob@ carried = blob.getCarriedBlob();
		if (carried is null) return;
		if (carried.getName()!="combatknife") {
			CBlob@ knife = blob.getInventory().getItem("combatknife");
			if (knife is null) return;
			blob.server_PutInInventory(carried);
			blob.server_Pickup(knife);
		}
		DefaultChaseBlob(blob, target);
		blob.setKeyPressed(key_action2, true);
	}
}

