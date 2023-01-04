void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1 )
{
    if (blob !is null && !this.hasTag("collided"))
    {
		if (doesCollideWithBlob( this, blob ))
		{
			//if (!solid && !blob.hasTag("flesh") && (blob.getName() != "mounted_bow" || this.getTeamNum() != blob.getTeamNum()))
			//{
			//	return;
			//}
	
			f32 dmg = this.get_f32("damage");
			
			if (blob.hasTag("dead"))
			{
				dmg *= 69;
			}
			
			//u16 sound_num = XORRandom(3) + 1;
			if (blob.hasTag("player")) blob.getSprite().PlaySound( "ManHit" + (XORRandom(3) + 1), 2.0, 1.0 );
			
			this.server_Hit( blob, point1, normal, dmg, HittersKAWI::bullet_pistol);
			//f32 force = -2.0f * Maths::Sqrt(blob.getMass()+1);
			//blob.AddForce( blob.getVelocity() * force );
			this.server_Die();
		}
		else if (solid) this.server_Die();
	}
}