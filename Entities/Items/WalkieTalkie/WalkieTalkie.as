#include "MakeCrate"
#include "Requirements"
#include "ShopCommon"
#include "getShopMenuHeight"
#include "KIWI_Locales"
#include "SoldatInfo"

const u32 ORDER_INTERVAL = getTicksASecond()*30;

void onInit(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	
	this.addCommandID("say_something");
	this.addCommandID("change_channel");
	
	this.set_u8("current_voiceline", 0);
	this.set_u32("next_order", 0);
	//channel ID
	this.set_u8("channel", 3);
	
	sprite.SetEmitSound("skem_message.ogg");
	sprite.SetEmitSoundVolume(0.1f);
	sprite.SetEmitSoundSpeed(4.2f);
	sprite.SetEmitSoundPaused(true);
	
	InitWorkshop(this);
	this.Tag(SHOP_AUTOCLOSE);
}

void InitWorkshop(CBlob@ this)
{
	int teamnum = Maths::Min(this.getTeamNum(), 7);
	{
		ShopItem@ s = addShopItem(this, "Car", "$car_icon"+teamnum+"$", "kiy", "GO FAST!!", true);
		AddRequirement(s.requirements, "dogtag", "", "", 1200);
		//AddRequirement(s.requirements, "no more", "kiy", "Car", 4);
		s.customButton = true;
		s.spawnNothing = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "APC", "$apc_icon"+teamnum+"$", "brsn", "GO UHHH?!!", true);
		AddRequirement(s.requirements, "dogtag", "", "", 3600);
		//AddRequirement(s.requirements, "no more", "brsn", "APC", 4);
		s.customButton = true;
		s.spawnNothing = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Tank", "$tank_icon"+teamnum+"$", "tankhull", "GO STRONG!!", true);
		AddRequirement(s.requirements, "dogtag", "", "", 6000);
		//AddRequirement(s.requirements, "no more", "tankhull", "Tank", 2);
		s.customButton = true;
		s.spawnNothing = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, Names::atr, "$atr$", "atr", Descriptions::atr, true);
		AddRequirement(s.requirements, "dogtag", "", "", 3000);
		s.customButton = true;
		s.spawnNothing = true;
		s.buttonwidth = 3;
		s.buttonheight = 1;
	}
	this.set_Vec2f("shop menu size", getShopMenuHeight(this, 3));
}

void CheckForChannelSwitch(CBlob@ this)
{
	return;
	AttachmentPoint@ pickup = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (pickup is null) return;
    CBlob@ holder = pickup.getOccupied();
	if (holder is null) return;
	
	//all this code happens only on the local machine
	if (!holder.isMyPlayer()) return;
	
	CControls@ controls = getControls();
	const u8 CH_MAX = getRules().get_u8("wt_channel_max");
	const u8 CH_MIN = getRules().get_u8("wt_channel_min");
	const u8 CURRENT_CH = this.get_u8("channel");
	
	if (controls.isKeyJustPressed(KEY_RBUTTON)&&CURRENT_CH<CH_MAX) {
		CBitStream params;
		params.write_u8(1+CURRENT_CH);
		this.SendCommand(this.getCommandID("change_channel"), params);
	}
	if (controls.isKeyJustPressed(KEY_LBUTTON)&&CURRENT_CH>CH_MIN) {
		CBitStream params;
		params.write_u8(-1+CURRENT_CH);
		this.SendCommand(this.getCommandID("change_channel"), params);
	}
}

