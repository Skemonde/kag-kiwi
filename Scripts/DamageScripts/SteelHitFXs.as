#include "Hitters.as"
#include "HittersKIWI.as"

void playMetalSound(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	Vec2f sprite_dim = Vec2f(sprite.getFrameWidth(), sprite.getFrameHeight());
	//the bigger sprite the lower the metal sound pitch
	f32 sound_mod = (sprite_dim.x*sprite_dim.y)/1024;
	//print("sound_mod "+sound_mod);
	sprite.PlaySound("dig_stone.ogg", 2.0f, Maths::Max(0.3f, 2.0-sound_mod) + (XORRandom(100) / 1000.0f));
}