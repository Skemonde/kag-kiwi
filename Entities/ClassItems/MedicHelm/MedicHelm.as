
void onInit(CBlob@ this)
{
	this.set_string("associated_script", "MedicLogic.as");
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @ap)
{
	this.setAngleDegrees(0);
	this.getSprite().ResetTransform();
}