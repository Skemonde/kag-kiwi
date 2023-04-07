#include "FirearmVars"
#include "MakeBangEffect"

const int pitch_range = 10;

void shootGun(const u16 gunID, const f32 aimangle, const u16 hoomanID, const Vec2f pos) 
{
	CRules@ rules = getRules();
	CBitStream params;

	params.write_netid(hoomanID);
	params.write_netid(gunID);
	params.write_f32(aimangle);
	params.write_Vec2f(pos);
	rules.SendCommand(rules.getCommandID("fireGun"), params);
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
	FirearmVars@ vars;
	this.get("firearm_vars", @vars);
	if(cmd == reloadCMD)
	{
        if(isServer()){
            CBlob@ holder = getBlobByNetworkID(params.read_netid());
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
	
	if(cmd == this.getCommandID("fire_beginning"))
    {
		if (!vars.FIRE_START_SOUND.empty())
			this.getSprite().PlaySound(vars.FIRE_START_SOUND,1.0f,float(100*1.0f-pitch_range+XORRandom(pitch_range*2))*0.01f);
    }
	
	if(cmd == this.getCommandID("fire_ending"))
    {
		this.set_u16("shotcount", 0);
		this.getSprite().SetEmitSoundPaused(true);
		this.Tag("pshh");
		if (this.get_u8("clip") > 0 && !vars.FIRE_END_SOUND.empty())
			this.getSprite().PlaySound(vars.FIRE_END_SOUND,1.0f,float(100*1.0f-pitch_range+XORRandom(pitch_range*2))*0.01f);
    }
	
	if(cmd == this.getCommandID("cycle_animation"))
    {
		if (this.get_bool("do_cycle_sound")) {
			if (!vars.CYCLE_SOUND.empty())
				this.getSprite().PlaySound(vars.CYCLE_SOUND,1.0f,float(100*vars.CYCLE_PITCH-pitch_range+XORRandom(pitch_range*2))*0.01f);
			this.set_bool("do_cycle_sound", false);
		}
    }
	
	if(cmd == this.getCommandID("load_animation"))
    {
		this.getSprite().PlaySound(vars.LOAD_SOUND,1.0f,float(100*vars.LOAD_PITCH-pitch_range+XORRandom(pitch_range*2))*0.01f);
		this.getSprite().SetAnimation("reload");
		this.getSprite().SetEmitSoundPaused(true);
		this.set_u8("clickReload", 0);
    }
	
	if(cmd == this.getCommandID("reload_animation"))
    {
		if(vars.RELOAD_SOUND != "" && this.get_u8("clip") == vars.CLIP)
			this.getSprite().PlaySound(vars.RELOAD_SOUND,1.0f,float(100*vars.RELOAD_PITCH-pitch_range+XORRandom(pitch_range*2))*0.01f);
		this.getSprite().SetAnimation("wield");
		this.set_u8("clickReload", 0);
    }
	
	if(cmd == this.getCommandID("make_clipgib"))
    {
		makeGibParticle(vars.CLIP_SPRITE,this.getPosition(),Vec2f((this.isFacingLeft() ? -1 : 1),-1),0,0,Vec2f(8, 8),1.0f,0,"empty_magazine", this.getTeamNum());
    }
	
	if(cmd == this.getCommandID("dryshot_animation"))
    {
		f32 default_pitch = 110;
		default_pitch -= 10*(vars.B_DAMAGE);
		this.getSprite().PlaySound("DryShot.ogg",1.0f,float(default_pitch-pitch_range+XORRandom(pitch_range*2))*0.01f);
		this.add_u8("clickReload", 1);
        MakeBangEffect(this, "click");
    }
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint) 
{
	this.getCurrentScript().runFlags &= ~Script::tick_not_sleeping;
	this.SetDamageOwnerPlayer(attached.getPlayer());

	CSprite@ sprite = this.getSprite();
	sprite.SetAnimation("wield");
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
    
	if(isServer()){
		if(vars.T_TO_DIE > -1)this.server_SetTimeToDie(vars.T_TO_DIE);
	}
}
