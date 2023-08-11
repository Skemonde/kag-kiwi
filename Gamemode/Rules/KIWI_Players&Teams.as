#include "BaseTeamInfo"
#include "PlayerInfo"

shared class KIWIPlayerInfo : PlayerInfo
{
	u32 can_spawn_time;

	u32 flag_captures;

	u32 spawn_point;

	u32 items_collected;
	
	//kiwi vars
	
	bool auto_pickup;

	KIWIPlayerInfo() { Setup("", 0, ""); }
	KIWIPlayerInfo(string _name, u8 _team, string _default_config) { Setup(_name, _team, _default_config); }

	void Setup(string _name, u8 _team, string _default_config)
	{
		PlayerInfo::Setup(_name, _team, _default_config);
		can_spawn_time = 0;
		flag_captures = 0;
		spawn_point = 0;

		items_collected = 0;
		auto_pickup = true;
	}
};

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