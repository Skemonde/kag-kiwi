shared s32 getControlledZones(u16 team_num, u16 zone_count)
{
	CRules@ rules = getRules();
	u16 controlled = 0;

	for (int k=0; k<zone_count; ++k)
	{
		u16 zone_team_num = rules.get_u16("towzone"+k+"team");

		u16 power = rules.get_u16("towzone"+k+"power");

		if (power > 0 && zone_team_num == team_num) ++controlled;
	}

	return controlled;
}

shared s32 getZoneTOW(Vec2f pos)
{
	CRules@ rules = getRules();
	for (int k=0; k<5; ++k)
	{
		f32 left = rules.get_f32("towzone" + k);
		f32 right = rules.get_f32("towzone" + (k+1));

		if (pos.x>= left && pos.x <= right)
		{
			return k;
		}
	}

	// blue territory
	if (pos.x < rules.get_f32("towzone0")) return 101;

	// red territory
	else if (pos.x > rules.get_f32("towzone5")) return 102;

	// somethings fucked
	return 69;

}

shared s32 getPointsPerTick_Zones(u16 team_num, u16 zone_count)
{
	return 10 * getControlledZones(team_num, zone_count);
}

shared s32 getPointsPerTick(f32 map_control_percentage)
{
	f32 y = ( (2*map_control_percentage - 1) / (1+Maths::Abs(2*map_control_percentage-1)) )+0.5;
	return y * 100;
}

shared f32 getResupplyModifier(f32 map_control_percentage)
{
	return 1.0 + (map_control_percentage * 0.5);
}

shared f32 getCoinGainModifier(f32 map_control_percentage)
{
	if (getRules().getCurrentState() == WARMUP || getRules().getCurrentState() == INTERMISSION) return 1.00f;

	return 1.0;
	//return (0.4 + 2 * map_control_percentage);
}

shared f32 getCoinLoss(f32 map_control_percentage)
{
	return 0.15;

	//return (0.2 - (0.1 * map_control_percentage));
}