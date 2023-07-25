

void onDie(CBlob@ this)
{
	CPlayer@ player = this.getPlayer();
	if (player is null) return;
	string player_name = player.getUsername();
	bool had_helm = getRules().get_bool(player_name + "helm");
	
	if (had_helm && isServer() && !getRules().get_string(player_name+"hat_name").empty()) {
		CBlob@ new_helm = server_CreateBlob(getRules().get_string(player_name+"hat_name"), -1, this.getPosition());
	}
}