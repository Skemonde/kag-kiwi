#include "FirearmVars"

void onInit(CBlob@ this)
{
	this.addCommandID("automat_give");
	this.addCommandID("add_ammo");
	
	this.Tag("heavy weight");
	this.Tag("no team lock");
	this.Tag("bullet_hits");
	this.Tag("vehicle");
	
	if (getNet().isServer())
	{
		CBlob@ blob = server_CreateBlob("highmg");
		if (blob !is null)
		{
			blob.server_setTeamNum(this.getTeamNum());
			//blob.setInventoryName(this.getInventoryName() + "'s Turret");
			//blob.getShape().getConsts().collideWhenAttached = true;
			blob.getSprite().SetRelativeZ(40);
			this.server_AttachTo(blob, "GUNPOINT");
			this.set_u16("cannon_id", blob.getNetworkID());
			blob.set_u16("turret_id", this.getNetworkID());
			blob.set_u16("storage_id", this.getNetworkID());
		}
		AddSomeAmmo(this);
	}
	AttachmentPoint@ gunner = this.getAttachments().getAttachmentPointByName("GUNPOINT_GUNNER");
	if (gunner !is null)
	{
		gunner.SetKeysToTake(key_left | key_right | key_up | key_down | key_inventory);
		// pilot.SetMouseTaken(true);
	}
}

string getAmmoName(CBlob@ this)
{
	string ammo_name = "mat_stone";
	CBlob@ cannon = getBlobByNetworkID(this.get_u16("cannon_id"));
	if (cannon is null) return ammo_name;
	
	FirearmVars@ vars;
	if (!cannon.get("firearm_vars", @vars)) return ammo_name;
	if (vars.AMMO_TYPE.size()<1) return ammo_name;
	
	ammo_name = vars.AMMO_TYPE[0];
	
	return ammo_name;
}

void setShapeOffsetOnce(CBlob@ this)
{
	if (this.getTickSinceCreated()>1) return;
	
	const bool FLIP = this.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	this.getShape().SetOffset(Vec2f(4*FLIP_FACTOR, 0));
}

void onTick(CBlob@ this)
{
	setShapeOffsetOnce(this);
	
	AttachmentPoint@ gunner_ap = this.getAttachments().getAttachmentPointByName("GUNPOINT_GUNNER");
	CBlob@ gunner = gunner_ap.getOccupied();
	if (gunner is null)
	{
		AttachmentPoint@ gun_ap = this.getAttachments().getAttachmentPointByName("GUNPOINT");
		CBlob@ gun = gun_ap.getOccupied();
		if (gun !is null)
			gun.SetFacingLeft(this.isFacingLeft());
		return;
	}
	bool facing = (gunner.getAimPos().x <= gunner.getPosition().x);
	if (!(Maths::Abs(gunner.getAimPos().x-gunner.getPosition().x)>Maths::Abs(gunner.getAimPos().y-gunner.getPosition().y)*0.5f)) return;
	this.SetFacingLeft(facing);
	gunner.SetFacingLeft(facing);
}

void AddSomeAmmo(CBlob@ this)
{
	if (!isServer()) return;
	for (int idx = 0; idx < 2; ++idx)
	{
		CBlob@ blob = server_CreateBlob(getAmmoName(this), this.getTeamNum(), this.getPosition());
		this.server_PutInInventory(blob);
	}
}

void onTick(CSprite@ this)
{
	return;
	this.SetZ(-30.0f);
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	if (attachedPoint.name=="GUNPOINT") {
		attachedPoint.offsetZ=2.3f;
	}
	if (attached.hasTag("player"))
		this.Tag("occupied");
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint @attachedPoint )
{
	if (attachedPoint.name=="GUNPOINT") {
		detached.set_u16("turret_id", 0);
	}
	if (detached.hasTag("player"))
		this.Untag("occupied");
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return !this.hasTag("occupied")&&byBlob.isOverlapping(this);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller is null) return;
	if (caller.getTeamNum() != this.getTeamNum()) return;
	CBlob@ carried = caller.getCarriedBlob();
	
	// if (caller.getTeamNum() == this.getTeamNum() && caller.isOverlapping(this))
	if (carried !is null && carried.hasTag("firearm") && (caller.getPosition() - this.getPosition()).Length() < 24.0f && false)
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		CButton@ button = caller.CreateGenericButton(11, Vec2f(0, 0), this,  this.getCommandID("automat_give"), "Attach Item", params);
	}
	
	if (caller.getInventory() is null) return;
	
	string ammo_name = getAmmoName(this);
	bool has_ammo = caller.getBlobCount(ammo_name)>0;
	bool can_use = !caller.isAttached()&&has_ammo;
	
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	CButton@ button = caller.CreateGenericButton("$"+ammo_name+"$", Vec2f(0, -10), this, this.getCommandID("add_ammo"), "Add ammo", params);
	if (button !is null) {
		button.SetEnabled(can_use);
	}
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return false;
}

void onDie(CBlob@ this)
{
	CBlob@ cannon = getBlobByNetworkID(this.get_u16("cannon_id"));
	if (cannon !is null)
		cannon.server_Die();
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("add_ammo")) 
	{
		u16 caller_id; if (!params.saferead_u16(caller_id)) return;
		
		CBlob@ caller = getBlobByNetworkID(caller_id);
		if (caller is null) return;
		CInventory@ inv = caller.getInventory();
		if (inv is null) return;
		
		string ammo_name = getAmmoName(this);
		
		CBlob@ carried = caller.getCarriedBlob();
		if (carried !is null && carried.getName()==ammo_name)
		{
			if (!this.server_PutInInventory(carried))
				caller.server_PutInInventory(carried);
		}
		for (int idx = 0; idx < inv.getItemsCount()+2; ++idx)
		{
			CBlob@ item = inv.getItem(ammo_name);
			if (item is null) continue;
			
			if (!this.server_PutInInventory(item))
			{
				// once we're not able to fit more we end cycle
				caller.server_PutInInventory(item);
				break;
			}
		}
	}
	if (cmd == this.getCommandID("automat_give"))
	{
		if (isServer())
		{
			CBlob@ caller = getBlobByNetworkID(params.read_u16());
			
			if (caller !is null)
			{
				CBlob@ carried = caller.getCarriedBlob();
	
				if (carried !is null && this !is null && carried.getName() == "tripod") return;
	
				if ((true||!this.hasAttached())&&carried !is null)
				{
					//this.server_Pickup(carried);
					carried.server_DetachFromAll();
					this.server_AttachTo(carried, "GUNPOINT");
					this.set_u16("cannon_id", carried.getNetworkID());
					carried.set_u16("turret_id", this.getNetworkID());
					carried.set_u16("storage_id", this.getNetworkID());
				}
				else
				{
					//this.DropCarried();
					CBlob@ attached = getBlobByNetworkID(this.get_u16("cannon_id"));
					if (attached is null) return;
					attached.server_DetachFrom(this);
				}
			}
		}
	}
}
