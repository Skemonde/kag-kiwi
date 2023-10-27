void onInit(CBlob@ this)
{	
	this.maxQuantity = 50;
	this.inventoryIconFrame = 1;
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}