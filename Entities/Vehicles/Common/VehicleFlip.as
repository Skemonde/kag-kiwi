
void onInit( CBlob@ this )
{
	this.addCommandID("flip_vehicle");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if (caller.getTeamNum()!=this.getTeamNum()) return;
	f32 crit_angle = 80;
	if (this.getAngleDegrees()<crit_angle||this.getAngleDegrees()>(360-crit_angle)) return;
	
	bool can_use = !caller.isAttached();
	
	CButton@ button = caller.CreateGenericButton("$arrow_topleft$", Vec2f(0, -8), this, this.getCommandID("flip_vehicle"), can_use?"Flip it!":"Jump of the vehicle first!");
	if (button !is null) {
		button.SetEnabled(can_use);
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if(cmd == this.getCommandID("flip_vehicle")) 
	{
		const bool FLIP = this.isFacingLeft();
		const f32 FLIP_FACTOR = FLIP ? -1 : 1;
		this.AddForce(Vec2f(0, -this.getMass()*4));
		this.AddTorque(FLIP_FACTOR*-10*this.getMass());
	}
}

bool isInventoryAccessible( CBlob@ this, CBlob@ forBlob )
{
	f32 crit_angle = 80;
	bool flipped = this.getAngleDegrees()<crit_angle||this.getAngleDegrees()>(360-crit_angle);
	
	return flipped;
}