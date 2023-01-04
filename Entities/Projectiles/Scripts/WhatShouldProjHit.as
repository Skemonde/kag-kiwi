/*
bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return !blob.hasTag("projectile")
		&& !blob.hasTag("firearm")
		&& !blob.hasTag("ignore_saw")
		&& !(blob.getTeamNum() == this.getTeamNum());
}
*/
bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	//return ((blob.hasTag("player") || blob.hasTag("flesh") || blob.hasTag("bullet_hits") || blob.getShape().isStatic())
	//	&& (blob.getTeamNum() != this.getTeamNum()));
	bool check = ((blob.hasTag("player") || blob.hasTag("flesh") || blob.hasTag("bullet_hits"))
			&& (blob.getTeamNum() != this.getTeamNum())
			&& !blob.isAttached());
		
	//maybe collide with team structures
	//if (!check)
	//{
	//	CShape@ shape = blob.getShape();
	//	check = (shape.isStatic() && !shape.getConsts().platform);
	//}

	if (check)
	{
		if (
			//we've collided
			this.getShape().isStatic()
			|| this.hasTag("collided")
			//or they ignore us
			|| blob.hasTag("ignore_proj")
			//of they're dead and bullet doesn't have a right to damage them
			|| ( !this.get_bool("hit_dead_bodies") && blob.hasTag("dead"))
		)
		{
			return false;
		}
		else
		{
			return true;
		}
	}

	return false;
}