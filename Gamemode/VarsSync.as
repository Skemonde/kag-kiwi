#include "SoldatInfo"
#include "SDF"

void server_SyncPlayerVars(CRules@ this)
{
	if (!isServer()) return;
	
	SyncRulesProps(this);
	
	SoldatInfo[]@ infos = getSoldatInfosFromRules();
	if (infos is null) return;
	
	for (u32 idx = 0; idx < infos.size(); ++idx) {
		SoldatInfo@ info = infos[idx];
		if (info is null) continue;
		//print("got there");
		CBitStream info_params;
		
		u32 info_destruct_tick = info.getDestructTick();
		if (info_destruct_tick < getGameTime()) {
			server_RemoveSoldatInfo(info.username);
		}
		
		info.serialize(info_params);
		this.SendCommand(this.getCommandID("sync_soldat_info"), info_params);
	}
}

//NOT MEANT TO BE USED ELSEWHERE
void SyncRulesProps(CRules@ this)
{
	return;
	for (u8 player_idx = 0; player_idx < getPlayerCount(); player_idx++)
	{
		CPlayer@ player = getPlayer(player_idx);
		if (player is null) return;
		CBitStream stream;
		string player_name = player.getUsername();
		stream.write_string(player_name);
		stream.write_bool(this.get_bool(player_name + "helm"));
		stream.write_u8(this.get_u8(player_name+"rank"));
		stream.write_bool(this.get_bool(player_name + "autopickup"));
		stream.write_string(this.get_string(player_name + "hat_name"));
		stream.write_string(this.get_string(player_name + "class"));
		stream.write_string(this.get_string(player_name + "hat_script"));
		
		this.SendCommand(this.getCommandID("sync_player_vars"), stream);
	}
}

void server_SyncGamemodeVars(CRules@ this = null)
{
	if (!isServer()||isClient()) return;
	
	if (this is null)
		@this = getRules();
	
	CBitStream stream;
	stream.write_bool(this.get_bool("ammo_usage_enabled"));
	stream.write_u32(this.get_u32("match_time"));
	
	stream.write_f32(this.get_f32("blue points"));
	stream.write_f32(this.get_f32("red points"));
	stream.write_f32(this.get_f32("victory points"));
	stream.write_f32(this.get_f32("winning gap points"));
	stream.write_u16(this.daycycle_speed);
	stream.write_bool(this.get_bool("quit_on_new_map"));
	stream.write_u8(this.get_u8("team6flags"));
	stream.write_u8(this.get_u8("team1flags"));
	stream.write_bool(this.get_bool("cursor_recoil_enabled"));
	stream.write_bool(this.get_bool("free shops"));
	stream.write_u32(this.get_u32("team_6_tags"));
	stream.write_u32(this.get_u32("team_1_tags"));
	
	
	this.SendCommand(this.getCommandID("sync_gamemode_vars"), stream);
	
	SDFVars@ sdf_vars;
	if (!this.get("sdf_vars", @sdf_vars)) return;
	CBitStream SDFparams;
	sdf_vars.serialize(SDFparams);
	this.SendCommand(this.getCommandID("sync_sdf_vars"), SDFparams);
}