#define SERVER_ONLY

void onDie(CBlob@ this)
{
	CPlayer@ player = this.getPlayer();
	if (player is null) return;
	string player_name = player.getUsername();
	bool had_helm = getRules().get_bool(player_name + "helm");
	had_helm = !getRules().get_string(player_name+"hat_name").empty();
	
	if (had_helm) {
		CBlob@ new_helm = server_CreateBlob(getRules().get_string(player_name+"hat_name"), this.getTeamNum(), this.getPosition());
	}
}