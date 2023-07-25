shared class SDFVars
{
	u32 match_time;
	u16 first_team_lives;
	u16 second_team_lives;
	
	SDFVars(const u32&in _match_time)
	{
		this.match_time = _match_time;
		this.first_team_lives = 10;
		this.second_team_lives = 10;
	}
	
	SDFVars(CBitStream@ params)
	{
		u32 _match_time; if (!params.saferead_u32(_match_time)) return;
		u16 _first_team_lives; if (!params.saferead_u16(_first_team_lives)) return;
		u16 _second_team_lives; if (!params.saferead_u16(_second_team_lives)) return;
		
		this.match_time = _match_time;
		this.first_team_lives = _first_team_lives;
		this.second_team_lives = _second_team_lives;
	}
	
	void serialize(CBitStream@ params)
    {
		params.Clear();
		
		params.write_u32(match_time);
		params.write_u16(first_team_lives);
		params.write_u16(second_team_lives);
	}
	
	void SetFirstTeamLives(u16 _first_team_lives) {
		this.first_team_lives = _first_team_lives;
	}
	
	void SetSecondTeamLives(u16 _second_team_lives) {
		this.second_team_lives = _second_team_lives;
	}
	
	f32 getMatchTime() {
		return match_time;
	}
	
	void SetMatchTime(u32 _match_time) {
		this.match_time = _match_time;
	}
};
