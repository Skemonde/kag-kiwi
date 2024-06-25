#include "WhatShouldProjHit"

void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	shape.getConsts().mapCollisions = false;
	this.getShape().SetRotationsAllowed(true);
	this.SetMapEdgeFlags(u8(CBlob::map_collide_none | CBlob::map_collide_left | CBlob::map_collide_right | CBlob::map_collide_nodeath));
}

void onTick(CBlob@ this)
{
	HitInfo@[] hitInfos;
	
	f32 our_angle = -this.getVelocity().getAngle();
	Vec2f dir = Vec2f(1, 0).RotateBy(our_angle);
	
	CMap@ map = getMap();
	if (map.getHitInfosFromRay(this.getPosition()-dir*10, our_angle, Maths::Max(this.getWidth()+24, this.getVelocity().Length()), this, @hitInfos)) {}
	
	for (int counter = 0; counter < hitInfos.length; ++counter)
	{
		CBlob@ doomed = hitInfos[counter].blob;
		if (doomed !is null) {
			if (!doomed.hasTag("scenary")&&shouldRaycastHit(doomed, our_angle, this.isFacingLeft(), this.getTeamNum(), this.get_u8("custom_hitter"), hitInfos[counter].hitpos))
			{
				this.set_Vec2f("custom_explosion_pos", hitInfos[counter].hitpos-dir*10);
				this.server_Die();
			}
		}
		else
		{
			this.set_Vec2f("custom_explosion_pos", this.getPosition());
			this.server_Die();
		}
	}
}