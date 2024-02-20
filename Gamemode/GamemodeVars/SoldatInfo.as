

shared class SoldatInfo
{
	string username;
	string hat_name;
	bool autopickup;
	u8 rank;
	bool commanding;
	string[] hat_scripts;
	
	SoldatInfo(CPlayer@ player)
	{
		if (player is null) {
			error("Null player on SoldatInfo constructor calling! Investigate!");
			return;
		}
		
		this.username = player.getUsername();
		this.hat_name = "";
		this.autopickup = true;
		this.rank = 0;
		this.commanding = false;
	}
	
	SoldatInfo(CBitStream@ params)
	{
		string _username; if (!params.saferead_string(_username)) return;
		string _hat_name; if (!params.saferead_string(_hat_name)) return;
		bool _autopickup; if (!params.saferead_bool(_autopickup)) return;
		u8 _rank; if (!params.saferead_u8(_rank)) return;
		bool _commanding; if (!params.saferead_bool(_commanding)) return;
		
		this.username = _username;
		this.hat_name = _hat_name;
		this.autopickup = _autopickup;
		this.rank = _rank;
		this.commanding = _commanding;
		//print("received rank "+_rank);
		
		//doing hat scripts at the very end so you can add multiple of them to a params obj
		while (!params.isBufferEnd()) {
			string _hat_script; if (!params.saferead_string(_hat_script)) return;
			hat_scripts.push_back(_hat_script);
		}
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
		//print("sending rank "+rank);
		
		for (int idx = 0; idx < hat_scripts.size(); ++idx) {
			params.write_string(hat_scripts[idx]);
		}
	}
};

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

void server_RemoveSoldatInfo(CPlayer@ player)
{
	if (!isServer()) return;
	
	if (player is null) return;
	string username = player.getUsername();
	
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
