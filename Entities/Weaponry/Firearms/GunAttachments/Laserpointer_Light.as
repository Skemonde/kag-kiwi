#include "FirearmVars"

void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightRadius(16.0f);
	this.SetLightColor(SColor(255, 255, 50, 120));
	this.getSprite().SetZ(1500.3f);
	this.getSprite().setRenderStyle(RenderStyle::additive);
	this.sendonlyvisible = false;
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;
	this.getSprite().getConsts().accurateLighting = false;
	
	this.getShape().SetStatic(true);
	this.sendonlyvisible = false;
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
		this.setPosition(Vec2f(0, -400));
	}
}