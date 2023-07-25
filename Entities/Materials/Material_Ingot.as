void onInit(CBlob@ this)
{	
	this.maxQuantity = 60;
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}