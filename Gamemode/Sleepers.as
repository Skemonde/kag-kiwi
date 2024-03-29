//Allow reconnecting players to get back into the game fast

#define SERVER_ONLY;

#include "RespawnCommon.as";
#include "KnockedCommon.as";

const u32 unused_time_required = 60*getTicksASecond(); //time it takes for a sleeper to be available for respawning players to use

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	//set leaving player as sleeper
	
	CBlob@ blob = player.getBlob();
	if (blob is null || blob.hasTag("undead")) return;
	
	blob.server_SetPlayer(null);
	blob.set_string("sleeper_name", player.getUsername());
	blob.Sync("sleeper_name", true);
	blob.set_string("sleeper_charname", player.getClantag()+"  "+player.getCharacterName());
	blob.setInventoryName(blob.get_string("sleeper_charname"));
	blob.Sync("sleeper_charname", true);
	blob.set_u32("sleeper_time", getGameTime());
	blob.Tag("sleeper");
	
	if (isKnockable(blob))
		setKnocked(blob, 255, true);
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	//see if joining player has a sleeper to use
	
	if (player is null) return;
	
	CBlob@[] sleepers;
	if (!getBlobsByTag("sleeper", @sleepers)) return;
	
	const u8 sleepersLength = sleepers.length;
	for (u8 i = 0; i < sleepersLength; i++)
	{
		CBlob@ sleeper = sleepers[i];
		sleeper.setInventoryName(sleeper.get_string("sleeper_charname"));
		
		if (!sleeper.hasTag("dead") && sleeper.get_string("sleeper_name") == player.getUsername())
		{
			CBlob@ oldBlob = player.getBlob();
			if (oldBlob !is null) oldBlob.server_Die();

			WakeupSleeper(sleeper, player);
			break;
		}
	}
}

void onTick(CRules@ this)
{
	const u32 gametime = getGameTime();
	if (gametime % 250 == 0)
	{
		KnockSleepers();
	}
	
	if (gametime % (30*30) == 0)
	{
		UseSleepersAsRespawn(this);
	}
}

void WakeupSleeper(CBlob@ sleeper, CPlayer@ player)
{
	player.server_setTeamNum(sleeper.getTeamNum());
	
	sleeper.server_SetPlayer(player);
	sleeper.set_string("sleeper_name", "");
	sleeper.Sync("sleeper_name", true);
	sleeper.Untag("sleeper");
	
	//remove knocked
	if (isKnockable(sleeper))
	{
		sleeper.set_u8(knockedProp, 1);

		CBitStream params;
		params.write_u8(1);
		sleeper.SendCommand(sleeper.getCommandID(knockedProp), params);
	}
}

void KnockSleepers()
{
	CBlob@[] sleepers;
	if (!getBlobsByTag("sleeper", @sleepers)) return;
	
	const u8 sleepersLength = sleepers.length;
	for (u8 i = 0; i < sleepersLength; i++)
	{
		CBlob@ sleeper = sleepers[i];
		sleeper.setAimPos(sleeper.getPosition()+Vec2f(10*(sleeper.isFacingLeft()?-1:1),0).RotateBy(30*(sleeper.isFacingLeft()?-1:1)));
		if (isKnockable(sleeper))
			setKnocked(sleeper, 255, true);
	}
}

void UseSleepersAsRespawn(CRules@ this)
{	
	return;
	Respawn[]@ respawns;
	if (!this.get("respawns", @respawns)) return;
	
	CBlob@[] sleepers;
	if (!getBlobsByTag("sleeper", @sleepers)) return;
	
	const u8 sleepersLength = sleepers.length;
	for (u8 i = 0; i < sleepersLength; i++)
	{
		CBlob@ sleeper = sleepers[i];
		if (!sleeper.hasTag("dead") && sleeper.get_u32("sleeper_time") < getGameTime() - unused_time_required)
		{
			for (u8 q = 0; q < respawns.length; q++)
			{
				CPlayer@ player = getPlayerByUsername(respawns[q].username);
				if (player is null || player.getBlob() !is null) continue;
				
				WakeupSleeper(sleeper, player);
				
				respawns.erase(q);
				break;
			}
		}
	}
}
