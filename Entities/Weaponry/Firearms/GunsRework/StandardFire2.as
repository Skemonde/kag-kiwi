#include "BulletCase"
#include "MakeBangEffect"
#include "GunStandard"
#include "KIWI_Locales"
#include "FirearmVars"
#include "Hitters"
#include "SocialStatus"
#include "Help"
#include "Knocked"

const uint8 NO_AMMO_INTERVAL = 10;
u8 reloadCMD, setClipCMD;

bool canSendGunCommands(CBlob@ blob)
{
	if (blob is null) return false;
	CPlayer@ player = blob.getPlayer();
	if (player is null) return false;
	
	return (blob.isMyPlayer() || (isClient() && (player.isBot()||blob.hasTag("bot")))) && !isKnocked(blob);
}

void onInit(CBlob@ this) 
{
	FirearmVars@ vars;
	if (!this.get("firearm_vars", @vars)) return;
	
	this.Tag("firearm");
	this.Tag(vars.C_TAG);
	
	this.addCommandID("change_shotsintime");
	this.addCommandID("change_shotsintime_client");
	reloadCMD = this.addCommandID("reload");
	this.addCommandID("set_clip");
	
	this.addCommandID("sync_action_interval");
	this.addCommandID("sync_gun_state");
    
    this.addCommandID("toggle_shooting");
    this.addCommandID("change_firemode");
    this.addCommandID("change_altfire");
    this.addCommandID("change_shotsintime");
    this.addCommandID("make_emtpy_case");
    this.addCommandID("start_reload");
    this.addCommandID("start_reload_client");
    this.addCommandID("cancel_reload");
    this.addCommandID("make_slash");
    this.addCommandID("create_laser_light");
	
	//this.getShape().getConsts().net_threshold_multiplier = 0.3f;
	this.RemoveScript("IgnoreDamage.as");
	this.Untag("invincible");
	this.server_SetHealth(15);
	if (this.hasTag("basic_gun"))
		this.AddScript("Wooden.as");
	else if (this.hasTag("advanced_gun"))
		this.AddScript("SteelHit.as");
	this.AddScript("DamageProcessing.as");
	
	this.set_u8("clip", 0);
	
	if (this.getAttachments().getAttachmentPointByName("ADDON") !is null) {
		CBlob@ blob = server_CreateBlobNoInit("pointer");
		if (blob !is null)
		{
			blob.server_setTeamNum(this.getTeamNum());
			//blob.setInventoryName(this.getInventoryName() + "'s Turret");
			//blob.getSprite().SetRelativeZ(40);
			this.set_u16("pointer_id", blob.getNetworkID());
			blob.set_u16("gun_id", this.getNetworkID());
			blob.set_f32("range", vars.RANGE);
			blob.Init();
			this.server_AttachTo(blob, "ADDON");
			this.getShape().getConsts().mapCollisions = true;
			//blob.getShape().getConsts().collideWhenAttached = true;
		}
	}
	
	if (this.getAttachments().getAttachmentPointByName("ADDON_UNDER_BARREL") !is null) {
		CBlob@ blob = server_CreateBlobNoInit("underbarrelnader");
		if (blob !is null)
		{
			blob.server_setTeamNum(this.getTeamNum());
			//blob.setInventoryName(this.getInventoryName() + "'s Turret");
			//blob.getSprite().SetRelativeZ(40);
			this.set_u16("underbarrel_id", blob.getNetworkID());
			blob.set_u16("gun_id", this.getNetworkID());
			blob.Init();
			this.server_AttachTo(blob, "ADDON_UNDER_BARREL");
			this.getShape().getConsts().mapCollisions = true;
			//blob.getShape().getConsts().collideWhenAttached = true;
		}
	}
	
	if (this.getAttachments().getAttachmentPointByName("ADDON_UNDER_BARREL_2") !is null && this.get_u8("gun idx") < 100) {
		CBlob@ blob = server_CreateBlobNoInit("atr2");
		if (blob !is null)
		{
			blob.server_setTeamNum(this.getTeamNum());
			//blob.setInventoryName(this.getInventoryName() + "'s Turret");
			//blob.getSprite().SetRelativeZ(40);
			this.set_u16("underbarrel_id", blob.getNetworkID());
			blob.set_u16("gun_id", this.getNetworkID());
			blob.set_u16("owner_gun_id", this.getNetworkID());
			if (this.exists("gun_id"))
				blob.set_u16("gun_id", this.get_u16("gun_id"));
			blob.Init();
			blob.set_u8("gun idx", this.get_u8("gun idx"));
			this.server_AttachTo(blob, "ADDON_UNDER_BARREL_2");
			this.getShape().getConsts().mapCollisions = true;
			//blob.getShape().getConsts().collideWhenAttached = true;
		}
	}
}

