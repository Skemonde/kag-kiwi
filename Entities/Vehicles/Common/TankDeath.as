
#include "MetroBoomin"
#include "MakeExplodeParticles"

void onDie(CBlob@ this)
{
	if (!this.hasTag("died naturally")) return;
	this.set_bool("explosive_teamkill", true);
	MakeItBoom(this, 80, 16.0f);
	KillCrew(this);
	
	if (isServer())
	for (int idx = 0; idx < 6; ++idx) {
		CBlob@ flare = server_CreateBlob("napalm", this.getTeamNum(), this.getPosition()+Vec2f(0, -16));
		if (flare is null) continue;
		flare.setVelocity(getRandomVelocity(90+this.getAngleDegrees(), 12+XORRandom(6), 40));
	}
	
	if (isClient())
	{
		Vec2f pos = this.getPosition();
		CMap@ map = getMap();
		
		MakeBangEffect(this, "bakoom", 4.0);
		Sound::Play("tank_death", this.getPosition(), 2, 1.0f + XORRandom(2)*0.1);
		u8 particle_amount = 6;
		for (int i = 0; i < particle_amount; i++)
		{
			MakeExplodeParticles(this, Vec2f( XORRandom(64) - 32, XORRandom(64) - 32), getRandomVelocity(360/particle_amount*i, XORRandom(220) * 0.01f, 90));
		}
	}
}

void KillCrew(CBlob@ this)
{
	AttachmentPoint@[] aps;
	if (this.getAttachmentPoints(@aps))
	{
		for (uint i = 0; i < aps.length; i++)
		{
			AttachmentPoint@ ap = aps[i];
			if (ap.socket)
			{
				CBlob@ occBlob = ap.getOccupied();
				if (occBlob is null) continue;
				if (!occBlob.hasTag("player")) continue;
				
				occBlob.Untag("isInVehicle");
				this.server_Hit(occBlob, this.getPosition(), Vec2f(), 25.00f, HittersKIWI::boom, true);
			}
		}
	}
}