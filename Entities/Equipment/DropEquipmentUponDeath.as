#define SERVER_ONLY
#include "SoldatInfo"
#include "VarsSync"

void onDie(CBlob@ this)
{
	CPlayer@ player = this.getPlayer();
	if (player is null) return;
	
	f32 hp = Maths::Min(Maths::Abs(this.getHealth()), 2.0f) + 1.0f;
	Vec2f vel = this.getVelocity();
	vel.y -= 3.0f;
	
	string player_name = player.getUsername();
	
	SoldatInfo[]@ infos = getSoldatInfosFromRules();
	if (infos is null) return;
	SoldatInfo our_info = getSoldatInfoFromUsername(player_name);
	if (our_info is null) return;
	int info_idx = getInfoArrayIdx(our_info);
	
	string hat_name = infos[info_idx].hat_name;
	bool had_helm = !hat_name.empty();
	
	if (had_helm) {
		CBlob@ new_helm = server_CreateBlob(hat_name, this.getTeamNum(), this.getPosition());
		if (new_helm is null) return;
		new_helm.setVelocity(vel + getRandomVelocity(90, hp , 80));
		
		infos[info_idx].hat_name = "";
		infos[info_idx].clearHatScripts();
	
		getRules().set("soldat_infos", infos);
		server_SyncPlayerVars(getRules());
	}
}