void onThisAddToInventory( CBlob@ this, CBlob@ inventoryBlob )
{
	if (this.exists("pointer_id")) {
		CBlob@ underbarrel_thing = getBlobByNetworkID(this.get_u16("pointer_id"));
		if (underbarrel_thing !is null) {
			underbarrel_thing.getShape().SetGravityScale(0);
			underbarrel_thing.setPosition(Vec2f(0, -400));
			underbarrel_thing.getShape().getConsts().collidable = false;
			underbarrel_thing.getSprite().getConsts().accurateLighting = false;
		}
	}
	if (this.exists("underbarrel_id")) {
		CBlob@ underbarrel_thing = getBlobByNetworkID(this.get_u16("underbarrel_id"));
		if (underbarrel_thing !is null) {
			underbarrel_thing.getShape().SetGravityScale(0);
			underbarrel_thing.setPosition(Vec2f(0, -400));
			underbarrel_thing.getShape().getConsts().collidable = false;
			underbarrel_thing.getSprite().getConsts().accurateLighting = false;
		}
	}
}

void onThisRemoveFromInventory( CBlob@ this, CBlob@ inventoryBlob )
{	
	if (this.exists("pointer_id")) {
		CBlob@ underbarrel_thing = getBlobByNetworkID(this.get_u16("pointer_id"));
		if (underbarrel_thing !is null) {
			this.server_AttachTo(underbarrel_thing, "ADDON");
			underbarrel_thing.getShape().SetGravityScale(1);
			this.getShape().getConsts().mapCollisions = true;
			underbarrel_thing.getShape().getConsts().collidable = true;
			underbarrel_thing.getSprite().getConsts().accurateLighting = true;
		}
	}
	if (this.exists("underbarrel_id")) {
		CBlob@ underbarrel_thing = getBlobByNetworkID(this.get_u16("underbarrel_id"));
		if (underbarrel_thing !is null) {
			this.server_AttachTo(underbarrel_thing, "ADDON_UNDER_BARREL");
			underbarrel_thing.getShape().SetGravityScale(1);
			this.getShape().getConsts().mapCollisions = true;
			underbarrel_thing.getShape().getConsts().collidable = true;
			underbarrel_thing.getSprite().getConsts().accurateLighting = true;
		}
	}
}

void onDie(CBlob@ this)
{
	if (this.exists("pointer_id")) {
		CBlob@ underbarrel_thing = getBlobByNetworkID(this.get_u16("pointer_id"));
		if (underbarrel_thing !is null) {
			underbarrel_thing.server_Die();
		}
	}
	if (this.exists("underbarrel_id")) {
		CBlob@ underbarrel_thing = getBlobByNetworkID(this.get_u16("underbarrel_id"));
		if (underbarrel_thing !is null) {
			underbarrel_thing.server_Die();
		}
	}
}

void WriteLastMenusTime(CBlob@ this)
{
	if (getHUD().hasButtons()||getRules().get_bool("show_gamehelp"))
		this.set_u32("last_menus_time", getGameTime());
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	AttachmentPoint@ point = blob.getAttachments().getAttachmentPointByName("PICKUP");
	CBlob@ holder = point.getOccupied();
	@holder = getHolder(blob, holder);
}

