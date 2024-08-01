//#include "KIWI_Locales"

void onInit(CBlob@ this)
{
	//this.setInventoryName(Names::name_medic_helmet);
	this.set_string("associated_script", "MedicLogic.as");
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @ap)
{
	this.setAngleDegrees(0);
	this.getSprite().ResetTransform();
}