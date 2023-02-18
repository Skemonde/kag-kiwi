//////////////////////
///
/// MapsCore
///
/// Used so there's less duplicate code with adding a map level

#include "BlobCharacter"
#include "RunnerHead"

// Add in spawns based on a blob
// Some maps might want you to spawn at a tent
// Some might want you to spawn at a shop, idk
//
// Returns true if spawning was done correctly
bool AddSpawns(CMap@ map, string markerName, string blobToSpawn, int teamNum = 0)
{
	Vec2f[] spawns;
	if (map.getMarkers(markerName, spawns))
	{
		for (int a = 0; a < spawns.length; a++)
		{
			server_CreateBlob(blobToSpawn, 0, spawns[a]);
		}

		return true;
	}
	
	return false;
}

// Same as above, but we remove all scripts attached to them
// This prevents us from using it
bool AddSpawnsCosmeticOnly(CMap@ map, string markerName, string blobToSpawn, int teamNum = 0)
{
	Vec2f[] spawns;
	if (map.getMarkers(markerName, spawns))
	{
		for (int a = 0; a < spawns.length; a++)
		{
			CBlob@ blob = server_CreateBlob(blobToSpawn, 0, spawns[a]);
			if (blob is null) 
				continue;

			// TODO-> Engine side need a way to get all scripts by name!
		}

		return true;
	}
	
	return false;
}



/*CBlob@ SpawnInCharacter(string blobName, int team, Vec2f pos, string characterName, bool onInit = true, string customBody = "")
{
	CBlob@ blob = null;
	// Offer them an option to auto init or not
	// In case they want to set their own settings
	if (onInit)
	{
		@blob = server_CreateBlob(blobName, team, pos);
	}
	else 
	{
		@blob = server_CreateBlobNoInit(blobName);
		blob.setPosition(pos);
		blob.server_setTeamNum(team);
	}
	
	if (blob is null) {
		error("SpawnInCharacter creating a blob has failed!");
		return null;
	}
	if (customBody != "")
		blob.set_string("custom_body", customBody);
	blob.AddScript("InteractableCharacter");
	// Set character data
	BlobCharacter@ character = BlobCharacter(blob, characterName);
	character.PushToGlobalHandler();
	return blob;
}*/

BlobCharacter@ addCharacterToBlob(CBlob@ blob, string &in characterName, string &in textFile)
{
	if (blob.hasScript("BlobCharacterAddon"))
	{
		error("Trying to add a script to a blob that already has BlobCharacterAddon.as");
		return null;
	}

	blob.AddScript("BlobCharacterAddon");

	BlobCharacter@ character = BlobCharacter(blob, characterName);
	character.LoadTextConfig(textFile);
	character.PushToGlobalHandler();


	if (!blob.hasScript("EmoteBubble.as"))
	{
		blob.AddScript("EmoteBubble.as");
	}

	return character;
}



/// TODO: MOVE TO A NEW FILE


// Basic 0 to 255        (70 heads)
// Flags 256 to 511      (78 heads)
// Fantasy 512 to 767    (18 heads)
// Community 768 to 1023 (60 heads)
// 30 unique heads per pack

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