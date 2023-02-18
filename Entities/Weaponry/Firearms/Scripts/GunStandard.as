#include "MakeBangEffect"

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
    if(holder.isInWater())return false;

	int currentTotalAmount = this.get_u8("total");
    int currentClipAmount = this.get_u8("clip");
    int currentInventoryAmount = holder.getBlobCount(AMMO_TYPE);
    
    if(currentClipAmount >= CLIP)return false;
    
    return currentTotalAmount+currentInventoryAmount > 0;
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params) 
{
	if(cmd == reloadCMD) 
	{
        if(isServer()){
            CBlob@ holder = getBlobByNetworkID(params.read_netid());
            int currentTotalAmount = this.get_u8("total");
            int currentClipAmount = this.get_u8("clip");
            int currentInventoryAmount = holder.getBlobCount(AMMO_TYPE);
            int TakeFromInventory = 0;
            
            int neededClipAmount = CLIP - currentClipAmount;
            if(RELOAD_HANDFED_ROUNDS > 0)neededClipAmount = Maths::Min(CLIP - currentClipAmount,RELOAD_HANDFED_ROUNDS);
            int GiveToClip = 0;
            
            if(TOTAL > 0){ //Most guns won't have a total value so we may as well skip this step in those cases for performance
                GiveToClip = Maths::Min(neededClipAmount,currentTotalAmount);
            
                currentClipAmount += GiveToClip;
                currentTotalAmount -= GiveToClip;
                neededClipAmount = CLIP - currentClipAmount;
            }
            
            if(neededClipAmount > 0){ //Total couldn't fill us up, so take from invetory instead
                GiveToClip = Maths::Min(neededClipAmount,currentInventoryAmount);
                currentClipAmount += GiveToClip;
                TakeFromInventory += GiveToClip;
            }
            
            if(TOTAL > 0){ //Most guns won't have a total value so we may as well skip this step in those cases for performance
                int neededTotalAmount = TOTAL - currentTotalAmount;
                currentInventoryAmount -= TakeFromInventory; //Pretend we've taken from inventory, so we don't have to make multiple TakeBlob calls
                
                int GiveToTotal = Maths::Min(neededTotalAmount,currentInventoryAmount);
                
                currentTotalAmount += GiveToTotal;
                TakeFromInventory += GiveToTotal;
            }
            
            holder.TakeBlob(AMMO_TYPE, TakeFromInventory);
            
            this.set_u8("clip", Maths::Clamp(currentClipAmount, 0, CLIP));
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
	
	if(cmd == this.getCommandID("finish_shooting"))
    {
		this.set_u16("shotcount", 0);
		this.getSprite().SetEmitSoundPaused(true);
		if (this.get_u8("clip") > 0 && (!this.hasTag("NoAccuracyBonus") && FIRE_AUTOMATIC))
			this.getSprite().PlaySound("Steam",1.0f,float(90+XORRandom(21))*0.01f);
    }
	
	if(cmd == this.getCommandID("load_animation"))
    {
		this.getSprite().PlaySound(LOAD_SOUND,1.0f,float(90+XORRandom(21))*0.01f);
		this.getSprite().SetAnimation("reload");
		this.getSprite().SetEmitSoundPaused(true);
		this.set_u8("clickReload", 0);
    }
	
	if(cmd == this.getCommandID("reload_animation"))
    {
		if(RELOAD_SOUND != "")
			this.getSprite().PlaySound(RELOAD_SOUND,1.0f,float(90+XORRandom(21))*0.01f);
		this.getSprite().SetAnimation("default");
		this.set_u8("clickReload", 0);
    }
	
	if(cmd == this.getCommandID("make_clipgib"))
    {
		makeGibParticle(CLIP_SPRITE,this.getPosition(),Vec2f((this.isFacingLeft() ? -1 : 1),-1),0,0,Vec2f(8, 8),1.0f,0,"empty_magazine");
    }
	
	if(cmd == this.getCommandID("dryshot_animation"))
    {
		this.getSprite().PlaySound("DryShot.ogg",1.0f,float(90+XORRandom(21))*0.01f);
		this.add_u8("clickReload",1);
        MakeBangEffect(this, "click");
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
	//this.getSprite().PlaySound("PickupAmmo.ogg");
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint @detachedPoint) 
{
    CSprite@ sprite = this.getSprite();
    sprite.ResetTransform();
    sprite.animation.frame = 0;

    Vec2f aimvector = detached.getAimPos() - this.getPosition();
 	f32 angle = 0 - aimvector.Angle() + (this.isFacingLeft() == true ? 180.0f : 0);
    this.setAngleDegrees(angle);
    
	if(isServer()){
		if(T_TO_DIE > -1)this.server_SetTimeToDie(T_TO_DIE);
	}
}
