//Ghost logic

#include "Hitters.as";
#include "Knocked.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "Help.as";
#include "Requirements.as"

void onInit(CBlob@ this)
{
	//this.Tag("noBubbles"); this is for disabling emoticons, we won't need that.
	this.Tag("notarget"); //makes AI never target us
	this.Tag("noCapturing");
	this.Tag("truesight");

	this.Tag("noUseMenu");
	this.set_f32("gib health", -3.0f);

	this.getShape().getConsts().mapCollisions = false;

	this.Tag("player");
	this.Tag("invincible");
	this.Tag("no_invincible_removal");

	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(true);
	shape.getConsts().net_threshold_multiplier = 0.5f;

	this.set_Vec2f("inventory offset", Vec2f(0.0f, -152.0f));

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";

	if (!getRules().hasTag("tournament"))
	{
		this.SetLight(true);
		this.SetLightRadius(80.0f);
		this.SetLightColor(SColor(255, 255, 0, 0));

		ShakeScreen(64, 32, this.getPosition());
	}
	this.getSprite().SetZ(1300);

	if(!isClient()){return;}
	//ParticleZombieLightning(this.getPosition());
	//if (!this.hasTag("nosound")) this.getSprite().PlaySound("MagicWand.ogg");

	this.set_u8("rotation_mod", 1);
	this.set_bool("increment", true);
	this.set_f32("rotation", 0);
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null)
	{
		/*player.server_setTeamNum(-1);
		this.server_setTeamNum(-1);*/
		player.SetScoreboardVars("ScoreboardIcons.png", (this.getSexNum() == 0 ? 8 : 9), Vec2f(16, 16));
		//client_AddToChat(player.getUsername() + " has entered the " + (this.getSexNum() == 0 ? "Grandpa" : "Grandma") + " Administrator mode!", SColor(255, 255, 80, 150));
	}
}

void onDie(CBlob@ this)
{
	CPlayer@ player = this.getPlayer();

	//if (player !is null)
	//{
	//	// client_AddToChat(player.getUsername() + " is no longer in the Grandpa Administrator mode!", SColor(255, 255, 80, 150));
	//	client_AddToChat(player.getUsername() + " has left the " + (this.getSexNum() == 0 ? "Grandpa" : "Grandma") + " Administrator mode!", SColor(255, 255, 80, 150));
	//}

	ShakeScreen(64, 32, this.getPosition());
	if(!isClient()){return;}
	ParticleZombieLightning(this.getPosition());
	this.getSprite().PlaySound("SuddenGib.ogg", 0.9f, 1.0f);
}

void onTick(CBlob@ this)
{
	if (this.isKeyPressed(key_action1)) this.AddForce(this.getAimPos()-this.getPosition());
	CSprite@ sprite = this.getSprite();
	CMap@ map = this.getMap();
	if (map !is null)
	{
		if (this.getPosition().y > map.tilemapheight*8-24) this.AddForce(Vec2f(0, -1000.0f));
	}
	if (sprite !is null)
	{
		//if (this.isKeyPressed(key_action2))
		//{
		//	if (this.isKeyJustPressed(key_action2))
		//	{
		//		this.set_u8("rotation_mod", 0);
		//		this.set_bool("increment", true);
		//	}
		//	this.get_bool("increment") ? this.add_u8("rotation_mod", 1) : this.add_u8("rotation_mod", -1);
		//	if (this.get_u8("rotation_mod") >= 60 || this.get_u8("rotation_mod") == 0) this.set_bool("increment", !this.get_bool("increment"));
		//	u8 mod = this.get_u8("rotation_mod");
		//	u32 gametime = getGameTime();
		//	this.isFacingLeft() ? sprite.RotateBy(-1.0f*mod, Vec2f(0,0)) : sprite.RotateBy(1.0f*mod, Vec2f(0,0));
		//}

		if (this.isKeyJustPressed(key_action3)) this.setAngleDegrees(0);
		if (this.isKeyJustPressed(key_action2))
		{
			this.set_u8("rotation_mod", 0);
			this.set_bool("increment", true);
		}
		if (this.isKeyPressed(key_action2))
		{
			if (this.get_u8("rotation_mod") <= 100) this.add_u8("rotation_mod", 1);
		}
		else if (this.get_u8("rotation_mod") > 0) this.add_u8("rotation_mod", -1);
		
		u8 mod = this.get_u8("rotation_mod");
		u32 gametime = getGameTime();
		if (this.isFacingLeft())
		{
			//sprite.RotateBy(-1.0f*mod, Vec2f(0,0));
			this.setAngleDegrees(this.getAngleDegrees() - 1.0f*mod);
			this.set_f32("rotation", (this.get_f32("rotation")-1.0f*mod) % 360.0f);
		}
		else
		{
			//sprite.RotateBy(1.0f*mod, Vec2f(0,0));
			this.setAngleDegrees(this.getAngleDegrees() + 1.0f*mod);
			this.set_f32("rotation", (this.get_f32("rotation")+1.0f*mod) % 360.0f);
		}
	}

	if (this.isInInventory()) return;
}