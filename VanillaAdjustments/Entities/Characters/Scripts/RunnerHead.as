// generic character head script

// TODO: fix double includes properly, added the following line temporarily to fix include issues
#include "PaletteSwap.as"
#include "PixelOffsets.as"
#include "RunnerTextures.as"
#include "Accolades.as"

const s32 NUM_HEADFRAMES = 4;
const s32 NUM_UNIQUEHEADS = 30;
const int FRAMES_WIDTH = 8 * NUM_HEADFRAMES;

//handling Heads pack DLCs

int getHeadsPackIndex(int headIndex)
{
	if (headIndex > 255) {
		if ((headIndex % 256) >= NUM_UNIQUEHEADS) {
			return Maths::Min(getHeadsPackCount() - 1, Maths::Floor(headIndex / 256.0f));
		}
	}
	return 0;
}

bool doTeamColour(int packIndex)
{
	switch (packIndex) {
		case 1: //FOTW
			return false;
	}
	//otherwise
	return true;
}

bool doSkinColour(int packIndex)
{
	switch (packIndex) {
		case 1: //FOTW
			return false;
	}
	//otherwise
	return true;
}

int getHeadFrame(CBlob@ blob, int headIndex, bool default_pack)
{
	if (headIndex < NUM_UNIQUEHEADS)
	{
		return headIndex * NUM_HEADFRAMES;
	}

	//special heads logic for default heads pack
	if (default_pack && (headIndex == 255 || headIndex < NUM_UNIQUEHEADS))
	{
		CRules@ rules = getRules();
		bool holidayhead = false;
		if (rules !is null && rules.exists("holiday"))
		{
			const string HOLIDAY = rules.get_string("holiday");
			if (HOLIDAY == "Halloween")
			{
				headIndex = NUM_UNIQUEHEADS + 43;
				holidayhead = true;
			}
			else if (HOLIDAY == "Christmas")
			{
				headIndex = NUM_UNIQUEHEADS + 61;
				holidayhead = true;
			}
		}

		//if nothing special set
		if (!holidayhead)
		{
			string config = blob.getConfig();
			if (config == "builder")
			{
				headIndex = NUM_UNIQUEHEADS;
			}
			else if (config == "knight")
			{
				headIndex = NUM_UNIQUEHEADS + 1;
			}
			else if (config == "archer")
			{
				headIndex = NUM_UNIQUEHEADS + 2;
			}
			else if (config == "migrant")
			{
				Random _r(blob.getNetworkID());
				headIndex = 69 + _r.NextRanged(2); //head scarf or old
			}
			else
			{
				// default
				headIndex = NUM_UNIQUEHEADS;
			}
		}
	}

	return (((headIndex - NUM_UNIQUEHEADS / 2) * 2) +
	        (blob.getSexNum() == 0 ? 0 : 1)) * NUM_HEADFRAMES;
}

string getHeadTexture(int headIndex)
{
	return getHeadsPackByIndex(getHeadsPackIndex(headIndex)).filename;
}

void onPlayerInfoChanged(CSprite@ this)
{
	LoadHead(this, this.getBlob().getHeadNum());
	getHat(this);
}