CBlob@ getHolder(CBlob@ this, CBlob@ holder)
{
	//print("was called");
	if (true) {
		//print("holder is null");
		CBlob@ tripod = getBlobByNetworkID(this.get_u16("tripod_id"));
		if (tripod !is null) {
			//print("tripod is ok");
			CBlob@ gunner = getBlobByNetworkID(tripod.get_u16("gunner_id"));
			if (gunner !is null && gunner.isAttachedTo(tripod) && this.isAttachedTo(tripod)) {
				
				return gunner;
				//print("gunner is ok");
			}
		} //else print("tripod is NOT ok");
		//print("gothere1");
		if (holder !is null && holder.getPlayer() is null) {
			//print("gothere2");
			//print("tripod id"+this.get_u16("tripod_id"));
			if (tripod !is null) {
				//print("tripod isn't null!");
				AttachmentPoint@ gunner_seat = tripod.getAttachments().getAttachmentPointByName("MACHINEGUNNER");
				if (gunner_seat !is null) {
					//print("gunner_seat isn't null!");
					@holder = gunner_seat.getOccupied();
					if (holder !is null) {
						//print("holder "+holder.getName());
						return holder;
					}
				}
			}
		}
		return holder;
	}
	return null;
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
	
	f32 angle = -aimvector.Angle()+ANGLE_FLIP_FACTOR;
	//angle = Maths::Round(angle);
	HitInfo@[] hitInfos;
	//bool blobHit = getMap().getHitInfosFromRay(start_pos, -aimvector.Angle(), carried.getWidth()*2, holder, @hitInfos);
	//print("angle "+angle);
	
	return angle;
}

void ManageAddons(CBlob@ this, f32 angle = -800)
{	
	const bool FLIP = this.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	for (int idx = 0; idx < this.getAttachmentPointCount(); ++idx)
	{
		AttachmentPoint@ c_ap = this.getAttachmentPoint(idx);
		if (c_ap.name.find("ADDON")<0) continue;
		CBlob@ attached = c_ap.getOccupied();
		if (attached is null) continue;
		
		AttachmentPoint@ pickup_point = attached.getAttachments().getAttachmentPointByName("PICKUP");
		bool has_human_attached = pickup_point.getOccupied() !is null || !attached.exists("gun_id");
		if (has_human_attached) continue;
		
		//using -800 because aim angles are clamped between -720 and 720
		//so you can't get -800 naturally
		attached.setAngleDegrees(angle==-800?this.getAngleDegrees():angle);
		attached.SetFacingLeft(this.isFacingLeft());
	}
}

void ManageShotsInTime(CBlob@ this, CBlob@ holder)
{
	if (!holder.isMyPlayer()) return;
	if (this.get_s32("shots_in_time") < 1 ) return;
	if (!this.isAttached()) return;
	FirearmVars@ vars;
	if (!this.get("firearm_vars", @vars)) return;
	if ((getGameTime()-this.get_u32("last_shot_time"))<(vars.FIRE_INTERVAL+10)) return;
	
	CBitStream shots;
	shots.Clear();
	shots.write_s32(-(getGameTime()-this.get_u32("last_shot_time")));
	this.SendCommand(this.getCommandID("change_shotsintime"), shots);
}

