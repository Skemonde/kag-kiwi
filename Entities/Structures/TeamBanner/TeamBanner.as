#include "MapFlags.as"
#include "ParticleSparks.as";
#include "KIWI_Hitters.as";

int openRecursion = 0;

void onInit(CBlob@ this)
{
	//this.getShape().SetRotationsAllowed(false);
    this.getSprite().getConsts().accurateLighting = false;
	this.getSprite().SetZ(-10);
	//this.getShape().SetOffset(this.getSprite().getOffset()*-1);

	//this.Tag("builder always hit");
	//this.Tag("steel"); //so it plays ding sound on damageprocessing
	//this.Tag("lamp");
	this.Tag("place ignore facing");
	this.Tag("no bullet affecting");
	
	this.set_Vec2f("snap offset", Vec2f(0, -12));
}

void onSetStatic( CBlob@ this, const bool isStatic )
{
	if (!isStatic) return;
	
	//this.SetLight(true);
	this.getSprite().SetZ(-30); //background

	this.getSprite().PlaySound("/build_door.ogg");
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint) 
{
	this.setAngleDegrees(0);
	this.getShape().SetRotationsAllowed(false);
	
	AttachmentPoint@ head_point = attached.getAttachments().getAttachmentPointByName("HEADWEAR");
	if (head_point !is null && attachedPoint.name=="HEADWEAR")
	{
		//this.setAngleDegrees(30);
		head_point.offsetZ = -10;
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint @detachedPoint) 
{
	this.getShape().SetRotationsAllowed(true);
}

void onTick(CBlob@ this)
{
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return false;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	bool friend = byBlob.getTeamNum()==this.getTeamNum();
	bool standing_nearby = (byBlob.getPosition()-this.getPosition()).Length()<6;
    return friend && standing_nearby;
}