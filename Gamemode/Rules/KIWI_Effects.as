#define CLIENT_ONLY

#include "KIWI_Locales"
#include "Zombattle"

void onTick(CRules@ this)
{
	s32 gameTime = getGameTime();
	
	u32 u32_max = -1;
	u32 ticks_left = this.get_u32("match_time")-getTicksASecond();
	f32 minutes_left = ticks_left/(60*getTicksASecond());
	f32 seconds_left = (ticks_left%(60*getTicksASecond()))/getTicksASecond();
	u8 warning_seconds = this.get_u8("seconds_pinging");
	
	if (warning_seconds < 1) return;
	
	if (minutes_left < 1 && seconds_left < warning_seconds && (ticks_left%(60*getTicksASecond()))%getTicksASecond()==0) {
		CPlayer@ localplayer = getLocalPlayer();
		if (localplayer !is null)
		{
			if (seconds_left < 1)
				Sound::Play("/TimeoutPing.ogg");
			else
				Sound::Play("/TimePing.ogg");
		}
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("make_respawn_animation"))
	{
		Vec2f spawnPos;
		if (!params.saferead_Vec2f(spawnPos)) return;
		Sound::Play("reinforcements.ogg", spawnPos, 1, 1);
	}
}