void ReadReloadAction(CBlob@ this, CBlob@ holder)
{
	CControls@ controls = holder.getControls();
	if (controls is null) return;
	
	if (this.exists("gun_id")) return;
	
	FirearmVars@ vars;
	if (!this.get("firearm_vars", @vars)) return;
	
	CSprite@ sprite = this.getSprite();
	
	u8 clip = this.get_u8("clip");
	
	bool reload_interval_passed = (getGameTime()-this.get_u32("reload_start_time"))>vars.RELOAD_TIME;
	bool fire_interval_passed = (getGameTime()-this.get_u32("last_shot_time"))>vars.FIRE_INTERVAL;
	
	if(this.get_bool("doReload")&&reload_interval_passed) 
    {
        bool finishedReloading = true;
        bool special_reload = vars.RELOAD_HANDFED_ROUNDS == vars.CLIP;
        
        if(vars.RELOAD_HANDFED_ROUNDS > 0){
            if(canReload(this,holder)){
                if(canSendGunCommands(holder)){
                    reload(this, holder);
                    
					if (!special_reload)
						startReload(this,(clip<1?1.15f:1)*vars.RELOAD_TIME);
                }
                
                finishedReloading = false;
            }
        } else {
            if(canSendGunCommands(holder))reload(this, holder);
        }
        
        if (finishedReloading) {
            if (isClient()) {
                if (vars.RELOAD_SOUND != "")
					//PlayDistancedSound(vars.RELOAD_SOUND, 1.0f, 1.0f, this.getPosition(), 0, 0, 0);
					sprite.PlaySound(vars.RELOAD_SOUND,1.0f,float(100*vars.RELOAD_PITCH-pitch_range+XORRandom(pitch_range*2))*0.01f);
                this.set_u8("clickReload", 0);
            }
            this.set_bool("doReload", false);
        }
		return;
    }
	
	if (!reload_interval_passed)
	{
		sprite.SetAnimation("reload");
		Animation@ r_anim = sprite.getAnimation("reload");
		if (r_anim !is null)
			r_anim.time = vars.RELOAD_TIME/r_anim.getFramesCount();
		return;
	}
	if (!fire_interval_passed) return;
	
	bool clip_empty = clip<1;
	bool reload_on_empty_map = (clip_empty && (vars.FIRE_AUTOMATIC && holder.isKeyPressed(key_action1)) && (this.get_u8("clickReload")>=3||vars.FIRE_INTERVAL>2&&this.get_u8("clickReload")>=1));
	
	if (!(controls.isKeyJustPressed(KEY_KEY_R)||reload_on_empty_map)) return;
	
	bool should_reload = clip < vars.CLIP;
	
	if (canReload(this,holder)) {
        startReload(this,vars.RELOAD_TIME);
    } else if (controls.isKeyJustPressed(KEY_KEY_R) && should_reload){
		sprite.PlaySound("NoAmmo",1.0f,float(100*vars.FIRE_PITCH-pitch_range+XORRandom(pitch_range*2))*0.01f);
		if (!v_fastrender)
			MakeBangEffect(this, "ammo");
    }
}

