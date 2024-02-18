#include "FirearmVars"
#include "MakeBangEffect"
#include "Hitters"
#include "Skemlib"
#include "MaterialCommon"

const int pitch_range = 10;
bool ammo_enabled = true;

int getAmmoUsageFactor(string ammo_name)
{
	if (ammo_name=="mat_battery")
		return 10;
	else
		return 1;
	return 1;
}

void shootGun(const u16 gunID, const f32 aimangle, const u16 hoomanID, const Vec2f pos, const bool altfire = false) 
{
	CRules@ rules = getRules();
	CBitStream params;

	params.write_netid(hoomanID);
	params.write_netid(gunID);
	params.write_f32(aimangle);
	params.write_Vec2f(pos);
	params.write_bool(altfire);
	rules.SendCommand(rules.getCommandID("fireGun"), params);
}

void startReload(CBlob@ this, u8 reloadTime){
    this.set_bool("doReload", true);
    this.set_u8("actionInterval",reloadTime);
	this.set_u8("gun_state", RELOADING);
    this.SendCommand(this.getCommandID("start_reload"));
}

void reload(CBlob@ this, CBlob@ holder) 
{
	CBitStream params;
	params.write_netid(holder.getNetworkID());
	this.SendCommand(reloadCMD,params);
	this.set_u8("clickReload",0);
}

bool canReload(CBlob@ this, CBlob@ holder) 
{
	bool ammo_enabled = getRules().get_bool("ammo_usage_enabled");
	FirearmVars@ vars;
	if (!this.get("firearm_vars", @vars)) return false;
    if(holder.isInWater())return false;

	int currentTotalAmount = this.get_u8("total");
    int currentClipAmount = this.get_u8("clip");
    int currentInventoryAmount = 0;
	
	string ammo_name = "";
	if (vars.AMMO_TYPE.size()>0) {
		if (vars.BULLET=="blobconsuming")
			ammo_name = "mat_battery";
		else
			ammo_name = vars.AMMO_TYPE[0];
	}
	
    //cheat
	if (vars.AMMO_TYPE.size()<1||!ammo_enabled)
		currentInventoryAmount = 255;
	else
		currentInventoryAmount = Maths::Floor(holder.getBlobCount(ammo_name)/getAmmoUsageFactor(ammo_name));
    
	if(currentClipAmount >= vars.CLIP)return false;
    
    return currentTotalAmount+currentInventoryAmount > 0;
}

