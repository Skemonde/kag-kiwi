//set facing direction to aiming direction
#include "FirearmVars"

void onInit(CMovement@ this)
{
	//this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
	this.getCurrentScript().tickFrequency = 3;
}

void onTick(CMovement@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob.hasTag("halfdead")) return;
	
	CBlob@ carried = blob.getCarriedBlob();
	
	if (carried !is null && carried.hasTag("firearm")) return;
	
	CBlob@ holder_vehicle = getBlobByNetworkID(blob.get_u16("my vehicle"));
	
	bool turret_gunner = holder_vehicle !is null && blob.isAttachedTo(holder_vehicle) && holder_vehicle.hasTag("turret");
	
	bool facing = (blob.getAimPos().x <= blob.getPosition().x);
	
	Vec2f tl = Vec2f(0, -getScreenHeight());
	Vec2f br = Vec2f(0, getScreenHeight());
	
	f32 angle = blob.getAngleRadians();
	
	tl = Vec2f(tl.x * Maths::FastCos(angle) - tl.y * Maths::FastSin(angle), tl.x * Maths::FastSin(angle) + tl.y * Maths::FastCos(angle));
	br = -tl;
	//br = Vec2f(br.x * Maths::FastCos(angle) - br.y * Maths::FastSin(angle), br.x * Maths::FastSin(angle) + br.y * Maths::FastCos(angle));
	
	Vec2f relative_mouse = blob.getAimPos()-blob.getPosition();
	
	if (g_debug == 1 && (getGameTime()%50==0) && blob.isMyPlayer())
	{
		print("\n\n"+getGameTime());
		print("relative mouse "+relative_mouse);
		print("point A "+tl);
		print("point B "+br);
	}
	
	facing = (br.x - tl.x)*(relative_mouse.y - tl.y) - (br.y - tl.y)*(relative_mouse.x - tl.x) > 0;
	
	if ((blob.isAttached()&&blob.hasTag("isInVehicle")&&turret_gunner)||blob.isAttached()&&!blob.hasTag("can change facing")) return;
	
	//print("hello");
	
	if (blob.exists("build_angle")) {
		if (blob.isFacingLeft()&&!facing) {
			//changed from left to right
			if (blob.get_u16("build_angle")==90)
				blob.set_u16("build_angle", 180+blob.get_u16("build_angle"));
			else if (blob.get_u16("build_angle")==270)
				blob.set_u16("build_angle", -180+blob.get_u16("build_angle"));
		} else if (!blob.isFacingLeft()&&facing) {
			//from right to the left
			if (blob.get_u16("build_angle")==90)
				blob.set_u16("build_angle", 180+blob.get_u16("build_angle"));
			else if (blob.get_u16("build_angle")==270)
				blob.set_u16("build_angle", -180+blob.get_u16("build_angle"));
		}
	}
	
	blob.SetFacingLeft(facing);

	// face for all attachments

	if (blob.hasAttached())
	{
		AttachmentPoint@[] aps;
		if (blob.getAttachmentPoints(@aps))
		{
			for (uint i = 0; i < aps.length; i++)
			{
				AttachmentPoint@ ap = aps[i];
				if (ap.socket && ap.getOccupied() !is null)
				{
					ap.getOccupied().SetFacingLeft(facing);
				}
			}
		}
	}
}