void ReadShootAction(CBlob@ this, CBlob@ holder, f32 fire_interval, f32 GUN_ANGLE, bool can_shoot_next_round)
{
	FirearmVars@ vars;
	if (!this.get("firearm_vars", @vars)) return;
	
	const bool FLIP = this.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	CSprite@ sprite = this.getSprite();
	
	CSpriteLayer@ muzzle_flash = sprite.getSpriteLayer("muzzle_flash");
	if (muzzle_flash is null && !vars.FLASH_SPRITE.empty()) @muzzle_flash = getMuzzleFlashSprite(sprite);
	
	bool burst_firing = vars.BURST > 1;
	
	bool bursting = this.get_u8("rounds_left_in_burst") > 0;
	
	bool main_gun = !this.exists("gun_id");
	
	bool using_lmb_semiauto = holder.isKeyJustPressed(key_action1);
	
	bool using_lmb_auto = vars.FIRE_AUTOMATIC && holder.isKeyPressed(key_action1);
	
	bool using_rmb_semiauto = holder.isKeyJustPressed(key_action2);
	
	bool using_rmb_auto = vars.FIRE_AUTOMATIC && holder.isKeyPressed(key_action2);
	
	bool lmb_activation = main_gun&&(using_lmb_semiauto||using_lmb_auto);
	
	bool rmb_activation = !main_gun&&(using_rmb_semiauto||using_rmb_auto);
	
	CBlob@ storage_blob = getBlobByNetworkID(this.get_u16("storage_id"));
	bool takes_blob_directly = !main_gun;
	bool can_take_blob = takes_blob_directly&&((storage_blob !is null && storage_blob.getInventory() !is null && storage_blob.getInventory().getItem(vars.AMMO_TYPE[0]) !is null)||(holder.getInventory() !is null && holder.getInventory().getItem(vars.AMMO_TYPE[0]) !is null));
	
	bool ammo_cheating_xd = !getRules().get_bool("ammo_usage_enabled");
	bool enough_ammo = this.get_u8("clip")>0||can_take_blob||ammo_cheating_xd;
	
	bool reload_interval_passed = (getGameTime()-this.get_u32("reload_start_time"))>vars.RELOAD_TIME+5; //adding 5 ticks so we cannot shoot RIGHT after reloading
	bool should_change_fire_animation = (getGameTime()-this.get_u32("last_shot_time"))>=1;
	
	if (reload_interval_passed&&should_change_fire_animation)
		sprite.SetAnimation("wield");
	
	if ((lmb_activation||rmb_activation||bursting)&&!enough_ammo&&can_shoot_next_round&&reload_interval_passed) {
		f32 default_pitch = 110;
		default_pitch -= (vars.B_DAMAGE);
		default_pitch = Maths::Max(30, default_pitch);
		sprite.PlaySound("DryShot.ogg",1.0f,float(default_pitch-pitch_range+XORRandom(pitch_range*2))*0.01f);
		MakeBangEffect(this, "click");
		this.add_u8("clickReload", 1);
		this.set_u32("last_shot_time", getGameTime());
		if (bursting)
			this.sub_u8("rounds_left_in_burst", 1);
	}
	
	if ((lmb_activation||rmb_activation||bursting)&&can_shoot_next_round&&enough_ammo&&reload_interval_passed) {
		f32 SHOT_ANGLE = GUN_ANGLE/* -(NEW_GUN_ANGLE-GUN_ANGLE)*FLIP_FACTOR */;
		Vec2f muzzle_offset = Vec2f(0, vars.MUZZLE_OFFSET.y).RotateBy(SHOT_ANGLE)-Vec2f(this.getWidth()/2*FLIP_FACTOR, 0).RotateBy(SHOT_ANGLE);
		if (canSendGunCommands(holder))
			shootGun(this.getNetworkID(), SHOT_ANGLE, holder.getNetworkID(), this.getPosition()+muzzle_offset+holder.getVelocity());
		if (muzzle_flash !is null) {
			muzzle_flash.SetFrameIndex(0);
			
			Vec2f ray_hitpos;
			Vec2f muzzle_world = this.getPosition()+Vec2f((-16-muzzle_flash.getOffset().x)*FLIP_FACTOR, muzzle_flash.getOffset().y).RotateBy(SHOT_ANGLE);
			bool muzzle_blocked = getMap().rayCastSolid(this.getPosition(), muzzle_world, ray_hitpos);
			muzzle_flash.SetVisible(!muzzle_blocked);
		}
		this.set_u32("last_shot_time", getGameTime());
		sprite.SetAnimation("fire");
		
		if (burst_firing)
		{
			if (!bursting)
				this.set_u8("rounds_left_in_burst", vars.BURST-1); //minus 1 since one shot is already made
			else
				this.sub_u8("rounds_left_in_burst", 1);
		}
		CBitStream shots;
		shots.Clear();
		shots.write_s32(7);
		this.SendCommand(this.getCommandID("change_shotsintime"), shots);
	}
}

