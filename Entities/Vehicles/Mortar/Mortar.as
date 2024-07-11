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
		back_layer.SetOffset(Vec2f(0,2));
	}
	CSpriteLayer@ cap = this.getSprite().addSpriteLayer("cap", "Mortar.png", 48, 16, this.getTeamNum(), 0);
	if (cap !is null) {
		cap.SetFrame(2);
		cap.SetRelativeZ(1);
		cap.SetOffset(Vec2f(0,2));
	}
}

void onChangeTeam( CBlob@ this, const int oldTeam )
{
	CSprite@ sprite = this.getSprite();
	
	CSpriteLayer@ back_layer = sprite.getSpriteLayer("back_layer");
	if (back_layer is null) return;
	CSpriteLayer@ cap = sprite.getSpriteLayer("cap");
	if (cap is null) return;
	
	back_layer.SetFrame(1);
	cap.SetFrame(2);
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
			cap.SetOffset(Vec2f(0,2));
		return;
	}
	else
	{
		if (cap !is null)
			cap.SetOffset(Vec2f(20, 1));
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

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	CBlob@ host = getBlobByNetworkID(this.get_u16("carriage_id"));
	if (host is null) return damage;
	
	f32 dmg_mod = 0.2f;
	
	if ((getGameTime()-host.get_u32("last_hit"))>0)
	{
		hitterBlob.server_Hit(host, worldPoint, velocity, damage*dmg_mod, customData);
	}
	else
	{
		//print("didn't hit host");
	}
	
	return 0;
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	if (!attached.hasTag("player")) return;
	if (attached.getCarriedBlob() !is null && attached.getCarriedBlob().getName()=="mortarcarriage")
	{
		attached.getCarriedBlob().server_DetachFrom(attached);
		return;
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
		
		item.setPosition(this.getPosition()+dir+(Vec2f(0, 0)).RotateBy(this.getAngleDegrees()));
		item.AddScript("MortarLaunched.as");
		
		if (!item.hasTag("player"))
		{
			item.setVelocity(dir);
		}
		else
		{
			CBitStream n_params;
			n_params.write_Vec2f(dir*0.75f*item.getMass());
			
			if (isServer() && item.hasCommandID("add force"))
			{
				item.SendCommand(item.getCommandID("add force"), n_params);
			}
		}
		{
			CBitStream n_params;
			n_params.write_u16(item.getNetworkID());
			this.SendCommand(this.getCommandID("launch_item_client"), n_params);
		}
	}
	if(cmd == this.getCommandID("launch_item_client"))
	{
		u16 launched_id; if (!params.saferead_u16(launched_id)) return;
		CBlob@ launched = getBlobByNetworkID(launched_id);
		if (launched is null) return;
		launched.AddScript("MortarLaunched.as");
		
		PlayDistancedSound("Howitzer_Shoot.ogg", 1.0f, 1.35f, this.getPosition(), 0.01f, 0, 0, 0);
		
		const bool FLIP = this.isFacingLeft();
		const f32 FLIP_FACTOR = FLIP ? -1 : 1;
		
        CShape@ shape = this.getShape();
        Vec2f shape_vel = shape.getVelocity();
		f32 angle = this.getAngleDegrees();
		Vec2f dir = Vec2f(25*FLIP_FACTOR, 0).RotateBy(angle);
		Vec2f pos = this.getPosition()+dir;
		Vec2f vel = dir;

		for (int i = 0; i < 16; i++)
		{
			ParticleAnimated("LargeSmokeGray", pos, shape_vel + getRandomVelocity(0.0f, XORRandom(45) * 0.005f, 360) + vel/(10+XORRandom(24)), float(XORRandom(360)), 0.5f + XORRandom(40) * 0.01f, 2 + XORRandom(2), -0.0031f, true);
		}

		bool apc = false;

		for (int i = 0; i < 4; i++)
		{
			if (!apc)
			{
				float angle = Maths::ATan2(vel.y, vel.x) + 20;
				ParticleAnimated("LargeSmoke", pos, shape_vel + Vec2f(Maths::Cos(angle), Maths::Sin(angle))/2, float(XORRandom(360)), 0.4f + XORRandom(40) * 0.01f, 4 + XORRandom(3), -0.0031f, true);
				float angle2 = Maths::ATan2(vel.y, vel.x) - 20;
				ParticleAnimated("LargeSmoke", pos, shape_vel + Vec2f(Maths::Cos(angle2), Maths::Sin(angle2))/2, float(XORRandom(360)), 0.4f + XORRandom(40) * 0.01f, 4 + XORRandom(3), -0.0031f, true);
			}

			ParticleAnimated("LargeSmokeGray", pos, shape_vel + getRandomVelocity(0.0f, XORRandom(45) * 0.005f, 360) + vel/(40+XORRandom(24)), float(XORRandom(360)), 0.5f + XORRandom(40) * 0.01f, 6 + XORRandom(3), -0.0031f, true);
			ParticleAnimated("Explosion", pos, shape_vel + getRandomVelocity(0.0f, XORRandom(45) * 0.005f, 360) + vel/(40+XORRandom(24)), float(XORRandom(360)), 0.5f + XORRandom(40) * 0.01f, 2, -0.0031f, true);
		}
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