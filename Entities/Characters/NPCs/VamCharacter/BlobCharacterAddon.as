//////////////////////
///
/// InteractableCharacter
///
/// This is added to any new blob when used with MapsCore addCharacterToBlob
/// Code in this is subject to change, buttons were used just as a quick and simple way to test the code

// TODO -> Create Token

#include "BlobCharacter"

void onInit(CBlob@ this)
{
	if (getCharacter(this) is null)
	{
		error("Blob " + this.getName() + " has InteractableCharacter.as with no character!");
		this.RemoveScript("InteractableCharacter");
		return;
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	// Unsure if this can even go null
	BlobCharacter@ char = getCharacter(this);

	if (caller is null || this.hasTag("dead") || char is null || char.CurrentlyInteracting)
		return;

	CButton@ button = caller.CreateGenericButton(30, Vec2f(0,-16), this, TryingToTalk, "Talk");
}

void TryingToTalk(CBlob@ this, CBlob@ caller)
{
	BlobCharacter@ char = getCharacter(this);
	char.ButtonPress();
}

void onHealthChange(CBlob@ this, f32 oldHealth)
{
	// Work around to 'Invalid networkid' for trying to tell CRules to remove our character
	if (this.hasTag("dead"))
	{
		CBitStream cbs = CBitStream();
		cbs.write_u16(this.getNetworkID());
		getRules().SendCommand(getRules().getCommandID("character_unbound"), cbs);
	}
}