CSpriteLayer@ LoadHead(CSprite@ this, int headIndex)
{
	CBlob@ blob = this.getBlob();
	CPlayer@ player = blob.getPlayer();
	CRules@ rules = getRules();

	// strip old head
	this.RemoveSpriteLayer("head");

	// get dlc pack info
	int headsPackIndex = getHeadsPackIndex(headIndex);
	HeadsPack@ pack = getHeadsPackByIndex(headsPackIndex);
	string texture_file = pack.filename;

	bool override_frame = false;

	//get the head index relative to the pack index (without unique heads counting)
	int headIndexInPack = (headIndex - NUM_UNIQUEHEADS) - (headsPackIndex * 256);

	//(has default head set)
	bool defaultHead = (headIndex == 255 || headIndexInPack < 0 || headIndexInPack >= pack.count);
	if (defaultHead)
	{
		//accolade custom head handling
		//todo: consider pulling other custom head stuff out to here
		u8 head_idx = 0;
		if (player !is null)
		{			
			string head_file = player.getUsername() + ".png";
			print("headfile "+head_file);
			if(CFileMatcher(head_file).hasMatch())
			{
				print(player.getCharacterName() + " the " + blob.getName() + " has their head set properly! Congratz");
				if (rules.exists(player.getUsername() + "HeadIndex"))
				{
					head_idx = rules.get_u8(player.getUsername() + "HeadIndex");
				}
				if (rules.exists(player.getUsername() + "Headpack"))
					texture_file = rules.get_string(player.getUsername() + "Headpack");
				else
					texture_file = player.getUsername();
				
				headIndex = head_idx;
				headsPackIndex = 0;
				override_frame = true;
				player.Tag("custom_head");
			}
			else
			{
				player.Untag("custom_head");
				print("no head fo ya :C");
			}
		}
	}
	else
	{
		//it's not a custom head but it's definitely not a default one too ?_?
		if (player !is null)
			player.Tag("custom_head");
	}

	int team = doTeamColour(headsPackIndex) ? blob.getTeamNum() : 0;
	int skin = doSkinColour(headsPackIndex) ? blob.getSkinNum() : 0;
	
	//if player is a mere grunt or doesn't have a cool head to show off in role of CO they get a super basic head (commanders will still have a cool hat though)
	if (blob.hasTag("grunt") || (player !is null && !player.hasTag("custom_head")))
	{
		texture_file = "GruntHead.png";
		headIndex = 0;
	}
	
	//add new head
	CSpriteLayer@ head = this.addSpriteLayer("head", texture_file, 16, 16, team, skin);

	//
	headIndex = headIndex % 256; // wrap DLC heads into "pack space"

	// figure out head frame
	s32 headFrame = override_frame ?
		(headIndex * NUM_HEADFRAMES) :
		getHeadFrame(blob, headIndex, headsPackIndex == 0);

	if (head !is null)
	{
		Animation@ anim = head.addAnimation("default", 0, false);
		anim.AddFrame(headFrame);
		anim.AddFrame(headFrame + 1);
		anim.AddFrame(headFrame + 2);
		head.SetAnimation(anim);

		head.SetFacingLeft(blob.isFacingLeft());
	}

	//setup gib properties
	blob.set_s32("head index", headFrame);
	blob.set_string("head texture", texture_file);
	blob.set_s32("head team", team);
	blob.set_s32("head skin", skin);

	return head;
}

void onGib(CSprite@ this)
{
	if (g_kidssafe)
	{
		return;
	}

	CBlob@ blob = this.getBlob();
	if (blob !is null && blob.getName() != "bed")
	{
		int frame = blob.get_s32("head index");
		int framex = frame % FRAMES_WIDTH;
		int framey = frame / FRAMES_WIDTH;

		Vec2f pos = blob.getPosition();
		Vec2f vel = blob.getVelocity();
		f32 hp = Maths::Min(Maths::Abs(blob.getHealth()), 2.0f) + 1.5;
		makeGibParticle(
			blob.get_string("head texture"),
			pos, vel + getRandomVelocity(90, hp , 30),
			framex, framey, Vec2f(16, 16),
			2.0f, 20, "/BodyGibFall", blob.getTeamNum()
		);
		
		if(!blob.get_string("hat_name").empty())
		{
			print("hat gib");
			makeGibParticle(
				blob.get_string("hat_name"),
				pos, vel + getRandomVelocity(90, hp , 30),
				0, 0, Vec2f(16, 16),
				2.0f, 20, "/BodyGibFall", blob.getTeamNum()
			);
		}
	}
}

