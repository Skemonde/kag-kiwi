#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "Costs.as";
#include "GenericButtonCommon.as";
#include "KIWI_Locales.as";
#include "getShopMenuHeight.as";
#include "ProductionCommon"

const Vec2f SIGN_OFFSET(9, 0);

void onInit(CSprite@ this)
{
	this.SetEmitSound("gachuuck");
    this.SetEmitSoundSpeed(1);
	this.SetEmitSoundVolume(0.15);
	this.SetEmitSoundPaused(false);
	
	AddSignLayerFrom(this);
}

void onTick(CSprite@ this)
{
	updateIconLayer(this);
}

void AddSignLayerFrom(CSprite@ this)
{
	RemoveSignLayer(this);

	CBlob@ blob = this.getBlob();

	int team = blob.getTeamNum();
	int skin = blob.getSkinNum();

	int rot = 0;
	if (blob.exists("rot")) {
		rot = blob.get_f32("rot");
	}
	else {
		rot = 15 - XORRandom(30);
		blob.set_f32("rot", rot);
	}

	CSpriteLayer@ sign = this.addSpriteLayer("sign", "Factory.png" , 32, 16, team, skin);
	{
		Animation@ anim = sign.addAnimation("default", 0, false);
		anim.AddFrame(11);
		sign.SetOffset(SIGN_OFFSET);
		sign.SetRelativeZ(2);
		sign.RotateBy(rot, Vec2f());
	}
}

void disableSignAndIconSprites(CSprite@ this)
{
	if (this.getSpriteLayer("icon") !is null)
		this.getSpriteLayer("icon").SetVisible(false);
		
	if (this.getSpriteLayer("sign") !is null)
		this.getSpriteLayer("sign").SetVisible(false);
	return;
}

void updateIconLayer(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	
	ShopItem[]@ shop_items;
	if (!blob.get(SHOP_ARRAY, @shop_items)) return;
	u8 item_idx = blob.get_u8("crafting");
	ShopItem@ item = null;
	if (item_idx==255) {
		disableSignAndIconSprites(this);
		return;
	}
	@item = @shop_items[item_idx];
	Vec2f icon_dims = Vec2f();
	
	CSpriteLayer@ icon = this.getSpriteLayer("icon");
	if (icon is null || icon.getFilename()!=getIconTokenFilename(item.iconName)) {
		this.RemoveSpriteLayer("icon");
		
		GUI::GetIconDimensions(item.iconName, icon_dims);
		@icon = this.addSpriteLayer("icon", getIconTokenFilename(item.iconName), icon_dims.x, icon_dims.y, blob.getTeamNum(), 0);
	} else {
		icon.SetVisible(true);
		this.getSpriteLayer("sign").SetVisible(true);
		
		icon.ResetTransform();
		icon.SetOffset(SIGN_OFFSET);
		icon.SetRelativeZ(2.2f);
		icon.RotateBy(blob.get_f32("rot"), Vec2f());
	}
	
	
	return;
	if (icon is null) {
		this.RemoveSpriteLayer("icon");
		@icon = this.addSpriteLayer("icon", "AssemblerIcons.png", 16, 16, blob.getTeamNum(), 0);
	} else {
		if (item_idx==255) {
			icon.SetVisible(false);
			this.getSpriteLayer("sign").SetVisible(false);
			return;
		}
		icon.SetVisible(true);
		this.getSpriteLayer("sign").SetVisible(true);
		
		icon.ResetTransform();
		icon.SetOffset(SIGN_OFFSET);
		icon.SetRelativeZ(2.2f);
		icon.RotateBy(blob.get_f32("rot"), Vec2f());
		icon.SetFrameIndex(item_idx);
	}
}

void RemoveSignLayer(CSprite@ this)
{
	this.RemoveSpriteLayer("sign");
	this.RemoveSpriteLayer("icon");
}

