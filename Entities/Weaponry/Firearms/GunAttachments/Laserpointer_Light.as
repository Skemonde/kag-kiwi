#include "FirearmVars"

void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightRadius(16.0f);
	this.SetLightColor(SColor(255, 255, 50, 120));
	this.getSprite().SetZ(1500.3f);
	this.getSprite().setRenderStyle(RenderStyle::additive);
	this.getSprite().getConsts().accurateLighting = false;
	
	this.getShape().SetStatic(true);
}

void onTick(CBlob@ this)
{
	//if (!isServer()) return;
	CBlob@ gun = getBlobByNetworkID(this.get_u16("owner_netid"));
	if (gun is null) {
		this.server_Die();
		return;
	}
		
	if (!gun.isAttached()||gun.isInInventory()) {
		this.setPosition(Vec2f());
	}
	
	FirearmVars@ vars;
	if (!gun.get("firearm_vars", @vars))return;
	int AltFire = gun.get_u8("override_alt_fire");
	if(AltFire == AltFire::Unequip) //in case override value is 0 we use altfire type from vars
		AltFire = vars.ALT_FIRE;
	
	if (AltFire != AltFire::LaserPointer)
		this.server_Die();
}