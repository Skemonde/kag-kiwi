
void onInit(CBlob@ this)
{
	this.addCommandID("attach_frame");
}

void onTick(CBlob@ this)
{
	f32 speed_mod = 0.5f;
	this.setAngleDegrees(0);
	//this.setAngleDegrees((geGameTime()%(360*speed_mod))/speed_mod);
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	for (int attached_id = 0; attached_id < this.getAttachmentPointCount(); ++attached_id) {
		AttachmentPoint@ point = this.getAttachmentPoint(attached_id);
		if (point is null) continue;
		CBlob@ point_occupant = point.getOccupied();
		if (point_occupant !is null) {
			continue;
		}
		CBitStream params;
		params.write_u8(attached_id);
		CButton@ button = caller.CreateGenericButton(2, point.offset/2, this, this.getCommandID("attach_frame"), "id "+attached_id, params);
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("attach_frame"))
	{
		if (!isServer()) return;
		CBlob@ blob = server_CreateBlob("woodenframe");
		if (blob is null) return;
		u8 slot_id; if (!params.saferead_u8(slot_id)) return;
		AttachmentPoint@ point = this.getAttachmentPoint(slot_id);
		if (point !is null) {
			Vec2f shape_offset = point.offset+Vec2f(1,1)*12;
			Vec2f blob_dims = Vec2f(blob.getWidth(), blob.getHeight());
			Vec2f[] solid_shape =
			{
				Vec2f(shape_offset.x-blob_dims.x/2, shape_offset.y-blob_dims.y/2),
				Vec2f(shape_offset.x+blob_dims.x/2, shape_offset.y-blob_dims.y/2),
				Vec2f(shape_offset.x+blob_dims.x/2, shape_offset.y+blob_dims.y/2),
				Vec2f(shape_offset.x-blob_dims.x/2, shape_offset.y+blob_dims.y/2)
			};
			this.getShape().AddShape(solid_shape);
			//this.getShape().SetCenterOfMassOffset(shape_offset);
		}
		this.server_AttachTo(blob, "SLOT_"+(slot_id+1));
		blob.set_u16("owner_blob_id", this.getNetworkID());
	}
}