// Tank logic 
#include "FirearmVars"

void onInit( CBlob@ this )
{
	const bool FLIP = this.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	CSprite@ sprite = this.getSprite();
	AddTankSpriteLayers(sprite);
	
	this.Tag("vehicle");
	this.Tag("ground_vehicle");
	this.Tag("tank");
	this.Tag("non_pierceable");
	this.Tag("convert on sit");
	this.Tag("no team lock");
	this.Tag("bullet_hits");
	
	this.set_f32("move_speed", 120);
	this.set_f32("turn_speed", 20);
	this.set_string("movement_sound", "med_tank_tracks1.ogg");
	
	this.addCommandID("add_ammo");
	
	this.getSprite().SetZ(-1);
	
	CShape@ shape = this.getShape();
	//shape.getConsts().mapCollisions = false;
	
	AttachmentPoint@ gunner = this.getAttachments().getAttachmentPointByName("GUNPOINT_GUNNER");
	if (gunner !is null)
	{
		gunner.SetKeysToTake(key_left | key_right | key_up | key_down | key_inventory);
		// pilot.SetMouseTaken(true);
	}
	if (true) {
		CBlob@ blob = server_CreateBlob("firsttankcannon");
		if (blob !is null)
		{
			blob.server_setTeamNum(this.getTeamNum());
			blob.setInventoryName(this.getInventoryName() + "'s Cannon");
			//blob.getShape().getConsts().collideWhenAttached = true;
			blob.set_Vec2f("gun_trans_from_carrier", Vec2f(0, 0));
			blob.getSprite().SetRelativeZ(-30);
			this.server_AttachTo(blob, "GUNPOINT");
			this.set_u16("cannon_id", blob.getNetworkID());
			blob.set_u16("storage_id", this.getNetworkID());
			blob.set_u16("turret_id", this.getNetworkID());
			blob.setAngleDegrees(-20);
		}
	}
	if (true) {
		CBlob@ blob = server_CreateBlob("steelplate");
		if (blob !is null)
		{
			blob.server_setTeamNum(this.getTeamNum());
			this.server_AttachTo(blob, "PLATE1");
			this.set_u16("plate1_id", blob.getNetworkID());
			blob.set_u16("owner_blob_id", this.getNetworkID());
		}
	}
	if (true) {
		CBlob@ blob = server_CreateBlob("steelplate");
		if (blob !is null)
		{
			blob.server_setTeamNum(this.getTeamNum());
			this.server_AttachTo(blob, "PLATE2");
			this.set_u16("plate2_id", blob.getNetworkID());
			blob.set_u16("owner_blob_id", this.getNetworkID());
		}
	}
	
	{
		Vec2f turret_offset = Vec2f(16, 2);
		Vec2f turret_dims = Vec2f(32, 16);
		
		Vec2f[] turret =
		{
			Vec2f(turret_offset.x-turret_dims.x/2, 			turret_offset.y-turret_dims.y/2),
			Vec2f(turret_offset.x+turret_dims.x/2, 			turret_offset.y-turret_dims.y/2),
			Vec2f(turret_offset.x+turret_dims.x/2, 			turret_offset.y+turret_dims.y/2),
			Vec2f(turret_offset.x-turret_dims.x/2, 			turret_offset.y+turret_dims.y/2)
		};
		this.getShape().AddShape(turret);
	}
	
	CSpriteLayer@ tracks = sprite.addSpriteLayer("tracks", "FirstTankTracks.png", 64, 32);
	if (tracks !is null)
	{
		Animation@ anim = tracks.addAnimation("default", 1, true);
		int[] frames = { 0, 1, 2, 3, 4, 5, 6, 7, 8 };
		anim.AddFrames(frames);
		Animation@ rev = tracks.addAnimation("reverse", 1, true);
		int[] rev_frames = { 8, 7, 6, 5, 4, 3, 2, 1, 0 };
		rev.AddFrames(rev_frames);
		tracks.SetRelativeZ(0.0f);
		tracks.SetOffset(sprite.getOffset());
		tracks.SetVisible(true);
	}
	
	AddTankAmmo(this);
}

string getAmmoName(CBlob@ this)
{
	string ammo_name = "mat_stone";
	CBlob@ cannon = getBlobByNetworkID(this.get_u16("cannon_id"));
	if (cannon is null) return ammo_name;
	
	FirearmVars@ vars;
	if (!cannon.get("firearm_vars", @vars)) return ammo_name;
	if (vars.AMMO_TYPE.size()<1) return ammo_name;
	
	ammo_name = vars.AMMO_TYPE[0];
	
	return ammo_name;
}

