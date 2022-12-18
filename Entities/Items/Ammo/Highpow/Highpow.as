
void onInit(CBlob@ this)
{
  if (getNet().isServer())
  {
    this.set_u8('decay step', 2);
  }
  
  this.Tag("ammo");

  this.maxQuantity = 40;

  this.getCurrentScript().runFlags |= Script::remove_after_this;
}
