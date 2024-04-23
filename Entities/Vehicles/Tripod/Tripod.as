

void onInit(CBlob@ this)
{
	this.addCommandID("automat_give");
	
	if (getNet().isServer())
	{
		CBlob@ blob = server_CreateBlob("hmg");
		if (blob !is null)
		{
			blob.server_setTeamNum(this.getTeamNum());
			//blob.setInventoryName(this.getInventoryName() + "'s Turret");
			//blob.getShape().getConsts().collideWhenAttached = true;
			blob.getSprite().SetRelativeZ(40);
			this.server_AttachTo(blob, "GUNPOINT");
			this.set_u16("mg_id", blob.getNetworkID());
			blob.set_u16("tripod_id", this.getNetworkID());
		}
	}
	AttachmentPoint@ gunner = this.getAttachments().getAttachmentPointByName("MACHINEGUNNER");
	if (gunner !is null)
	{
		gunner.SetKeysToTake(key_left | key_right | key_up | key_down);
		// pilot.SetMouseTaken(true);
	}
}

void onTick(CBlob@ this)
{
	CBlob@ gunner = getBlobByNetworkID(this.get_u16("gunner_id"));
	if (gunner is null || !gunner.isAttachedTo(this)) return;
	bool facing = (gunner.getAimPos().x <= gunner.getPosition().x);
	if (!(Maths::Abs(gunner.getAimPos().x-gunner.getPosition().x)>Maths::Abs(gunner.getAimPos().y-gunner.getPosition().y)*0.5f)) return;
	this.SetFacingLeft(facing);
}

void onTick(CSprite@ this)
{
	return;
	this.SetZ(-30.0f);
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	if (attachedPoint.name=="GUNPOINT") {
		attachedPoint.offsetZ=0.3f;
	}
	if (!attached.hasTag("player")) return;
	this.set_u16("gunner_id", attached.getNetworkID());
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return true;
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller is null) return;
	if (caller.getTeamNum() != this.getTeamNum()) return;
	
	// if (caller.getTeamNum() == this.getTeamNum() && caller.isOverlapping(this))
	if ((caller.getPosition() - this.getPosition()).Length() < 24.0f)
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		CButton@ button = caller.CreateGenericButton(11, Vec2f(0, 0), this,  this.getCommandID("automat_give"), "Attach Item", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("automat_give"))
	{
		if (isServer())
		{
			CBlob@ caller = getBlobByNetworkID(params.read_u16());
			
			if (caller !is null)
			{
				CBlob@ carried = caller.getCarriedBlob();
	
				if (carried !is null && this !is null && carried.getName() == "automat") return;
	
				if ((true||!this.hasAttached())&&carried !is null)
				{
					//this.server_Pickup(carried);
					carried.server_DetachFromAll();
					this.server_AttachTo(carried, "GUNPOINT");
					this.set_u16("mg_id", carried.getNetworkID());
					carried.set_u16("tripod_id", this.getNetworkID());
				}
				else
				{
					//this.DropCarried();
					CBlob@ attached = getBlobByNetworkID(this.get_u16("mg_id"));
					if (attached is null) return;
					attached.server_DetachFrom(this);
				}
			}
		}
	}
}
