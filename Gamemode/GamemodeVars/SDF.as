shared class SDFVars
{
	u32 match_time;
	u16 first_team_lives;
	u16 second_team_lives;
	u32 match_ending_time; // a moment a map is changed at
	
	SDFVars(const u32&in _match_time)
	{
		this.match_time = _match_time;
		this.first_team_lives = 10;
		this.second_team_lives = 10;
		this.match_ending_time = 20*60*getTicksASecond();
	}
	
	SDFVars(CBitStream@ params)
	{
		u32 _match_time; if (!params.saferead_u32(_match_time)) return;
		u16 _first_team_lives; if (!params.saferead_u16(_first_team_lives)) return;
		u16 _second_team_lives; if (!params.saferead_u16(_second_team_lives)) return;
		u32 _match_ending_time; if (!params.saferead_u32(_match_ending_time)) return;
		
		this.match_time = _match_time;
		this.first_team_lives = _first_team_lives;
		this.second_team_lives = _second_team_lives;
		this.match_ending_time = _match_ending_time;
	}
	
	void serialize(CBitStream@ params)
    {
		params.Clear();
		
		params.write_u32(match_time);
		params.write_u16(first_team_lives);
		params.write_u16(second_team_lives);
		params.write_u32(match_ending_time);
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
	
	f32 getMatchEngingTime() {
		return match_ending_time;
	}
	
	void SetMatchTime(u32 _match_time) {
		this.match_time = _match_time;
	}
	
	void SetMatchEngingTime(u32 _match_ending_time) {
		this.match_ending_time = _match_ending_time;
	}
};
