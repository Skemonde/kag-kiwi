//////////////////////
///
/// CharacterHandler
///
/// This script is added into gamemode.cfg
/// It handles rendering, ticking and clearing BlobCharacterHandler
/// This may change later on, as I'd like this to render all other 'Character' type classes (if we ever do that)

#include "BlobCharacter"
#include "RunnerTextures"

BlobCharacterHandler Handler;

// In localhost, this executes before CMap onInit does
void onInit(CRules@ this)
{
	// This will be called when ever we have set a character
	// The blob network ID will need to be sent as well.
	this.addCommandID("character_bound"); 
	// This will be called when a blob dies
	// This is required unless you want the game to crash
	this.addCommandID("character_unbound");
	
	///// TEMP
	
	// Reloads all blob configs
	this.addCommandID("DebugReloadConfigs");
	// Toggles Pathfinding
	this.addCommandID("TogglePathfinding");

	onRestart(this);

	// Might get used if we want to use render:: in character rendering anywhere
	//id = Render::addScript(Render::layer_posthud, "CharacterHandler.as", "NewRender", 10.0f);
}

void onRestart(CRules@ this)
{
	if (Handler !is null) 
		Handler.Clear();

	Handler = BlobCharacterHandler();
}

void onReload(CRules@ this)
{	
	if (Handler !is null) 
		Handler.Clear();

	Handler = BlobCharacterHandler();

	ReloadCharacters(this);
}

void onTick(CRules@ this)
{
	if (Handler !is null)
		Handler.onTick();
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (Handler is null)
		return;

	if (cmd == this.getCommandID("character_bound"))
	{
		u16 networkId = params.read_u16();
		CBlob@ blob = getBlobByNetworkID(networkId);

		if (blob is null)
		{
			error("Invalid networkid character_bound : " + networkId);
			return;
		}

		Handler.AddCharacter(blob);
	}
	else if (cmd == this.getCommandID("character_unbound"))
	{
		u16 networkId = params.read_u16();
		CBlob@ blob = getBlobByNetworkID(networkId);

		if (blob is null)
		{
			error("Invalid networkid character_bound : " + networkId);
			return;
		}

		Handler.RemoveCharacter(blob);
	}
	else if (cmd == this.getCommandID("DebugReloadConfigs"))
	{
		ReloadCharacters(this);
	}
}

void onRender(CRules@ this)
{
	if (Handler !is null)
		Handler.onRender();
}

void ReloadCharacters(CRules@ this)
{
	Handler.Clear();

	
	CBlob@[] blobs;
	getBlobs(@blobs);

	for (int a = 0; a < blobs.length; a++)
	{
		CBlob@ blob = blobs[a];
		if (blob is null)
			continue;

		BlobCharacter@ char = getCharacter(blob);

		if (char is null)
			continue;

		char.ReloadTextFromConfig();

		Handler.AddCharacter(char);
	}
}