void AddTankAmmo(CBlob@ this)
{
	if (!isServer()) return;
	for (int idx = 0; idx < 15; ++idx)
	{
		CBlob@ blob = server_CreateBlob(getAmmoName(this), this.getTeamNum(), this.getPosition());
		this.server_PutInInventory(blob);
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if (caller.getTeamNum()!=this.getTeamNum()) return;
	if (caller.getInventory() is null) return;
	
	string ammo_name = getAmmoName(this);
	bool has_ammo = caller.getBlobCount(ammo_name)>0;
	bool can_use = !caller.isAttached()&&has_ammo;
	
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	
	CButton@ button = caller.CreateGenericButton("$"+ammo_name+"$", Vec2f(0, -10), this, this.getCommandID("add_ammo"), "Add ammo", params);
	if (button !is null) {
		button.SetEnabled(can_use);
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if(cmd == this.getCommandID("add_ammo")) 
	{
		u16 caller_id; if (!params.saferead_u16(caller_id)) return;
		
		CBlob@ caller = getBlobByNetworkID(caller_id);
		if (caller is null) return;
		CInventory@ inv = caller.getInventory();
		if (inv is null) return;
		
		string ammo_name = getAmmoName(this);
		
		CBlob@ carried = caller.getCarriedBlob();
		if (carried !is null && carried.getName()==ammo_name)
		{
			if (!this.server_PutInInventory(carried))
				caller.server_PutInInventory(carried);
		}
		for (int idx = 0; idx < inv.getItemsCount()+2; ++idx)
		{
			CBlob@ item = inv.getItem(ammo_name);
			if (item is null) continue;
			
			if (!this.server_PutInInventory(item))
			{
				// once we're not able to fit more we end cycle
				caller.server_PutInInventory(item);
				break;
			}
		}
	}
}

void onChangeTeam( CBlob@ this, const int oldTeam )
{
	AddTankSpriteLayers(this.getSprite());
}

void AddTankSpriteLayers(CSprite@ this)
{	
	CSpriteLayer@ front_plate = this.getSpriteLayer("front_plate");
	if (front_plate !is null) this.RemoveSpriteLayer("front_plate");
	
	CSpriteLayer@ gunner_seat = this.getSpriteLayer("gunner_seat");
	if (gunner_seat !is null) this.RemoveSpriteLayer("gunner_seat");
	
	CBlob@ blob = this.getBlob();
	
	@ front_plate = this.addSpriteLayer("front_plate", "FirstTankTurret.png", 40, 20, blob.getTeamNum(), 0);
	if (front_plate !is null) {
		front_plate.SetFrame(1);
		front_plate.SetRelativeZ(0);
		front_plate.SetOffset(Vec2f(0,-8)+Vec2f(6, -14));
	}
	@ gunner_seat = this.addSpriteLayer("gunner_seat", "FirstTankTurret.png", 40, 20, blob.getTeamNum(), 0);
	if (gunner_seat !is null) {
		gunner_seat.SetFrame(0);
		gunner_seat.SetRelativeZ(-20);
		gunner_seat.SetOffset(Vec2f(0,-8)+Vec2f(6, -14));
	}
}

void sprite_ManageTrackSprite(CSprite@ this)
{
	CSpriteLayer@ tracks = this.getSpriteLayer("tracks");
	if (tracks is null) return;
	Animation@ def_anim = tracks.getAnimation("default");
	if (def_anim is null) return;
	Animation@ rev_anim = tracks.getAnimation("reverse");
	if (rev_anim is null) return;
	Animation@ anim = null;
	
	CBlob@ blob = this.getBlob();
	
	if (Maths::Abs(blob.getVelocity().x)<0.1)
	{
		def_anim.time = 0;
		rev_anim.time = 0;
		return;
	}
	
	if ((blob.getVelocity().x>0&&!blob.isFacingLeft())||(blob.getVelocity().x<=0&&blob.isFacingLeft()))
	{
		tracks.SetAnimation(def_anim);
		@anim = def_anim;
	}
	else
	{
		tracks.SetAnimation(rev_anim);
		@anim = rev_anim;
	}
	
	if (anim is null) return;
	
	//print(""+(blob.getVelocity().x));
	f32 anim_delta = 1/Maths::Abs(blob.getVelocity().x);
	if (anim_delta>=1)
		anim.time = Maths::Max(1, anim_delta);
	else
	{
		anim.time = 0;
		int frames_per_tick = Maths::Ceil(Maths::Abs(blob.getVelocity().x));
		int frames_amount = anim.getFramesCount();
		
		if (getGameTime()%frames_per_tick==0)
		{
			int frame_to_set = 0;
			bool overlaping_frame_count = (anim.frame+frames_per_tick)>=frames_amount;
			if (overlaping_frame_count)
				frame_to_set = (anim.frame+frames_per_tick)-frames_amount;
			else
				frame_to_set = anim.frame+frames_per_tick;
			anim.SetFrameIndex(frame_to_set);
		}
	}
	//if (Maths::Abs(blob.getVelocity().x)<0.1) anim.time = 0;
}

void sprite_ManageInterior(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	
	AttachmentPoint@ dp = blob.getAttachments().getAttachmentPointByName("DRIVER");
	if (dp is null) return;
	
	CBlob@ driver = dp.getOccupied();
	if (driver is null) {
		
		if (isClient())
		{
			this.SetFrame(0);
			dp.offsetZ=-10.0f;
		}
		return;
	}
	
	AttachmentPoint@ tp = blob.getAttachments().getAttachmentPointByName("GUNPOINT_GUNNER");
	if (tp is null) return;
	
	CBlob@ turret_gunner = tp.getOccupied();
	
	if (!(driver.isMyPlayer()||turret_gunner !is null && turret_gunner.isMyPlayer())) {
		
		if (isClient())
		{
			this.SetFrame(0);
			dp.offsetZ=-10.0f;
		}
		return;
	}
	
	this.SetFrame(1);
	dp.offsetZ=-2.0f;
}

void onTick(CSprite@ this)
{
	sprite_ManageTrackSprite(this);
	sprite_ManageInterior(this);
}

void onTick(CBlob@ this)
{
	const bool FLIP = this.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	if (this.getTickSinceCreated()<2)
	{
		this.getShape().SetOffset(Vec2f(-3*FLIP_FACTOR, 0));
	}
	
	CBlob@ plate1 = getBlobByNetworkID(this.get_u16("plate1_id"));
	if (plate1 is null) return;
	
	CBlob@ plate2 = getBlobByNetworkID(this.get_u16("plate2_id"));
	if (plate2 is null) return;
	
	plate2.setAngleDegrees(this.getAngleDegrees()-15*FLIP_FACTOR);
	plate1.setAngleDegrees(this.getAngleDegrees()-55*FLIP_FACTOR);
	
	//cannon.setVelocity(this.getVelocity());
	//cannon.setPosition(this.getPosition());
}

void onDie(CBlob@ this)
{
	CBlob@ turret = getBlobByNetworkID(this.get_u16("turret_id"));
	if (turret !is null)
		turret.server_Die();

	CBlob@ cannon = getBlobByNetworkID(this.get_u16("cannon_id"));
	if (cannon !is null)
		cannon.server_Die();	
	
	CBlob@ plate1 = getBlobByNetworkID(this.get_u16("plate1_id"));
	if (plate1 !is null)
		plate1.server_Die();	
	
	CBlob@ plate2 = getBlobByNetworkID(this.get_u16("plate2_id"));
	if (plate2 !is null)
		plate2.server_Die();
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	//return Vehicle_doesCollideWithBlob_ground( this, blob );
	//print("speed"+(this.getVelocity().Length()));
	bool player = blob.hasTag("player");
	bool fren = blob.getTeamNum() == this.getTeamNum();
	bool blob_above = blob.getPosition().y<this.getPosition().y&&player;
	
	return (
		(
		(!fren && this.getVelocity().Length() > 0.2 && player) ||
		//(blob.isKeyPressed(key_up)) ||
		(blob.hasTag("vehicle") && !fren) ||
		blob.hasTag("dead") ||
		blob.hasTag("door") ||
		blob.hasTag("scenary") ||
		blob.getName().find("tree")>-1 ||
		blob.getVelocity().y>1&&blob_above&&player
		)
		&&!lyingProne(blob)
		);
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
	if (blob !is null) {
		if (blob.getName()==getAmmoName(this) && !blob.isAttached() && !blob.isInInventory())
			this.server_PutInInventory(blob);
	}
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	if (attached.hasTag("player")) {
		if (attachedPoint.name != "GUNPOINT_GUNNER")
			attached.Tag("isInVehicle");
		attached.Tag("hidden_head");
		attached.Tag("vehicle_changes_facing");
	}
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{
	if (detached.hasTag("player")) {
		detached.Untag("isInVehicle");
		detached.Untag("hidden_head");
		detached.Untag("vehicle_changes_facing");
	}
}