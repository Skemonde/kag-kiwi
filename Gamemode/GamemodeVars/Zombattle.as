shared class ZombattleVars
{
	u32 recess_time;
	u32 recess_start;
	u16 waves_survived;
	u16 zombs_max;

	ZombattleVars(const u32&in recess_time, const u32&in recess_start, const u16&in waves_survived)
	{
		this.recess_time = recess_time;
		this.recess_start = recess_start;
		this.waves_survived = waves_survived;
	}
	
	void SetZombsMaximum(u16 zombs_max) {
		this.zombs_max = zombs_max;
	}
};
