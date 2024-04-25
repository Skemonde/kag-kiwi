//set facing direction to aiming direction

void onInit(CMovement@ this)
{
	//this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
	this.getCurrentScript().tickFrequency = 3;
}

void onTick(CMovement@ this)
{
	CBlob@ blob = this.getBlob();
	CBlob@ holder_vehicle = getBlobByNetworkID(blob.get_u16("my vehicle"));
	
	bool turret_gunner = holder_vehicle !is null && blob.isAttachedTo(holder_vehicle) && holder_vehicle.hasTag("turret");
	
	bool facing = (blob.getAimPos().x <= blob.getPosition().x);
	if (!(Maths::Abs(blob.getAimPos().x-blob.getPosition().x)>Maths::Abs(blob.getAimPos().y-blob.getPosition().y)*0.15f)||(blob.isAttached()&&blob.hasTag("isInVehicle")&&turret_gunner)) return;
	
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
