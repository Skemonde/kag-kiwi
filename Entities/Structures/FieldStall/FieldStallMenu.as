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
		AddRequirement(s.requirements, "no more", "masonhammer", "Brick Hammer", sv_maxplayers/2);
	}
	{
		ShopItem@ s = addShopItem(this, "Drill", "$drill$", "drill", "a Drill huh?", true);
		AddRequirement(s.requirements, "coin", "", "", 1);
		AddRequirement(s.requirements, "no more", "drill", "Drill", sv_maxplayers/2);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	}
	this.set_Vec2f("shop menu size", getShopMenuHeight(this, 4));
	this.set_bool("shop available", true);
}