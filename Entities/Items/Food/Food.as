#include "FoodCommon"
#include "Skemlib"

void onInit(CBlob@ this)
{
	this.Tag("ignore_saw");
	this.set_u32("customData", 2);

	this.server_setTeamNum(0); // blue fishy like in sprite sheet
}

void onTick(CBlob@ this)
{
	u8 index = this.get_u32("customData");
	if (index > foodz.size()-2)
		index = 3;
	if (this.exists("food sprite"))
	{
		index = this.get_u8("food sprite");
	}
	this.setInventoryName(foodz[index]+getPercentStringFromFloat(food_quality[index]));
	if (this.exists("food name"))
	{
		this.setInventoryName(this.get_string("food name"));
	}
	this.set_f32("food_quality", food_quality[index]);
	
	switch (index) {
		case 2: //healing potion
			this.server_setTeamNum(2);
		case 6: //bier
			this.set_string("eat sound", "drinking.ogg"); break;
		default:
			this.set_string("eat sound", "eating.ogg");
	}

	this.getSprite().SetFrameIndex(index);
	this.SetInventoryIcon(this.getSprite().getConsts().filename, index, Vec2f(16, 16));
	
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}