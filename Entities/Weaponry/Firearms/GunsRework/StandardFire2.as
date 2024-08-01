#include "BulletCase"
#include "MakeBangEffect"
#include "GunStandard"
#include "KIWI_Locales"
#include "FirearmVars"
#include "Hitters"
#include "SocialStatus"
#include "Help"
#include "Knocked"
#include "Skemlib"

const uint8 NO_AMMO_INTERVAL = 10;
u8 reloadCMD, setClipCMD;

bool canSendGunCommands(CBlob@ blob)
{
	if (blob is null) return false;
	CPlayer@ player = blob.getPlayer();
	if (player is null) return false;
	
	return (blob.isMyPlayer() || (isClient() && (player.isBot()||blob.hasTag("bot")))) && !isKnocked(blob);
}

bool isSubGun(CBlob@ this)
{
	if (!this.exists("gun_id")) return false;
	
	if (this.get_u16("gun_id")!=0) return true;
	
	return false;
	//return !this.exists("gun_id")||this.get_u16("gun_idx")==0;
}

bool isStationaryGun(CBlob@ this)
{
	if (!this.exists("turret_id")) return false;
	
	if (this.get_u16("turret_id")!=0) return true;
	
	return false;
	//return !this.exists("gun_id")||this.get_u16("gun_idx")==0;
}

