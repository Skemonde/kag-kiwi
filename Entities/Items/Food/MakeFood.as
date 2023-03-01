CBlob@ server_MakeFood(Vec2f atpos, const u8 foodIndex)
{
	if (!getNet().isServer()) { return null; }

	CBlob@ blob = server_CreateBlobNoInit("food");
	if (blob !is null)
	{
		blob.setPosition(atpos);
		blob.Init();
		blob.set_u32("customData", foodIndex);
	}
	return blob;
}

ShopItem@ addFoodItem(CBlob@ this, const string &in foodName, const u8 spriteIndex,
                      const string &in  description, u16 timeToMakeSecs, const u16 quantityLimit, CBitStream@ requirements = null)
{
	const string newIcon = "$" + foodName + "$";
	AddIconToken(newIcon, "Entities/Items/Food/Food.png", Vec2f(16, 16), spriteIndex);
	ShopItem@ item = addProductionItem(this, foodName, newIcon, "food", description, timeToMakeSecs, false, quantityLimit, requirements);
	if (item !is null)
	{
		item.customData = spriteIndex;
	}
	return item;
}

CBlob@ cookFood(CBlob@ this)
{
	u32 foodIndex;

	if (this.getName() == "fishy")
	{
		foodIndex = 1;
	}
	else if (this.getName() == "steak")
	{
		foodIndex = 0;
	}
	else if (this.getName() == "grain")
	{
		foodIndex = 3;
	}
	else if (this.getName() == "egg")
	{
		foodIndex = 4;
	}
	else
	{
		return null;
	}

	CBlob@ food = server_MakeFood(this.getPosition(), foodIndex);
	if (food !is null)
	{
		this.server_Die();
		food.setVelocity(this.getVelocity());
		food.getSprite().PlaySound("SparkleShort.ogg");
		return food;
	}
	return null;
}