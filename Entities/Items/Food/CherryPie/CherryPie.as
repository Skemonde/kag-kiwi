void onInit(CBlob@ this)
{
	this.Tag("ignore_saw");
	//this.setInventoryName("Piwo");
	this.set_f32("food_quality", 0.5f);
	
	this.set_string("eat sound", "eating.ogg");

	//this.getSprite().SetFrameIndex(0);
	//this.SetInventoryIcon(this.getSprite().getConsts().filename, 0, Vec2f(16, 16));
	
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}