void onInit(CBlob@ this)
{	
	this.set_u8("decay step", 3);
	this.maxQuantity = 50;
	this.inventoryIconFrame = 1;
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}