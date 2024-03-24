#include "MapFlags.as"

int openRecursion = 0;

void onInit(CBlob@ this)
{
	//this.getShape().SetRotationsAllowed(false);
    this.getSprite().getConsts().accurateLighting = false;
	this.getShape().SetOffset(this.getSprite().getOffset()*-1);
	this.getSprite().SetZ(-70); //background

	this.Tag("builder always hit");
	this.Tag("steel"); //so it plays ding sound on damageprocessing
	this.Tag("lamp");
	this.Tag("place ignore facing");
	
	this.set_Vec2f("snap offset", Vec2f(4, 0));

	this.SetLight(false);
	this.SetLightRadius(96.0f);
	this.SetLightColor(SColor(255, 255, 240, 171));
}

void onSetStatic( CBlob@ this, const bool isStatic )
{
	if (!isStatic) return;
	
	this.SetLight(true);

	this.getSprite().PlaySound("/build_door.ogg");
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