void local_SyncGunState(CBlob@ this)
{
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	CBlob@ holder = point.getOccupied();
	//from local machine to all the cliens except the local machine itself
	if (holder is null || holder !is getLocalPlayerBlob()) return;
	
	CBitStream stream;
	stream.write_u8(this.get_u8("gun_state"));
	
	this.SendCommand(this.getCommandID("sync_gun_state"), stream);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params) 
{
	bool ammo_enabled = getRules().get_bool("ammo_usage_enabled");
	CSprite@ sprite = this.getSprite();
	FirearmVars@ vars;
	if (!this.get("firearm_vars", @vars)) return;
	const bool flip = this.isFacingLeft();
	const f32 flip_factor = flip ? -1 : 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	
	if(cmd == this.getCommandID("change_firemode"))
	{
		u8 new_mode; if (!params.saferead_u8(new_mode)) return;
		this.set_u8("firemode", new_mode);
		//print("new mode "+new_mode);
	}
	if(cmd == this.getCommandID("create_laser_light"))
	{
		if (this.hasTag("laser_pointer")) return;
		this.Tag("laser_pointer");
		if (!isServer()) return;
		CBlob@ light = server_CreateBlob("laserpointer_light", -1, this.getPosition());
		if (light is null) return;
		print("created laser on "+getMachineType());
		this.set_u16("remote_netid", light.getNetworkID());
		this.Sync("remote_netid", true);
		light.set_u16("owner_netid", this.getNetworkID());
		
	}
	if(cmd == this.getCommandID("make_emtpy_case"))
	{
		if (v_fastrender) return;
		//if (isServer()) return;
		if (vars.CART_SPRITE.empty()) return;
		
		if(vars.SELF_EJECTING) {
			MakeEmptyShellParticle(this, vars.CART_SPRITE, 1, Vec2f(-69, -69), this);
		} else {
			this.add_u8("stored_carts", 1);
		}
	}
	if(cmd == reloadCMD)
	{
        if(isServer()){
            CBlob@ holder = getBlobByNetworkID(params.read_netid());
			if (holder is null) {
				this.set_u8("clip", vars.CLIP);
				return;
			}
            int currentTotalAmount = this.get_u8("total");
            int currentClipAmount = this.get_u8("clip");
            int currentInventoryAmount = 0;
			
			string ammo_name = "";
			if (vars.BULLET=="blobconsuming")
				ammo_name = "mat_battery";
			else
				ammo_name = vars.AMMO_TYPE[0];
			
			//cheat
			if (vars.AMMO_TYPE.size()<1||!ammo_enabled)
				currentInventoryAmount = 255;
			else
				currentInventoryAmount = Maths::Floor(holder.getBlobCount(ammo_name)/getAmmoUsageFactor(ammo_name));
				
            int TakeFromInventory = 0;
            
            int neededClipAmount = vars.CLIP - currentClipAmount;
            if(vars.RELOAD_HANDFED_ROUNDS > 0)neededClipAmount = Maths::Min(vars.CLIP - currentClipAmount,vars.RELOAD_HANDFED_ROUNDS);
            int GiveToClip = 0;
            
            if(vars.TOTAL > 0){ //Most guns won't have a total value so we may as well skip this step in those cases for performance
                GiveToClip = Maths::Min(neededClipAmount,currentTotalAmount);
            
                currentClipAmount += GiveToClip;
                currentTotalAmount -= GiveToClip;
                neededClipAmount = vars.CLIP - currentClipAmount;
            }
            
            if(neededClipAmount > 0){ //Total couldn't fill us up, so take from invetory instead
                GiveToClip = Maths::Min(neededClipAmount,currentInventoryAmount);
                currentClipAmount += GiveToClip;
                TakeFromInventory += GiveToClip;
            }
            
            if(vars.TOTAL > 0){ //Most guns won't have a total value so we may as well skip this step in those cases for performance
                int neededTotalAmount = vars.TOTAL - currentTotalAmount;
                currentInventoryAmount -= TakeFromInventory; //Pretend we've taken from inventory, so we don't have to make multiple TakeBlob calls
                
                int GiveToTotal = Maths::Min(neededTotalAmount,currentInventoryAmount);
                
                currentTotalAmount += GiveToTotal;
                TakeFromInventory += GiveToTotal;
            }
            
			if ((vars.BULLET=="blobconsuming"||vars.AMMO_TYPE.size()>0)&&!holder.hasTag("bot")&&!(holder.getPlayer() !is null && holder.getPlayer().isBot())) {
				holder.TakeBlob(ammo_name, TakeFromInventory*getAmmoUsageFactor(ammo_name));
			}
            
            this.set_u8("clip", Maths::Clamp(currentClipAmount, 0, vars.CLIP));
            this.set_u8("total", Maths::Clamp(currentTotalAmount, 0, 255));
            
            CBitStream params;
            params.write_u8(this.get_u8("clip"));
            params.write_u8(this.get_u8("total"));
            this.SendCommand(this.getCommandID("set_clip"),params);
		}
	}
	
	if(cmd == this.getCommandID("change_altfire"))
	{
		u16 caller_id, carried_id;
		if (!params.saferead_u16(caller_id)) return;
		if (!params.saferead_u16(carried_id)) return;
		CBlob@ caller = getBlobByNetworkID(caller_id);
		CBlob@ carried = getBlobByNetworkID(carried_id);
		if (caller is null || carried is null) return;
		
		this.set_u8("override_alt_fire", carried.get_u8("alt_fire_item"));
		if (carried.exists("alt_fire_interval"))
			this.set_u8("override_altfire_interval", carried.get_u16("alt_fire_interval"));
			
		if (carried.getName()=="naderitem") {
			FirearmVars@ vars;
			if (!this.get("firearm_vars", @vars)) return;
			
			if (vars.AMMO_TYPE.size()<2) {
				vars.AMMO_TYPE.push_back("froggy");
			} else {
				vars.AMMO_TYPE[1].opAssign("froggy");
			}
		} else {
			FirearmVars@ vars;
			if (!this.get("firearm_vars", @vars)) return;
			if (vars.AMMO_TYPE.size()>1)
				vars.AMMO_TYPE.erase(1);
		}
		
		carried.server_Die();
	}
    
    if(cmd == this.getCommandID("set_clip"))
    {
        u8 clip = params.read_u8();
        u8 total = params.read_u8();
        this.set_u8("clip",clip);
        this.set_u8("total",total);
    }
    
    if(cmd == this.getCommandID("start_reload"))
    {
		this.set_bool("doReload", true);
		this.set_u8("gun_state", RELOADING);
        this.set_u8("actionInterval",vars.RELOAD_TIME);
        //print("actionInterval being reloaded");
        
        if(vars.CLIP_SPRITE != ""){
            makeGibParticle(vars.CLIP_SPRITE,this.getPosition(),Vec2f((this.isFacingLeft() ? -1 : 1),-1),0,0,Vec2f(8, 8),1.0f,0,"empty_magazine", this.getTeamNum());
        }
        
        //sound only plays when we load whole clip at once
        //it's either reloading by X rounds a time and this X = CLIP or reloading full magazine (RHR variable = 0)
        //it's made so when rifle reloads by 5 (it's capacity) instead of full clip reload gun actually plays load sound
        //print("vars.RELOAD_HANDFED_ROUNDS "+vars.RELOAD_HANDFED_ROUNDS);
        //print("vars.LOAD_SOUND " + vars.LOAD_SOUND);
        if(vars.LOAD_SOUND != "" && this.get_u8("clip") != vars.CLIP){ //(vars.RELOAD_HANDFED_ROUNDS <= 0 || vars.RELOAD_HANDFED_ROUNDS == vars.CLIP) && 
            sprite.PlaySound(vars.LOAD_SOUND,1.0f,float(100*vars.LOAD_PITCH-pitch_range+XORRandom(pitch_range*2))*0.01f);
            sprite.SetEmitSoundPaused(true);
            this.set_u8("clickReload", 0);
            if (!vars.CART_SPRITE.empty() && !vars.SELF_EJECTING) {
                int carts = this.get_u8("stored_carts");
                if(carts > 0){
					if (!v_fastrender)
						MakeEmptyShellParticle(this, vars.CART_SPRITE, carts);
                    this.set_u8("stored_carts", 0);
                }
            }
        }
        
        if(vars.EMPTY_RELOAD)
        if(isServer()){
            this.set_u8("clip",0);
            CBitStream params;
            params.write_u8(this.get_u8("clip"));
            params.write_u8(this.get_u8("total"));
            this.SendCommand(this.getCommandID("set_clip"),params);
        }
    }

    if(cmd == this.getCommandID("cancel_reload"))
    {
		this.set_bool("doReload", false);
        this.set_u8("actionInterval",0);
    }
	

	if(cmd == this.getCommandID("toggle_shooting"))
    {
        bool shooting = params.read_bool();
        
        this.set_bool("shooting",shooting);
    }
	
	if(cmd == this.getCommandID("make_slash"))
	{
		//print("receiving slash command");
		//if (getGameTime()-this.get_u32("last_slash")<9) return;
		CBlob@ holder = getBlobByNetworkID(params.read_netid());
		if (holder is null) return;
		f32 aimangle = params.read_f32();
		Vec2f pos = params.read_Vec2f();
		f32 arc_angle = params.read_f32();
		f32 range = params.read_f32();
		f32 damage = 43;
		
		if(!isServer()) return;
		
        HitInfo@[] hitInfos;
		u16[] TargetsPierced;
        CMap@ map = getMap();
        if (map.getHitInfosFromArc(pos, aimangle+angle_flip_factor, arc_angle, range, holder, @hitInfos)) {
            for (int counter = 0; counter < hitInfos.length; ++counter) {
                CBlob@ doomed = hitInfos[counter].blob;
                if (doomed !is null && TargetsPierced.find(doomed.getNetworkID()) <= -1) {
					if(holder.getTeamNum() == doomed.getTeamNum() && !doomed.hasTag("dummy") || doomed.hasTag("vehicle") || doomed.hasTag("tree") || doomed.hasTag("invincible") || doomed.getName()=="sandbag") continue;
					
					bool fighting_undeads = doomed.hasTag("undead");
					bool intended_target = doomed.hasTag("player") || doomed.hasTag("dummy");
					
					if (vars.B_HITTER==HittersKIWI::shovel) {
						damage = 25;
					} else
					if (holder.getVelocity().y > 2.0f && intended_target) {
						//print("vel y "+holder.getVelocity().y);
						damage = 68;
						MakeBangEffect(doomed, "crit", 1.0f, false, Vec2f((XORRandom(10)-5) * 0.1, -(3/2)), Vec2f(XORRandom(11)-5,-XORRandom(4)-1));
					}
					
					holder.server_Hit(doomed, hitInfos[counter].hitpos, Vec2f_zero, damage/10, HittersKIWI::bayonet, true);
					this.set_u32("last_shot_time", getGameTime());
					TargetsPierced.push_back(doomed.getNetworkID());
					//print("making slash hit");
					if (fighting_undeads)
						continue;
					else
						break;
                    //holder.server_Hit(doomed, doomed.getPosition(), Vec2f_zero, damage/10, HittersKIWI::bayonet, true);
					//print("hellow from 'for'");
                } else {
					//tile hit
					Vec2f hitpos = hitInfos[counter].hitpos;
					TileType tile_type = map.getTile(hitpos).type;
					if (vars.B_HITTER==HittersKIWI::bayonet) {
						if (map.isTileWood(tile_type)) {
							map.server_DestroyTile(hitpos, 1.0f);
							break;
						}
					} else if (vars.B_HITTER==HittersKIWI::shovel) {
						if (map.isTileGroundStuff(tile_type)||map.isTileWood(tile_type)) {
							map.server_DestroyTile(hitpos, 1.0f);
							Material::fromTile(holder, tile_type, 1.0f);
							if (counter>0)// shovel hits 2 tiles
								break;
						}
					}
					//break;
				}
            }
        }
		//print("hellow from slashing command\n\n");
		this.add_u8("stored_carts", 1);
		//this.set_u32("last_slash", getGameTime());
	}
	
	if(cmd == this.getCommandID("sync_action_interval"))
    {
		u8 interval = params.read_u8();
		if (interval > 0)
			print(getMachineType()+" has interval of "+interval, SColor(0xff1be7ff));
        
        AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
        CBlob@ holder = point.getOccupied();
        if(holder != null){
            if(!holder.isMyPlayer())this.set_u8("actionInterval", interval);
        }
    }
	
	if(cmd == this.getCommandID("sync_gun_state"))
	{
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		CBlob@ holder = point.getOccupied();
		if (holder is null || holder is getLocalPlayerBlob()) return;
		
		u8 state; if (!params.saferead_u8(state)) return;
		this.set_u8("gun_state", state);
	}
	
	if(cmd == this.getCommandID("change_shotsintime"))
	{
		s32 shots_amount; if (!params.saferead_s32(shots_amount)) return;
		this.set_s32("shots_in_time", Maths::Max(0, this.get_s32("shots_in_time")+shots_amount));
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return byBlob.getName()!="knight";
}

bool canBePutInInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	return inventoryBlob.getName()!="engi"||(inventoryBlob.getName()=="engi"&&this.hasTag("handgun"));
}

