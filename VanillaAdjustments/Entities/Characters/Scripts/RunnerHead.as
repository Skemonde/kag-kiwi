// generic character head script

// TODO: fix double includes properly, added the following line temporarily to fix include issues
#include "PaletteSwap.as"
#include "PixelOffsets.as"
#include "RunnerTextures.as"
#include "Accolades.as"
#include "FirearmVars.as" //for angle function
#include "KIWI_Players&Teams"
#include "KIWI_RespawnSystem"
#include "RulesCore"
#include "KIWI_RulesCore"
#include "HolidayCommon"
#include "SoldatInfo"

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
	
	bool is_bot = false;
	u8 bot_sex;
	CPlayer@ player = blob.getPlayer();
	if (player !is null && player.isBot()) {
		is_bot = true;
		bot_sex = player.getNetworkID()%512<256?0:1;
	}

	return (((headIndex - NUM_UNIQUEHEADS / 2) * 2) +
	        ((blob.getSexNum() == 0 || (is_bot&&bot_sex==0)) ? 0 : 1)) * NUM_HEADFRAMES;
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
	if (blob !is null)
		blob.set_s32("headIndex", headIndex);

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
			string file_path = "../Mods/KIWI/Gamemode/Headpacks/";
			string head_file = file_path + player.getUsername() + ".png";
				
			bool customFileExists = CFileMatcher(head_file).hasMatch();
			bool isHeadValid = false;
			if (customFileExists)
				isHeadValid = CFileImage(head_file).getWidth()==64;
			Accolades@ acc = getPlayerAccolades(player.getUsername());
			bool gotAccoladeHead = acc.hasCustomHead();
			
			if (g_debug>0) {
				print("headfile "+head_file);
			}
			//print("got accolade head "+gotAccoladeHead);
				
			if(customFileExists)
			{
				if (g_debug>0) {
					CFileMatcher(head_file).printMatches();
					print(player.getCharacterName() + " the " + blob.getName() + " has their head set properly! Congratz");
				}
				if (rules.exists(player.getUsername() + "HeadIndex"))
				{
					head_idx = rules.get_u8(player.getUsername() + "HeadIndex");
				}
				if (rules.exists(player.getUsername() + "Headpack"))
					texture_file = rules.get_string(player.getUsername() + "Headpack");
				else
					texture_file = head_file;
				
				headIndex = head_idx;
				headsPackIndex = 0;
				override_frame = true;
				//player.Tag("custom_head");
				rules.set_bool("custom_head"+player.getUsername(), true);
				
			} else if (gotAccoladeHead) {
				texture_file = acc.customHeadTexture;
				headIndex = acc.customHeadIndex;
				headsPackIndex = 0;
				override_frame = true;
				rules.set_bool("custom_head"+player.getUsername(), true);
			}
			else if (rules.exists(holiday_prop))
			{
				if (rules.exists(holiday_head_prop))
				{
					headIndex = rules.get_u8(holiday_head_prop);
					headsPackIndex = 0;

					if (rules.exists(holiday_head_texture_prop))
					{
						texture_file = rules.get_string(holiday_head_texture_prop);
						override_frame = true;

						headIndex += blob.getSexNum();
						//sex for bots
						if (player.isBot())
							headIndex += player.getNetworkID()%512<256?0:1;
					}
				}
			}
			else
			{
				//player.Untag("custom_head");
				rules.set_bool("custom_head"+player.getUsername(), false);
				if (g_debug>0)
					print("no head fo ya :C");
			}
		}
	}
	else
	{
		//it's not a custom head but it's definitely not a default one too ?_?
		if (player !is null)
			rules.set_bool("custom_head"+player.getUsername(), true);
	}

	int team = doTeamColour(headsPackIndex) ? blob.getTeamNum() : 0;
	int skin = doSkinColour(headsPackIndex) ? blob.getSkinNum() : 0;
	
	bool has_hat = false;
	if (player !is null) {
		SoldatInfo@ info = getSoldatInfoFromUsername(player.getUsername());
		bool infos_exist = info !is null;
		if (!infos_exist) return null;
		
		string player_hat = info.hat_name;
		has_hat = !player_hat.empty();
	}
	
	//if player is a mere grunt or doesn't have a cool head to show off in role of CO they get a super basic head (commanders will still have a cool hat though)
	if (g_debug >0)
		print("head n "+headIndex);
	if (wearsHat(blob) && (player !is null && (!rules.get_bool("custom_head"+player.getUsername())
		||has_hat
		/* || getRules().get_u8(player.getUsername()+"rank")>3 */)) &&
		allowed_heads.find(headIndex)<0 &&
		!isFlagHead(headIndex) &&
		allowed_usernames.find(player.getUsername())<0
		)
	{
		if (!wearsHat(blob))
			headIndex = player.getNetworkID()%69+30;
		else {
			texture_file = "GruntHead.png";
			headIndex = player.getNetworkID()%3;
		}
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

string[] allowed_usernames = {
	"GoldenGuy",
};

bool isFlagHead(int head_id)
{
	return head_id>=287&&head_id<=363;
}

u16[] allowed_heads = {
	30,
	31,
	33,
	34,
	35,
	36,
	40,
	41,
	43,
	45,
	46,
	48,
	49,
	50,
	51,
	52,
	53,
	54,
	55,
	56,
	57,
	58,
	61,
	62,
	64,
	66,
	67,
	69,
	70,
	71,
	72,
	74,
	76,
	85,
	89,
	94,
	95,
	96,
	97,
	98,
	543,
	549,
	554,
	555,
	557
};

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
		
		CPlayer@ player = blob.getPlayer();
		if (player is null||true) return;
		if(!getRules().get_string(player.getUsername() + "hat_name").empty())
		{
			print("hat gib");
			makeGibParticle(
				getRules().get_string(player.getUsername() + "hat_name")+".png",
				pos, vel + getRandomVelocity(90, hp , 30),
				0, 0, Vec2f(16, 16),
				2.0f, 20, "/BodyGibFall", blob.getTeamNum()
			);
		}
	}
}

