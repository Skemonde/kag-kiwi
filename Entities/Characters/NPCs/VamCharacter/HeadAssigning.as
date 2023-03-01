#include "RunnerHead.as";

namespace Heads
{
	const int[] KNIGHT_WITH_HELMS = {
		46,
		47,
		48,
		50,
		53,
		54,
		55,
		815,
		819,
		823,
		824,
		825,
		826
	};
}

// Todo, maybe include this with a custom CreateBlob & addCharacter func
void SetRandomKnightHelm(CBlob@ blob)
{
	blob.setHeadNum(Heads::KNIGHT_WITH_HELMS[XORRandom(Heads::KNIGHT_WITH_HELMS.length)]);
	LoadHead(blob.getSprite(), blob.getHeadNum());
}