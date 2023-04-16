#include "FirearmVars"
#include "MakeBangEffect"
#include "Hitters"
#include "Skemlib"

const int pitch_range = 10;

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
	FirearmVars@ vars;
	this.get("firearm_vars", @vars);
    if(holder.isInWater())return false;

	int currentTotalAmount = this.get_u8("total");
    int currentClipAmount = this.get_u8("clip");
    int currentInventoryAmount = holder.getBlobCount(vars.AMMO_TYPE);
    
    if(currentClipAmount >= vars.CLIP)return false;
    
    return currentTotalAmount+currentInventoryAmount > 0;
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params) 
{
	CSprite@ sprite = this.getSprite();
	FirearmVars@ vars;
	this.get("firearm_vars", @vars);
	const bool flip = this.isFacingLeft();
	const f32 flip_factor = flip ? -1 : 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
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
            int currentInventoryAmount = holder.getBlobCount(vars.AMMO_TYPE);
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
            
            holder.TakeBlob(vars.AMMO_TYPE, TakeFromInventory);
            
            this.set_u8("clip", Maths::Clamp(currentClipAmount, 0, vars.CLIP));
            this.set_u8("total", Maths::Clamp(currentTotalAmount, 0, 255));
            
            CBitStream params;
            params.write_u8(this.get_u8("clip"));
            params.write_u8(this.get_u8("total"));
            this.SendCommand(this.getCommandID("set_clip"),params);
		}
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
        if(vars.LOAD_SOUND != ""){ //(vars.RELOAD_HANDFED_ROUNDS <= 0 || vars.RELOAD_HANDFED_ROUNDS == vars.CLIP) && 
            sprite.PlaySound(vars.LOAD_SOUND,1.0f,float(100*vars.LOAD_PITCH-pitch_range+XORRandom(pitch_range*2))*0.01f);
            sprite.SetEmitSoundPaused(true);
            this.set_u8("clickReload", 0);
            if (!vars.CART_SPRITE.empty() && !vars.SELF_EJECTING) {
                int carts = this.get_u8("stored_carts");
                if(carts > 0){
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
		CBlob@ holder = getBlobByNetworkID(params.read_netid());
		f32 aimangle = params.read_f32();
		Vec2f pos = params.read_Vec2f();
		f32 arc_angle = params.read_f32();
		f32 range = params.read_f32();
		f32 damage = 4;
		if (holder.getVelocity().y > 0)
			damage = 6;
		if(isServer()){
            HitInfo@[] hitInfos;
            CMap@ map = getMap();
            if (map.getHitInfosFromArc(pos, aimangle+angle_flip_factor, arc_angle, range, holder, @hitInfos)) {
                for (int counter = 0; counter < hitInfos.length; ++counter) {
                    CBlob@ doomed = hitInfos[counter].blob;
                    if (doomed !is null && holder !is null) {
                        if(holder.getTeamNum() == doomed.getTeamNum())
                            continue;
                        holder.server_Hit(doomed, doomed.getPosition(), Vec2f_zero, damage, Hitters::sword, true);
                    }
                }
            }
        }
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
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint) 
{
	this.getCurrentScript().runFlags &= ~Script::tick_not_sleeping;
	this.SetDamageOwnerPlayer(attached.getPlayer());

	CSprite@ sprite = this.getSprite();
	sprite.ResetTransform();
	this.server_SetTimeToDie(-1);
	this.setAngleDegrees(0);
	if(isServer())this.server_SetTimeToDie(0);
	this.getSprite().PlaySound("pistol_holster",1.0f,float(100-pitch_range+XORRandom(pitch_range*2))*0.01f);
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
	this.set_bool("beginReload", false);
	this.set_bool("doReload", false);
	//gun keeps its pos while sleeping in inventory and if actioninterval isn't increased by some amount it will cause a gun shoot from the pos it was put in inventory which can be million blocks away. It needs some time to get new position
	this.add_u8("actionInterval", 3);
	this.set_u8("gun_state", 0);
    
	if(isServer()){
		if(vars.T_TO_DIE > -1)this.server_SetTimeToDie(vars.T_TO_DIE);
	}
}

void onChangeTeam( CBlob@ this, const int oldTeam )
{
	CSprite@ sprite = this.getSprite();
	//for a very sus reason i have to scale sprite layer once more after blob's team's changed...
	CSpriteLayer@ flash = sprite.getSpriteLayer("m_flash");
	if (flash !is null)
	{
		flash.ScaleBy(Vec2f(1.4f, 1.4f));
	}
}