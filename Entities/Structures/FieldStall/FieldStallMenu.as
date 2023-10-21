#include "Requirements"
#include "ShopCommon"
#include "getShopMenuHeight"

void onInit(CBlob@ this)
{
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 8));
	this.set_u8("shop icon", 25);
	{
		ShopItem@ s = addShopItem(this, "Brick Hammer", "$masonhammer$", "masonhammer", "You can build with it!", true);
		AddRequirement(s.requirements, "coin", "", "", 1);
		AddRequirement(s.requirements, "no more", "masonhammer", "Brick Hammer", 6);
	}
	{
		ShopItem@ s = addShopItem(this, "Drill", "$drill$", "drill", "a Drill huh?", true);
		AddRequirement(s.requirements, "coin", "", "", 1);
		AddRequirement(s.requirements, "no more", "drill", "Drill", 6);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	this.set_Vec2f("shop menu size", getShopMenuHeight(this, 4));
	this.set_bool("shop available", true);
}