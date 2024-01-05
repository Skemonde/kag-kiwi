void onInit(CBlob@ this)
{
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}
