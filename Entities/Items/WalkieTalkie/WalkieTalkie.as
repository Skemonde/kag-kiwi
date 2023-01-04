
void onInit(CBlob@ this)
{
	this.addCommandID("say_something");
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @ap)
{
	this.getSprite().PlaySound("wt_gal_jawoll.ogg");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBlob@ carried = caller.getCarriedBlob();
	if (carried !is null && carried.getNetworkID() == this.getNetworkID())
	{
		caller.CreateGenericButton("$wt$", Vec2f(2.5, -2), this, this.getCommandID("say_something"), "Order the team to do something!");
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("say_something"))
	{
		u8 person = XORRandom(2);
		u8 voiceline;
		string speaker_name;
		switch (person)
		{
			case 1:
			case 0:
				voiceline = XORRandom(6);
				speaker_name = "gal";
				break;
			//default:
			//	voiceline = XORRandom(3);
			//	speaker_name = "lad";
		}
		this.getSprite().PlaySound("walkie_talkie_" + speaker_name + "_" + voiceline + ".ogg");
	}
}