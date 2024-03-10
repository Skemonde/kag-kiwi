#include "RunnerCommon.as";
#include "Hitters.as";
#include "KnockedCommon.as"
#include "FireCommon.as"
#include "Help.as"
#include "UpdateInventoryOnClick.as"

void onInit(CBlob@ this)
{
	this.getCurrentScript().removeIfTag = "dead";
	this.Tag("heavy weight");

	//default player minimap dot - not for migrants
	if (this.getName() != "migrant")
	{
		this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 8, Vec2f(8, 8));
	}

	this.set_s16(burn_duration , 130);
	this.set_f32("heal amount", 0.0f);

	//fix for tiny chat font
	this.SetChatBubbleFont("hud");
	this.maxChatBubbleLines = 4;

	InitKnockable(this);
}

void onTick(CBlob@ this)
{
	const bool flip = this.isFacingLeft();
	const f32 flip_factor = flip ? -1: 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	
	if (this.getName()=="soldat")
	{
		if (this.isOnGround()||this.isOnWall()) {
			if (Maths::Abs(this.getVelocity().x)>0.2f) {
				this.setAngleDegrees(0+this.getVelocity().x*7.3f);
			} else
				this.setAngleDegrees(0);
		} else {
			//print("ANGLE"+this.getAngleDegrees());
			f32 crit_angle = 30;
			
			if (this.getVelocity().y<-7||(this.getAngleDegrees()<(360-crit_angle)&&this.getAngleDegrees()>crit_angle)) {
				this.setAngleDegrees(this.getAngleDegrees()+10*(flip?-1:1));
			} else
				this.setAngleDegrees(0);
		}
	}
	
	this.Untag("prevent crouch");
	DoKnockedUpdate(this);
	/* 
	for (int count = 0; count < this.getTouchingCount(); ++count) {
		CBlob@ touching_blob = this.getTouchingByIndex(count);
		if (touching_blob !is null && touching_blob.getShape().getConsts().transports && this.getVelocity().Length()>0 && this.getVelocity().Length()<touching_blob.getVelocity().Length()*2.8f)
		{
			const bool LEFT = this.isKeyPressed(key_left);
			const bool RIGHT = this.isKeyPressed(key_right);
			
			CBlob@ host = getBlobByNetworkID(touching_blob.get_u16("owner_blob_id"));
			Vec2f host_vel = host is null ? touching_blob.getVelocity() : host.getVelocity();
			//this.setVelocity(touching_blob.getVelocity());
			//this.setVelocity(this.getVelocity()+Vec2f(2*(this.isKeyPressed(key_left)?(this.isKeyPressed(key_right)?0:-1):1),0));
			if (this.isKeyJustReleased(key_right)||this.isKeyJustReleased(key_left)) {
				//this.setPosition(this.getPosition()+this.getVelocity());
			}
			if (this.isKeyPressed(key_down)&&!LEFT&&!RIGHT) {
				this.setVelocity(host_vel*1.4);
			}
			
			//print(""+(touching_blob.getVelocity().x>0));
			//this.AddForce(Vec2f(touching_blob.getVelocity().x*20*(touching_blob.getVelocity().x>0?1:-0.002),0));
			//break;
		}
	}
	 */
	CBlob@ carried = this.getCarriedBlob();
	if (carried !is null && this.isAttached())
		carried.SetFacingLeft(this.isFacingLeft());
}

// pick up efffects
// something was picked up

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	if (!blob.hasTag("quick_detach"))
		this.getSprite().PlaySound("/PutInInventory.ogg");
}

void onRender( CSprite@ this )
{
	return;
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	CPlayer@ player = blob.getPlayer();
	if (player is null) return;
	CPlayer@ local = getLocalPlayer();
	if (local is null) return;
	
	Vec2f bubble_center = blob.getInterpolatedPosition()-Vec2f(0, 24);
	
	const u32 LAST_MSG = blob.get_u32("last chat tick");
	const string MESSAGE = blob.get_string("last chat msg");
	Vec2f message_dims = Vec2f();
	GUI::SetFont("neue");
	GUI::GetTextDimensions(MESSAGE, message_dims);
	
	if (getGameTime()>(LAST_MSG+Maths::Clamp(MESSAGE.length()*2, 60, 210))) return;
	Vec2f pane_center_screen = getDriver().getScreenPosFromWorldPos(bubble_center);
	Vec2f mouse_screen = getControls().getMouseScreenPos();
	
	Vec2f pane_tl = pane_center_screen-Vec2f(message_dims.x/2, message_dims.y/2)-Vec2f(1, 1)*8;
	Vec2f pane_br = pane_center_screen+Vec2f(message_dims.x/2, message_dims.y/2)+Vec2f(1, 1)*8;
	if (!(mouse_screen.x < pane_tl.x || mouse_screen.x > pane_br.x || mouse_screen.y < pane_tl.y || mouse_screen.y > pane_br.y)) return;
	
	const u8 CHAT_CHANNEL = blob.get_u8("last chat channel");
	bool global_chat = CHAT_CHANNEL==0;
	
	if (global_chat||!global_chat&&local !is null&&local.getTeamNum()==player.getTeamNum()) {
		GUI::DrawBubble(pane_tl, pane_br);
		GUI::DrawText(MESSAGE, pane_tl+Vec2f(1, 1)*4, pane_br-Vec2f(1, 1)*4, SColor(0xff000000), false, false, false);
	}
	GUI::SetFont("default");
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if (this.hasTag("has_inventory_opened"))
		UpdateInventoryOnClick(this);

	if (!attached.hasTag("quick_detach"))
		this.getSprite().PlaySound("/Pickup.ogg");

	this.ClearButtons();

	if (getNet().isClient())
	{
		RemoveHelps(this, "help throw");

		if (!attached.hasTag("activated"))
			SetHelp(this, "help throw", "", getTranslatedString("${ATTACHED}$Throw    $KEY_C$").replace("{ATTACHED}", getTranslatedString(attached.getName())), "", 2);
	}

	CBlob@ carried = this.getCarriedBlob();
	if (carried is null) return;
	if (!carried.isAttached()) return;
	
	if (carried.hasTag("detach on seat in vehicle") && attached.hasTag("vehicle")) {
		if (!this.server_PutInInventory(carried))
			carried.server_DetachFromAll();
	}
	
	if (carried.hasTag("detach on seat in TANK") && attached.hasTag("tank")) {
		carried.server_DetachFromAll();
	}
	
	//made this so i can track vehicle we're in to add its vel when needed
	if (attached.hasTag("vehicle")) {
		this.set_u16("my vehicle", attached.getNetworkID());
	}
	
	// check if we picked a player - don't just take him out of the box
	/*if (attached.hasTag("player"))
	this.server_DetachFrom( attached ); CRASHES*/
}

// set the Z back
// The baseZ is assumed to be 0
void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	if (this.hasTag("has_inventory_opened")) UpdateInventoryOnClick(this);
	
	const bool FLIP = this.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	this.getSprite().SetZ(0.0f);
	this.getSprite().SetRelativeZ(0.0f);
	
	if (isServer() && detached !is null && detached.hasTag("firearm")) {
		detached.setPosition(detached.getPosition()+Vec2f(detached.getWidth()/2,0).RotateBy(detached.get_f32("gunangle")+ANGLE_FLIP_FACTOR,Vec2f()));
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	bool isSleeper = !(this.get_string("sleeper_name").empty()||!this.exists("sleeper_name"));
	return this.hasTag("migrant") || this.hasTag("dead") || this.hasTag("halfdead") || isSleeper;
}
