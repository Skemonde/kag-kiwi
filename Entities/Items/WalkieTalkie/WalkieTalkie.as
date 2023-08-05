#include "MakeCrate"

const u32 ORDER_INTERVAL = getTicksASecond()*120;

void onInit(CBlob@ this)
{
	this.addCommandID("say_something");
	this.set_u8("current_voiceline", 0);
	this.set_u32("next_order", 0);
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @ap)
{
	this.getSprite().PlaySound("wt_gal_jawoll.ogg");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBlob@ carried = caller.getCarriedBlob();
	u32 order_time = this.get_u32("next_order");
	if (carried !is null && carried.getNetworkID() == this.getNetworkID() && order_time < getGameTime())
	{
		caller.CreateGenericButton("$wt$", Vec2f(2.5, -2), this, this.getCommandID("say_something"), "Order the team to do something!");
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
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
			
		server_MakeCrateOnParachute("tankhull", "A Cool Tank", 0, this.getTeamNum(), Vec2f(this.getPosition().x,0));
		this.server_Die();
		this.set_u32("next_order", getGameTime()+ORDER_INTERVAL);
	}
}

void onRender(CSprite@ this)
{
	if (isClient()) {
		CBlob@ blob = this.getBlob();
		AttachmentPoint@ point = blob.getAttachments().getAttachmentPointByName("PICKUP");	   		
		CBlob@ holder = point.getOccupied();
		if (holder is null) return;
		CPlayer@ player = holder.getPlayer();
		if (player is null || (player !is null && !player.isMyPlayer())) return;
		
		u32 order_time = blob.get_u32("next_order");
		u32 ticks_left = Maths::Max(0, order_time - getGameTime());
		if (ticks_left < 1 || ticks_left > ORDER_INTERVAL) return;
		//print("hello");
		const f32 scalex = getDriver().getResolutionScaleFactor();
		const f32 zoom = getCamera().targetDistance * scalex;
		Vec2f pos2d =  holder.getInterpolatedScreenPos() + Vec2f(0.0f, (-blob.getHeight() - 20.0f) * zoom);
		Vec2f pos = pos2d + Vec2f(-30.0f, -40.0f);
		Vec2f dimension = Vec2f(60.0f - 8.0f, 8.0f);
			
		GUI::DrawIconByName("$progress_bar$", pos);
		
		f32 percentage = 1.0f* ticks_left / ORDER_INTERVAL;
		Vec2f bar = Vec2f(pos.x + (dimension.x * percentage), pos.y + dimension.y);
		
		GUI::DrawRectangle(pos + Vec2f(4, 4), bar + Vec2f(4, 4), SColor(255, 59, 20, 6));
		GUI::DrawRectangle(pos + Vec2f(6, 6), bar + Vec2f(2, 4), SColor(255, 148, 27, 27));
		GUI::DrawRectangle(pos + Vec2f(6, 6), bar + Vec2f(2, 2), SColor(255, 183, 51, 51));
	}
}