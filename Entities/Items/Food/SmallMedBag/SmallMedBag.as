void onInit(CBlob@ this)
{	
	this.Tag("medkit");
	
	this.set_f32("food_quality", 75.0f/200);
	this.set_u32("heal_penalty", 1.0f*getTicksASecond());
	
	this.set_string("eat sound", "Heal.ogg");
	
	this.maxQuantity = 2;
	
	if (this.getQuantity()==1)
		this.server_SetQuantity(this.getMaxQuantity());
	
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}