void onTick(CBlob@ this) 
{	
	WriteLastMenusTime(this);
	
	const bool FLIP = this.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	FirearmVars@ vars;
	if (!this.get("firearm_vars", @vars)) return;
	AttachmentPoint@ pickup_point = this.getAttachments().getAttachmentPointByName("PICKUP");
	
	if (pickup_point is null) {
		error("Pickup point is null in a firearm!");
		return;
	}
	
	CSprite@ sprite = this.getSprite();
	CBlob@ holder = pickup_point.getOccupied();
	if (holder !is null) {
		this.getShape().getConsts().net_threshold_multiplier = 0.2f;
	} else
		this.getShape().getConsts().net_threshold_multiplier = 1.0f;
	
	CSpriteLayer@ right_arm = this.getSprite().getSpriteLayer("right_arm");
	if (right_arm is null) @right_arm = getRightArmSprite(this.getSprite());
	
	CSpriteLayer@ left_arm = this.getSprite().getSpriteLayer("left_arm");
	if (left_arm is null) @left_arm = getLeftArmSprite(this.getSprite());
	
	CSpriteLayer@ left_hand = this.getSprite().getSpriteLayer("left_hand");
	if (left_hand is null) @left_hand = getLeftHandSprite(this.getSprite());
	
	CSpriteLayer@ muzzle_flash = this.getSprite().getSpriteLayer("muzzle_flash");
	if (muzzle_flash is null && !vars.FLASH_SPRITE.empty()) @muzzle_flash = getMuzzleFlashSprite(this.getSprite());
	
	f32 flash_orig_dim = 32;
	f32 flash_scale = 1.4f;
	f32 flash_dim = flash_orig_dim*flash_scale;
	
	if (muzzle_flash !is null) {
		muzzle_flash.ResetTransform();
		//muzzle_flash.SetFrameIndex(2);
		muzzle_flash.ScaleBy(flash_scale, flash_scale);
		muzzle_flash.SetOffset(Vec2f(vars.MUZZLE_OFFSET.x-(flash_orig_dim*(flash_scale-1.0)/2), vars.MUZZLE_OFFSET.y));
		
	}
	
	right_arm.ResetTransform();
	right_arm.SetVisible(holder !is null);
	left_arm.SetVisible(false);
	left_hand.SetVisible(holder !is null);
	
	if (this.exists("gun_id"))
	{
		CBlob@ main_gun = getBlobByNetworkID(this.get_u16("gun_id"));
		if (main_gun !is null && main_gun.isAttachedTo(this))
		{
			AttachmentPoint@ main_gun_pickup_ap = main_gun.getAttachments().getAttachmentPointByName("PICKUP");
			if (main_gun_pickup_ap.getOccupied() !is null)
			{
				//print("hey "+this.getName());
				@holder = main_gun_pickup_ap.getOccupied();
			}
		}
		else
		{
			this.clear("gun_id");
		}
	}
	
	if (holder is null)
	{
		ManageAddons(this);
		return;
	}
	//from this point we are sure holder is not null
	
	ManageShotsInTime(this, holder);
	ReadReloadAction(this, holder);
	const f32 GUN_ANGLE = getGunAngle(holder);
	
	Vec2f left_hand_offset = Vec2f(-11, 0)+vars.SPRITE_TRANSLATION-Vec2f(this.getWidth()/10, this.getHeight()/6);
	Vec2f left_hand_world = this.getPosition()+Vec2f(6*FLIP_FACTOR, 2).RotateBy(GUN_ANGLE);
	Vec2f holder_left_shoulder = holder.getPosition() - holder.getOldVelocity();
	f32 left_hand_angle = -(-holder_left_shoulder+left_hand_world).Angle()+ANGLE_FLIP_FACTOR;
	
	left_hand.SetOffset(left_hand_offset);
	left_arm.SetOffset(left_hand_offset);
	left_arm.ResetTransform();
	left_arm.SetRelativeZ(-40);
	left_arm.RotateBy(left_hand_angle-this.getAngleDegrees(), Vec2f());
	left_hand.SetVisible(false);
	
	Vec2f trans_from_holder = this.get_Vec2f("gun_trans_from_carrier").RotateBy(0);
	Vec2f shoulder_joint = Vec2f(3, 0).RotateBy(0);
	shoulder_joint += Vec2f(trans_from_holder.x, -trans_from_holder.y);
	
	bool player_crouching = gunCrouching(holder);
	bool proning = player_crouching && (holder.isKeyPressed(key_left) || holder.isKeyPressed(key_right));
	
	if(vars.TRENCH_AIM==1 || player_crouching && !proning){
		// "aiming" style wield
		this.Tag("trench_aim");
		right_arm.SetAnimation("aim");
    } else {
		// normal wield
		this.Untag("trench_aim");
		right_arm.SetAnimation("default");
    }
	
	Vec2f gun_offset = (this.hasTag("trench_aim") ? Vec2f(-trench_aim.x, -trench_aim.y) : Vec2f_zero)-vars.SPRITE_TRANSLATION+Vec2f(trans_from_holder.x, -trans_from_holder.y);
	right_arm.SetOffset(Vec2f(-2-gun_offset.x, gun_offset.y)+trans_from_holder);
	
	bool burst_firing = vars.BURST > 1;
	
	bool bursting = this.get_u8("rounds_left_in_burst") > 0;
	
	bool localhost = isServer()&&isClient();
	
	bool should_use_burst_interval = burst_firing && (bursting || this.get_u8("rounds_left_in_burst") == 0 && (getGameTime()-this.get_u32("last_shot_time"))>0);
	
	f32 kick_interval = Maths::Max(1, 1.0f*(should_use_burst_interval?vars.BURST_INTERVAL:vars.FIRE_INTERVAL)-(localhost?0:1));
	f32 fire_interval = Maths::Max(0, 1.0f*(bursting?vars.BURST_INTERVAL:vars.FIRE_INTERVAL)-(localhost?0:1));
	
	u32 time_from_last_shot = getGameTime()-this.get_u32("last_shot_time");
	f32 kickback_value = Maths::Clamp(1.0f*kick_interval+1, 1, 10);
	
	bool do_recoil = time_from_last_shot<=kickback_value&&!this.exists("gun_id");
	//do_recoil = false;
	
	f32 kickback_angle = (Maths::Tan(50)*(64-this.getSprite().getFrameWidth()))*-1;
	kickback_angle *= 1.0f*(kickback_value-time_from_last_shot)/kickback_value;
	Vec2f kickback_offset = Vec2f(5, 0);
	kickback_offset.x *= 1.0f*(kickback_value-time_from_last_shot)/kickback_value;
	if (do_recoil) {
		gun_offset += kickback_offset;
		right_arm.SetOffset(right_arm.getOffset()-kickback_offset);
	}
	
	bool reload_interval_passed = (getGameTime()-this.get_u32("reload_start_time"))>vars.RELOAD_TIME;
	
	f32 NEW_GUN_ANGLE = !reload_interval_passed ? (FLIP ? 0-vars.RELOAD_ANGLE : 0+vars.RELOAD_ANGLE) : GUN_ANGLE;
	NEW_GUN_ANGLE = do_recoil&&false ? (NEW_GUN_ANGLE-kickback_angle*FLIP_FACTOR) : NEW_GUN_ANGLE;
	
	bool menu_free = (getGameTime()-this.get_u32("last_menus_time"))>5;

	bool can_shoot_next_round = (getGameTime()-this.get_u32("last_shot_time"))>fire_interval&&menu_free;
	
	if (!can_shoot_next_round && muzzle_flash !is null && do_recoil) {
		//disabled so far
		muzzle_flash.RotateBy(-(NEW_GUN_ANGLE-GUN_ANGLE), Vec2f(-muzzle_flash.getOffset().x*FLIP_FACTOR, -muzzle_flash.getOffset().y));
		muzzle_flash.SetOffset(muzzle_flash.getOffset()+Vec2f(-kickback_offset.x/2, kickback_offset.y));
	}
	
	//only rotate if it's a main gun and not attached to another gun
	if (!this.exists("gun_id")) {
		ManageAddons(this, NEW_GUN_ANGLE);
		
		this.setAngleDegrees(NEW_GUN_ANGLE);
		
		AttachmentPoint@ holder_pickup_ap = holder.getAttachments().getAttachmentPointByName("PICKUP");
		
		holder_pickup_ap.occupied_offset = gun_offset.RotateBy((NEW_GUN_ANGLE-holder.getAngleDegrees())*FLIP_FACTOR, shoulder_joint);
	}
	
	ReadShootAction(this, holder, fire_interval, NEW_GUN_ANGLE, can_shoot_next_round);
}

