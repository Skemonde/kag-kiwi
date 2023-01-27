void onInit(CBlob@ this)
{
	this.getSprite().SetRelativeZ(500.0f);
	this.SetLight(true);
	this.SetLightRadius(8.0f);
	this.SetLightColor(SColor(255, 218, 92, 108));
	
	this.getShape().SetStatic(true);
}