void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightRadius(16.0f);
	this.SetLightColor(SColor(255, 255, 50, 120));
	this.getSprite().SetZ(1500.3f);
	this.getSprite().setRenderStyle(RenderStyle::additive);
	this.getSprite().getConsts().accurateLighting = false;
	
	this.getShape().SetStatic(true);
}