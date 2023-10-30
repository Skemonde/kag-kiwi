#include "MakeCrate"

const u32 ORDER_INTERVAL = getTicksASecond()*120;

void onInit(CBlob@ this)
{
	this.addCommandID("say_something");
	this.addCommandID("change_channel");
	
	this.set_u8("current_voiceline", 0);
	this.set_u32("next_order", 0);
	//channel ID
	this.set_u8("channel", 3);
}

void onTick(CBlob@ this)
{
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

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @ap)
{
	this.getSprite().PlaySound("wt_gal_jawoll.ogg");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	return;
	CBlob@ carried = caller.getCarriedBlob();
	u32 order_time = this.get_u32("next_order");
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
		Sound::Play("click");
		this.set_u8("channel", target_channel);
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
	const f32 SCALEX = getDriver().getResolutionScaleFactor();
	const f32 ZOOM = getCamera().targetDistance * SCALEX;
	
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	AttachmentPoint@ pickup = blob.getAttachments().getAttachmentPointByName("PICKUP");
	if (pickup is null) return;
    CBlob@ holder = pickup.getOccupied();
	if (holder is null) return;
	if (!holder.isMyPlayer()) return;
	
	Vec2f screen_pos = blob.getInterpolatedScreenPos();
	Vec2f text_dims;
	string text = "LMB < Channel "+blob.get_u8("channel")+" > RMB";
	GUI::GetTextDimensions(text, text_dims);
	GUI::DrawText(text, screen_pos-Vec2f(text_dims.x/2, 32*ZOOM), color_white);
}