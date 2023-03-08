void MakeExplodeParticles(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	//ParticleAnimated(filename, this.getPosition() + pos, vel, float(XORRandom(360)), 0.5f + XORRandom(100) * 0.01f, 1 + XORRandom(4), XORRandom(100) * -0.00005f, true);
	ParticleAnimated(
	"explosion64.png",                   	// file name
	this.getPosition() + pos,            	// position
	vel,                         			// velocity
	float(XORRandom(360)),                  // rotation
	0.5f + XORRandom(100) * 0.01f,			// scale
	3,                                  	// ticks per frame
	0.0f,                               	// gravity
	true);
}

void MakeExplodeParticles(const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;
	ParticleAnimated(
	"explosion64.png",                   	// file name
	pos,            						// position
	vel,                         			// velocity
	float(XORRandom(360)),                  // rotation
	0.5f + XORRandom(100) * 0.01f,			// scale
	3,                                  	// ticks per frame
	0.0f,                               	// gravity
	true);
}