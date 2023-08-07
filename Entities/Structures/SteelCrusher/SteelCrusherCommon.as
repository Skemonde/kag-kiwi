u16 getProducingInterval()
{
	//return 20;
	return Maths::Max(60, 180.0f-Maths::Floor(getRules().get_u32("match_time")/getTicksASecond()/60)*2);
}