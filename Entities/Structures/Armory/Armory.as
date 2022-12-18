#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "CheckSpam.as"
#include "Costs.as"
#include "GenericButtonCommon.as"

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	//INIT COSTS
	InitCosts();

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 5));
	this.set_string("shop description", " Hachi from Orange Star sends his greetings  ");
	this.set_u8("shop icon", 25);
	this.Tag("workshop");

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	this.set_string("required class", "soldat");

	{
		ShopItem@ s = addShopItem(this, "Lowcal Ammo", "$lowcal$", "lowcal", " Ammo for handguns and submachine guns  ", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 5);
	}
	{
		ShopItem@ s = addShopItem(this, "Revolver", "$revo$", "revo", " Simple but still dangerous - the handgun is a good choice for those who's tired of fighting with their bare hands\n\nUses  $lowcal$ as ammo.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 10);
	}
	{
		ShopItem@ s = addShopItem(this, "SMP", "$pp$", "pp", " Amazing choice for those who got themselves in a meele fight where you don't have time for aiming and reloading\n\nUses  $lowcal$ as ammo.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 15);
	}
	{
		ShopItem@ s = addShopItem(this, "SMG", "$kp$", "kp", " Amazing choice for those who got themselves in a meele fight where you don't have time for aiming and reloading\n\nUses  $lowcal$ as ammo.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 15);
	}
	{
		ShopItem@ s = addShopItem(this, "Highpow Ammo", "$highpow$", "highpow", " Ammo for rifles and heavy machine guns  ", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 15);
	}
	{
		ShopItem@ s = addShopItem(this, "Rifle", "$rifle$", "rifle", " Power and accuracy are a brilliant choice for shooting foes who keep themselves afar\n\nUses  $highpow$ as ammo.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 20);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Machine Pistol", "$mp$", "mp", " Simple but still dangerous - the handgun is a good choice for those who's tired of fighting with their bare hands. This one is a good choice for those who's got their fingers tired\n\nUses  $lowcal$ as ammo.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 10);
	}
	/*
	{
		ShopItem@ s = addShopItem(this, "Grenades", "$grenades$", "grenades", " Ammo for Grenade Launcher  ", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 5);
	}
	{
		ShopItem@ s = addShopItem(this, "Grenade Launcher", "$gl$", "gl", " A foe is hinding in a trench or behind a wall? This gun is a right choice!  ", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 25);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	*/
	{
		ShopItem@ s = addShopItem(this, "Shotgun Shells", "$shells$", "shells", " Shotgun shells for shotguns you guessed it!  ", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 10);
	}
	{
		ShopItem@ s = addShopItem(this, "Shotgun", "$shotgun$", "shotgun", " Everyone loves powerful guns!!\n\nUses  $shells$ as ammo.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 25);
	}
	{
		ShopItem@ s = addShopItem(this, "Full-Auto Shotgun", "$ass$", "ass", " God mothaducking dammmn\n\nUses  $shells$ as ammo.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 40);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Frag Grenade 'Froggy'", "$froggy$", "froggy", " Holy moly!\n Use with caution!!  ", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 5);
	}
	{
		ShopItem@ s = addShopItem(this, "Flash Grenades 'Flashy'", "$flashy$", "flashy", " Holy moly!\n Use with caution!!  ", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 5);
	}
	{
		ShopItem@ s = addShopItem(this, "Sniper Rifle", "$sniper$", "sniper", " What seems an ordinary gun with just an increased damage happens to be an actual mere one but with a very cool projectile (it pierces 3 targets before fading)\n\nUses  $highpow$ as ammo.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 40);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Kushana's Blaster", "$blaster$", "blaster", " If you've seen Nausicaa of Miyadzaki Hayao you probably are familiar the handgun\n\nUses  $lowcal$ as ammo.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
	}
	{
		ShopItem@ s = addShopItem(this, "Sniper Machine Gun 'Ruhm'", "$ruhm$", "ruhm", " VALKYRIA CHRONICLES 1 !!!!!!!!!!!!\nSelvaria Bles is best girl\n\nUses  $highpow$ as ammo.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Amogus", "$sugoma$", "sugoma",
			"bruh\nyou lookin' real sussy over there\ndid you take the fortnite card for me bruh?\nimma need that fortnite card back\nbut you're sussy and i'm coming to get it\nimma BLOCK you go\nB L O C C", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 69);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

	if (caller.getConfig() == this.get_string("required class"))
	{
		this.set_Vec2f("shop offset", Vec2f_zero);
	}
	else
	{
		this.set_Vec2f("shop offset", Vec2f(6, 0));
	}
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
	}
}