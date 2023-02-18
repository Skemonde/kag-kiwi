#include "BlobCharacter"

BlobCharacter@ addCharacterToBlob(CBlob@ blob, string &in characterName, string &in textFile)
{
	if (blob.hasScript("BlobCharacterAddon"))
	{
		error("Trying to add a script to a blob that already has BlobCharacterAddon.as");
		return null;
	}


	BlobCharacter@ character = BlobCharacter(blob, characterName);
	character.LoadTextConfig(textFile);
	character.PushToGlobalHandler();

	blob.AddScript("BlobCharacterAddon");

	if (!blob.hasScript("EmoteBubble.as"))
	{
		blob.AddScript("EmoteBubble.as");
	}

	return character;
}