CSpriteLayer@ getMuzzleFlashSprite (CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return null;
	
	FirearmVars@ vars;
	if (!blob.get("firearm_vars", @vars)) return null;
	
	string sprite_layer_name = "muzzle_flash";
	this.RemoveSpriteLayer(sprite_layer_name);
	
	string file_name;
	if (vars.FLASH_SPRITE=="from_bullet")
		file_name = "flash_"+vars.BULLET_SPRITE;
	else if (!vars.FLASH_SPRITE.empty())
		file_name = vars.FLASH_SPRITE;
	else return null;
	
	CSpriteLayer@ flash = this.addSpriteLayer(sprite_layer_name, file_name, 32, 32, blob.getTeamNum(), 0);
	
	if (flash !is null)
	{
		Animation@ anim = flash.addAnimation("default", 1, false);
		int[] frames = {0, 1, 2, 3, 4, 5, 6, 7};
		anim.AddFrames(frames);
		flash.SetRelativeZ(600.0f);
		// for bazookas we want to have fancy flash from their back end
		//flash.SetFacingLeft(false);
		//flash.setRenderStyle(RenderStyle::additive);
		flash.SetVisible(false);
	}
	
	return flash;
}

CSpriteLayer@ getRightArmSprite (CSprite@ this)
{
	string sprite_layer_name = "right_arm";
	this.RemoveSpriteLayer(sprite_layer_name);
	CSpriteLayer@ right_arm = this.addSpriteLayer(sprite_layer_name, "right_arm.png", 16, 16, this.getBlob().getTeamNum(), 0);
	
	Animation@ anim = right_arm.addAnimation("default", 1, false);
	anim.AddFrame(0);
	Animation@ aim_anim = right_arm.addAnimation("aim", 1, false);
	aim_anim.AddFrame(1);
	right_arm.SetRelativeZ(50.0f);
	right_arm.SetOffset(Vec2f(3, -2));
	right_arm.SetVisible(false);
	
	return right_arm;
}

CSpriteLayer@ getLeftArmSprite (CSprite@ this)
{
	string sprite_layer_name = "left_arm";
	this.RemoveSpriteLayer(sprite_layer_name);
	CSpriteLayer@ left_arm = this.addSpriteLayer(sprite_layer_name, "left_arm.png", 32, 16, this.getBlob().getTeamNum(), 0);
	
	left_arm.SetRelativeZ(50.0f);
	
	return left_arm;
}

CSpriteLayer@ getLeftHandSprite (CSprite@ this)
{
	string sprite_layer_name = "left_hand";
	this.RemoveSpriteLayer(sprite_layer_name);
	CSpriteLayer@ left_hand = this.addSpriteLayer(sprite_layer_name, "left_hand.png", 16, 16, this.getBlob().getTeamNum(), 0);
	
	left_hand.SetRelativeZ(50.0f);
	
	return left_hand;
}

void onRender(CSprite@ this)
{
	return;
	const f32 SCALEX = getDriver().getResolutionScaleFactor();
	const f32 ZOOM = getCamera().targetDistance * SCALEX;
	
	FirearmVars@ vars;
	this.getBlob().get("firearm_vars", @vars);
}