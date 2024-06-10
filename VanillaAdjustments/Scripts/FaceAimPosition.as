//set facing direction to aiming direction
#include "FirearmVars"

void onInit(CMovement@ this)
{
	//this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
	this.getCurrentScript().tickFrequency = 3;
}

void onTick(CMovement@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob.hasTag("halfdead")) return;
	
	CBlob@ carried = blob.getCarriedBlob();
	
	if (carried !is null && (getGameTime()-carried.get_u32("last_slash"))<6) return;
	
	CBlob@ holder_vehicle = getBlobByNetworkID(blob.get_u16("my vehicle"));
	
	bool turret_gunner = holder_vehicle !is null && blob.isAttachedTo(holder_vehicle) && holder_vehicle.hasTag("turret");
	
	bool facing = (blob.getAimPos().x <= blob.getPosition().x);
	if (!(Maths::Abs(blob.getAimPos().x-blob.getPosition().x)>Maths::Abs(blob.getAimPos().y-blob.getPosition().y)*0.15f)||(blob.isAttached()&&blob.hasTag("isInVehicle")&&turret_gunner)) return;
	
	if (blob.exists("build_angle")) {
		if (blob.isFacingLeft()&&!facing) {
			//changed from left to right
			if (blob.get_u16("build_angle")==90)
				blob.set_u16("build_angle", 180+blob.get_u16("build_angle"));
			else if (blob.get_u16("build_angle")==270)
				blob.set_u16("build_angle", -180+blob.get_u16("build_angle"));
		} else if (!blob.isFacingLeft()&&facing) {
			//from right to the left
			if (blob.get_u16("build_angle")==90)
				blob.set_u16("build_angle", 180+blob.get_u16("build_angle"));
			else if (blob.get_u16("build_angle")==270)
				blob.set_u16("build_angle", -180+blob.get_u16("build_angle"));
		}
	}
	
	blob.SetFacingLeft(facing);

	// face for all attachments

	if (blob.hasAttached())
	{
		AttachmentPoint@[] aps;
		if (blob.getAttachmentPoints(@aps))
		{
			for (uint i = 0; i < aps.length; i++)
			{
				AttachmentPoint@ ap = aps[i];
				if (ap.socket && ap.getOccupied() !is null)
				{
					bool faced_left = ap.getOccupied().isFacingLeft();
					ap.getOccupied().SetFacingLeft(facing);
					
					if (ap.getOccupied().hasTag("firearm")&&facing!=faced_left)
					{
						ap.getOccupied().setAngleDegrees(getGunAngle(blob));
					}
				}
			}
		}
	}
}

f32 getGunAngle(CBlob@ holder)
{
	if (holder is null) return 0;
	const bool FLIP = holder.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	CBlob@ carried = holder.getCarriedBlob();
	if (carried is null) return 0;
	FirearmVars@ vars;
	if (!carried.get("firearm_vars", @vars)) return 0;
	
	
	Vec2f shoulder_joint = Vec2f(-3*FLIP_FACTOR, 0);
	shoulder_joint += Vec2f(-carried.get_Vec2f("gun_trans_from_carrier").x*FLIP_FACTOR, carried.get_Vec2f("gun_trans_from_carrier").y);
	if (carried.hasTag("trench_aim"))
		shoulder_joint += Vec2f(-trench_aim.x*FLIP_FACTOR, trench_aim.y);
	Vec2f end_pos = holder.getAimPos();
	//f32 raw_angle = -(end_pos - carried.getPosition()+Vec2f(100*FLIP_FACTOR,0).RotateBy(carried.get_f32("GUN_ANGLE"))).Angle()+ANGLE_FLIP_FACTOR;
	Vec2f muzzle_offset = (Vec2f(-20*FLIP_FACTOR, 0)+Vec2f(vars.MUZZLE_OFFSET.x*FLIP_FACTOR, vars.MUZZLE_OFFSET.y)).RotateBy(carried.getAngleDegrees());
	Vec2f start_pos = carried.getPosition()+muzzle_offset;
	
	Vec2f aimvector = end_pos - start_pos;
	
	f32 angle = constrainAngle(-aimvector.Angle()+ANGLE_FLIP_FACTOR);
	//angle = Maths::Round(angle);
	HitInfo@[] hitInfos;
	//bool blobHit = getMap().getHitInfosFromRay(start_pos, -aimvector.Angle(), carried.getWidth()*2, holder, @hitInfos);
	//print("angle "+angle);
	
	return angle;
}
