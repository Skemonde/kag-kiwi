#include "Skemlib"

void onInit(CBlob@ this)
{
	//this.set_f32("hand angle offset", 90);
	this.Tag("heavy weight");
	this.Tag("bullet_hits");
	this.Tag("turret");
	
	this.addCommandID("launch_item");
	this.addCommandID("place_item");
	this.addCommandID("launch_item_client");
	
	AttachmentPoint@ item_point = this.getAttachments().getAttachmentPointByName("ITEM");
	if (item_point is null) return;
	
	item_point.offsetZ = -10;
	
	CSpriteLayer@ back_layer = this.getSprite().addSpriteLayer("back_layer", "Mortar.png", 48, 16, this.getTeamNum(), 0);
	if (back_layer !is null) {
		back_layer.SetFrame(1);
		back_layer.SetRelativeZ(-40);
		back_layer.SetOffset(Vec2f(0,4));
	}
	CSpriteLayer@ cap = this.getSprite().addSpriteLayer("cap", "Mortar.png", 48, 16, this.getTeamNum(), 0);
	if (cap !is null) {
		cap.SetFrame(2);
		cap.SetRelativeZ(1);
		cap.SetOffset(Vec2f(0,4));
	}
}

void onTick(CBlob@ this)
{
	const bool FLIP = this.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	AttachmentPoint@ item_point = this.getAttachments().getAttachmentPointByName("ITEM");
	if (item_point is null) return;
	
	CSpriteLayer@ cap = this.getSprite().getSpriteLayer("cap");
	
	CBlob@ item = item_point.getOccupied();
	if (item is null)
	{
		if (cap !is null)
			cap.SetOffset(Vec2f(0,4));
		return;
	}
	else
	{
		if (cap !is null)
			cap.SetOffset(Vec2f(20, 3));
	}
	
	item.SetFacingLeft(this.isFacingLeft());
	item.setAngleDegrees(this.getAngleDegrees()+(item.hasTag("bomb")?-90*FLIP_FACTOR:0));
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if (caller is null) return;
	if (caller.getTeamNum() != this.getTeamNum()) return;
	
	//if ((caller.getPosition() - this.getPosition()).Length() < 24.0f)
	{
		AttachmentPoint@ item_point = this.getAttachments().getAttachmentPointByName("ITEM");
		if (item_point is null) return;
		
		CBlob@ item = item_point.getOccupied();
		
		if (item !is null)
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			CButton@ button = caller.CreateGenericButton("$"+item.getName()+"$", Vec2f(0, 0), this,  this.getCommandID("launch_item"), "Launch "+item.getName()+"!!!", params);
		}
		else
		{
			CBlob@ carried = caller.getCarriedBlob();
			if (carried is null)
			{
				//@carried = caller;
			}
			if (carried is null || carried !is null && carried.getName()=="mortarcarriage") return;
			
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			params.write_u16(carried.getNetworkID());
			CButton@ button = caller.CreateGenericButton("$"+carried.getName()+"$", Vec2f(0, 0), this,  this.getCommandID("place_item"), "Place "+carried.getName()+" to be launched", params);
		}
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if(cmd == this.getCommandID("launch_item"))
	{
		u16 caller_id; if (!params.saferead_u16(caller_id)) return;
		
		AttachmentPoint@ item_point = this.getAttachments().getAttachmentPointByName("ITEM");
		if (item_point is null) return;
		
		CBlob@ item = item_point.getOccupied();
		if (item is null) return;
		
		const bool FLIP = this.isFacingLeft();
		const f32 FLIP_FACTOR = FLIP ? -1 : 1;
		const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
		
		item.server_DetachFrom(this);
		Vec2f dir = Vec2f(25*FLIP_FACTOR, 0).RotateBy(this.getAngleDegrees());
		AttachmentPoint@ mortar_point = this.getAttachments().getAttachmentPointByName("MORTAR");
		if (mortar_point is null) return;
		
		item.setPosition(this.getPosition()+dir+(Vec2f(0, 2)).RotateBy(this.getAngleDegrees()));
		if (!item.hasTag("player"))
		{
			item.setVelocity(dir);
		}
		else
		{
			CBitStream params;
			params.write_Vec2f(dir*0.75f*item.getMass());
			
			if (isServer() && item.hasCommandID("add force"))
			{
				item.SendCommand(item.getCommandID("add force"), params);
			}
		}
		this.SendCommand(this.getCommandID("launch_item_client"), params);
	}
	if(cmd == this.getCommandID("launch_item_client"))
	{
		PlayDistancedSound("GrenadeExplosion.ogg", 1.0f, 1.35f, this.getPosition(), 0.01f, 0, 0, 0);
	}
	if(cmd == this.getCommandID("place_item"))
	{
		u16 caller_id; if (!params.saferead_u16(caller_id)) return;
		u16 carried_id; if (!params.saferead_u16(carried_id)) return;
		CBlob@ caller = getBlobByNetworkID(caller_id);
		if (caller is null) return;
		CBlob@ carried = getBlobByNetworkID(carried_id);
		if (carried is null) return;
		
		carried.server_DetachFrom(caller);
		this.server_AttachTo(carried, "ITEM");
	}
}