// Tank logic 

void onInit( CBlob@ this )
{
	this.Tag("vehicle");
	this.Tag("ground_vehicle");
	this.Tag("tank");
	this.Tag("non_pierceable");
	this.Tag("convert on sit");
	this.Tag("no team lock");
	
	this.set_f32("move_speed", 100);
	this.set_f32("turn_speed", 20);
	this.set_string("movement_sound", "med_tank_tracks1.ogg");
	
	this.getSprite().SetZ(-1);
	
	if (getNet().isServer()||true)
	{
		CBlob@ blob = server_CreateBlobNoInit("firsttankturret");
		if (blob !is null)
		{
			blob.server_setTeamNum(this.getTeamNum());
			blob.setInventoryName(this.getInventoryName() + "'s Turret");
			//blob.getSprite().SetRelativeZ(40);
			this.set_u16("turret_id", blob.getNetworkID());
			blob.set_u16("mothertank_id", this.getNetworkID());
			blob.Init();
			this.server_AttachTo(blob, "TURRET");
			blob.getShape().getConsts().collideWhenAttached = true;
		}
	}
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	//return Vehicle_doesCollideWithBlob_ground( this, blob );
	//print("speed"+(this.getVelocity().Length()));
	bool fren = blob.getTeamNum() == this.getTeamNum();
	
	return ((!fren && this.getVelocity().Length() > 0.2) ||
		(blob.isKeyPressed(key_up) && blob.getVelocity().y>0) ||
		blob.hasTag("vehicle") && !fren ||
		blob.hasTag("dead") ||
		blob.hasTag("scenary") ||
		blob.getName().find("tree")>-1 ||
		(blob.getPosition().y<this.getPosition().y-this.getHeight()*0.75f&&!blob.isKeyPressed(key_down)));
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	if (attached.hasTag("flesh")) {
		attached.Tag("isInVehicle");
	}
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{
	if (detached.hasTag("flesh")) {
		detached.Untag("isInVehicle");
	}
}