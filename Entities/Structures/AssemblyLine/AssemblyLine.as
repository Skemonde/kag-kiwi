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
	this.SetEmitSoundVolume(0.15);
	this.SetEmitSoundPaused(false);
}

void onInit(CBlob@ this)
{
	// set up tracks (positions are relative to this blob's sprite texture)
	Vec2f points_offset = Vec2f(8, 4);
	Vec2f[] tracks_points = {
		Vec2f(-11.5,  3.5)+points_offset,
		Vec2f(  0.0,  4.8)+points_offset,
		Vec2f( 11.5,  3.5)+points_offset,
		Vec2f( 11.5, -3.5)+points_offset,
		Vec2f(  0.0, -4.8)+points_offset,
		Vec2f(-11.5, -3.5)+points_offset
	};
	this.set("tracks_points", tracks_points);
	this.set_f32("tracks_distanced", 6.0f);
	this.set_f32("tracks_const_speed", 0.15f);
	this.set_Vec2f("tracks_rotation_center", Vec2f(0, 0)+this.getSprite().getOffset());
	this.set_Vec2f("tracks_rotation_offset", Vec2f(0, 0));
	this.set_string("tracks_texture", "tank_track.png");
	
	
	this.set_TileType("background tile", CMap::tile_wood_back);
	CSprite@ sprite = this.getSprite();

	sprite.SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	addTokens(this);

	// PRODUCTION
	//this.Tag("huffpuff production");   // for production.as
	this.set_Vec2f("production offset", Vec2f(24,0));
	//this.set_string("produce sound", "item_produced");
	
	{
		CBitStream requirements;
		AddRequirement( requirements, "blob", "mat_steel", "Steel Bar", 5 );
		//ShopItem@ s = addProductionItem(this, Names::lowcal, "$lowcal$", "lowcal", Descriptions::lowcal, 6, false, 20, @requirements, 80);
		ShopItem@ s = addProductionItem(this, Names::highpow, "$highpow$", "highpow", Descriptions::highpow, 6, false, 20, @requirements, 40);
	}
	{
		CBitStream requirements;
		AddRequirement( requirements, "blob", "mat_steel", "Steel Bar", 5 );
		AddRequirement( requirements, "blob", "mat_wood", "Wood", 100 );
		ShopItem@ s = addProductionItem(this, Names::shotgunshells, "$shells$", "shells", Descriptions::shotgunshells, 6, false, 20, @requirements, 24);
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