

void onInit(CBlob@ this)
{
	if (getNet().isServer())
	{
		CBlob@ blob = server_CreateBlob("mpmgm2");
		if (blob !is null)
		{
			blob.server_setTeamNum(this.getTeamNum());
			//blob.setInventoryName(this.getInventoryName() + "'s Turret");
			//blob.getShape().getConsts().collideWhenAttached = true;
			blob.getSprite().SetRelativeZ(40);
			this.server_AttachTo(blob, "GUNPOINT");
			this.set_u16("mg_id", blob.getNetworkID());
			blob.set_u16("tripod_id", this.getNetworkID());
		}
	}
}

void onTick(CSprite@ this)
{
	this.SetZ(-30.0f);
}