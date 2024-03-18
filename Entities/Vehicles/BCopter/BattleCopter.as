
void onInit( CBlob@ this )
{
    this.addCommandID("set head to update");
	this.addCommandID("emote");
	this.addCommandID("emote_sound");
	//this.getShape().SetGravityScale(0);
	//this.Tag("player");
	CSprite@ sprite = this.getSprite();
	
	sprite.SetEmitSound("Eurokopter_Loop.ogg");
	sprite.SetEmitSoundSpeed(0.01f);
	sprite.SetEmitSoundPaused(false);
	
    this.addCommandID("detach_pilot");
    this.addCommandID("add_force");
}

void onTick(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSoundSpeed(Maths::Clamp(this.getVelocity().Length()/4, 0.9f, 3));
	
	if (Maths::Abs(this.getVelocity().x)>0.2f) {
		this.setAngleDegrees(0+this.getVelocity().x*3.3f);
	} else
		this.setAngleDegrees(0);
	
	CPlayer@ ply = this.getPlayer();
	if (ply is null) return;
	CBlob@ pilot = getBlobByNetworkID(this.get_u16("pilot_body_id"));
	if (pilot is null) return;
	CPlayer@ local = getLocalPlayer();
	
	if (isServer()) return;
	
	CControls@ controls = getControls();
	bool weare = ply.isMyPlayer();
	
	Vec2f m_screen = controls.getMouseScreenPos();
	
	f32 percent_m_screen_x = (m_screen.x)/getDriver().getScreenWidth();
	f32 percent_m_screen_y = (m_screen.y)/(getDriver().getScreenHeight());
	
	f32 percent_pos_y = this.getPosition().y/(getMap().tilemapheight*8);
	
	//bool going_up = (percent_pos_y-percent_m_screen_y)<0;
	
	f32 y_diff = percent_pos_y-percent_m_screen_y;
	f32 x_diff = m_screen.x-getDriver().getScreenWidth()/2;
	
	f32 y_sin = Maths::Abs(y_diff)<0.1?(getGameTime()%30==0?310:0):0;
	
	f32 max_x_force = 150;
	f32 max_y_force = 500;
	
	Vec2f dir = Vec2f(Maths::Abs(x_diff)>80?Maths::Clamp(x_diff, -max_x_force, max_x_force):0, y_sin+Maths::Clamp(-y_diff*this.getMass()*4, -max_y_force, -100));
	this.SetFacingLeft(dir.x>0);
	//print("POEWR "+(-(percent_pos_y-percent_m_screen_y)*200));
	//print("y "+getMap().tilemapheight);
	//dir.Normalize();
	
	if (weare||controls.isKeyPressed(KEY_LBUTTON)) {
		CBitStream params;
		params.write_Vec2f(dir);
		this.SendCommand(this.getCommandID("add_force"), params);
	}
		//print("gotthere");
		
	if (weare&&controls.isKeyPressed(KEY_LSHIFT))
		this.SendCommand(this.getCommandID("detach_pilot"));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params) 
{
	if(cmd == this.getCommandID("detach_pilot"))
	{
		CBlob@ pilot = getBlobByNetworkID(this.get_u16("pilot_body_id"));
		if (pilot is null) return;
		
		this.server_DetachFrom(pilot);
	}
	if(cmd == this.getCommandID("add_force"))
	{
		Vec2f dir; if(!params.saferead_Vec2f(dir)) return;
		this.AddForce(dir);
	}
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return false;
}

void ResetPlayer(CBlob@ this, CBlob@ detached)
{
	CBlob@ pilot = getBlobByNetworkID(this.get_u16("pilot_body_id"));
	if (pilot is null || detached is null) return;
	if (detached !is pilot) return;
	
	pilot.server_SetPlayer(this.getPlayer());
	this.set_u16("pilot_body_id", 0);
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{
	ResetPlayer(this, detached);
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	if (attached.hasTag("player"))
	{
		CPlayer@ ply = attached.getPlayer();
		
		if (ply !is null) {
			this.server_SetPlayer(ply);
			this.set_u16("pilot_body_id", attached.getNetworkID());
		}
	}
}