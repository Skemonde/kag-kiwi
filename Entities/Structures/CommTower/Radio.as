// BuilderShop.as

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "CheckSpam.as"
#include "MakeCrate.as"

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(2, 7));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 11);

	{
		AddIconToken("$ammo_box_icon$", "AmmoBox.png", Vec2f(14, 11), 0);
		ShopItem@ s = addShopItem(this, "Ammunition Box", "$ammo_box_icon$", "ammo_box", "A box containing ammo that allows you to reload even when your gun is out of ammunition.", false);
		AddRequirement(s.requirements, "coin", "", "War Funds", 5);
		s.spawnNothing = true;
	}
	/*{
		AddIconToken("$grenade_icon$", "GrenadeIcon.png", Vec2f(16, 16), 0);
		ShopItem@ s = addShopItem(this, "Grenade", "$grenade_icon$", "grenade", "A grenade with a 5 second timer.", false);
		AddRequirement(s.requirements, "coin", "", "War Funds", 5);
		s.spawnNothing = true;
	}*/
	{
		AddIconToken("$med_box_icon$", "MedBox.png", Vec2f(16, 16), 0);
		ShopItem@ s = addShopItem(this, "Medical Supplies", "$med_box_icon$", "med_box", "Supplies for healing injuries.", false);
		AddRequirement(s.requirements, "coin", "", "War Funds", 5);
		s.spawnNothing = true;
	}
	{
		AddIconToken("$smgmk2_icon$", "SMGMk2.png", Vec2f(32, 16), 0);
		ShopItem@ s = addShopItem(this, "SMG Mk.II", "$smgmk2_icon$", "smg_mk2", "$smgmk2_icon$", false);
		AddRequirement(s.requirements, "coin", "", "War Funds", 25);
		s.spawnNothing = true;
	}
	{
		AddIconToken("$smgmk3_icon$", "SMGMk3.png", Vec2f(32, 16), 0);
		ShopItem@ s = addShopItem(this, "SMG Mk.III", "$smgmk3_icon$", "smg_mk3", "$smgmk3_icon$", false);
		AddRequirement(s.requirements, "coin", "", "War Funds", 50);
		s.spawnNothing = true;
	}
	{
		AddIconToken("$snipermk2_icon$", "SniperMk2.png", Vec2f(32, 16), 0);
		ShopItem@ s = addShopItem(this, "Sniper Mk.II", "$snipermk2_icon$", "sniper_mk2", "$snipermk2_icon$", false);
		AddRequirement(s.requirements, "coin", "", "War Funds", 25);
		s.spawnNothing = true;
	}
	{
		AddIconToken("$shotgun_icon$", "Shotgun.png", Vec2f(32, 16), 0);
		ShopItem@ s = addShopItem(this, "Shotgun", "$shotgun_icon$", "shotgun", "$shotgun_icon$", false);
		AddRequirement(s.requirements, "coin", "", "War Funds", 25);
		s.spawnNothing = true;
	}
	{
		AddIconToken("$gatlinggun_icon$", "GatlingGun.png", Vec2f(32, 16), 0);
		ShopItem@ s = addShopItem(this, "Gatling Gun", "$gatlinggun_icon$", "gatling_gun", "$gatlinggun_icon$", false);
		AddRequirement(s.requirements, "coin", "", "War Funds", 25);
		s.spawnNothing = true;
	}
	{
		AddIconToken("$autorifle_icon$", "AutoRifle.png", Vec2f(32, 16), 0);
		ShopItem@ s = addShopItem(this, "Auto-Rifle", "$autorifle_icon$", "auto_rifle", "$autorifle_icon$", false);
		AddRequirement(s.requirements, "coin", "", "War Funds", 50);
		s.spawnNothing = true;
	}
}

CBlob@ getRadioTower(CBlob @this){
	CBlob @Tower = null;
	CBlob@[] blobs;

	getBlobsByName("radio_tower",@blobs);
	
	for (int i = 0; i < blobs.length; i++)
	{
		CBlob@ b = blobs[i];

		if(Tower is null || this.getDistanceTo(b) < this.getDistanceTo(Tower)){
			@Tower = b;
		}
	}
	return Tower; 
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_Vec2f("shop offset", Vec2f(0,0));
	CBlob @tower = getRadioTower(this);
	if(tower !is null){
		this.set_bool("shop available", tower.getTeamNum() == caller.getTeamNum());
		if(tower.getTeamNum() != caller.getTeamNum()){
			CButton @but = caller.CreateGenericButton(9, Vec2f(0,0), this, 0, "Capture the nearest radio tower first.");
			if(but !is null)but.SetEnabled(false);
		}
	} else {
		CButton @but = caller.CreateGenericButton(9, Vec2f(0,0), this, 0, "No connected tower.");
		if(but !is null)but.SetEnabled(false);
		this.set_bool("shop available", false);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");

		if(!getNet().isServer()) return; /////////////////////// server only past here

		u16 caller, item;
		if (!params.saferead_netid(caller) || !params.saferead_netid(item))
		{
			return;
		}
		string name = params.read_string();
		{
			CBlob@ callerBlob = getBlobByNetworkID(caller);
			if (callerBlob is null)
			{
				return;
			}
			
			Vec2f pos = this.getPosition();
			
			CBlob @tower = getRadioTower(this);
			if(tower !is null)pos = tower.getPosition();

			CBlob @crate = server_MakeCrateOnParachute(name, "", 5, callerBlob.getTeamNum(), getDropPosition(pos));
			if(callerBlob.getPlayer() !is null){
				crate.Tag("only_owner");
				crate.set_string("owner",callerBlob.getPlayer().getUsername());
			}
		}
	}
}