void onThisAddToInventory( CBlob@ this, CBlob@ inventoryBlob )
{
	//doesn't take any effect
	this.SetLight(false);
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint) 
{
	if (!this.hasTag("quick_detach")) {
		this.getSprite().PlaySound("pistol_holster",1.0f,float(100-pitch_range+XORRandom(pitch_range*2))*0.01f);
	}
	this.Untag("quick_detach");
	//this.getCurrentScript().runFlags &= ~Script::tick_not_sleeping;
	this.SetDamageOwnerPlayer(attached.getPlayer());

	CSprite@ sprite = this.getSprite();
	sprite.ResetTransform();
	this.server_SetTimeToDie(-1);
	this.setAngleDegrees(0);
	if(isServer())this.server_SetTimeToDie(0);
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint @detachedPoint) 
{
    CSprite@ sprite = this.getSprite();
	sprite.SetEmitSoundPaused(true);
    sprite.ResetTransform();
    sprite.SetAnimation("default");
	
	FirearmVars@ vars;
	this.get("firearm_vars", @vars);
	if (vars is null) return;

    Vec2f aimvector = detached.getAimPos() - this.getPosition();
 	f32 angle = 0 - aimvector.Angle() + (this.isFacingLeft() == true ? 180.0f : 0);
    this.setAngleDegrees(angle);
	if (this.hasTag("quick_detach")) return;
	
	this.set_bool("beginReload", false);
	this.set_bool("doReload", false);
	//gun keeps its pos while sleeping in inventory and if actioninterval isn't increased by some amount it will cause a gun shoot from the pos it was put in inventory which can be million blocks away. It needs some time to get new position
	this.add_u8("actionInterval", 3);
	this.set_u8("gun_state", 0);
	this.set_u8("stored_carts", 0);
	
	this.set_u8("clip", this.get_u8("clip")-this.get_u8("rounds_left_in_burst"));
	this.set_u8("rounds_left_in_burst", 0);
    
	if(isServer()){
		if(vars.T_TO_DIE > -1)this.server_SetTimeToDie(vars.T_TO_DIE);
	}
}

bool canUseTheGun(CBlob@ holder, CBlob@ gun)
{
	return holder.getName()=="engi"&&!gun.hasTag("handgun");
}