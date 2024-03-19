#include "Requirements"

void onInit( CBlob@ this )
{
    this.addCommandID("set head to update");
	this.addCommandID("emote");
	this.addCommandID("emote_sound");
	//this.getShape().SetGravityScale(0);
	this.Tag("vehicle");
	this.Tag("aerial");
	this.Tag("no team lock");
	this.Tag("bullet_hits");
	this.Tag("allow guns");
	
	CSprite@ sprite = this.getSprite();
	
	sprite.SetEmitSound("Eurokopter_Loop.ogg");
	sprite.SetEmitSoundSpeed(0.01f);
	sprite.SetEmitSoundPaused(false);
	sprite.SetZ(-3);
	
    this.addCommandID("detach_pilot");
    this.addCommandID("add_force");
	
	AttachmentPoint@ p_point = this.getAttachments().getAttachmentPointByName("PILOT");
	p_point.offsetZ = -3;
	AttachmentPoint@ p2_point = this.getAttachments().getAttachmentPointByName("PILOT2");
	p2_point.offsetZ = -3;
	AttachmentPoint@ p3_point = this.getAttachments().getAttachmentPointByName("DOOR");
	p3_point.offsetZ = 100;
	
	p2_point.SetKeysToTake(key_left | key_right | key_up | key_down | key_action1 | key_action2);
	
	p3_point.SetKeysToTake(key_left | key_right | key_up | key_down);
	// pilot.SetMouseTaken(true);
}

void onInit(CSprite@ this)
{
	CSpriteLayer@ interior = this.addSpriteLayer("interior", "BattleCopterInterior.png", 80, 64, 0, 0);
	if (interior !is null) {
		interior.SetRelativeZ(-40.0f);
	}
	CSpriteLayer@ exterior = this.addSpriteLayer("exterior", "BattleCopterExterior.png", 80, 64, 0, 0);
	if (exterior !is null) {
		exterior.SetRelativeZ(0.5f);
	}
}

void RotateAttached(CBlob@ this)
{
	for (int idx = 0; idx < this.getAttachmentPointCount(); ++idx)
	{
		AttachmentPoint@ point = this.getAttachmentPoint(idx);
		if (point is null) continue;
		CBlob@ blob = point.getOccupied();
		if (blob is null) continue;
		//print("gog "+blob.getName());
		blob.setAngleDegrees(this.getAngleDegrees());
	}
}

void ManageDoor(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ door = sprite.getSpriteLayer("door");
	if (door is null) return;
	
	AttachmentPoint@ p3_point = this.getAttachments().getAttachmentPointByName("DOOR");
	if (p3_point is null) return;
	
	if (p3_point.getOccupied() is null) {
		door.SetRelativeZ(0.3f);
		return;
	}
	
	door.SetRelativeZ(20);
}

void ReadSecondPilotActions(CBlob@ this)
{
	if (!isServer()) return;
	if (getGameTime()-this.get_u32("last bombing") < 30) return;
	
	AttachmentPoint@ p2_point = this.getAttachments().getAttachmentPointByName("PILOT2");
	if (p2_point is null) return;
	CBlob@ gunner = p2_point.getOccupied();
	if (gunner is null) return;
	
	CBitStream missing;
	CBitStream bomb_reqs = getBombReqs();
	
	if (!hasRequirements(this.getInventory(), null, bomb_reqs, missing)) return;
	//print("hey");
	if (gunner.isKeyJustPressed(key_action3)) {
		CBlob@ bomb = server_CreateBlob("abomb", gunner.getTeamNum(), this.getPosition()+Vec2f(0, 24));
		this.setVelocity(Vec2f(this.getVelocity().x*3, 30));
		this.set_u32("last bombing", getGameTime());
		server_TakeRequirements(this.getInventory(), null, bomb_reqs);
	}
}

CBitStream getBombReqs()
{
	CBitStream reqs;
	reqs.write_string("blob");
	reqs.write_string("abomb");
	reqs.write_string("friendlyName");
	reqs.write_u16(1);
	return reqs;
}

void onTick(CBlob@ this)
{
	RotateAttached(this);
	
	ReadSecondPilotActions(this);
	
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
	if (pilot.getPlayer() !is null) return;
	CPlayer@ local = getLocalPlayer();
	
	if (!isClient()) return;
	
	CControls@ controls = getControls();
	bool weare = this.isMyPlayer();
	if (!weare || (local !is null && ply !is local)) return;
	
	Vec2f m_screen = controls.getMouseScreenPos();
	
	f32 percent_m_screen_x = (m_screen.x)/getDriver().getScreenWidth();
	f32 percent_m_screen_y = (m_screen.y)/(getDriver().getScreenHeight());
	
	f32 percent_pos_y = this.getPosition().y/(getMap().tilemapheight*8);
	
	//bool going_up = (percent_pos_y-percent_m_screen_y)<0;
	
	f32 y_diff = percent_pos_y-percent_m_screen_y;
	f32 x_diff = m_screen.x-getDriver().getScreenWidth()/2;
	
	f32 y_sin = Maths::Abs(y_diff)<0.1?(getGameTime()%30==0?310:0):0;
	
	f32 max_x_force = 150;
	f32 max_y_force = 300;
	
	Vec2f dir = Vec2f(Maths::Abs(x_diff)>40?Maths::Clamp(x_diff, -max_x_force, max_x_force):0, y_sin-(500-max_y_force)+Maths::Clamp(-y_diff*this.getMass()*4, -max_y_force, 0));
	
	bool rmb_pressed = controls.isKeyPressed(KEY_RBUTTON);
	//print("POEWR "+(-(percent_pos_y-percent_m_screen_y)*200));
	//print("y "+getMap().tilemapheight);
	//dir.Normalize();
	
	if (true||controls.isKeyPressed(KEY_LBUTTON)) {
		CBitStream params;
		params.write_Vec2f(dir);
		params.write_bool(rmb_pressed);
		this.SendCommand(this.getCommandID("add_force"), params);
	}
		//print("gotthere");
		
	if (controls.isKeyPressed(KEY_LSHIFT))
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
		bool rmb_pressed; if(!params.saferead_bool(rmb_pressed)) return;
		this.AddForce(dir);
		this.SetFacingLeft(rmb_pressed||Maths::Abs(dir.x)<5?this.isFacingLeft():dir.x<0);
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
	//this.set_u16("pilot_body_id", 0);
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{
	if (detached.hasTag("flesh")) {
		detached.Untag("isInVehicle");
		
		AttachmentPoint@ pilot_pickup = detached.getAttachments().getAttachmentPointByName("PICKUP");
		if (pilot_pickup !is null) {
			pilot_pickup.offsetZ = 1;
		}
	}
	if (attachedPoint.name=="PILOT")
		ResetPlayer(this, detached);
		
	detached.setAngleDegrees(0);
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	if (attached.hasTag("flesh") && attachedPoint.name!="DOOR") {
		attached.Tag("isInVehicle");
	}
	if (attached.hasTag("player") && attachedPoint.name=="PILOT")
	{
		CPlayer@ ply = attached.getPlayer();
		
		AttachmentPoint@ pilot_pickup = attached.getAttachments().getAttachmentPointByName("PICKUP");
		if (pilot_pickup !is null) {
			pilot_pickup.offsetZ = attachedPoint.offsetZ+2;
		}
		
		if (ply !is null) {
			this.server_SetPlayer(ply);
			this.set_u16("pilot_body_id", attached.getNetworkID());
		}
	}
}