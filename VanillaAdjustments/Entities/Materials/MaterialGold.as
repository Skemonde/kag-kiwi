
void onInit(CBlob@ this)
{
  if (isServer())
  {
	this.set_u8("decay step", 0);
  }
  
  this.maxQuantity = 100;

  this.getCurrentScript().runFlags |= Script::remove_after_this;
}