bool wearsHat(CBlob@ blob)
{
	//return false;
	return blob.getName() == "engi" || blob.getName() == "soldat" || blob.hasTag("has_hat");
}

CSpriteLayer@ getHat(CSprite@ this)
{
	this.RemoveSpriteLayer("hat");
	CBlob@ blob = this.getBlob();
	CPlayer@ player = blob.getPlayer();
	
	string hat_name = "";
	
	if (wearsHat(blob) && player !is null) {
		//KIWICore@ core;
		//getRules().get("core", @core);
		//if (core is null) return null;
		//
		//KIWIPlayerInfo@ info = core.getKIWIInfoFromPlayer(player);
		//if (info is null) return null;
		SoldatInfo@ info = getSoldatInfoFromUsername(player.getUsername());
		bool infos_exist = info !is null;
		if (!infos_exist) return null;
		
		string player_hat = info.hat_name;
		
		if (!player_hat.empty()) {
			{//if (!player_hat.empty()) {
				if (player_hat=="helm") {
					hat_name = "team_helm";
					switch (blob.getTeamNum()) {
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
					if (blob.hasTag("commander") || info.rank>3) {
						hat_name += "_cap";
						//if (getRules().get_bool("custom_head"+player.getUsername()))
						//	//commanders can be unique!!!!
						//	hat_name = "";
					} else if (blob.hasTag("grunt")) {
						hat_name += "_helm";
					}
				}
				else {
					hat_name = "hat_"+player_hat;
				}
			}
		}
	}
		
	blob.set_string("hat_name", hat_name);
	if (!hat_name.empty()) {
		if (g_debug >0)
			print(""+hat_name);
		CSpriteLayer@ hat = this.addSpriteLayer("hat", hat_name, 32, 32, blob.getTeamNum(), 0);
		return hat;
	}
	else {
		return null;
	}
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	CPlayer@ player = blob.getPlayer();
	const bool FLIP = blob.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1: 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;

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
	
	bool needs_update = blob.hasTag("needs a head update");
	
	if (hat is null || (needs_update && isClient())) {
		@hat = getHat(this);
		//this tag is only given to guys on client
		blob.Untag("needs a head update");
	}
	// load head when player is set or it is AI
	if (head is null && (player !is null || (blob.getBrain() !is null && blob.getBrain().isActive()) || blob.getTickSinceCreated() > 3) || needs_update || (blob.get_s32("headIndex") != blob.getHeadNum()))
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
		f32 head_z = this.getRelativeZ() + layer * 0.55f; //changed from 0.25 to 0.55 so it's above legs, torso and arms
		if (blob.isAttached()&&!blob.hasTag("isInVehicle")&&!blob.isAttachedToPoint("PICKUP"))
			head_z += 300;

		// behind, in front or not drawn
		if (layer == 0)
		{
			head.SetVisible(false);
		}
		else
		{
			head.SetVisible(this.isVisible());
			head.SetRelativeZ(head_z);
		}

		offset = head_offset;

		// set the proper offset
		Vec2f headoffset(this.getFrameWidth() / 2, -this.getFrameHeight() / 2);
		headoffset += this.getOffset();
		headoffset += Vec2f(-offset.x, offset.y);
		headoffset += Vec2f(0, -2);
		if (blob.hasTag("attack head"))
			headoffset += Vec2f(1, 0);
		if (blob.hasTag("dead head"))
			headoffset += Vec2f(0, 2);
		head.SetOffset(headoffset);
		head.ResetTransform();
		f32 lower_clamp = Maths::Abs(blob.getVelocity().x)<1?-35:0;
		f32	upper_clamp = 45;
		f32 headangle = Maths::Clamp(getHeadAngle(blob, headoffset), FLIP?lower_clamp:-upper_clamp, FLIP?upper_clamp:-lower_clamp);
		if (blob.getCarriedBlob() !is null && blob.getCarriedBlob().getName()=="bino" && (blob.isKeyPressed(key_down))||blob.isAttached())
			headangle = 0;
		//printf("angle "+headangle);

		if (blob.hasTag("dead") || blob.hasTag("dead head"))
		{
			headangle = -lower_clamp*FLIP_FACTOR+blob.getAngleDegrees();
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
		
		blob.set_f32("head_angle", headangle);
		
		if (hat !is null)
		{
			Vec2f hat_offset = Vec2f(headoffset.x, headoffset.y-8);
			hat_offset += Vec2f(1, 6);
			
			hat.SetRelativeZ(head_z+0.3f);
			hat.SetFacingLeft(blob.isFacingLeft());
			hat.SetOffset(hat_offset);
			hat.SetVisible(blob.hasTag("dead") ? false : (this.isVisible()));
			hat.ResetTransform();
			hat.RotateBy(headangle+blob.getAngleDegrees()*0, Vec2f(-1*FLIP_FACTOR,6));
		}
		head.RotateBy(headangle+blob.getAngleDegrees()*0, Vec2f(0, 4));
	}
}

f32 getHeadAngle(CBlob@ this, Vec2f headoffset)
{
	const bool flip = this.isFacingLeft();
	const f32 flip_factor = flip ? -1: 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	
	Vec2f pos = this.getPosition() + headoffset.RotateBy(-this.getAngleDegrees());
 	Vec2f aimvector = this.getAimPos() - pos;
	f32 angle = aimvector.Angle() + this.getAngleDegrees();
    return constrainAngle(angle_flip_factor-(angle+flip_factor));
}