
CSpriteLayer@ getVehicleInsignia (CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return null;
	
	const u8 TEAM = Maths::Min(7, blob.getTeamNum());
	
	this.RemoveSpriteLayer("insignia");
	CSpriteLayer@ insignia = this.addSpriteLayer("insignia", "vehicle_insignia.png", 8, 8, TEAM, 0);
	
	insignia.SetRelativeZ(1.0f);
	insignia.SetVisible(true);
	insignia.SetFrameIndex(TEAM);
	
	return insignia;
}