CSpriteLayer@ getHat(CSprite@ this)
{
	this.RemoveSpriteLayer("hat");
	
	string hat_name = "";
	
	if (this.getBlob().getName() == "soldat" || this.getBlob().hasTag("has_hat")) {
		switch (this.getBlob().getTeamNum()) {
			case 1:
				hat_name = "imp";
				break;
			case 0:
			case 6:
				hat_name = "sov";
				break;
			
			default:
				hat_name = "team";
				break;
		};
		if (this.getBlob().hasTag("commander")) {
			hat_name += "_cap";
			if (this.getBlob().getPlayer() !is null && this.getBlob().getPlayer().hasTag("custom_head"))
				//commanders can be unique!!!!
				hat_name = "";
		} else if (this.getBlob().hasTag("grunt")) {
			hat_name += "_helm";
			//hat_name = "team_helm";
		}
	}
		
	if (!hat_name.empty()) {
		print(""+hat_name);
		CSpriteLayer@ hat = this.addSpriteLayer("hat", hat_name, 32, 32, this.getBlob().getTeamNum(), 0);
		this.getBlob().set_string("hat_name", hat_name);
		return hat;
	}
	else
		return null;
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	ScriptData@ script = this.getCurrentScript();
	if (script is null)
		return;

	if (blob.getShape().isStatic())
	{
		script.tickFrequency = 60;
	}
	else
	{
		script.tickFrequency = 1;
	}


	// head animations
	CSpriteLayer@ head = this.getSpriteLayer("head");
	CSpriteLayer@ hat = this.getSpriteLayer("hat");
	
	if (hat is null)
		@hat = getHat(this);

	// load head when player is set or it is AI
	if (head is null && (blob.getPlayer() !is null || (blob.getBrain() !is null && blob.getBrain().isActive()) || blob.getTickSinceCreated() > 3))
	{
		@head = LoadHead(this, blob.getHeadNum());
	}
	

	if (head !is null)
	{
		Vec2f offset;

		// pixeloffset from script
		// set the head offset and Z value according to the pink/yellow pixels
		int layer = 0;
		Vec2f head_offset = getHeadOffset(blob, -1, layer);

		// behind, in front or not drawn
		if (layer == 0)
		{
			head.SetVisible(false);
		}
		else
		{
			head.SetVisible(this.isVisible());
			head.SetRelativeZ(this.getRelativeZ() + layer * 0.25f);
		}

		offset = head_offset;

		// set the proper offset
		Vec2f headoffset(this.getFrameWidth() / 2, -this.getFrameHeight() / 2);
		headoffset += this.getOffset();
		headoffset += Vec2f(-offset.x, offset.y);
		headoffset += Vec2f(0, -2);
		head.SetOffset(headoffset);

		if (blob.hasTag("dead") || blob.hasTag("dead head"))
		{
			head.animation.frame = 2;

			// sparkle blood if cut throat
			if (getNet().isClient() && getGameTime() % 2 == 0 && blob.hasTag("cutthroat"))
			{
				Vec2f vel = getRandomVelocity(90.0f, 1.3f * 0.1f * XORRandom(40), 2.0f);
				ParticleBlood(blob.getPosition() + Vec2f(this.isFacingLeft() ? headoffset.x : -headoffset.x, headoffset.y), vel, SColor(255, 126, 0, 0));
				if (XORRandom(100) == 0)
					blob.Untag("cutthroat");
			}
		}
		else if (blob.hasTag("attack head"))
		{
			head.animation.frame = 1;
		}
		else
		{
			head.animation.frame = 0;
		}
		
		if (hat !is null)
		{
			Vec2f hat_offset = Vec2f(headoffset.x, headoffset.y-8);
			hat_offset += Vec2f(1, 6);
			
			hat.SetRelativeZ(this.getRelativeZ() + layer*0.5);
			hat.SetFacingLeft(blob.isFacingLeft());
			hat.SetOffset(hat_offset);
			hat.SetVisible(blob.hasTag("dead") ? false : this.isVisible());
		}
	}
}