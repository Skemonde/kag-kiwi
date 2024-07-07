

shared class SoldatInfo
{
	string username;
	string hat_name;
	bool autopickup;
	u8 rank;
	bool commanding;
	u32 destruct_tick;
	string lmb_bind_name;
	string mmb_bind_name;
	string rmb_bind_name;
	string[] hat_scripts;
	
	SoldatInfo(CPlayer@ player)
	{
		if (player is null) {
			error("Null player on SoldatInfo constructor call! Investigate!");
			return;
		}
		
		this.username = player.getUsername();
		this.hat_name = "";
		this.autopickup = true;
		this.rank = 0;
		this.commanding = false;
		this.destruct_tick = -1;
		this.lmb_bind_name = "";
		this.mmb_bind_name = "";
		this.rmb_bind_name = "";
	}
	
	SoldatInfo(CBitStream@ params)
	{
		string _username; if (!params.saferead_string(_username)) return;
		string _hat_name; if (!params.saferead_string(_hat_name)) return;
		bool _autopickup; if (!params.saferead_bool(_autopickup)) return;
		u8 _rank; if (!params.saferead_u8(_rank)) return;
		bool _commanding; if (!params.saferead_bool(_commanding)) return;
		u32 _destruct_tick; if (!params.saferead_u32(_destruct_tick)) return;
		string _lmb_bind_name; if (!params.saferead_string(_lmb_bind_name)) return;
		string _mmb_bind_name; if (!params.saferead_string(_mmb_bind_name)) return;
		string _rmb_bind_name; if (!params.saferead_string(_rmb_bind_name)) return;
		
		this.username = _username;
		this.hat_name = _hat_name;
		this.autopickup = _autopickup;
		this.rank = _rank;
		this.commanding = _commanding;
		this.destruct_tick = _destruct_tick;
		this.lmb_bind_name = _lmb_bind_name;
		this.mmb_bind_name = _mmb_bind_name;
		this.rmb_bind_name = _rmb_bind_name;
		
		//doing hat scripts at the very end so you can add multiple of them to a params obj
		while (!params.isBufferEnd()) {
			string _hat_script; if (!params.saferead_string(_hat_script)) return;
			hat_scripts.push_back(_hat_script);
		}
	}
	
	void clearHatScripts()
	{
		this.hat_scripts.clear();
	}
	
	void SetDestructTick(u32 game_time)
	{
		this.destruct_tick = game_time;
	}
	
	u32 getDestructTick()
	{
		return this.destruct_tick;
	}
	
	void SetRank(u8 new_rank)
	{
		this.rank = new_rank;
	}
	
	u8 getRank()
	{
		return this.rank;
	}
	
	void serialize(CBitStream@ params)
    {
		params.Clear();
		
		params.write_string(username);
		params.write_string(hat_name);
		params.write_bool(autopickup);
		params.write_u8(rank);
		params.write_bool(commanding);
		params.write_u32(destruct_tick);
		params.write_string(lmb_bind_name);
		params.write_string(mmb_bind_name);
		params.write_string(rmb_bind_name);
		
		for (int idx = 0; idx < hat_scripts.size(); ++idx) {
			params.write_string(hat_scripts[idx]);
		}
	}
};

void server_ReassignCommander(CPlayer@ traitor, int abandoned_team = -1)
{
	if (!isServer()) return;
	
	if (abandoned_team<0) abandoned_team = traitor.getTeamNum();
	
	if (traitor is null)
	{
		error("Skem should consider killing himself >:(");
		return;
	}
	
	SoldatInfo[]@ infos = getSoldatInfosFromRules();
	if (infos is null) return;
	SoldatInfo info = getSoldatInfoFromUsername(traitor.getUsername());
	if (info is null) return;
	if (info.rank < 4 || !info.commanding) return;
	int traitor_idx = getInfoArrayIdx(info);
	
	infos[traitor_idx].SetRank(0);
	infos[traitor_idx].commanding = true;
	
	CPlayer@[] team;
	for (u32 i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ p = getPlayer(i);
		if (p is null) continue;
		if (p.getTeamNum()!=abandoned_team || p is traitor) continue;
		
		team.push_back(p);
	}
	
	if (team.size()<1) return;
	
	int best_score = 0;
	int our_hero = 0;
	for (u32 i = 0; i < team.size(); i++)
	{
		CPlayer@ p = team[i];
		if (p is null) continue;
		
		if (p.getScore() > best_score) {
			best_score = p.getScore();
			our_hero = i;
		}
	}
	
	int hero_idx = getInfoArrayIdx(getSoldatInfoFromUsername(team[our_hero].getUsername()));
	
	server_CheckIfShouldBecomeCommanding(team[our_hero], abandoned_team);
	//infos[hero_idx].SetRank(6);
	//infos[hero_idx].commanding = true;
	
	getRules().set("soldat_infos", infos);
}