void onInit(CBlob@ this) 
{	
	FirearmVars@ vars;
	if (!this.get("firearm_vars", @vars)) return;
	
	this.Tag("no throw via action3");
	this.Tag("firearm");
	this.Tag(vars.C_TAG);
	this.Tag("ejected_case");
	this.Tag("burst_finished");
	this.Tag("detach on seat in vehicle");
	
	this.addCommandID("change_shotsintime");
	this.addCommandID("change_shotsintime_client");
	reloadCMD = this.addCommandID("reload");
	this.addCommandID("set_clip");
	this.addCommandID("set_clip_client");
	
	this.addCommandID("sync_action_interval");
	this.addCommandID("sync_gun_state");
    
    this.addCommandID("toggle_shooting");
    this.addCommandID("change_firemode");
    this.addCommandID("change_altfire");
    this.addCommandID("change_shotsintime");
    this.addCommandID("change_roundsinburst");
    this.addCommandID("make_emtpy_case");
    this.addCommandID("start_reload");
    this.addCommandID("start_reload_client");
    this.addCommandID("cancel_reload");
    this.addCommandID("make_slash");
    this.addCommandID("create_laser_light");
    this.addCommandID("make_hit_particle");
	
	//this.getShape().getConsts().net_threshold_multiplier = 0.3f;
	//this.RemoveScript("IgnoreDamage.as");
	//this.Untag("invincible");
	this.server_SetHealth(15);
	if (this.hasTag("basic_gun"))
		this.AddScript("Wooden.as");
	else if (this.hasTag("advanced_gun"))
		this.AddScript("SteelHit.as");
	this.AddScript("DamageProcessing.as");
	
	this.set_u16("action_interval", 0);
	this.set_u8("clip", vars.CLIP);
	this.set_bool("diff_left", true);
	this.set_f32("diff_angle", 15);
	
	this.getShape().getConsts().net_threshold_multiplier = 0.2f;
	
	if (this.getAttachments().getAttachmentPointByName("ADDON") !is null) {
		string addon_name = "";
		if (this.getName()=="sniperrifle"||this.getName()=="assaultrifle")
			addon_name = "pointer";
			
		if (!addon_name.empty())
		{
			CBlob@ blob = server_CreateBlobNoInit(addon_name);
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
	}
	
	if (this.getAttachments().getAttachmentPointByName("ADDON_UNDER_BARREL") !is null) {
		string addon_name = "";
		if (this.getName()=="semiautorifle")
			addon_name = "bayonet";
		else if (this.getName()=="assaultrifle")
			addon_name = "underbarrelnader";
		
		if (!addon_name.empty())
		{
			CBlob@ blob = server_CreateBlobNoInit(addon_name);
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
				blob.AddScript("IgnoreDamage.as");
				//blob.getShape().getConsts().collideWhenAttached = true;
			}
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
	AttachmentPoint@ pickup_point = this.getAttachments().getAttachmentPointByName("PICKUP");
	CBlob@ holder = pickup_point.getOccupied();
	CBlob@ n_holder = getSoldatControllerBlob(this);
	if (n_holder !is null)
		@holder = n_holder;
		
	if (holder is null)
		@holder = this;
	
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

f32 getGunAngle(CBlob@ holder, CBlob@ gun = null)
{
	if (holder is null) return 0;
	
	bool FLIP = holder.isFacingLeft();;
	f32 FLIP_FACTOR = FLIP ? -1 : 1;
	u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	//trying to get a blob handle from carried if no blob handle were given via params
	if (gun is null)
	{
		CBlob@ carried = holder.getCarriedBlob();
		if (carried is null) return 0;
		
		@gun = carried;
	}
	
	FirearmVars@ vars;
	if (!gun.get("firearm_vars", @vars)) return 0;
	
	Vec2f end_pos = holder.getAimPos();
	//f32 raw_angle = -(end_pos - carried.getPosition()+Vec2f(100*FLIP_FACTOR,0).RotateBy(carried.get_f32("GUN_ANGLE"))).Angle()+ANGLE_FLIP_FACTOR;
	Vec2f muzzle_offset = (Vec2f(-20*FLIP_FACTOR, 0)+Vec2f(vars.MUZZLE_OFFSET.x*FLIP_FACTOR, vars.MUZZLE_OFFSET.y)).RotateBy(gun.get_f32("prev_angle"));
	Vec2f start_pos = gun.getPosition()+muzzle_offset;
	
	Vec2f aimvector = end_pos - start_pos;
	
	f32 holder_angle = constrainAngle(holder.getAngleDegrees());
	
	f32 angle = constrainAngle(-aimvector.Angle()+ANGLE_FLIP_FACTOR);
	
	HitInfo@[] hitInfos;
	bool blobHit = getMap().getHitInfosFromRay(start_pos, -aimvector.Angle(), gun.getWidth()*2, holder, @hitInfos);
	
	if (isStationaryGun(gun))
	{
		f32 upper_line = 15;
		f32 lower_line = -20;
		angle = Maths::Clamp(angle, (FLIP?lower_line:-upper_line)+holder_angle, (FLIP?upper_line:-lower_line)+holder_angle);
		gun.set_f32("diff_angle", angle-holder.getAngleDegrees());
		gun.set_bool("diff_left", holder.isFacingLeft());
	}
	bool proning = lyingProne(holder);
	
	if (proning&&false)
	{
		f32 upper_line = 30;
		f32 lower_line = -60;
		angle = Maths::Clamp(angle, (FLIP?lower_line:-upper_line)+holder_angle, (FLIP?upper_line:-lower_line)+holder_angle);
	}
	
	//print("angle "+angle);
	
	gun.set_f32("prev_angle", angle);
	
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
		bool has_human_attached = pickup_point.getOccupied() !is null || !isSubGun(attached);
		if (has_human_attached) continue;
		
		//using -800 because aim angles are clamped between -720 and 720
		//so you can't get -800 naturally
		attached.setAngleDegrees(angle==-800?this.getAngleDegrees():angle);
		attached.SetFacingLeft(this.isFacingLeft());
		attached.getShape().getConsts().net_threshold_multiplier = 0.3f;
	}
}

void ManageShotsInTime(CBlob@ this, CBlob@ holder)
{
	if (this.get_s32("shots_in_time") < 1 ) return;
	if (!this.isAttached()) return;
	FirearmVars@ vars;
	if (!this.get("firearm_vars", @vars)) return;
	
	if (!this.hasTag("burst_finished")&&((getGameTime()-this.get_u32("last_shot_time"))>(vars.FIRE_INTERVAL)))
	{
		if (this.hasTag("charging")&&isClient())
		{
			this.getSprite().PlaySound("Coilgun_Spindown.ogg", 1, vars.CYCLE_PITCH);
		}
		this.Tag("burst_finished");
		
		if (vars.COOLING_INTERVAL==0) {
			this.set_s32("shots_in_time", 0);
			//this.Sync("shots_in_time", true);
			
			if (isServer())
			{
				CBitStream shots;
				shots.write_s32(-99999);
				this.SendCommand(this.getCommandID("change_shotsintime_client"), shots);
			}
		}
		//SetWieldAnimation(this, holder);
		return;
	}
	
	if ((getGameTime()-this.get_u32("last_shot_time"))<(vars.FIRE_INTERVAL+10)) return;
	
	//SetWieldAnimation(this, holder);
	
	if (holder is null || holder !is null && !holder.isMyPlayer()) return;
	CBitStream shots;
	shots.Clear();
	shots.write_s32(-(getGameTime()-this.get_u32("last_shot_time")));
	this.SendCommand(this.getCommandID("change_shotsintime"), shots);
}

void ManageInterval(CBlob@ this)
{
	u16 interval = this.get_u16("action_interval");
	
	if (interval>0)
	{
		this.sub_u16("action_interval", 1);
	}
}

void ManageLoopedSound(CBlob@ this)
{
	if (!this.hasTag("looped_sound")) return;
	if (!isClient()) return;
	
	FirearmVars@ vars;
	if (!this.get("firearm_vars", @vars)) return;
	CSprite@ sprite = this.getSprite();
	
	bool shooting = (getGameTime()-this.get_u32("last_shot_time"))>vars.FIRE_INTERVAL;
	
	bool sub_gun = isSubGun(this);
	
	bool stationary_gun = isStationaryGun(this);
	
	bool enough_ammo = (this.get_u8("clip"))>0;
	
	bool ammo_cheating_xd = !getRules().get_bool("ammo_usage_enabled");
	
	if (isStationaryGun(this))
	{
		CBlob@ storage_blob = getBlobByNetworkID(this.get_u16("storage_id"));
		
		bool ammo_in_inventory = false;
		if (storage_blob !is null && storage_blob.getInventory() !is null && storage_blob.getInventory().getItem(vars.AMMO_TYPE[0]) !is null)
			ammo_in_inventory = true;
			
		enough_ammo = enough_ammo && ammo_in_inventory;
	}
	
	enough_ammo = enough_ammo||(ammo_cheating_xd&&stationary_gun);
	
	bool attached = this.isAttached();
	
	f32 command_lag_factor = (isClient()&&!isServer()?2:1);
	f32 smooth_vol = Maths::Clamp(1.0f*this.get_s32("shots_in_time")/(10.0f*7)*command_lag_factor-0.15f, 0, 1);
	sprite.SetEmitSoundPaused(shooting||!enough_ammo||!attached);
	sprite.SetEmitSoundSpeed(vars.FIRE_PITCH);
	sprite.SetEmitSound(vars.FIRE_SOUND);
	
	if (!sprite.getEmitSoundPaused()&&false)
		print("smooth_vol "+smooth_vol);
	
	sprite.SetEmitSoundVolume(1*(vars.FIRE_START_SOUND.empty()?1.0f:smooth_vol));
}

void SetWieldAnimation(CBlob@ this, CBlob@ holder)
{
	FirearmVars@ vars;
	if (!this.get("firearm_vars", @vars)) return;
	
	CSprite@ sprite = this.getSprite();
	
	bool sub_gun = isSubGun(this);
	
	bool stationary_gun = isStationaryGun(this);
	
	if (!(sub_gun||stationary_gun)&&holder is null) return;
	
	bool reload_interval_passed = (getGameTime()-this.get_u32("reload_start_time"))>vars.RELOAD_TIME+5; //adding 5 ticks so we cannot shoot RIGHT after reloading
	
	Animation@ fire_anim = sprite.getAnimation("fire");
	u32 fire_anim_interval = fire_anim !is null ? (fire_anim.getFramesCount()*fire_anim.time) : 1;
	
	bool should_change_fire_animation = (getGameTime()-this.get_u32("last_shot_time"))>=fire_anim_interval;
	
	if (!(reload_interval_passed&&should_change_fire_animation)) return;
	
	CBlob@ storage_blob = getBlobByNetworkID(this.get_u16("storage_id"));
	
	bool ammo_cheating_xd = !getRules().get_bool("ammo_usage_enabled");
	
	bool takes_blob_directly = isSubGun(this)||isStationaryGun(this);
	
	bool ammo_in_inventory = false;
	if (storage_blob !is null && storage_blob.getInventory() !is null && storage_blob.getInventory().getItem(vars.AMMO_TYPE[0]) !is null)
		ammo_in_inventory = true;
	else if (holder !is null && !isStationaryGun(this) && holder.getInventory() !is null && holder.getInventory().getItem(vars.AMMO_TYPE[0]) !is null)
		ammo_in_inventory = true;
		
	bool can_take_blob = (ammo_in_inventory||ammo_cheating_xd)&&takes_blob_directly;
	
	bool enough_ammo = (this.get_u8("clip"))>0&&!takes_blob_directly||can_take_blob;
	
	Animation@ wield_empty_anim = sprite.getAnimation("wield_empty");
	if (enough_ammo || wield_empty_anim is null)
		sprite.SetAnimation("wield");
	else
		sprite.SetAnimation("wield_empty");
}

void ReadReloadAction(CBlob@ this, CBlob@ holder)
{
	CControls@ controls = holder.getControls();
	//if (controls is null) return;
	
	FirearmVars@ vars;
	if (!this.get("firearm_vars", @vars)) return;
	
	CSprite@ sprite = this.getSprite();
	
	u8 clip = this.get_u8("clip");
	
	bool reload_interval_passed = (getGameTime()-this.get_u32("reload_start_time"))>vars.RELOAD_TIME;
	bool fire_interval_passed = (getGameTime()-this.get_u32("last_shot_time"))>vars.FIRE_INTERVAL;
	
	if (isSubGun(this)) return;
	
	if (isStationaryGun(this)) return;
	
	if (controls !is null && controls.isKeyJustPressed(KEY_KEY_J) && (holder.getPlayer() !is null && IsCool(holder.getPlayer().getUsername())))
    {
        if (clip != 255) {
            this.set_u8("clip", -1);
            Sound::Play("PowerUp", this.getPosition(), 3.0, 1.0f + (XORRandom(10)-5)*0.01);
        }
        else {
            this.set_u8("clip", 0);
            Sound::Play("PowerDown", this.getPosition(), 3.0, 1.0f + (XORRandom(10)-5)*0.01);
        }
		CBitStream params;
		params.write_u8(this.get_u8("clip"));
		params.write_u8(this.get_u8("total"));
		params.write_bool(true);
		this.SendCommand(this.getCommandID("set_clip"), params);
    }
	
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
	bool reload_on_empty_mag = (clip_empty && (vars.FIRE_AUTOMATIC && holder.isKeyPressed(key_action1)) && (this.get_u8("clickReload")>=3||vars.FIRE_INTERVAL>2&&this.get_u8("clickReload")>=1));
	
	if (!(controls !is null && controls.isKeyJustPressed(KEY_KEY_R)||reload_on_empty_mag)) return;
	
	bool should_reload = clip < vars.CLIP;
	
	if (canReload(this,holder)) {
        startReload(this,vars.RELOAD_TIME);
    } else if (controls !is null && controls.isKeyJustPressed(KEY_KEY_R) && should_reload){
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
	
	bool main_gun = !isSubGun(this);
	
	bool stationary_gun = isStationaryGun(this);
	
	bool using_lmb_semiauto = holder.isKeyJustPressed(key_action1);
	
	bool using_lmb_auto = vars.FIRE_AUTOMATIC && holder.isKeyPressed(key_action1);
	
	bool using_rmb_semiauto = holder.isKeyJustPressed(key_action3);
	
	bool using_rmb_auto = vars.FIRE_AUTOMATIC && holder.isKeyPressed(key_action3);
	
	bool lmb_activation = (main_gun||stationary_gun)&&(using_lmb_semiauto||using_lmb_auto);
	
	bool rmb_activation = !main_gun&&(using_rmb_semiauto||using_rmb_auto);
	
	CBlob@ storage_blob = getBlobByNetworkID(this.get_u16("storage_id"));
	
	bool ammo_cheating_xd = !getRules().get_bool("ammo_usage_enabled");
	
	bool takes_blob_directly = !main_gun||stationary_gun;
	
	bool ammo_in_inventory = false;
	if (storage_blob !is null && storage_blob.getInventory() !is null && storage_blob.getInventory().getItem(vars.AMMO_TYPE[0]) !is null)
		ammo_in_inventory = true;
	else if (!stationary_gun && holder.getInventory() !is null && holder.getInventory().getItem(vars.AMMO_TYPE[0]) !is null)
		ammo_in_inventory = true;
		
	bool can_take_blob = (ammo_in_inventory||ammo_cheating_xd)&&takes_blob_directly;
	//else if (holder !is null && holder.getInventory() !is null && holder.getInventory().getItem(vars.AMMO_TYPE[0]) !is null)
	//	can_take_blob = true||ammo_cheating_xd;
	u16 shot_count = this.get_u16("shotcount");
	
	f32 fast_shooting_gun_factor = (((getGameTime()-this.get_u32("last_shot_time"))<=1)&&fire_interval<2&&isClient()&&!isServer())?1:0;
	bool enough_ammo = (this.get_u8("clip"))>0&&!takes_blob_directly||can_take_blob;
	
	bool reload_interval_passed = (getGameTime()-this.get_u32("reload_start_time"))>vars.RELOAD_TIME+5; //adding 5 ticks so we cannot shoot RIGHT after reloading
	
	if ((lmb_activation||rmb_activation||bursting)&&!enough_ammo&&can_shoot_next_round&&reload_interval_passed&&isClient()) {
		f32 default_pitch = 110;
		default_pitch -= (vars.B_DAMAGE);
		default_pitch = Maths::Max(30, default_pitch);
		sprite.PlaySound("DryShot.ogg",1.0f,float(default_pitch-pitch_range+XORRandom(pitch_range*2))*0.01f);
		MakeBangEffect(this, "click");
		this.add_u8("clickReload", 1);
		this.set_u32("last_shot_time", getGameTime());
		if (bursting)
			this.sub_u8("rounds_left_in_burst", 1);
			
		this.set_u16("action_interval", Maths::Max(3, vars.FIRE_INTERVAL));
	}
	
	if ((lmb_activation||rmb_activation||bursting)&&can_shoot_next_round&&enough_ammo&&reload_interval_passed) {
		if (this.hasTag("charging"))
		{
			u16 charge = this.get_u16("charging_interval");
			
			if (charge < 40 && this.get_s32("shots_in_time") < 7)
			{
				if (charge < 1)
					this.getSprite().PlaySound("Coilgun_Spinup.ogg");
				this.add_u16("charging_interval", 1);
				return;
			}
			else
			{
				this.set_u16("charging_interval", 0);
			}
		}
		if (!vars.FIRE_START_SOUND.empty()&&this.get_s32("shots_in_time") < 7)
		{
			sprite.PlaySound(vars.FIRE_START_SOUND,1.0f,float(100*vars.FIRE_PITCH-pitch_range+XORRandom(pitch_range*2))*0.01f);
		}
		
		u32 time_from_last_shot = getGameTime()-this.get_u32("last_shot_time");
		
		f32 SHOT_ANGLE = ANGLE_FLIP_FACTOR+180-(this.getPosition()-holder.getAimPos()).Angle();
		if (stationary_gun)
			SHOT_ANGLE = GUN_ANGLE;
		Vec2f muzzle_offset = Vec2f(0, vars.MUZZLE_OFFSET.y).RotateBy(SHOT_ANGLE)-Vec2f(this.getWidth()/2*FLIP_FACTOR, 0).RotateBy(SHOT_ANGLE);
		if (canSendGunCommands(holder))
		{
			shootGun(this.getNetworkID(), SHOT_ANGLE, holder.getNetworkID(), this.getPosition()+muzzle_offset);
			//do it here so out machine knows about when we're out of ammo before the commands set the value to 0
			if (holder.isMyPlayer() && this.get_u8("clip")<255)
			{
				int new_clip = Maths::Max(0, -1+this.get_u8("clip"));
				//this.sub_u8("clip", 1);
				this.set_u8("clip", new_clip);
			}
			this.Untag("burst_finished");
		}
		
		int too_fast_shooting_interval = 3;
		bool can_create_bang_effect = (time_from_last_shot <= too_fast_shooting_interval && this.get_u16("shotcount")%(6-fire_interval)==0 || time_from_last_shot > too_fast_shooting_interval);
		if (true)
		{
			Vec2f onomatopoeia_pos = muzzle_offset+Vec2f(this.getWidth()*2.0f*FLIP_FACTOR, 0).RotateBy(SHOT_ANGLE);
			
			if (burst_firing && this.get_u8("rounds_left_in_burst") == Maths::Floor(vars.BURST/2))
				MakeBangEffect(this, "brrrap.png", 1.0f, false, Vec2f((XORRandom(10)-5) * 0.1, -(3/2)), onomatopoeia_pos);
			else if (!burst_firing && can_create_bang_effect)
				MakeBangEffect(this, vars.ONOMATOPOEIA, 1.0f, false, Vec2f((XORRandom(10)-5) * 0.1, -(3/2)), onomatopoeia_pos);
		}
		
		this.set_u32("last_shot_time", getGameTime());
		if (muzzle_flash !is null) {
			if (shot_count%2==1&&vars.FIRE_INTERVAL<2||vars.FIRE_INTERVAL>1)
				muzzle_flash.SetFrameIndex(0);
			
			Vec2f ray_hitpos;
			Vec2f muzzle_world = this.getPosition()+Vec2f((-16-muzzle_flash.getOffset().x)*FLIP_FACTOR, muzzle_flash.getOffset().y).RotateBy(SHOT_ANGLE);
			bool muzzle_blocked = getMap().rayCastSolid(this.getPosition(), muzzle_world, ray_hitpos);
			muzzle_flash.SetVisible(!muzzle_blocked);
		}
		
		OnClientShot@ shot_funcdef;
		this.get("onClientShot handle", @shot_funcdef);
		if (shot_funcdef !is null)
		{
			shot_funcdef(this.getNetworkID(), SHOT_ANGLE, holder.getNetworkID(), this.getPosition()+muzzle_offset);
		}
		
		sprite.SetAnimation("fire");
		
		if (burst_firing)
		{
			if (!bursting)
				this.set_u8("rounds_left_in_burst", vars.BURST-1); //minus 1 since one shot is already made
			else
				this.sub_u8("rounds_left_in_burst", 1);
		}
		bursting = this.get_u8("rounds_left_in_burst") > 0;
		
		f32 shots_in_time = 1.0f*this.get_s32("shots_in_time")/10;
		f32 gun_fire_interval = this.getName()=="minigun"?Maths::Max(1, vars.FIRE_INTERVAL-shots_in_time):vars.FIRE_INTERVAL;
		this.set_u16("action_interval", bursting?vars.BURST_INTERVAL+1:gun_fire_interval);
		
		CBitStream shots;
		shots.write_s32(7);
		this.SendCommand(this.getCommandID("change_shotsintime"), shots);
		CBitStream rounds;
		rounds.write_u8(this.get_u8("rounds_left_in_burst"));
		this.SendCommand(this.getCommandID("change_roundsinburst"), rounds);
	}
	else
	{
		this.set_u16("charging_interval", 0);
	}
}

void GunRotations(CBlob@ this, CBlob@ holder)
{
	if (holder !is null) return;
	
	FirearmVars@ vars;
	if (!this.get("firearm_vars", @vars)) return;
	
	const bool FLIP = this.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	bool should_rotate_towards_cursor = (getGameTime()-this.get_u32("last_facing_change_time"))>2;
	if (!isStationaryGun(this)||isSubGun(this)||!should_rotate_towards_cursor) return;
	
	f32 DIFF_ANGLE = this.get_f32("diff_angle")*(this.get_bool("diff_left") != FLIP ? -1 : 1);
	f32 DIFF_VEHANGLE;
	
	AttachmentPoint@ holder_pickup_ap = null;
	if (isStationaryGun(this))
	{
		CBlob@ turret = getBlobByNetworkID(this.get_u16("turret_id"));
		if (turret !is null && turret.isAttachedTo(this))
		{
			DIFF_VEHANGLE=DIFF_ANGLE+turret.getAngleDegrees();
			@holder_pickup_ap = turret.getAttachments().getAttachmentPointByName("GUNPOINT");
		}
	}
	
	this.setAngleDegrees(DIFF_VEHANGLE);
	
	if (holder_pickup_ap is null) return;
	
	Vec2f trans_from_holder = this.get_Vec2f("gun_trans_from_carrier").RotateBy(0);
	Vec2f shoulder_joint = Vec2f(3, 0).RotateBy(0);
	shoulder_joint += Vec2f(trans_from_holder.x, -trans_from_holder.y);
	
	Vec2f sprite_offset = this.getSprite().getOffset();
	
	Vec2f gun_offset = (this.hasTag("trench_aim") ? Vec2f(-trench_aim.x, -trench_aim.y) : Vec2f_zero)-vars.SPRITE_TRANSLATION+sprite_offset+Vec2f(trans_from_holder.x, -trans_from_holder.y);
	
	holder_pickup_ap.occupied_offset = gun_offset.RotateBy(DIFF_ANGLE*FLIP_FACTOR, shoulder_joint);
}

CBlob@ getSoldatControllerBlob(CBlob@ this)
{
	bool sub_gun = isSubGun(this);
	bool stationary_gun = isStationaryGun(this);
	
	CBlob@ holder = null;
	
	if (sub_gun)
	{
		CBlob@ main_gun = getBlobByNetworkID(this.get_u16("gun_id"));
		if (main_gun !is null)// && main_gun.isAttachedTo(this))
		{
			AttachmentPoint@ main_gun_pickup_ap = main_gun.getAttachments().getAttachmentPointByName("PICKUP");
			CBlob@ occupied = main_gun_pickup_ap.getOccupied();
			if (occupied !is null)
			{
				//print("hey "+this.getName());
				if (occupied.isAttachedTo(this))
					@holder = occupied;
			}
		}
		else
		{
			this.clear("gun_id");
		}
	}
	
	if (stationary_gun)
	{
		CBlob@ turret = getBlobByNetworkID(this.get_u16("turret_id"));
		if (turret !is null && turret.isAttachedTo(this))
		{
			AttachmentPoint@[] aps;
			turret.getAttachmentPoints(@aps);
			for (int idx = 0; idx < aps.size(); ++idx)
			{
				AttachmentPoint@ ap = aps[idx];
				if (ap.getOccupied() !is null && ap.getOccupied() is this)
				{
					AttachmentPoint@ turret_seat = turret.getAttachments().getAttachmentPointByName(ap.name+"_GUNNER");
					if (turret_seat !is null)
					{
						@holder = turret_seat.getOccupied();
					}
				}
			}
		}
	}
	
	return holder;
}

void UntagFirearm(CBlob@ this)
{	
	if (!isSubGun(this)||!this.hasTag("firearm")) return;
	
	this.Untag("firearm");
}

void onTick(CBlob@ this) 
{
	//print(""+this.getName()+" "+this.exists("turret_id"));
	WriteLastMenusTime(this);
	ManageInterval(this);
	ManageLoopedSound(this);
	//print(""+this.getName()+this.getShape().isRotationsAllowed());
	//print(""+this.getName()+Maths::Round(this.getAngleDegrees()));
	
	const bool FLIP = this.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	bool sub_gun = isSubGun(this);
	bool stationary_gun = isStationaryGun(this);
	
	FirearmVars@ vars;
	if (!this.get("firearm_vars", @vars)) return;
	AttachmentPoint@ pickup_point = this.getAttachments().getAttachmentPointByName("PICKUP");
	
	if (pickup_point is null) {
		error("Pickup point is null in a firearm!");
		return;
	}
	
	CSprite@ sprite = this.getSprite();
	CBlob@ holder = pickup_point.getOccupied();
	//if (holder !is null) {
	//	this.getShape().getConsts().net_threshold_multiplier = 0.2f;
	//} else
	//	this.getShape().getConsts().net_threshold_multiplier = 1.0f;
	
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
	
	CBlob@ n_holder = getSoldatControllerBlob(this);
	if (n_holder !is null)
		@holder = n_holder;

	ManageShotsInTime(this, holder);
	SetWieldAnimation(this, holder);
	
	if (holder is null)
	{
		if (stationary_gun)
			this.setAngleDegrees(this.get_f32("last_owner_angle"));
		GunRotations(this, holder);
		if (!(sub_gun||stationary_gun))
			ManageAddons(this);
			
		if (!this.hasTag("ejected_case"))
		{
			if (isServer())
				this.SendCommand(this.getCommandID("make_emtpy_case"));
			if (isClient())
				sprite.PlaySound(vars.CYCLE_SOUND,1.0f,float(100*vars.CYCLE_PITCH-pitch_range+XORRandom(pitch_range*2))*0.01f);
			this.Tag("ejected_case");
		}
			
		return;
	}
	//from this point we are sure holder is not null
	this.set_u16("previous_holder", holder.getNetworkID());
	
	if (stationary_gun)
	{
		this.setAngleDegrees(holder.getAngleDegrees());
		this.set_f32("last_owner_angle", holder.getAngleDegrees());
	}
	
	ReadReloadAction(this, holder);
	const f32 GUN_ANGLE = getGunAngle(holder, this);
	
	Vec2f left_hand_offset = Vec2f(-11, 0)+vars.SPRITE_TRANSLATION-Vec2f(this.getWidth()/10, this.getHeight()/6);
	Vec2f left_hand_world = this.getPosition()+Vec2f(6*FLIP_FACTOR, 2).RotateBy(GUN_ANGLE);
	
	Vec2f trans_from_holder = this.get_Vec2f("gun_trans_from_carrier").RotateBy(0);
	Vec2f shoulder_joint = Vec2f(3, 0).RotateBy(0);
	shoulder_joint += Vec2f(trans_from_holder.x, -trans_from_holder.y);
	
	Vec2f holder_left_shoulder = holder.getPosition() + shoulder_joint - Vec2f(6, 0);
	f32 left_hand_angle = -(-holder_left_shoulder+left_hand_world).Angle()+ANGLE_FLIP_FACTOR;
	
	left_hand.SetOffset(left_hand_offset);
	left_arm.SetOffset(left_hand_offset);
	left_arm.ResetTransform();
	left_arm.SetRelativeZ(-40);
	left_arm.RotateBy(left_hand_angle-this.getAngleDegrees(), Vec2f());
	left_hand.SetVisible(false);
	
	bool player_crouching = gunCrouching(holder);
	bool proning = lyingProne(holder);//player_crouching && (holder.isKeyPressed(key_left) || holder.isKeyPressed(key_right));
	
	if(vars.TRENCH_AIM==1 || player_crouching && !proning){
		// "aiming" style wield
		this.Tag("trench_aim");
		right_arm.SetAnimation("aim");
    } else {
		// normal wield
		this.Untag("trench_aim");
		right_arm.SetAnimation("default");
    }
	
	Vec2f sprite_offset = sprite.getOffset();
	
	Vec2f gun_offset = (this.hasTag("trench_aim") ? Vec2f(-trench_aim.x, -trench_aim.y) : Vec2f_zero)-vars.SPRITE_TRANSLATION+sprite_offset+Vec2f(trans_from_holder.x, -trans_from_holder.y);
	right_arm.SetOffset(Vec2f(-2-gun_offset.x, gun_offset.y)+trans_from_holder);
	
	bool burst_firing = vars.BURST > 1;
	
	bool bursting = this.get_u8("rounds_left_in_burst") > 0;
	
	bool localhost = isServer()&&isClient();
	bool my_machine = holder.isMyPlayer()&&!localhost&&false;
	
	bool should_use_burst_interval = burst_firing && (bursting || this.get_u8("rounds_left_in_burst") == 0 && (getGameTime()-this.get_u32("last_shot_time"))>0);
	
	u16 shot_count = this.get_u16("shotcount");
	f32 shots_in_time = 1.0f*this.get_s32("shots_in_time")/10;
	f32 gun_fire_interval = this.getName()=="minigun"?Maths::Max(1, vars.FIRE_INTERVAL-shots_in_time):vars.FIRE_INTERVAL;
	f32 kick_interval = Maths::Max(1, 1.0f*(should_use_burst_interval?vars.BURST_INTERVAL:gun_fire_interval)-(my_machine?0:0));
	f32 fire_interval = Maths::Max(0, 1.0f*(bursting?vars.BURST_INTERVAL:gun_fire_interval)-(my_machine?1:0));
	
	AttachmentPoint@ subwep_p = holder.getAttachments().getAttachmentPointByName("ADDON_UNDER_BARREL");
	CBlob@ subwep;
	if (subwep_p !is null)
		@subwep = subwep_p.getOccupied();
	
	u32 time_from_last_shot = getGameTime()-this.get_u32("last_shot_time");
	u32 time_from_last_slash = getGameTime()-(subwep is null ? 0 : subwep.get_u32("last_slash"));
	bool using_shot_action = time_from_last_shot<=time_from_last_slash;
	
	u32 last_action_time = using_shot_action?time_from_last_shot:time_from_last_slash;
	f32 subwep_factor = using_shot_action?0:8;
	
	f32 fast_shooting_diffa = (shot_count%2==1&&vars.FIRE_INTERVAL<2)?1:0;
	f32 kickback_value = Maths::Clamp(1.0f*(kick_interval+fast_shooting_diffa+subwep_factor), 1, 10);
	
	bool do_recoil = last_action_time+1<=kickback_value&&!sub_gun&&vars.RECOIL!=0;
	//do_recoil = false;
	
	f32 kickback_angle = !using_shot_action?0:(Maths::Tan(50)*(64-this.getSprite().getFrameWidth()))*-1;
	kickback_angle *= 1.0f*(kickback_value-last_action_time+fast_shooting_diffa)/kickback_value;
	Vec2f kickback_offset = Vec2f(using_shot_action?3:-5, 0);
	kickback_offset.x *= 1.0f*(kickback_value-last_action_time+fast_shooting_diffa)/kickback_value;
	if (do_recoil) {
		gun_offset += kickback_offset;
		right_arm.SetOffset(right_arm.getOffset()-kickback_offset);
	}
	
	bool old_enough = this.getTickSinceCreated()>10;
	
	if (!do_recoil&&!this.hasTag("ejected_case")&&old_enough)
	{
		if (isServer())
			this.SendCommand(this.getCommandID("make_emtpy_case"));
		if (isClient())
			sprite.PlaySound(vars.CYCLE_SOUND,1.0f,float(100*vars.CYCLE_PITCH-pitch_range+XORRandom(pitch_range*2))*0.01f);
		this.Tag("ejected_case");
	}
	
	bool reload_interval_passed = (getGameTime()-this.get_u32("reload_start_time"))>vars.RELOAD_TIME;
	
	f32 NEW_GUN_ANGLE = GUN_ANGLE;
	
	if (!stationary_gun)
	{
		NEW_GUN_ANGLE = !reload_interval_passed ? (FLIP ? 0-vars.RELOAD_ANGLE : 0+vars.RELOAD_ANGLE) : GUN_ANGLE;
		NEW_GUN_ANGLE = do_recoil ? (NEW_GUN_ANGLE-kickback_angle*FLIP_FACTOR) : NEW_GUN_ANGLE;
		NEW_GUN_ANGLE = Maths::Clamp(NEW_GUN_ANGLE, -91, 91);
	}
	
	bool menu_free = (getGameTime()-this.get_u32("last_menus_time"))>5;

	bool can_shoot_next_round = this.get_u16("action_interval")<1&&menu_free;
	
	if (!can_shoot_next_round && muzzle_flash !is null && do_recoil) {
		//disabled so far
		muzzle_flash.RotateBy(-(NEW_GUN_ANGLE-GUN_ANGLE), Vec2f(-muzzle_flash.getOffset().x*FLIP_FACTOR, -muzzle_flash.getOffset().y));
		muzzle_flash.SetOffset(muzzle_flash.getOffset()+Vec2f(-kickback_offset.x/2, kickback_offset.y));
	}
	
	bool cannon_isnt_locked = !stationary_gun || stationary_gun && !holder.isKeyPressed(key_action2);
	bool should_rotate_towards_cursor = (getGameTime()-this.get_u32("last_facing_change_time"))>2;
	
	//only rotate if it's a main gun and not attached to another gun
	if (!sub_gun&&should_rotate_towards_cursor) {
		
		this.setAngleDegrees(NEW_GUN_ANGLE);
		
		//print("angle "+NEW_GUN_ANGLE);
		bool should_change_facing = !stationary_gun&&(GUN_ANGLE<-90||GUN_ANGLE>90)&&!isKnocked(holder)&&reload_interval_passed;
		
		AttachmentPoint@ holder_pickup_ap = holder.getAttachments().getAttachmentPointByName("PICKUP");
		
		AttachmentPoint@ holder_underbarrel_addon = holder.getAttachments().getAttachmentPointByName("ADDON_UNDER_BARREL");
		AttachmentPoint@ holder_addon = holder.getAttachments().getAttachmentPointByName("ADDON");
		AttachmentPoint@ gun_underbarrel_addon = this.getAttachments().getAttachmentPointByName("ADDON_UNDER_BARREL");
		AttachmentPoint@ gun_addon = this.getAttachments().getAttachmentPointByName("ADDON");
		
		Vec2f underbarrel_addon_offset = gun_offset - (gun_underbarrel_addon is null ? Vec2f() : gun_underbarrel_addon.offset);
		Vec2f addon_offset = gun_offset - (gun_addon is null ? Vec2f() : gun_addon.offset);
		
		if (stationary_gun)
		{
			CBlob@ turret = getBlobByNetworkID(this.get_u16("turret_id"));
			if (turret !is null && turret.isAttachedTo(this))
			{
				@holder_pickup_ap = turret.getAttachments().getAttachmentPointByName("GUNPOINT");
			}
		}
		
		if (should_change_facing)
		{
			bool new_facing = !holder.isFacingLeft();
			f32 mouse_y = holder.getAimPos().y;
			holder.SetFacingLeft(new_facing);
			f32 change_facing_angle = 0;
			if (mouse_y>this.getPosition().y)
				if (new_facing)
					change_facing_angle=90;
				else
					change_facing_angle=270;
			else
				if (new_facing)
					change_facing_angle=270;
				else
					change_facing_angle=90;
			this.SetFacingLeft(new_facing);
			this.setAngleDegrees(change_facing_angle+180);
			
			//skipping like 3 ticks when change facing
			//to give server time to calculate stuff
			this.set_u32("last_facing_change_time", getGameTime());
			holder_pickup_ap.occupied_offset = gun_offset.RotateBy((change_facing_angle)*FLIP_FACTOR, shoulder_joint);
			right_arm.SetVisible(false);
			return;
		}
		
		f32 item_angle = (NEW_GUN_ANGLE-holder.getAngleDegrees())*FLIP_FACTOR;
		
		holder_pickup_ap.occupied_offset = gun_offset.RotateBy(item_angle, shoulder_joint);
		holder_underbarrel_addon.occupied_offset = underbarrel_addon_offset.RotateBy(item_angle, shoulder_joint);
		holder_addon.occupied_offset = addon_offset.RotateBy(item_angle, shoulder_joint);
	}
	if (!(sub_gun||stationary_gun))
		ManageAddons(holder, this.getAngleDegrees());
	
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

void onChangeTeam( CBlob@ this, const int oldTeam )
{
	if (this.hasAttached())
	{
		AttachmentPoint@[] aps;
		if (this.getAttachmentPoints(@aps))
		{
			for (uint i = 0; i < aps.length; i++)
			{
				AttachmentPoint@ ap = aps[i];
				if (ap.socket && ap.getOccupied() !is null)
				{
					ap.getOccupied().server_setTeamNum(this.getTeamNum());
				}
			}
		}
	}
}

void onRender(CSprite@ this)
{
	const f32 SCALEX = getDriver().getResolutionScaleFactor();
	const f32 ZOOM = getCamera().targetDistance * SCALEX;
	
	if (ZOOM<=0.5f) return;
	
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	
	AttachmentPoint@ pickup_point = blob.getAttachments().getAttachmentPointByName("PICKUP");
	CBlob@ holder = pickup_point.getOccupied();
	
	if (holder is null) return;
	
	if (!holder.isMyPlayer()) return;
	
	Vec2f screen_pos = holder.getInterpolatedScreenPos();
	Vec2f text_dims;
	
	string help = "- LMB for shooting\n\n- RMB for aiming\n\n- hold S to lay prone\n(saves from gunfire a bit)\n\n- press R to reload\n\n- SPACE for sub-gun";
	
	if (!u_showtutorial)
		help = "press [F1] for gun help";
	
	string text = help;
	GUI::SetFont("default");
	GUI::GetTextDimensions(text, text_dims);
	GUIDrawTextOutlined(text, screen_pos+Vec2f(-text_dims.x/2, 48+text_dims.y/2), SColor(0xff999999), color_black, 1);
}