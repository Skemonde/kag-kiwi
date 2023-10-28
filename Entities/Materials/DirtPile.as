void onInit(CBlob@ this)
{	
	this.maxQuantity = 250;
	this.inventoryIconFrame = 1;
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}