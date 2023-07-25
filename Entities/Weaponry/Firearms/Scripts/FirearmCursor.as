void ManageCursors(CBlob@ this)
{
	if (this !is getLocalPlayerBlob()) return;
	// set cursor
	if (getHUD().hasButtons())
	{
		getHUD().SetDefaultCursor();
	}
	else
	{
		AttachmentPoint@ pickup_point = this.getAttachments().getAttachmentPointByName("PICKUP");
		if (pickup_point is null) return;
		
        CBlob@ b = pickup_point.getOccupied();
		//if (b !is null && b.exists("clip")) return;
		// set cursor
		getHUD().SetCursorImage("AimCrossCircle.png", Vec2f(16, 16));
		getHUD().SetCursorOffset(Vec2f(-20, -20));
		// frame set in logic
	}
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	ManageCursors(blob);
}