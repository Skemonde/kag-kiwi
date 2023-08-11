#include "Requirements.as";
#include "KIWI_Locales.as";
//#include "MakeMat.as";

const Vec2f SIGN_OFFSET(-4, -2);

void onInit(CSprite@ this)
{
	// Building
	this.SetZ(-50);

	this.SetEmitSound("assembler_loop.ogg");
	this.SetEmitSoundVolume(1.0f);
	this.SetEmitSoundSpeed(0.5f);
	this.SetEmitSoundPaused(false);

	{
		this.RemoveSpriteLayer("gear1");
		CSpriteLayer@ gear = this.addSpriteLayer("gear1", "Assembler.png" , 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

		if (gear !is null)
		{
			Animation@ anim = gear.addAnimation("default", 0, false);
			anim.AddFrame(3);
			gear.SetOffset(Vec2f(-10.0f, -6.0f));
			gear.SetAnimation("default");
			gear.SetRelativeZ(-60);
		}
	}

	{
		this.RemoveSpriteLayer("gear2");
		CSpriteLayer@ gear = this.addSpriteLayer("gear2", "Assembler.png" , 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

		if (gear !is null)
		{
			Animation@ anim = gear.addAnimation("default", 0, false);
			anim.AddFrame(3);
			gear.SetOffset(Vec2f(17.0f, -10.0f));
			gear.SetAnimation("default");
			gear.SetRelativeZ(-60);
		}
	}

	{
		this.RemoveSpriteLayer("gear3");
		CSpriteLayer@ gear = this.addSpriteLayer("gear3", "Assembler.png" , 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

		if (gear !is null)
		{
			Animation@ anim = gear.addAnimation("default", 0, false);
			anim.AddFrame(3);
			gear.SetOffset(Vec2f(6.0f, -4.0f));
			gear.SetAnimation("default");
			gear.SetRelativeZ(-60);
			gear.RotateBy(-22, Vec2f(0.0f,0.0f));
		}
	}
	
	AddSignLayerFrom(this);
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
	
	AssemblerItem[] items = getItems(blob);
	u8 item_idx = blob.get_u8("crafting");
	AssemblerItem@ item = null;
	if (item_idx==255) {
		disableSignAndIconSprites(this);
		return;
	}
	@item = items[item_idx];
	Vec2f icon_dims = Vec2f();
	
	CSpriteLayer@ icon = this.getSpriteLayer("icon");
	if (icon is null || icon.getFilename()!=getIconTokenFilename(item.icon_name)) {
		this.RemoveSpriteLayer("icon");
		
		GUI::GetIconDimensions(item.icon_name, icon_dims);
		@icon = this.addSpriteLayer("icon", getIconTokenFilename(item.icon_name), icon_dims.x, icon_dims.y, blob.getTeamNum(), 0);
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

void onTick(CSprite@ this)
{
	updateIconLayer(this);
	
	if (this.getBlob().get_u8("crafting")==255) {
		this.SetEmitSoundPaused(true);
		return;
	}
	this.SetEmitSoundPaused(false);
	
	if(this.getSpriteLayer("gear1") !is null){
		this.getSpriteLayer("gear1").RotateBy(5.0f*(this.getBlob().exists("gyromat_acceleration") ? this.getBlob().get_f32("gyromat_acceleration") : 1), Vec2f(0.0f,0.0f));
	}
	if(this.getSpriteLayer("gear2") !is null){
		this.getSpriteLayer("gear2").RotateBy(-5.0f*(this.getBlob().exists("gyromat_acceleration") ? this.getBlob().get_f32("gyromat_acceleration") : 1), Vec2f(0.0f,0.0f));
	}
	if(this.getSpriteLayer("gear3") !is null){
		this.getSpriteLayer("gear3").RotateBy(5.0f*(this.getBlob().exists("gyromat_acceleration") ? this.getBlob().get_f32("gyromat_acceleration") : 1), Vec2f(0.0f,0.0f));
	}
}

class AssemblerItem
{
	string resultname;
	u32 resultcount;
	string title;
	string icon_name;
	CBitStream reqs;

	AssemblerItem(string _resultname, u32 _resultcount, string _title, string _icon_name)
	{
		this.resultname = _resultname;
		this.resultcount = _resultcount;
		this.title = _title;
		this.icon_name = _icon_name;
	}
}

void onInit(CBlob@ this)
{
	AssemblerItem[] items;
	{
		AssemblerItem i("revo", 1, Names::revolver, "$REG$");
		AddRequirement(i.reqs, "blob", "mat_steel", "Steel Bar", 2);
		items.push_back(i);
	}
	{
		AssemblerItem i("spp", 1, Names::smg, "$SPP$");
		AddRequirement(i.reqs, "blob", "mat_steel", "Steel Bar", 10);
		items.push_back(i);
	}
	{
		AssemblerItem i("shaggy", 1, Names::shotgun, "$SHAG$");
		AddRequirement(i.reqs, "blob", "mat_steel", "Steel Bar", 20);
		items.push_back(i);
	}
	{
		AssemblerItem i("bifle", 1, Names::rifle, "$USAR$");
		AddRequirement(i.reqs, "blob", "mat_steel", "Steel Bar", 40);
		items.push_back(i);
	}
	{
		AssemblerItem i("mp", 1, Names::mp, "$MIZ$");
		AddRequirement(i.reqs, "blob", "mat_steel", "Steel Bar", 10);
		items.push_back(i);
	}
	{
		AssemblerItem i("kep", 1, "Submachine Gun \"KEP\n", "$KEP$");
		AddRequirement(i.reqs, "blob", "mat_steel", "Steel Bar", 30);
		items.push_back(i);
	}
	{
		AssemblerItem i("ass", 1, Names::fa_shotgun, "$PTZ$");
		AddRequirement(i.reqs, "blob", "mat_steel", "Steel Bar", 40);
		items.push_back(i);
	}
	{
		AssemblerItem i("arr", 1, Names::assaultrifle, "$TESR$");
		AddRequirement(i.reqs, "blob", "mat_steel", "Steel Bar", 60);
		items.push_back(i);
	}
	this.set("items", items);


	this.set_TileType("background tile", CMap::tile_castle_back);
	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = 60;

	this.Tag("builder always hit");

	this.addCommandID("menu");
	this.addCommandID("set");

	this.set_u8("crafting", 255);
	
	this.Tag("ignore extractor");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());

	CButton@ button = caller.CreateGenericButton(15, Vec2f(0,-8), this, this.getCommandID("menu"), "Set Item", params);
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("menu"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null)
		{
			if(caller.isMyPlayer())
			{
				CGridMenu@ menu = CreateGridMenu(getDriver().getScreenCenterPos() + Vec2f(0.0f, 0.0f), this, Vec2f(4, 3), "Set Assembly");
				if (menu !is null)
				{
					CBitStream reset_stream;
					reset_stream.write_u8(255);
					CGridButton@ noitem = menu.AddButton("NoItemIcon.png", 0, Vec2f(24, 24), "Reset Item", this.getCommandID("set"), Vec2f(4, 1), reset_stream);
					if (this.get_u8("crafting") == 255 && noitem !is null) {
						noitem.SetEnabled(false);
						noitem.hoverText = "Assembler produces nothing";
					}
					AssemblerItem[] items = getItems(this);
					for(uint i = 0; i < items.length; i += 1)
					{
						AssemblerItem item = items[i];

						CBitStream pack;
						pack.write_u8(i);
						//AddIconToken("$assembler_icon" + i + "$", "AssemblerIcons.png", Vec2f(16, 16), i);

						string text = "Set to Assemble: " + item.title;
						if(this.get_u8("crafting") == i)
						{
							text = "Already Assembling: " + item.title;
						}

						CGridButton @butt = menu.AddButton(item.icon_name, text, this.getCommandID("set"), pack);
						butt.hoverText = item.title + "\n" + getButtonRequirementsText(item.reqs, false);
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
		if (this.get_u8("crafting") == 255) {//was nothing
			//this.getSprite().PlaySound("PowerUp.ogg");
			//this.getSprite().PlaySound("LeverToggle.ogg", 2.0f, 1.2f);
			this.getSprite().PlaySound("ChargeLanceCycle.ogg", 2.0f, 1.5f);
		}
		u8 setting = params.read_u8();
		this.set_u8("crafting", setting);
		
		if (this.get_u8("crafting") == 255) {//set to nothing
			this.getSprite().PlaySound("PowerDown.ogg", 2.0f, 1.0f);
		}
	}
}



void onTick(CBlob@ this)
{
	if (this.get_u8("crafting") == 255) return;
	
	AssemblerItem item = getItems(this)[this.get_u8("crafting")];
	CInventory@ inv = this.getInventory();
	
	this.getCurrentScript().tickFrequency = 60 / (this.exists("gyromat_acceleration") ? this.get_f32("gyromat_acceleration") : 1);

	CBitStream missing;
	if (hasRequirements(inv, item.reqs, missing))
	{
		if (isServer())
		{
			CBlob @mat = server_CreateBlob(item.resultname, this.getTeamNum(), this.getPosition());
			mat.server_SetQuantity(item.resultcount);

			server_TakeRequirements(inv, item.reqs);
		}

		if(isClient())
		{
			this.getSprite().PlaySound("ProduceSound.ogg");
			this.getSprite().PlaySound("BombMake.ogg");
		}
	}
}



void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null || this.get_u8("crafting") == 255) return;
	bool isMat = false;

	AssemblerItem item = getItems(this)[this.get_u8("crafting")];
	CBitStream bs = item.reqs;
	bs.ResetBitIndex();
	string text, requiredType, name, friendlyName;
	u16 quantity = 0;

	while (!bs.isBufferEnd())
	{
		ReadRequirement(bs, requiredType, name, friendlyName, quantity);

		if(blob.getName() == name)
		{
			isMat = true;
			break;
		}
	}

	if (isMat && !blob.isAttached() && blob.hasTag("material"))
	{
		if (isServer()) this.server_PutInInventory(blob);
		if (isClient()) this.getSprite().PlaySound("bridge_open.ogg");
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return (this.getTeamNum() >= 100 ? true : (forBlob.getTeamNum() == this.getTeamNum())) && forBlob.isOverlapping(this);
}

AssemblerItem[] getItems(CBlob@ this)
{
	AssemblerItem[] items;
	this.get("items", items);
	return items;
}