#include "RunnerCommon.as"
#include "Help.as";
#include "KIWI_Locales.as";
#include "Hitters.as";
#include "addCharacterToBlob.as";
#include "BlobCharacter.as";

#include "Requirements.as";
#include "ShopCommon.as";

const string[] ed_faces =
{
	"mugshot_edward_forces_himself_to_smile.png", 			//0
	"mugshot_edward_surprised.png", 						//1
	"mugshot_edward_being_called_short.png", 				//2
	
	"nothing" //ed_faces.length
};

void onInit(CBlob@ this)
{
	//no spinning
	this.getShape().SetRotationsAllowed(false);
	this.getSprite().SetRelativeZ(-2);
	this.Tag("flesh");
	this.Tag("migrant");

	//this.getCurrentScript().runFlags |= Script::tick_not_attached;
	//this.getCurrentScript().runFlags |= Script::tick_moving;
	this.getCurrentScript().tickFrequency = 30;

	//check KIWI_Colors.as
	this.set_string("custom_color", "col-crimson");
	
	{
		this.set_u8("current_face", 0);
		this.set_string("custom_body", "faceedward.png");
		BlobCharacter@ character = BlobCharacter(this, "Itty Bitty Alchemist");
		character.LoadTextConfig("EdwardChatting.cfg");
		character.AddFunction("change face", setEdFace);
		character.PushToGlobalHandler();
		
	
		this.AddScript("BlobCharacterAddon");
	}
	if (isServer()) {
		this.server_setTeamNum(2);
	}
	
	//shop
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(5, 2));
	this.set_u8("shop icon", 25);
	this.set_string("shop description", "sugus");
	
	{
		ShopItem@ s = addShopItem(this, Names::ruhm, "$ruhm$", "ruhm", Descriptions::ruhm, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 20);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::highpow, "$highpow$", "highpow", Descriptions::highpow, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 10);
	}
	{
		ShopItem@ s = addShopItem(this, Names::amogus, "$amogus_con$", "sugoma", Descriptions::amogus, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 69);
	}
	return;

	// gun and ammo
	CBlob@ gun = server_CreateBlob("revo", this.getTeamNum(), this.getPosition());
	if (gun !is null)
	{
		this.server_Pickup(gun);
	}
	
	CBlob@ ammo = server_CreateBlob("highpow", this.getTeamNum(), this.getPosition());
	ammo.server_SetQuantity(ammo.maxQuantity * 2);
	this.server_PutInInventory(ammo);
}

void setEdFace(CBlob@ this, CBlob@ caller)
{
	//faces for messages from EdwardChatting.cfg
	if (this.get_u8("current_face") < ed_faces.length-2) {
		this.set_string("custom_body", ed_faces[this.get_u8("current_face")+1]);
		this.add_u8("current_face", 1);
	}
}

void createMenu(CBlob@ this, CBlob@ caller)
{
	this.set_bool("we need menu", true);
	BlobCharacter@ char = getCharacter(this);
	if (char !is null)
		char.CurrentlyInteracting = false;
}

void onTick(CBlob@ this)
{
	CBlob@[] playrs;
	f32 closest_dist = 999999.9f;
	const Vec2f pos = this.getPosition();
	if (getBlobsByTag("player", playrs) && isServer()) {
		for (int i = 0; i < playrs.size(); ++i)
		{
			//print("TARGET "+playrs[i].getName());
			const f32 dist = (playrs[i].getPosition() - pos).Length();
			if (dist < closest_dist)
			{
				closest_dist = dist;
				this.SetFacingLeft(playrs[i].getPosition().x<pos.x);
				this.setAimPos(playrs[i].getPosition());
				this.set_u16("player_id", playrs[i].getNetworkID());
			}
		}
	}
	
	this.set_string("custom_body", "faceedward.png");
	BlobCharacter@ character = BlobCharacter(this, "Itty Bitty Alchemist");
	character.LoadTextConfig("EdwardTrade.cfg");
	character.AddFunction("endingFunc", createMenu);
	character.PushToGlobalHandler();
	character.SetPreferedFont("readable");
	
	/* if (this.get_u8("current_face")==2){
		this.set_u8("current_face", 0);
		this.set_string("custom_body", "mugshot_edward_forces_himself_to_smile.png");
		BlobCharacter@ character = BlobCharacter(this, "Itty Bitty Alchemist");
		character.LoadTextConfig("EdwardChatting.cfg");
		character.AddFunction("change face", setEdFace);
		character.PushToGlobalHandler();
		//character.SetPreferedFont("pixeled");
	} */
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_bool("shop available", true);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
		u16 caller, item;
		if (!params.saferead_netid(caller) || !params.saferead_netid(item))
		{
			return;
		}
		CBlob@ blob = getBlobByNetworkID(caller);
		
		BlobCharacter@ char = getCharacter(this);
	
		if (blob is null || this.hasTag("dead") || char is null || char.CurrentlyInteracting || !blob.isMyPlayer())
			return;
			
		TryingToTalk(this, blob);
	}
}

void TryingToTalk(CBlob@ this, CBlob@ caller)
{
	BlobCharacter@ char = getCharacter(this);
	char.ButtonPress();
}

void onGib(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	Vec2f pos = blob.getPosition();
	Vec2f vel = blob.getVelocity();
	vel.y -= 3.0f;
	f32 hp = Maths::Min(Maths::Abs(blob.getHealth()), 2.0f) + 1.0;
	CParticle@ Gib1     = makeGibParticle("Entities/Special/WAR/Trading/TraderGibs.png", pos, vel + getRandomVelocity(90, hp , 80), 0, 0, Vec2f(16, 16), 2.0f, 20, "/BodyGibFall");
	CParticle@ Gib2     = makeGibParticle("Entities/Special/WAR/Trading/TraderGibs.png", pos, vel + getRandomVelocity(90, hp - 0.2 , 80), 1, 0, Vec2f(16, 16), 2.0f, 20, "/BodyGibFall");
	CParticle@ Gib3     = makeGibParticle("Entities/Special/WAR/Trading/TraderGibs.png", pos, vel + getRandomVelocity(90, hp , 80), 2, 0, Vec2f(16, 16), 2.0f, 0, "/BodyGibFall");
}

void onHealthChange(CBlob@ this, f32 oldHealth)
{
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	// doesnt collide with people or vehicles
	return !(blob.hasTag("player") || blob.hasTag("vehicle"));
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return false;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (hitterBlob !is this && getMap().isBlobInRadius("camp", this.getPosition(), 32.0f))
	{
		return 0.0f;
	}
	return damage;
}