void onTick(CBlob@ this)
{
	CheckForChannelSwitch(this);
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @ap)
{
	this.getSprite().PlaySound("wt_gal_jawoll.ogg");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	//default shop vars
	this.set_u8("shop button radius", 32);
	this.set_Vec2f("shop offset", Vec2f(5,0));
	this.set_string("shop description", "Call to generals for better gear");
	
	CPlayer@ player = caller.getPlayer();
	if (player is null) return;
	SoldatInfo[]@ infos = getSoldatInfosFromRules();
	if (infos is null) return;
	SoldatInfo our_info = getSoldatInfoFromUsername(player.getUsername());
	if (our_info is null) return;
	int info_idx = getInfoArrayIdx(our_info);
	
	u8 rank = infos[info_idx].rank;
	
	CBlob@ carried = caller.getCarriedBlob();
	u32 order_time = this.get_u32("next_order");
	//this.set_bool("shop available", order_time < getGameTime() && rank > 4);
	
	bool got_commtower_nearby = false;
	CBlob@[] blobs_nearby;
	if (getMap().getBlobsInRadius(this.getPosition(), 16, @blobs_nearby))
	{
		for (int idx = 0; idx < blobs_nearby.size(); ++idx)
		{
			CBlob@ cur_blob = blobs_nearby[idx];
			if (cur_blob is null) continue;
			if (cur_blob.getName()=="commtower")  {
				got_commtower_nearby = true;
				break;
			}
		}
	}
	
	if (order_time > getGameTime() || rank < 5 || !got_commtower_nearby)
	{
		this.set_u8("shop button radius", 0);
		if (rank < 5)
			this.set_string("shop description", "We ONLY talk to your platoon leader");
		else if (!got_commtower_nearby)
			this.set_string("shop description", "You need a Comm-Tower nearby to make a call");
		else if (order_time > getGameTime())
			this.set_string("shop description", "PLEASE wait until we finish our previous delivery ("+Maths::Max(1, Maths::Round((order_time-getGameTime())/getTicksASecond()))+"s)");
	}	
	
	return;
	if (carried !is null && carried.getNetworkID() == this.getNetworkID() && order_time < getGameTime())
	{
		caller.CreateGenericButton("$wt$", Vec2f(2.5, -2), this, this.getCommandID("say_something"), "Order the team to do something!");
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("change_channel"))
	{
		u8 target_channel; if(!params.saferead_u8(target_channel)) return;
		Sound::Play("click", this.getPosition(), 1, 1);
		this.set_u8("channel", target_channel);
	}
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("skem_message.ogg", 0.4f, 4.2f);
		u16 caller, item;
		if (!params.saferead_netid(caller) || !params.saferead_netid(item))
		{
			return;
		}
		string name = params.read_string();
		
		CBlob@ crate = server_MakeCrateOnParachute(name, "Goods", 0, this.getTeamNum(), Vec2f(this.getPosition().x,0));
		if (crate !is null) {
			crate.getSprite().SetAnimation("teamlabel");
			//crate.Tag("unpack upon impact");
			crate.Tag("unpack on land");
			this.set_u32("next_order", getGameTime()+ORDER_INTERVAL);
		}
	}
	if (cmd == this.getCommandID("say_something"))
	{
		u32 order_time = this.get_u32("next_order");
		if (order_time > getGameTime()) return;
		
		u8 person = XORRandom(2);
		u8 voiceline;
		string speaker_name;
		switch (person)
		{
			case 1:
			case 0:
				//voiceline = XORRandom(6);
				voiceline = this.get_u8("current_voiceline");
				speaker_name = "gal";
				break;
			//default:
			//	voiceline = XORRandom(3);
			//	speaker_name = "lad";
		}
		this.getSprite().PlaySound("walkie_talkie_" + speaker_name + "_" + voiceline + ".ogg");
		this.add_u8("current_voiceline", 1);
		if (this.get_u8("current_voiceline") > 5)
			this.set_u8("current_voiceline", 0);
			
		CBlob@ crate = server_MakeCrateOnParachute("tankhull", "A Cool Tank", 0, this.getTeamNum(), Vec2f(this.getPosition().x,0));
		if (crate !is null) {
			crate.getSprite().SetAnimation("teamlabel");
			crate.Tag("unpack upon impact");
		}
		this.server_Die();
		this.set_u32("next_order", getGameTime()+ORDER_INTERVAL);
	}
}

void onRender(CSprite@ this)
{
	return;
	const f32 SCALEX = getDriver().getResolutionScaleFactor();
	const f32 ZOOM = getCamera().targetDistance * SCALEX;
	
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	
	const u8 CH_MAX = getRules().get_u8("wt_channel_max");
	const u8 CH_MIN = getRules().get_u8("wt_channel_min");
	const u8 CURRENT_CH = blob.get_u8("channel");
	
	AttachmentPoint@ pickup = blob.getAttachments().getAttachmentPointByName("PICKUP");
	if (pickup is null) return;
    CBlob@ holder = pickup.getOccupied();
	if (holder is null) return;
	if (!holder.isMyPlayer()) return;
	
	Vec2f screen_pos = holder.getInterpolatedScreenPos();
	Vec2f text_dims;
	
	const bool MAX_CH = CURRENT_CH == CH_MAX;
	const bool MIN_CH = CURRENT_CH == CH_MIN;
	
	string help = "\n\nto send a msg hold a WT and chat\nor start chat message with r:\n(must have one in your inv for that)\n\nyou can only receive such message\nif you have a WT with the same channel set\nin your inventory or hands";
	string text = (MIN_CH?"____  ":"LMB ")+"< Channel "+formatInt(CURRENT_CH, "0", 2)+" >"+(MAX_CH?" ____":" RMB")+(u_showtutorial?help:"\nF1 for help");
	GUI::GetTextDimensions(text, text_dims);
	GUI::DrawText(text, screen_pos-Vec2f(text_dims.x/2, -24*ZOOM), color_white);
}