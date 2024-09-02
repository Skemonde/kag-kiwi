bool canEat(CBlob@ blob)
{
	return blob.exists("eat sound");
}

// returns the healing amount of a certain food (in quarter hearts) or 0 for non-food
u8 getHealingAmount(CBlob@ food)
{
	if (!canEat(food))
	{
		return 0;
	}

	if (food.getName() == "heart" || food.getName() == "food")	    // HACK
	{
		return 0; // 1 heart
	}

	return 1; // full healing
}

f32 getHealingQuality(CBlob@ human, CBlob@ food)
{
	if (food.exists("food_quality"))
	{
		return human.getInitialHealth()*2*food.get_f32("food_quality");
	}
	
	return 0;
}

void Heal(CBlob@ this, CBlob@ food)
{
	bool exists = getBlobByNetworkID(food.getNetworkID()) !is null;
	
	if (isServer() && this.hasTag("player") && this.getHealth() < this.getInitialHealth() && !food.hasTag("healed") && exists)
	{
		u32 ticks_till_next_heal = Maths::Max(0, 1.0f*(-getGameTime()+this.get_u32("next_heal")));
		
		if (ticks_till_next_heal > 0) return;
		
		u8 heal_amount = getHealingAmount(food);

		if (heal_amount == 255)
		{
			this.add_f32("heal amount", this.getInitialHealth() - this.getHealth());
			this.server_SetHealth(this.getInitialHealth());
			
			this.set_u32("last_hit_time", getGameTime());
		}
		else if (heal_amount > 0)
		{
			f32 oldHealth = this.getHealth();
			this.server_Heal(getHealingQuality(this, food));
			this.add_f32("heal amount", this.getHealth() - oldHealth);
			
			this.set_u32("last_hit_time", getGameTime());
		}
		else
		{
			if (this.getHealth()<=0)
				this.server_SetHealth(0.05f);
			this.set_u32("last_hit_time", getGameTime()-40.0f*getTicksASecond());
		}

		//give coins for healing teammate
		if (food.exists("healer"))
		{
			CPlayer@ player = this.getPlayer();
			u16 healerID = food.get_u16("healer");
			CPlayer@ healer = getPlayerByNetworkId(healerID);
			if (player !is null && healer !is null)
			{
				bool healerHealed = healer is player;
				bool sameTeam = healer.getTeamNum() == player.getTeamNum();
				if (!healerHealed && sameTeam)
				{
					int coins = 10;
					healer.server_setCoins(healer.getCoins() + coins);
				}
			}
		}

		this.Sync("heal amount", true);

		food.SendCommand(food.getCommandID("heal command client")); // for sound
		if (food.getMaxQuantity()<2)
		{
			food.Tag("healed");
			food.server_Die();
		}
		else
		{
			if (this.getInventory() !is null && this.getInventory().isInInventory(food))
				this.TakeBlob(food.getName(), 1);
			else
			{
				food.server_SetQuantity(food.getQuantity()-1);
				if (food.getQuantity()<1)
					food.server_Die();
			}
		}
		
		u32 eating_penalty_ticks = 165;
		if (food.exists("heal_penalty"))
			eating_penalty_ticks = food.get_u32("heal_penalty");
		
		this.set_u32("next_heal", getGameTime()+eating_penalty_ticks);
		this.set_u32("current_heal_penalty", eating_penalty_ticks);
	}
}
