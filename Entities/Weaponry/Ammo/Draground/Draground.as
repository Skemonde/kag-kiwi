
void onInit(CBlob@ this)
{  
  this.Tag("ammo");

  this.maxQuantity = 1;

  //this.getCurrentScript().runFlags |= Script::remove_after_this;
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2 )
{
	const f32 vellen = this.getOldVelocity().Length();
	if (solid) {			
		if (vellen > 1.7f)
		{
			Sound::Play("BombBounce", this.getPosition(), 1, 1.3f + XORRandom(2)*0.1);
		}
		if (vellen > 7.3f)
		{
			//print("vellen "+vellen);
			this.server_Hit(this, this.getPosition(), Vec2f(), 0.1f, 0);
		}
	}
}