void onInit(CBlob@ this)
{
	int teamnum = Maths::Min(this.getTeamNum(), 7);
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
	this.set_u8("crafting", 255);
	this.addCommandID("menu");
	this.addCommandID("set");
	this.Tag("inventory access");
	
	{
		ShopItem@ s = addShopItem(this, Names::revolver, "$revo$", "revo", Descriptions::revolver, true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 2);
	}
	{
		ShopItem@ s = addShopItem(this, Names::mp, "$mp$", "mp", Descriptions::mp, true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 2);
	}
	{
		ShopItem@ s = addShopItem(this, Names::smg, "$spp$", "spp", Descriptions::smg, true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 10);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::shotgun, "$shaggy$", "shaggy", Descriptions::shotgun, true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 10);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::rifle, "$bifle$", "bifle", Descriptions::rifle, true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 25);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Submachine Gun \"KEP\"", "$kep$", "kep", "An interesting thing! The more you shoot the worse your accuracy gets!!! Shoot by small bursts!", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 15);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Rocketer", "$rocketer$", "rocketer", "a cool thing gotta tell ya", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 25);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::empty, "$arr$", "arr", Descriptions::empty, true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 25);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::atr, "$atr$", "atr", Descriptions::atr, true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 100);
		s.customButton = true;
		s.buttonwidth = 3;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Tank Shell", "$tankshells$", "tankshells", "CAREFUL WITH THAT ONE!!!! GOES OFF UPON SMALLEST IMPACT", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 5);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Hand Grenade", "$froggy$", "froggy", "Cool grenade :>", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 3);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Anti-Tank Mine", "$tankmine_icon"+teamnum+"$", "tankmine", "Doesn't give a damn about filthy infantry", true);
		AddRequirement(s.requirements, "blob", "mat_steel", "Steel Bar", 15);
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
	return;
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
void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());

	CButton@ button = caller.CreateGenericButton(15, Vec2f(0,-8), this, this.getCommandID("menu"), "Set Item", params);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("menu"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null)
		{
			if(caller.isMyPlayer())
			{
				u8 menu_width = 6;
				CGridMenu@ menu = CreateGridMenu(getDriver().getScreenCenterPos() + Vec2f(0.0f, 0.0f), this, getShopMenuHeight(this, menu_width)+Vec2f(0,1), "Set Assembly");
				if (menu !is null)
				{
					CBitStream reset_stream;
					reset_stream.write_u8(255);
					CGridButton@ noitem = menu.AddButton("NoItemIcon.png", 0, Vec2f(24, 24), "Reset Item", this.getCommandID("set"), Vec2f(menu_width, 1), reset_stream);
					if (this.get_u8("crafting") == 255 && noitem !is null) {
						noitem.SetEnabled(false);
						noitem.hoverText = "Assembler produces nothing";
					}
					ShopItem[]@ shop_items;
					if (!this.get(SHOP_ARRAY, @shop_items)) return;
					for(uint i = 0; i < shop_items.length; i += 1)
					{
						ShopItem@ item = @shop_items[i];

						CBitStream pack;
						pack.write_u8(i);

						string text = "Set to Assemble: " + item.name;
						if(this.get_u8("crafting") == i)
						{
							text = "Already Assembling: " + item.name;
						}

						CGridButton @butt = menu.AddButton(item.iconName, text, this.getCommandID("set"), item.customButton?Vec2f(item.buttonwidth, item.buttonheight):Vec2f(1,1), pack);
						butt.hoverText = item.name + "\n\n" + item.description + "\n\n" + getButtonRequirementsText(item.requirements, false);
						if(this.get_u8("crafting") == i)
						{
							butt.SetEnabled(false);
						}
					}
				}
			}
		}
	}
	if (cmd == this.getCommandID("set"))
	{
		this.getSprite().PlaySound("LeverToggle.ogg", 2.0f, 0.8f);
		u8 old_setting = this.get_u8("crafting");
		u8 setting = params.read_u8();
		this.set_u8("crafting", setting);
		
		if (old_setting == 255) { //was nothing
			this.getSprite().PlaySound("PowerUp.ogg");
		}
			
		ShopItem[]@ queue_items;
		if (!this.get(PRODUCTION_QUEUE, @queue_items)) return;
		
		ShopItem[]@ prod_items;
		if (!this.get(PRODUCTION_ARRAY, @prod_items)) return;
		
		for (int i = 0; i<queue_items.size(); i++)
			queue_items.erase(i);
		for (int i = 0; i<prod_items.size(); i++)
			prod_items.erase(i);
		
		if (setting == 255) { //was just set to nothing
			this.getSprite().PlaySound("PowerDown.ogg", 2.0f, 1.0f);
			this.Tag("production paused");
		} else {
			this.Untag("production paused");
			ShopItem[]@ shop_items;
			if (!this.get(SHOP_ARRAY, @shop_items)) return;
				
			ShopItem@ our_item = @shop_items[setting];
			if (our_item !is null) {
				ShopItem@ s = addProductionItem(this, PRODUCTION_ARRAY, our_item.name, our_item.iconName,
	our_item.blobName, our_item.description, 10, false, -1, our_item.requirements, 1);
			}
		}
	}
}

void onTick(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	f32 cogSpeed = 13;
	sprite.SetEmitSoundPaused(this.get_u8("crafting") == 255);
	if (this.get_u8("crafting") == 255) return;
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