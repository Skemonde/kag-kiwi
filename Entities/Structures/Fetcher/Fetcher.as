#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "Costs.as";
#include "GenericButtonCommon.as";
#include "KIWI_Locales.as";
#include "ProductionCommon.as";

void onInit(CSprite@ this)
{
	this.SetEmitSound("gachuuck");
    this.SetEmitSoundSpeed(1);
	this.SetEmitSoundVolume(0.3);
	this.SetEmitSoundPaused(false);
}

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);
	CSprite@ sprite = this.getSprite();

	sprite.SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	addTokens(this);

	// PRODUCTION
	this.Tag("huffpuff production");   // for production.as
	this.set_Vec2f("production offset", Vec2f(20,0));
	//this.set_string("produce sound", "item_produced");
	
	{
		CBitStream requirements;
		AddRequirement( requirements, "blob", "froggy", "Nade", 1 );
		ShopItem@ s1 = addProductionItem(this, Names::revolver, "$revo$", "revo", Descriptions::revolver, 6, false, 2, @requirements, 1);
		ShopItem@ s2 = addProductionItem(this, Names::smg, "$smg$", "smg", Descriptions::smg, 6, false, 2, @requirements, 1);
		ShopItem@ s3 = addProductionItem(this, Names::rifle, "$rifle$", "rifle", Descriptions::rifle, 6, false, 2, @requirements, 1);
		ShopItem@ s4 = addProductionItem(this, Names::shotgun, "$shotgun$", "shotgun", Descriptions::shotgun, 6, false, 2, @requirements, 1);
		ShopItem@ s5 = addProductionItem(this, Names::mp, "$mp$", "mp", Descriptions::mp, 6, false, 2, @requirements, 1);
		ShopItem@ s6 = addProductionItem(this, Names::smg, "$kep$", "kep", Descriptions::smg, 6, false, 2, @requirements, 1);
		ShopItem@ s7 = addProductionItem(this, "", "$arr$", "arr", "", 6, false, 2, @requirements, 1);
		ShopItem@ s9 = addProductionItem(this, "", "$ass$", "ass", "", 6, false, 2, @requirements, 1);
	}
	sprite.addSpriteLayer("cog", "4teeth_cog.png", 10, 10);
	CSpriteLayer@ cog = sprite.getSpriteLayer("cog");
	if (cog !is null) {
		cog.SetOffset(Vec2f(-4,8));
		cog.SetRelativeZ(-55);
	}
	sprite.addSpriteLayer("cog2", "4teeth_cog.png", 10, 10);
	CSpriteLayer@ cog2 = sprite.getSpriteLayer("cog2");
	if (cog2 !is null) {
		cog2.SetOffset(Vec2f(-12,10));
		cog2.SetRelativeZ(-56);
	}
	sprite.addSpriteLayer("screw", "flathead_screw.png", 8, 8);
	CSpriteLayer@ screw = sprite.getSpriteLayer("screw");
	if (screw !is null) {
		screw.addAnimation("default", 3, true);
		int[] frames = { 0, 1, 2, 3};
		screw.animation.AddFrames(frames);
		screw.animation.backward;
		screw.SetOffset(Vec2f(2,6));
		//screw.SetRelativeZ(-30);
	}
	sprite.addSpriteLayer("screw2", "flathead_screw.png", 8, 8);
	CSpriteLayer@ screw2 = sprite.getSpriteLayer("screw2");
	if (screw2 !is null) {
		screw2.addAnimation("default", 3, true);
		int[] frames = { 1, 2, 3, 0};
		screw2.animation.AddFrames(frames);
		//screw2.animation.backward;
		screw2.SetOffset(Vec2f(-18,6));
		//screw.SetRelativeZ(-30);
	}
}

void onTick(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	f32 cogSpeed = 13;
	if (sprite !is null) {
		CSpriteLayer@ cog = sprite.getSpriteLayer("cog");
		CSpriteLayer@ cog2 = sprite.getSpriteLayer("cog2");
		if (cog !is null && cog2 !is null) {
			cog.RotateBy(cogSpeed, Vec2f_zero);
			cog2.RotateBy(-cogSpeed, Vec2f_zero);
		}
	}
}

void addTokens(CBlob@ this)
{
	int teamnum = this.getTeamNum();
	if (teamnum > 6) teamnum = 7;
}