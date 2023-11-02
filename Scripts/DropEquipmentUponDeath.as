#define SERVER_ONLY

void onDie(CBlob@ this)
{
	CPlayer@ player = this.getPlayer();
	if (player is null) return;
	
	f32 hp = Maths::Min(Maths::Abs(this.getHealth()), 2.0f) + 1.0f;
	Vec2f vel = this.getVelocity();
	vel.y -= 3.0f;
	
	string player_name = player.getUsername();
	bool had_helm = getRules().get_bool(player_name + "helm");
	had_helm = !getRules().get_string(player_name+"hat_name").empty();
	
	if (had_helm) {
		CBlob@ new_helm = server_CreateBlob(getRules().get_string(player_name+"hat_name"), this.getTeamNum(), this.getPosition());
		if (new_helm is null) return;
		new_helm.setVelocity(vel + getRandomVelocity(90, hp , 80));
	}
}