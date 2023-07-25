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
	bool facing = (blob.getAimPos().x <= blob.getPosition().x);
	if (!(Maths::Abs(blob.getAimPos().x-blob.getPosition().x)>Maths::Abs(blob.getAimPos().y-blob.getPosition().y)*0.5f)||blob.isAttached()) return;
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
