#include "GenericGibsEnum"

void playMetalSound(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	Vec2f sprite_dim = Vec2f(sprite.getFrameWidth(), sprite.getFrameHeight());
	//the bigger sprite the lower the metal sound pitch
	f32 sound_mod = (sprite_dim.x*sprite_dim.y)/750;
	sprite.PlaySound("dig_stone.ogg", 2.0f, Maths::Max(0.3f, 2.0-sound_mod) + (XORRandom(100) / 1000.0f));
}

void makeSteelGib(Vec2f pos, Vec2f worldPoint, f32 damage)
{
	f32 dmg_mod = Maths::Min(8, Maths::Round(damage/0.4));
	makeGibParticle("GenericGibs", worldPoint, getRandomVelocity((pos - worldPoint).getAngle(), 1.0f + damage, 90.0f) + Vec2f(0.0f, -2.0f),
		                Gibs::steel, 7-dmg_mod+XORRandom(dmg_mod), Vec2f(8, 8), 2.0f, 0, "", 0);
}