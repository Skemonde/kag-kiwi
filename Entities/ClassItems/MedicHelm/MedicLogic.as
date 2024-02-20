#include "ThrowCommon"
#include "SoldatInfo"

const u8 MAX_BOMB_AMOUNT = 4;
const u32 BOMB_PRODUCING_INTERVAL = 90;
const string BOMB_NAME = "healingbomb";
const string BOMB_AMOUNT_PROP = "current_bomb_amount";
const string BOMB_CREATION_PROP = "last_bomb_make";
const string BOMB_TROW_TIME_PROP = "last_bomb_throw";

void onTick(CBlob@ this)
{
	// this one works only once per player class live
	initProperties(this);
	
	pickBomb(this);
	
	generateBomb(this);
}

void pickBomb(CBlob@ this)
{
	CPlayer@ player = this.getPlayer();
	if (player is null) return;
	
	if (this.isKeyJustPressed(key_action3)&&
		this.get_u8(BOMB_AMOUNT_PROP)>0&&
		(getGameTime()-this.get_u32(BOMB_TROW_TIME_PROP))>5) {
		CBlob@ healnad;
		if (isServer()) {
		
			if (this.getCarriedBlob() !is null) {
				Sound::Play("NoAmmo.ogg", this.getPosition(), 1, 1);
				return;
			}
			
			@healnad = server_CreateBlob(BOMB_NAME, this.getTeamNum(), this.getPosition());
			if (healnad !is null) {
				this.server_Pickup(healnad);
			}
		}
		if (healnad !is null)
			healnad.SetDamageOwnerPlayer(player);
		
		//client_SendThrowCommand(this);
		
		this.set_u32(BOMB_CREATION_PROP, getGameTime());
		this.sub_u8(BOMB_AMOUNT_PROP, 1);
		// basically we want to sync it on variable change so it doesn't blink each tick
		server_Sync(this);		
	}
}

void generateBomb(CBlob@ this)
{
	if ((this.get_u32(BOMB_CREATION_PROP)+BOMB_PRODUCING_INTERVAL) > getGameTime()) return;
	
	if (this.get_u8(BOMB_AMOUNT_PROP)<MAX_BOMB_AMOUNT) {
		this.add_u8(BOMB_AMOUNT_PROP, 1);
	}
	server_Sync(this);
	
	this.set_u32(BOMB_CREATION_PROP, getGameTime());
}

void server_Sync(CBlob@ this)
{
	if (!isServer()) return;
	if (!this.hasCommandID("medic_vars_sync")) return;
	
	CBitStream stream;
	stream.write_u8(this.get_u8(BOMB_AMOUNT_PROP));
	
	this.SendCommand(this.getCommandID("medic_vars_sync"), stream);
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{
	if (detached is null) return;
	if (detached.getName()!=BOMB_NAME) return;
	
	this.set_u32(BOMB_TROW_TIME_PROP, getGameTime());
	this.set_u32(BOMB_CREATION_PROP, getGameTime());
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (!this.hasCommandID("medic_vars_sync")) return;
	if (cmd == this.getCommandID("medic_vars_sync"))
	{
		if (!isClient()) return;
		
		u8 bomb_amount; if (!params.saferead_u8(bomb_amount)) return;
		
		this.set_u8(BOMB_AMOUNT_PROP, bomb_amount);
	}
}

void initProperties(CBlob@ this)
{
	if (!this.hasCommandID("medic_vars_sync"))
		this.addCommandID("medic_vars_sync");
	if (!this.exists(BOMB_CREATION_PROP))
		this.set_u32(BOMB_CREATION_PROP, getGameTime());
	if (!this.exists(BOMB_AMOUNT_PROP))
		this.set_u8(BOMB_AMOUNT_PROP, 0);
}

void onRender(CSprite@ this)
{
	if (this is null) return;
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	CBlob@ localblob = getLocalPlayerBlob();
	if (localblob is null) return;
	if (localblob !is blob) return;
	if (!isClient()) return;
	CPlayer@ local = getLocalPlayer();
	if (local is null) return;
	SoldatInfo@ info = getSoldatInfoFromUsername(local.getUsername());
	if (info is null) return;
	//for some reasons removing a script from a CSprite doesn't work well on server+client so we do a hack check
	if (info.hat_name!="medhelm") return;
	
	Driver@ driver = getDriver();
	Vec2f screen_tl = Vec2f();
	Vec2f screen_br = Vec2f(driver.getScreenWidth(), driver.getScreenHeight());
	
	Vec2f gui_pos = Vec2f(screen_tl.x+120, screen_tl.y+92);
	
	for (int bomb_id = 0; bomb_id<MAX_BOMB_AMOUNT; ++bomb_id) {
		f32 scale = 2.0f;
		GUI::DrawIcon("MedicGUI.png", (blob.get_u8(BOMB_AMOUNT_PROP)>bomb_id?1:0), Vec2f(8, 16), gui_pos+Vec2f(bomb_id*12*scale,0), scale, blob.getTeamNum());
	}
	GUI::SetFont("menu");
	GUI::DrawTextCentered("SPACE to make\na Treatment Vial", gui_pos+Vec2f(55, 80), color_white);
}