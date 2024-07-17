#include "FirearmVars"
#include "WhatShouldProjHit"

void onInit(CBlob@ this)
{
	this.set_u8("alt_fire_item", AltFire::LaserPointer);
    this.addCommandID("create_laser_light");
    this.addCommandID("set_laser_pos");
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	
	AttachmentPoint@ point = blob.getAttachments().getAttachmentPointByName("PICKUP");
	CBlob@ holder = point.getOccupied();
	
	if (blob.exists("gun_id")) {
		CBlob@ main_gun = getBlobByNetworkID(blob.get_u16("gun_id"));
		if (main_gun !is null)// && main_gun.isAttachedTo(this))
		{
			AttachmentPoint@ main_gun_pickup_ap = main_gun.getAttachments().getAttachmentPointByName("PICKUP");
			CBlob@ occupied = main_gun_pickup_ap.getOccupied();
			if (occupied !is null)
			{
				//print("hey "+this.getName());
				if (occupied.isAttachedTo(blob))
					@holder = occupied;
			}
		}
	}
	
	const Vec2f SPRITE_OFFSET = this.getOffset();
	const bool FLIP = blob.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	Vec2f laser_offset = Vec2f(0, -0.5f);
	Vec2f pointer_offset = laser_offset+Vec2f(-2.5f-int(Maths::Clamp(blob.getWidth(), 6, 18)/3), 2.5f);
	
	Vec2f laser_offset_rotoff = -Vec2f(laser_offset.x*FLIP_FACTOR, laser_offset.y);
	Vec2f pointer_offset_rotoff = -Vec2f(pointer_offset.x*FLIP_FACTOR, pointer_offset.y);
	
	CSpriteLayer@ laser = this.getSpriteLayer("laser");
	if(laser !is null) {
		laser.SetVisible(false);
	}
	
	f32 angle = blob.getAngleDegrees();
	f32 actual_angle = angle;
	
	bool laser_visible = this.isVisible();
	if(laser is null)
	{
		@laser = this.addSpriteLayer("laser", "Laserpointer_Ray.png", 32, 1);
		Animation@ anim = laser.addAnimation("default", 0, false);
		anim.AddFrame(0);
		laser.SetVisible(true);
	} else if (holder !is null) {
		Vec2f hitPos;
		f32 laser_length;
		f32 range = blob.get_f32("range");
		Vec2f dir = Vec2f(FLIP_FACTOR, 0.0f).RotateBy(angle);
		Vec2f startPos = blob.getPosition()+(Vec2f()+SPRITE_OFFSET-laser_offset_rotoff).RotateBy(angle);
		Vec2f muzzle_start_pos = startPos-dir*7;
		//startPos.RotateBy(actual_angle, blob.getPosition()+laser_offset_rotoff+Vec2f(0,-2.5)*-1+shoulder_joint);
		blob.set_Vec2f("for_render", startPos);
		Vec2f weak_point = getDriver().getScreenPosFromWorldPos(startPos);
		GUI::DrawRectangle(weak_point-Vec2f(2,2), weak_point+Vec2f(2,2), SColor(255, 0, 255, 0));
		Vec2f endPos = startPos + dir * range;
		endPos = getControls().getMouseWorldPos();
		f32 sus_angle = -(endPos-startPos).Angle();
		if ((endPos-startPos).Length()<300)
			sus_angle = actual_angle+ANGLE_FLIP_FACTOR;
		
		//bool mapHit = getMap().rayCastSolid(startPos, endPos, hitPos);
		 
		HitInfo@[] hitInfos;
		bool blobHit = getMap().getHitInfosFromRay(startPos, sus_angle, range, blob, @hitInfos);
		for (int index = 0; index < hitInfos.size(); ++index) {
			HitInfo@ hit = hitInfos[index];
			CBlob@ target = @hit.blob;
			//rayHits(target, holder, actual_angle)
			if (target is null || target !is null && !target.hasTag("scenary") && shouldRaycastHit(target, sus_angle, FLIP, blob.getTeamNum(), 2, hit.hitpos, muzzle_start_pos)) {
				hitPos = hit.hitpos;
				break;
			}
			else continue;
				//hitPos = hit.hitpos;
		}
		
		laser_length = Maths::Min(80, (hitPos - startPos).Length());
		laser_length = Maths::Clamp((hitPos - startPos).Length()-(blob.getWidth()/2), 0, 80);
		
		laser.ResetTransform();
		laser.setRenderStyle(RenderStyle::additive);
		laser.SetRelativeZ(0.3f);
		laser.SetOffset(laser_offset+SPRITE_OFFSET);
		laser.ScaleBy(Vec2f(laser_length / 32.0f, 1.0f));
		laser.TranslateBy(Vec2f(laser_length / 2+blob.getWidth()/4, 0.0f)*FLIP_FACTOR);
		//laser.RotateBy(sus_angle-ANGLE_FLIP_FACTOR, laser_offset_rotoff);
		
		laser.SetVisible(laser_visible);
		
		//if (!isServer()) break;
		
		CBlob@ light = getBlobByNetworkID(blob.get_u16("remote_netid"));
		
		if (!holder.isMyPlayer()) return;
		
		if (light !is null)
		{
			CBitStream params;
			if (laser_visible) {
				params.write_Vec2f(hitPos);
				light.setPosition(hitPos);
			}
			else {
				params.write_Vec2f(Vec2f(0, -400));
				light.setPosition(Vec2f(0, -400));
			}
			blob.SendCommand(blob.getCommandID("set_laser_pos"), params);
		}
		else
		{
			blob.SendCommand(blob.getCommandID("create_laser_light"));
		}
	} else {
		CBlob@ light = getBlobByNetworkID(blob.get_u16("remote_netid"));
		
		if (light !is null)
		{
			light.setPosition(Vec2f(0, -400));
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params) 
{
	if(cmd == this.getCommandID("set_laser_pos"))
	{
		Vec2f pos; if (!params.saferead_Vec2f(pos)) return;
		
		CBlob@ light = getBlobByNetworkID(this.get_u16("remote_netid"));
		
		if (light is null) return;
		
		light.setPosition(pos);
	}
	if(cmd == this.getCommandID("create_laser_light"))
	{
		if (this.hasTag("laser_pointer")) return;
		this.Tag("laser_pointer");
		if (!isServer()) return;
		CBlob@ light = server_CreateBlob("laserpointer_light", -1, this.getPosition());
		if (light is null) return;
		//print("created laser on "+getMachineType());
		this.set_u16("remote_netid", light.getNetworkID());
		this.Sync("remote_netid", true);
		light.set_u16("owner_netid", this.getNetworkID());
	}
}