f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	if (this.hasTag("isInVehicle")) {
		damage *= 0;
	}
	
    return damage;
}