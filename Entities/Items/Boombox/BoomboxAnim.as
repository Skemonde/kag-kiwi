#define CLIENT_ONLY
#include "Tunes.as";

void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	
	this.SetEmitSoundSpeed(1);
	this.SetEmitSoundVolume(1);
	this.SetEmitSoundPaused(true);
	
	if (blob.get_u32("tune") < tunes.length-1) {
		blob.Tag("playing");
		this.SetEmitSound(tunes[blob.get_u32("tune")]);
		this.SetEmitSoundPaused(false);
	}
	this.SetZ(-2);
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	
	//don't want it to change facing direction
	this.SetFacingLeft(false);
	
	//with this boombox knows itself how big should sprite offset be depending of scale of jumping you set
	f32 scale = 0.625;
	u8 shift = (16-16*scale)/2;
	//making weeble woble animation
	if (blob.hasTag("shrinked")) {
		this.ScaleBy(Vec2f(scale, 1.0f/scale));
		blob.Untag("shrinked");
		this.SetOffset(this.getOffset()+Vec2f(0, -shift));
	}
	if (blob.hasTag("playing")) {
		if (getGameTime() % 10 == 0) {
			this.ScaleBy(Vec2f(1.0f/scale, scale));
			blob.Tag("shrinked");
			this.SetOffset(this.getOffset()+Vec2f(0, shift));
		}
		if (getGameTime() % 45 == 0) {
			CParticle@ p = ParticleAnimated("particle_note_"+(XORRandom(3) + 1)+".png", blob.getPosition(), Vec2f((XORRandom(100)-50)*0.01,-1), 0,1, RenderStyle::Style::normal,0,Vec2f(8,8),0,0,true);
			if (p !is null)
			{
				p.fastcollision = true;
				p.diesoncollide = true;
				p.gravity = Vec2f(0,0.0125);
				p.lighting = false;
			}
		}
	}
}