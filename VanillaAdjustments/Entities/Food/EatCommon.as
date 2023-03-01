const string heal_id = "heal command";

bool canEat(CBlob@ blob)
{
	return blob.exists("eat sound");
}

// returns the healing amount of a certain food (in quarter hearts) or 0 for non-food
f32 getHealingAmount(CBlob@ food)
{
	if (!canEat(food))
	{
		return 0;
	}

	if (food.getName() == "heart")	    // HACK
	{
		return 0.2; // 20%
	}
	
	if (food.exists("food_quality"))
		return food.get_f32("food_quality");

	return 255; // full healing
}

void Heal(CBlob@ this, CBlob@ food)
{
	bool exists = getBlobByNetworkID(food.getNetworkID()) !is null;
	if (getNet().isServer() && this.hasTag("player") && this.getHealth() < this.getInitialHealth() && !food.hasTag("healed") && exists)
	{
		CBitStream params;
		params.write_u16(this.getNetworkID());
		params.write_f32(getHealingAmount(food));
		food.SendCommand(food.getCommandID(heal_id), params);

		food.Tag("healed");
	}
}
