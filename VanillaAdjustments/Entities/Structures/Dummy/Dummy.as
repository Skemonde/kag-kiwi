#include "addCharacterToBlob"

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-20.0f);
	this.getSprite().animation.frame = (this.getNetworkID() * 31) % 4;

	this.SetFacingLeft(((this.getNetworkID() + 27) * 31) % 18 > 9);
	this.Tag("dummy");
	this.Tag("wood");
	this.Tag("flesh");
	
	this.set_string("custom_body", "mugshot_soundonly.png");
	//check KIWI_Colors.as
	this.set_string("custom_color", "col-liver_chestnut");
	
	{
		//BlobCharacter@ char = addCharacterToBlob(this, "Dorian the Dummy", "Dorian.cfg");
	}
}

void onGib(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	Vec2f pos = blob.getPosition();
	Vec2f vel = blob.getVelocity();
	vel.y -= 3.0f;
	f32 hp = Maths::Min(Maths::Abs(blob.getHealth()), 2.0f) + 2.0;
	const u8 team = blob.getTeamNum();

	const string filename = this.getFilename();

	if ((blob.getNetworkID() * 31) % 3 != 0)
	{
		CParticle@ Head     = makeGibParticle(filename, pos, vel + getRandomVelocity(90, hp , 80), 6, 0, Vec2f(16, 16), 2.0f, 20, "/material_drop", team);
	}

	{
		int r = ((blob.getNetworkID() * 31) % 3);
		CParticle@ Large1   = makeGibParticle(filename, pos, vel + getRandomVelocity(90, hp - 0.2 , 80), 7 - (r % 2), 1 - (r / 2), Vec2f(16, 16), 2.0f, 20, "/material_drop", team);
	}

	{
		int r = (((blob.getNetworkID() + 1) * 31) % 3);
		CParticle@ Large1   = makeGibParticle(filename, pos, vel + getRandomVelocity(90, hp - 0.2 , 80), 7 - (r % 2), 1 - (r / 2), Vec2f(16, 16), 2.0f, 20, "/material_drop", team);
	}

}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return false;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	this.SetFacingLeft(!(worldPoint.x > this.getPosition().x));
	if (damage > 0.0f)
	{
		f32 max_tilt = 10;
		if (worldPoint.x > this.getPosition().x)
		{
			if (this.getAngleDegrees() > -max_tilt)
				this.setAngleDegrees(this.getAngleDegrees() - 3 - XORRandom(10));
			else
				this.setAngleDegrees(-max_tilt + 3 + XORRandom(10));
		}
		else
		{
			if (this.getAngleDegrees() < max_tilt)
				this.setAngleDegrees(this.getAngleDegrees() + 3 + XORRandom(10));
			else
				this.setAngleDegrees(max_tilt - 3 - XORRandom(10));
		}
		
		f32 angle = (this.getPosition() - worldPoint).getAngle();
		makeGibParticle("/GenericGibs", worldPoint, getRandomVelocity(angle, 1.0f + damage, 90.0f) + Vec2f(0.0f, -2.0f),
		                1, 4 + XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);
	}
	return damage;
}
