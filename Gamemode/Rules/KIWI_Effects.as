#define CLIENT_ONLY

#include "KIWI_Locales"
#include "Zombattle"

void onTick(CRules@ this)
{
	s32 gameTime = getGameTime();
	CBlob@[] portals;
	bool zombs_have_spawn = false;
	if (getBlobsByName("zombieportal", portals)) {
		zombs_have_spawn = true;
	}
	if (!zombs_have_spawn) return;
	
	ZombattleVars@ game_vars;
	if (!this.get("zombattle_vars", @game_vars)) return;
	u32 ticks_left = game_vars.recess_time+game_vars.recess_start-gameTime-getTicksASecond();
	f32 minutes_left = ticks_left/(60*getTicksASecond());
	f32 seconds_left = (ticks_left%(60*getTicksASecond()))/getTicksASecond();
	if (minutes_left < 1 && seconds_left < 30 && (ticks_left%(60*getTicksASecond()))%getTicksASecond()==0) {
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