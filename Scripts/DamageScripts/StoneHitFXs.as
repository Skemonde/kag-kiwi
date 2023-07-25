#include "GenericGibsEnum"

void makeStoneGib(Vec2f pos, Vec2f worldPoint, f32 damage)
{
	makeGibParticle("GenericGibs", worldPoint, getRandomVelocity((pos - worldPoint).getAngle(), 1.0f + damage, 90.0f) + Vec2f(0.0f, -2.0f),
		                Gibs::stone, 4 + XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);
}