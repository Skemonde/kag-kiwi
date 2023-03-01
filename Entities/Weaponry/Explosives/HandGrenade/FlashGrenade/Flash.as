f32 death_seconds = 8;

void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightRadius(256.0f);
	this.SetLightColor(SColor(255, 255, 255, 255));
	
	this.getShape().SetStatic(true);
	this.server_SetTimeToDie(death_seconds);
}

void onTick(CBlob@ this)
{
	f32 fading = 255-(255.0f/(30*death_seconds))*this.getTickSinceCreated();
	//print("fading "+fading);
	this.SetLightColor(SColor(255, fading, fading, fading));
}