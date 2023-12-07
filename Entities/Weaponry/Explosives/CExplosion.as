
const int MAX_BOOMS_PER_TICK = 5;

class CExplosion
{
	u32 time;
	u16 owner_id;
	u8 power;
	f32 map_radius;
	f32 blob_radius;
	u8 map_damage;
	f32 blob_damage;
	
	CExplosion(
		const u32&in p_time,
		const u16&in p_owner_id,
		const u8&in p_power = 1,
		const f32&in p_map_radius = 8.0f,
		const f32&in p_blob_radius = 8.0f,
		const u8&in p_map_damage = 1,
		const f32&in p_blob_damage = 20
	)
	{
		time = p_time;
		owner_id = p_owner_id;
		power = p_power;
		map_radius = p_map_radius;
		blob_radius = p_blob_radius;
		map_damage = p_map_damage;
		blob_damage = p_blob_damage;
	}
};

class Holder
{
	CExplosion[] list;
	Holder()
	{}
};

bool gotTooManyInOneTick(u32 time)
{
	CRules@ rules = getRules();
    Holder@ holder;
    if (!rules.get("explosion processor", @holder)) return false;
	
	u32 expl_amount = 0;
	for (int idx = 0; idx < holder.list.size(); ++idx) {
		CExplosion@ boom = holder.list[idx];
		if (boom is null) continue;
		if (boom.time==time)
			expl_amount++;
	}
	print("got "+expl_amount+" booms at tick "+time);
	return expl_amount>=MAX_BOOMS_PER_TICK;
}

void RemoveFromProcessor(u16 element_id)
{
	if (!isServer()) return;
	
	CRules@ rules = getRules();
	
    Holder@ holder;

    rules.get("explosion processor", @holder);
	
	if (holder.list.size()<element_id) return;
	
	holder.list.removeAt(element_id);
	
	rules.set("explosion processor", holder);
}

void AddToProcessor(u16 owner_id, u32 time, u8 power)
{
	if (!isServer()) return;
	
	CRules@ rules = getRules();
	
    Holder@ holder;

    rules.get("explosion processor", @holder);
	
	u32 new_time = time;
	while (gotTooManyInOneTick(new_time)) {
		new_time++;
	}
	CExplosion@ new_boom = CExplosion(new_time, owner_id, power);
	
	holder.list.push_back(new_boom);
	print("added? "+holder.list.size());
	
    rules.set("explosion processor", holder);
}