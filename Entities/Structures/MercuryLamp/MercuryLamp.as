void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(false);
	this.getShape().getConsts().mapCollisions = true;
    this.getSprite().getConsts().accurateLighting = true;  
	this.getShape().SetStatic(true);
	this.getShape().SetOffset(this.getSprite().getOffset()*-1);
	this.getSprite().SetZ(-70); //background

	this.Tag("builder always hit");
	//so it plays ding sound on damageprocessing
	this.Tag("steel");

	this.SetLight(true);
	this.SetLightRadius(82.0f);
	this.SetLightColor(SColor(255, 255, 240, 171));
}

void onTick(CBlob@ this)
{
	//in case if it's damaged
	//i don't want my precious mercucy lamps to die of gunfire
	//though gunfire can "turn them off"
	if (this.getHealth()<this.getInitialHealth()) {
		this.Untag("bullet_hits");
		this.SetLight(false);
	} else {
		this.Tag("bullet_hits");
		this.SetLight(true);
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (this.getHealth() == this.getInitialHealth()) {
		this.getSprite().PlaySound("GlassBreak1.ogg", 1, float(90+XORRandom(21))*0.01f);
	}
	//constant 1
	return 1;
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return false;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
    return false;
}