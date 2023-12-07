//////////////////////
///
/// CharacterCore
///
/// This holds the core class to character talking. 
/// Currently not stable, everything is subject to change.
/// 
/// The class is a mixin, which means another class can inherit everything from it
/// This is useful in this case so we can write less code


#include "EmotesCommon"

const u16 KEYS_TO_TAKE = key_left | key_right | key_up | key_down | key_action1 | key_action2 | key_action3 | key_use | key_pickup | key_inventory;

mixin class Character 
{
	// String key, string value
	dictionary ResponseMap = dictionary();
	
	// Maybe you want this character to have a custom font
	//     - Set your own custom font, used before rendering text
	string PreferedFont = "menu";
	//idk why pixeled doesn't work.. :<

	// Custom character name, added to the start of the text render
	//     - Note: Will get changed at some point
	string CharacterName = "";

	// How fast should we write by default
	//     - Note: text cfg's can change this with "{S_NUM}"
	int WriteSpeed = 1;

	// Are we done writing text?
	//     - Used to know if text is done updating
	bool FinishedWriting = false;

	// We are interacting with a player
	//     - Used to end talking to the character (gui goes bye)
	bool CurrentlyInteracting = false;

	// CurrentRenderOutput Total length including special tokens that are not outputted
	//     - Used when updating text so we can grab the correct substr
	int TextRenderLength = 0;

	// Text render queue, when one is over done, the next will be pushed
	string[] ActiveResponseQueue;
	// Text that is currently on the screen
	string CurrentRenderOutput = "";
	// The whole text that is being written to ^
	string CurrentText = "";

	// Last loaded config file (for automatic debug reloading)
	string LastTextConfig = "";

	void SetName(string name)
	{
		CharacterName = name;
	}
	
	bool isInteracting()
	{
		return CurrentlyInteracting;
	}

	void AddResponse(string eventName, string text)
	{
		ResponseMap.set(eventName, getTranslatedString(text));
	}

	// Both getResponses do the same thing, but give the string back in different ways
	string getResponse(string eventName)
	{
		string text = "";
		ResponseMap.get(eventName, text);
		return text;
	}

	void GetResponse(string eventName, string &out text)
	{
		ResponseMap.get(eventName, text);
	}

	void AddToResponseQueue(string eventName)
	{
		string response = getResponse(eventName);
		if (response == "")
			return;

		ActiveResponseQueue.push_back(response);
		FrontToOutput();
	}

	void ClearResponseQueue()
	{
		ActiveResponseQueue.clear();
	}

	bool LoadNextInQueue()
	{
		if (ActiveResponseQueue.length < 2)
			return false;

		RemoveFrontOfQueue();
		FrontToOutput();

		return true;
	}

	void RemoveFrontOfQueue()
	{
		if (ActiveResponseQueue.isEmpty())
			return;

		ActiveResponseQueue.erase(0);
	}

	// Todo: rename to something better
	void FrontToOutput()
	{
		if (ActiveResponseQueue.isEmpty() || CurrentText == ActiveResponseQueue[0])
			return;

		CurrentText = ActiveResponseQueue[0];
		ResetTalkVars();
	}

	void ResetTalkVars()
	{
		FinishedWriting = false;
		TextRenderLength = 0;
		WriteSpeed = 1;
		CurrentRenderOutput = "";
	}

	void SetPreferedFont(string name)
	{
		PreferedFont = name;
	}

	const string getName()
	{
		return CharacterName;
	}

	void LoadTextConfig(string configName)
	{
		ConfigFile cf = ConfigFile(CFileMatcher(configName).getFirst());
		if (cf is null)
		{
			error("AttachedTextConfig " + configName + " is null (attached to character  " + CharacterName + ")");
			return;
		}

		LastTextConfig = configName;

		// Optional
		if (cf.exists("start")) 
		{
			string sentence = cf.read_string("start");
			
			AddResponse("start", sentence);
			AddToResponseQueue("start");
		}

		// Optional
		if (cf.exists("keys"))
		{
			// Temp work around until cfg has a get all keys func (would be named keys, but its an illegal name >:(
			// Might crash here on empty box
			string[] configKeys = cf.read_string("keys").split(';');

			// Todo -> error if not found
			for (int a = 0; a < configKeys.length; a++)
			{
				string text = cf.read_string(configKeys[a]);
				if (text != "")
					AddResponse(configKeys[a], text);
			}
		}
	}

	void ReloadTextFromConfig()
	{
		ResetTalkVars();
		ClearResponseQueue();
		LoadTextConfig(LastTextConfig);
	}

	// Temp bind with buttons
	void ButtonPress() 
	{
		if (!CurrentlyInteracting)
		{
			ResetTalkVars();
			CurrentlyInteracting = true;
		}
		CBlob@ blob = getLocalPlayerBlob();
		if (OwnerBlob !is null && blob !is null && isServer()) {
			OwnerBlob.SetFacingLeft(blob.getPosition().x<OwnerBlob.getPosition().x);
			OwnerBlob.setAimPos(blob.getPosition());
		}
	}

	void Update()
	{
		CBlob@ blob = getLocalPlayerBlob();
		if (blob is null || !CurrentlyInteracting) 
			return;	

		//LockMovement(blob);
		bool spacebarPressed = ClientInputs();

		if (spacebarPressed)
		{
			// Speed up writing
			if (!FinishedWriting)
			{
				while(!FinishedWriting)
					UpdateText(true);
			}
			else if (LoadNextInQueue())
			{
				UpdateText();
			}
			else
			{
				SetChatVisible(true);
				// User stops talking, gui closes
				CurrentlyInteracting = false;
				//calling endingfunc upon closing dialogue window
				CallbackButtonFunc@ func = getFunction("endingFunc");
				if (func is null)
					warn("endingFunc not found ");
				else
					func(OwnerBlob, getLocalPlayerBlob());
			}
		}
		else
		{
			if (!FinishedWriting && getGameTime() % WriteSpeed == 0)
				UpdateText();
			SetChatVisible(false);
		}
	}

	// TODO: Clean up, its pretty ugly and prone to breaking (sorry)
	void UpdateText(bool skip = false)
	{
		string chars = CurrentText.substr(TextRenderLength, 1);
		// Colour tokens
		if (chars == '$') 
		{
			for (int a = TextRenderLength + 1; a < CurrentText.length; a++)
			{
				string currentChar = CurrentText.substr(a, 1);
				chars += currentChar;
				if (currentChar == "$")
				{
					string temp = CurrentText.substr(a + 1, 1);
					if (!isSpecialChar(temp))
						chars += temp;
						
					break;
				}
			}
		}
		else if (chars == '{') // Emote/Custom text logic
		{
			string insides = "";

			for (int a = TextRenderLength + 1; a < CurrentText.length; a++)
			{
				string currentChar = CurrentText.substr(a, 1);
			
				if (currentChar == "}")
				{
					// Add in the next char so adding a token doesnt waste a text update
					string temp = CurrentText.substr(a + 1, 1);
					if (isSpecialChar(temp))
						chars = "";
					else
						chars = temp;

					break;
				}

				insides += currentChar;
			}

			string action = insides.substr(0, 2);
			string content = insides.substr(2, insides.length);

			// Emote (TODO: Move to BlobHandler)
			if (action == "E_")
			{
				if (OwnerBlob is null)
					warn("Dont call E_ with none blobs: " + CharacterName);
				else
					set_emote(OwnerBlob, content);
			}
			else if (action == "S_") // Write speed
			{
				WriteSpeed = parseInt(content);
				chars = "";
			}
			else if (action == "R_") // Add a new response to the queue 
			{
				AddToResponseQueue(content);
			}
			else if (action == "F_") // Execute a function (TODO: change funcdef for non blobs)
			{
				CallbackButtonFunc@ func = getFunction(content);
				if (func is null)
					warn("Function not found " + content);
				else
					func(OwnerBlob, getLocalPlayerBlob()); // TODO -> Pass who called it, not just local player
			}
			else if (action == "Z_") // Play a sound
			{
				Sound::Play(content);
			}

			TextRenderLength += 2 + action.length + content.length;
		}
		else if (chars != ' ' && !skip) // TODO -> Set custom audio and sort out what we are doing with audio
		{
			Sound::Play("Archer_blip" + (XORRandom(1) == 0 ? "_2" : ""));
		}

		CurrentRenderOutput += chars;
		TextRenderLength += chars.length;

		if (TextRenderLength == CurrentText.length)
			FinishedWriting = true;
	}

	// TEMP, this was a gay temp work around
	bool isSpecialChar(string input)
	{
		return (input == "{" || input == "}" || input == "$");
	}

	void LockMovement(CBlob@ blob)
	{
		blob.DisableKeys(KEYS_TO_TAKE);
		blob.setVelocity(Vec2f(
			0.0f,
			blob.getVelocity().y
		));
	}

	// Note: Space bar wont active bombs
	bool ClientInputs()
	{
		CControls@ controls = getControls();
		return controls.isKeyJustPressed(controls.getActionKeyKey(AK_ACTION3));
	}


	void RenderBox() 	
	{
		////colors
		//AddColorToken("$T_D$", color_white);
		//AddColorToken("$T_0$", SColor(255, 25, 140, 255));
		//AddColorToken("$green$", SColor(255, 100, 255, 100));
	
		////fonts
		//GUI::LoadFont("pixeled", CFileMatcher("uni0553.ttf").getFirst(), 26, true);
	

		// Character pane in pixels
		const Vec2f pane = Vec2f(108, 100);
		
		//this.SetPreferedFont("typewriter");

		// Text box background
		// Todo -> update screenwidth every tick
		const int rectangleWidth = getDriver().getScreenWidth();
		const int rectangleHeight = getDriver().getScreenHeight();
		Vec2f topLeft(0,rectangleHeight-pane.y-24);
		topLeft = Vec2f(rectangleWidth*0.70f, 0);

		// Bottom right
		Vec2f botRight = Vec2f(topLeft.x + pane.x, topLeft.y + pane.y + 8);
		botRight = Vec2f(rectangleWidth, 320);

		// Move the rest slightly right since we got that pane
		//topLeft.x += pane.x;

		// Shadowed box that sits behind the text
		GUI::DrawRectangle(topLeft, botRight, SColor(200,0,0,0));
		
		// Panes
		GUI::DrawFramedPane(topLeft-Vec2f((32+6)*2,0), topLeft+Vec2f(0,(32+6)*2));
		const string FACE_NAME = OwnerBlob.get_string("custom_body");
		GUI::DrawIcon(FACE_NAME, 0, Vec2f(32, 32), topLeft-Vec2f((32+6)*2,0)+Vec2f(1, 1)*6, 1.0f, Team);
		//GUI::DrawFramedPane(topLeft-Vec2f(0,40), topLeft+Vec2f(256,16));
		
		// Character name
		Vec2f CHAR_DIMS;
		GUI::SetFont(PreferedFont);
		GUI::DrawText(""+CharacterName, topLeft-Vec2f(0, 24)*0, botRight, color_white, true, false, false);
		GUI::GetTextDimensions(""+CharacterName, CHAR_DIMS);

		// Render font (and make sure we set the font they want before hand)
		GUI::SetFont(PreferedFont);
		GUI::DrawText(""+CurrentRenderOutput, topLeft+Vec2f(1,2)*16, 
			botRight+Vec2f(0, 1)*300, color_white, true, false, false);

		//GUI::DrawIcon("GUI/Keys.png", 8, Vec2f(24, 16), topLeft+Vec2f(-48, 64), 1.0f, color_white);
		//GUI::DrawText("Press", topLeft+Vec2f(-pane.x+2, 16), 
		//	Vec2f_zero, color_white, true, false, false);
	}
}


// Chat box used for global chat
// Not in use yet, will finish later on
/*class GlobalCharacter : Character
{

}*/