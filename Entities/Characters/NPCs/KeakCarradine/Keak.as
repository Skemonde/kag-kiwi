#include "RunnerCommon.as"
#include "Help.as";
#include "KIWI_Locales.as";
#include "Hitters.as";
#include "addCharacterToBlob.as";
#include "BlobCharacter.as";

#include "Requirements.as";
#include "ShopCommon.as";
#include "Skemlib.as";

void onInit(CBlob@ this)
{
	//no spinning
	this.getShape().SetRotationsAllowed(false);
	this.getSprite().SetRelativeZ(-2);
	this.Tag("flesh");
	this.Tag("migrant");

	//this.getCurrentScript().runFlags |= Script::tick_not_attached;
	//this.getCurrentScript().runFlags |= Script::tick_moving;
	this.getCurrentScript().tickFrequency = 1;
	
	{
		this.set_u8("current_face", 0);
		this.set_string("custom_body", "face_keak.png");
		BlobCharacter@ character = BlobCharacter(this, "Keak Carradine");
		character.LoadTextConfig("KeakSpeech.cfg");
		character.PushToGlobalHandler();
	
		this.AddScript("BlobCharacterAddon");
	}
	if (isServer()) {
		this.server_setTeamNum(0);
	}
	
	//shop
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(5, 2));
	this.set_u8("shop icon", 25);
	this.set_string("shop description", "sugus");
	
	{
		ShopItem@ s = addShopItem(this, "", "$ruhm$", "ruhm", "", true);
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
	int closest_id = -1;
	if (getBlobsByTag("player", playrs) && isServer()) {
		for (int i = 0; i < playrs.size(); ++i)
		{
			//print("TARGET "+playrs[i].getName());
			const f32 dist = (playrs[i].getPosition() - pos).Length();
			if (dist < closest_dist)
			{
				closest_dist = dist;
				closest_id = i;
				this.SetFacingLeft(playrs[i].getPosition().x<pos.x);
				this.setAimPos(playrs[i].getPosition());
				this.set_u16("player_id", playrs[i].getNetworkID());
			}
		}
	}
	
	if (closest_id < 0) return;
	
	CBlob@ closest_plr = playrs[closest_id];
	
	if (closest_plr is null) return;
	
	// Unsure if this can even go null
	BlobCharacter@ char = getCharacter(this);
	if (char.isInteracting()) return;

	if (closest_plr is null || this.hasTag("dead") || char is null || !closest_plr.isMyPlayer() || !closest_plr.isKeyJustPressed(key_down))
		return;
		
	//print ("wtf "+char.isInteracting()+" "+getMachineType());
		
	//char.CurrentlyInteracting = true;
	//TryingToTalk(this, closest_plr);
	
	this.set_string("custom_body", "face_keak.png");
	BlobCharacter@ character = BlobCharacter(this, "Keak Carradine");
	if (character is null) return;
	character.LoadTextConfig("KeakSpeech.cfg");
	character.AddFunction("endingFunc", createMenu);
	character.PushToGlobalHandler();
	character.SetPreferedFont("neue");
	this.set_string("custom_color", "col-lapis_lazuli");
	
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
	}
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

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2 )
{
	//return;
	// Unsure if this can even go null
	this.set_string("custom_body", "face_keak.png");
	BlobCharacter@ character = BlobCharacter(this, "Keak Carradine");
	if (character is null) return;
	character.LoadTextConfig("KeakSpeech.cfg");
	character.AddFunction("endingFunc", createMenu);
	character.PushToGlobalHandler();
	character.SetPreferedFont("neue");
	this.set_string("custom_color", "col-lapis_lazuli");
	
	BlobCharacter@ char = getCharacter(this);

	if (blob is null || this.hasTag("dead") || char is null || char.CurrentlyInteracting || !blob.isMyPlayer())
		return;
		
	TryingToTalk(this, blob);
}

void TryingToTalk(CBlob@ this, CBlob@ caller)
{
	BlobCharacter@ char = getCharacter(this);
	char.ButtonPress();
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (hitterBlob !is this && getMap().isBlobInRadius("camp", this.getPosition(), 32.0f))
	{
		return 0.0f;
	}
	return damage;
}