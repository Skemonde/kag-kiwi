#include "RunnerTextures.as"

const string[] chicken_textures= 
{
	"CommanderChicken",
	"ScoutChicken",
	"HeavyChicken",
	"SoldierChicken",
	"AmbassadorChicken",
	"CivilianChicken"
};

void onInit(CSprite@ this)
{
	string file_name = chicken_textures[XORRandom(chicken_textures.size())];
	addRunnerTextures(this, file_name, file_name, false);

	this.getCurrentScript().runFlags |= Script::tick_not_infire;
}

void onPlayerInfoChanged(CSprite@ this)
{
	string file_name = chicken_textures[XORRandom(chicken_textures.size())];
	addRunnerTextures(this, file_name, file_name, false);
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	if (blob.hasTag("dead"))
	{
		this.SetAnimation("dead");
		return;
	}
	
	const bool left = blob.isKeyPressed(key_left);
	const bool right = blob.isKeyPressed(key_right);
	
	if (right || left)
	{
		this.SetAnimation("walk");
	}
	else this.SetAnimation("idle");
}