void server_CheckIfShouldBecomeCommanding(CPlayer@ player, u8 team_num = 0, bool goes_commander = false)
{
	if (!isServer()) return;
	
	bool going_to_spec = team_num==getRules().getSpectatorTeamNum();
	
	if (player is null) return;
	string username = player.getUsername();
	
	SoldatInfo[]@ infos = getSoldatInfosFromRules();
	if (infos is null) return;
	SoldatInfo info = getSoldatInfoFromUsername(username);
	if (info is null) return;
	
	int info_idx = getInfoArrayIdx(info);
	
	//print("hello!");
	
	int teammate_amount;
	if (!goes_commander)
	{
		goes_commander = true;
		for (int plr_idx = 0; plr_idx < getPlayersCount(); ++plr_idx)
		{
			CPlayer@ current_player = getPlayer(plr_idx);
			if (current_player is null || current_player is player) continue;
			
			if (current_player.getTeamNum()==team_num) {
				SoldatInfo cur_info = getSoldatInfoFromUsername(current_player.getUsername());
				if (cur_info is null) continue;
				int cur_pla_rank = cur_info.rank;
				if (cur_pla_rank>4)
					goes_commander = false;
			}
		}
	}
	
	if (!goes_commander&&!going_to_spec) return;
	
	//print("yay");
	
	infos[info_idx].SetRank(going_to_spec?12:6);
	infos[info_idx].commanding = true;
	
	getRules().set("soldat_infos", infos);
}

void server_AddSoldatInfo(SoldatInfo@ info)
{
	if (!isServer()) return;
	
	SoldatInfo[]@ infos = getSoldatInfosFromRules();
	if (infos is null) {
		error("Rules got no soldat infos in server_AddSoldatInfo! Investigate!");
		return;
	}
	
	//info.SetRank(2);
	
	infos.push_back(info);
	getRules().set("soldat_infos", infos);
}

void server_SetInfoToRemove(CPlayer@ player)
{
	if (!isServer()) return;
	
	if (player is null) return;
	string username = player.getUsername();
	
	SoldatInfo[]@ infos = getSoldatInfosFromRules();
	if (infos is null) {
		error("Rules got no soldat infos in server_SetInfoToRemove! Investigate!");
		return;
	}
	
	SoldatInfo@ info = getSoldatInfoFromUsername(username);
	if (info is null) return;
	
	int info_idx = getInfoArrayIdx(info);
	
	if (info_idx < 0) return;
	
	//	~2 minutes are given to relog
	//	after that soldat info is destroyed
	infos[info_idx].SetDestructTick(getGameTime()+3590);
	getRules().set("soldat_infos", infos);
}

void server_RemoveSoldatInfo(string username)
{
	if (!isServer()) return;
	
	SoldatInfo[]@ infos = getSoldatInfosFromRules();
	if (infos is null) {
		error("Rules got no soldat infos in server_RemoveSoldatInfo! Investigate!");
		return;
	}
	
	SoldatInfo@ info = getSoldatInfoFromUsername(username);
	if (info is null) return;
	
	int info_idx = getInfoArrayIdx(info);
	
	if (info_idx < 0) return;
	
	infos.removeAt(info_idx);
	getRules().set("soldat_infos", infos);
}

void server_RemoveSoldatInfo(CPlayer@ player)
{
	if (!isServer()) return;
	
	if (player is null) return;
	string username = player.getUsername();
	
	server_RemoveSoldatInfo(username);
}

SoldatInfo[]@ getSoldatInfosFromRules()
{
	SoldatInfo[]@ infos;
	getRules().get("soldat_infos", @infos);
	return infos;
}

int getInfoArrayIdx(SoldatInfo@ info)
{
	SoldatInfo[]@ infos = getSoldatInfosFromRules();
	if (infos is null) {
		error("Rules got no soldat infos in getInfoArrayIdx! Investigate!");
		return -1;
	}
	
	for (int idx = 0; idx < infos.size(); ++idx)
	{
		SoldatInfo@ current_info = infos[idx];
		if (current_info is null || info is null) continue;
		if (current_info.username == info.username) {
			if (g_debug == 3)
				print(current_info.username+" info is at position "+idx);
			
			return idx;
		}
	}
	return -1;
}
	
SoldatInfo@ getSoldatInfoFromUsername(string username_to_search)
{
	SoldatInfo[]@ infos = getSoldatInfosFromRules();
	if (infos is null) {
		error("Rules got no soldat infos in getSoldatInfoFromUsername! Investigate!");
		return null;
	}
	//print("info size "+infos.size());
	
	return getSoldatInfoFromUsername(username_to_search, infos);
}

SoldatInfo@ getSoldatInfoFromUsername(string username_to_search, SoldatInfo[]@ infos)
{	
	if (infos !is null && infos.size() > 0)
	for (int idx = 0; idx < infos.size(); ++idx)
	{
		SoldatInfo@ current_info = infos[idx];
		if (current_info.username == username_to_search)
			return current_info;
	}
	return null;
}

SoldatInfo@ getSoldatInfoFromPlayer(CPlayer@ player)
{
	return getSoldatInfoFromUsername(player.getUsername());
}
