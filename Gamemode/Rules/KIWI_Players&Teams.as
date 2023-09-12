#include "BaseTeamInfo"
#include "PlayerInfo"

shared class KIWIPlayerInfo : PlayerInfo
{
	//from PlayerInfo
	//
	//string username;
	//u8 team, oldteam;
	//string blob_name;
	//int spawnsCount;
	//int lastSpawnRequest;
	//int customImmunityTime;
	
	u32 can_spawn_time;

	u32 spawn_point;
	
	bool auto_pickup;
	
	string helm_name;
	
	u8 rank;

	KIWIPlayerInfo() { Setup("", 0, ""); }
	KIWIPlayerInfo(string _name, u8 _team, string _default_config) { Setup(_name, _team, _default_config); }

	void Setup(string _name, u8 _team, string _default_config)
	{
		PlayerInfo::Setup(_name, _team, _default_config);
		can_spawn_time = 0;
		spawn_point = 0;
		auto_pickup = true;
		helm_name = "";
		rank = 0;
	}
	
	void SyncFromParams(CBitStream@ params)
	{
		//assuming it was already setup before serializing
		//so we change only KIWI's vars
		string _username; if (!params.saferead_string(_username)) return;
		bool _auto_pickup; if (!params.saferead_bool(_auto_pickup)) return;
		string _helm_name; if (!params.saferead_string(_helm_name)) return;
		u8 _rank; if (!params.saferead_u16(_rank)) return;
		
		this.auto_pickup = _auto_pickup;
		this.helm_name = _helm_name;
		this.rank = _rank;
	}
	
	void serialize(CBitStream@ params, bool clear = true)
    {
		if (clear) params.Clear();
		
		params.write_bool(auto_pickup);
		params.write_string(helm_name);
		params.write_u8(rank);
	}
};

KIWIPlayerInfo@ getKIWIPlayerInfo(string username, KIWIPlayerInfo[]@ infos)
{
	for (uint i = 0; i < infos.length; i++)
	{
		KIWIPlayerInfo@ b = infos[i];
		if (b.username == username)
			return b;
	}
	return null;
}

//teams

shared class KIWITeamInfo : BaseTeamInfo
{
	PlayerInfo@[] spawns;

	KIWITeamInfo() { super(); }

	KIWITeamInfo(u8 _index, string _name)
	{
		super(_index, _name);
	}

	void Reset()
	{
		BaseTeamInfo::Reset();
		//spawns.clear();
	}
};

shared void resetHeadwearFromUsername(string player_name)
{
	//
	getRules().set_string(player_name + "hat_script", "");
	getRules().set_string(player_name + "hat_name", "");
	//
	getRules().set_bool(player_name + "helm", false);
}