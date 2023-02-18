#include "CharacterMixin"

//////////////////////
///
/// BlobCharacter
///
/// This class is attached to a blob that wants the Character class
/// This lets us do special stuff with the blob class
/// - Adding a potrait based on the head currently equiped
/// - Emoting
/// And some other stuff that i forgot about

class BlobCharacter : Character
{
	// String key, func value
	dictionary FunctionMap = dictionary();

	string CharacterTextureFile = "";
	string HeadTextureFile = "";
	CBlob@ OwnerBlob; 



	s32 HeadIndex = 0; 
	s32 Team = 0;

	// Not in use
	u8 testFrame = 0;

	void AddFunction(string name, CallbackButtonFunc@ func)
	{
		FunctionMap.set(name, @func);
	}

	CallbackButtonFunc@ getFunction(string name)
	{
		CallbackButtonFunc@ func;
		FunctionMap.get(name, @func);
		return func;
	}

	BlobCharacter(CBlob@ owner, string name)
	{
		@OwnerBlob = owner;

		int team = owner.getTeamNum();
		SetName("$T_"+team+"$<"+name+">$col-white$");
		if (owner.exists("custom_color"))
			SetName("$"+owner.get_string("custom_color")+"$<"+name+">$col-floral_white$");

		owner.set("character", @this);

		// TODO MAYBE IN THE FUTURE (effort)
		// -> Load current blob sprite if custom_body doesnt exist
		// -> get frame data from there instead of making custom body

		if (owner.exists("custom_body"))
			CharacterTextureFile = owner.get_string("custom_body");
		else
			CharacterTextureFile = owner.getName() + (owner.getSexNum() == 0 ? "_male_body.png" : "_female_body.png");
	}

	void CustomUpdate()
	{
		Update();

		// Keep watch to update when the char changes head
		SetHeadData();

		// Disabled for now, looks cursed as fuck
		/*if (!FinishedWriting && CurrentRenderText.substr(CurrentRenderText.length -2, 1) != " ")
			testFrame = 1;
		else
			testFrame = 0;*/
	}

	void SetHeadData()
	{
		HeadIndex = OwnerBlob.get_s32("head index");
		Team = OwnerBlob.get_s32("head team");
		HeadTextureFile = OwnerBlob.get_string("head texture");
	}

	void CustomRender()
	{
		RenderBox();
		CharacterPortrait();
	}

	// TODO: Character head is empty the first few ticks
	void CharacterPortrait()
	{
		//Vec2f topLeft(0, 0);
		const Vec2f pane = Vec2f(108, 100);
		const int rectangleHeight = getDriver().getScreenHeight();
		Vec2f topLeft(0,rectangleHeight-pane.y-24);
		// Get character head pos
		Vec2f headpos(topLeft.x - 10, topLeft.y - 26);

		GUI::DrawIcon(OwnerBlob.get_string("custom_body"), 0, Vec2f(48, 48), Vec2f(topLeft.x + 6, topLeft.y + 6), 1.0f, Team);
		//GUI::DrawIcon(CharacterTextureFile, 0, Vec2f(12, 12), Vec2f(topLeft.x + 6, topLeft.y + 6), 4.0f, Team);
		//GUI::DrawIcon(HeadTextureFile, HeadIndex + testFrame, Vec2f(16, 16), headpos , 4.0f, Team);
	}

	// Todo -> Find a better way to do this maybe? It works for now i guess (unsure why i dislike this)
	void PushToGlobalHandler()
	{
		CBitStream@ cbs = CBitStream();
		cbs.write_u16(OwnerBlob.getNetworkID());

		getRules().SendCommand(getRules().getCommandID("character_bound"), cbs);
	}
}


class BlobCharacterHandler
{
	// List of all the blob characters in our game
	array<BlobCharacter@> BlobList;

	// Character we are going to render
	BlobCharacter@ CharacterToRender = null;

	BlobCharacterHandler()
	{
	}

	void AddCharacter(BlobCharacter@ character)
	{
		BlobList.push_back(character);

		if (g_debug > 0)
		{
			print("Adding character \"" + character.getName() + "\"");
		}
	}

	void RemoveCharacter(CBlob@ blob)
	{
		BlobCharacter@ character = null;
		blob.get("character", @character);

		if (character is null)
		{
			error("RemoveCharacter with blob " + blob.getName() +
				" is null, please only remove when blob has a character attached to it");
			return; 
		}

		if (CharacterToRender is character)
			@CharacterToRender = null;


		int index = getBlobIndex(character);
		if (index != -1)
			BlobList.erase(index);
	}

	int getBlobIndex(BlobCharacter@ char)
	{
		for (int a = 0; a < BlobList.length; a++)
		{
			if (char is BlobList[a])
			{
				return a;
			}
		}

		return -1;
	}

	int getBlobIndex(CBlob@ blob)
	{
		for (int a = 0; a < BlobList.length; a++)
		{
			BlobCharacter@ char = BlobList[a];

			if (char.OwnerBlob is blob)
			{
				return a;
			}
		}

		return -1;
	}

	void AddCharacter(CBlob@ blob)
	{
		BlobCharacter@ character = null;
		blob.get("character", @character);

		if (character is null) 
		{
			error("AddCharacter with blob " + blob.getName() + 
				" is null, please create character before hand!");

			return;
		}

		AddCharacter(character);
	}

	void SetBlobToRender(CBlob@ blob)
	{
		int index = getBlobIndex(blob);
		if (index != -1)
		{
			if (CharacterToRender !is null)
				CharacterToRender.ResetTalkVars();
			
			blob.get("character", @CharacterToRender);
			CharacterToRender.SetHeadData();
		}
	}

	bool FindAndSetToSpeak()
	{
		for (int a = 0; a < BlobList.length; a++)
		{
			BlobCharacter@ char = BlobList[a];

			if (char !is null && char.CurrentlyInteracting)
			{
				@CharacterToRender = char;
				return true;
			}
		}
		
		return false;
	}

	void onTick()
	{
		if (CharacterToRender is null && !FindAndSetToSpeak())
			return;
		
		CharacterToRender.CustomUpdate();

		if (!CharacterToRender.CurrentlyInteracting)
			@CharacterToRender = null;
	}

	void onRender()
	{
		if (CharacterToRender is null)
			return;

		CharacterToRender.CustomRender();
	}

	// Todo: some other stuff?
	void Clear()
	{
		BlobList.clear();
	}
}

////// Quick handles for scripts to use //////
BlobCharacter@ getCharacter(CBlob@ blob)
{
	BlobCharacter@ character = null;
	blob.get("character", @character);
	return character;
}
