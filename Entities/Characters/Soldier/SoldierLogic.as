// Princess brain

#include "Hitters"
#include "KIWI_Hitters"
#include "Explosion"
#include "FireParticle"
#include "FireCommon"
#include "RunnerCommon"
#include "ThrowCommon"
#include "ShieldCommon"
#include "Knocked"
#include "Help"
#include "FirearmVars"
#include "ParticleSparks"
#include "SoldatInfo"
#include "Gunlist"
#include "BuilderCommon"

void onInit(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();

	this.Tag("player");
	this.Tag("flesh");
	
    this.addCommandID("set head to update");
    this.addCommandID("get a gun");
    this.addCommandID("set invincible");
    this.addCommandID("add force");
    this.addCommandID("set vel");
    this.addCommandID("open inventory");
	this.addCommandID("activate/throw");
	
	this.getCurrentScript().tickFrequency = 1;
	
	this.sendonlyvisible = false;

	this.getShape().SetRotationsAllowed(false);
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;
	this.set_Vec2f("inventory offset", Vec2f(0.0f, 0.0f));
	this.set_f32("gib health", -5.0f);
	this.set_f32("death health", -5.0f);
	
	Vec2f legs_dims = Vec2f(12, 8);
	Vec2f legs_pos = Vec2f(0, 3.5);
	Vec2f[] legs_shape =
	{
		Vec2f(legs_pos.x-legs_dims.x/2, 			legs_pos.y-legs_dims.y/2),
		Vec2f(legs_pos.x+legs_dims.x/2, 			legs_pos.y-legs_dims.y/2),
		Vec2f(legs_pos.x+legs_dims.x/2, 			legs_pos.y+legs_dims.y/2),
		Vec2f(legs_pos.x-legs_dims.x/2, 			legs_pos.y+legs_dims.y/2)
	};
	//this.getShape().AddShape(legs_shape);
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if(cmd == this.getCommandID("set head to update"))
	{
		if (!isClient()) return;
		this.Tag("needs a head update");
		this.Tag("needs a torso update");
	}
	if(cmd == this.getCommandID("add force"))
	{
		Vec2f force; if (!params.saferead_Vec2f(force)) return;
		
		this.AddForce(force);
	}
	if(cmd == this.getCommandID("set vel"))
	{
		Vec2f vel; if (!params.saferead_Vec2f(vel)) return;
		
		this.setVelocity(vel);
	}
	if(cmd == this.getCommandID("get a gun"))
	{
		u16 gun_id; if (!params.saferead_u16(gun_id)) return;
		CBlob@ gun_blob = getBlobByNetworkID(gun_id);
		if (gun_blob is null) return;
		
		this.set_string("main gun", gun_blob.getName());
		this.server_Pickup(gun_blob);
	}
	if(cmd == this.getCommandID("set invincible"))
	{
		this.set_u32("spawn immunity time", getGameTime());
		this.set_u32("custom immunity time", 120);
		
		this.Untag("invincibility done");
		this.Tag("invincible");
		
		this.server_SetHealth(0.05f);
		
		this.getSprite().PlaySound("Heal.ogg", 1, 1);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller is null) return;
	if (caller.getTeamNum() != this.getTeamNum()) return;
	
	// if (caller.getTeamNum() == this.getTeamNum() && caller.isOverlapping(this))
	if ((caller.getPosition() - this.getPosition()).Length() >= 24.0f) return;
	if (this.isMyPlayer()) return;
	if (this.getPlayer() !is null && !this.getPlayer().isBot()) return;

	CBlob@ carried = caller.getCarriedBlob();
	if (carried is null) return;
	//if (!carried.hasTag("firearm")) return;

	CBitStream params;
	params.write_u16(carried.getNetworkID());
	CButton@ button = caller.CreateGenericButton(11, Vec2f(0, 0), this,  this.getCommandID("get a gun"), "Have this gun!", params);
}

void GiveGunAndStuff(CBlob@ this, CPlayer@ player)
{
	// gun and ammo
	if (!isServer()) return;
	
	this.Untag("needs_weps");
	u8 teamnum = this.getTeamNum();
	u8 gunid = XORRandom(gunids.length-1);
	
	SoldatInfo[]@ infos = getSoldatInfosFromRules();
	if (infos is null) return;
	SoldatInfo our_info = getSoldatInfoFromUsername(player.getUsername());
	if (our_info is null) return;
	int info_idx = getInfoArrayIdx(our_info);
	
	u8 rank = infos[info_idx].rank;
	bool commander = rank > 4;
	gunid = rank; //Maths::Min(3, rank);//+(player.getTeamNum()==1?5:0);
	//if (rank >= 10) gunid = rank;
	//gunid = Maths::Min(gunids.size()-2, getRules().get_u8(player.getUsername()+"rank"));
	
	if (commander) gunid = 6;
	
	CBlob@ gun = server_CreateBlob(gunids[Maths::Min(gunid, gunids.size()-2)], teamnum, this.getPosition());
	//CBlob@ knife = server_CreateBlob("combatknife", teamnum, this.getPosition());
	if (getRules().isWarmup()||true) {
		CBlob@ hammer = server_CreateBlob("masonhammer", teamnum, this.getPosition());
		this.server_PutInInventory(hammer);
		hammer.SetDamageOwnerPlayer(player);
		hammer.AddScript("DieUponOwnerDeath.as");
		hammer.AddScript("DoTicksInInventory.as");
		hammer.setInventoryName(player.getCharacterName()+"'s "+hammer.getInventoryName());
		hammer.Tag("supply thing");
	}
	if (commander) {
		CBlob@ talkie = server_CreateBlob("wt", teamnum, this.getPosition());
		this.server_PutInInventory(talkie);
		talkie.SetDamageOwnerPlayer(player);
		talkie.AddScript("DieUponOwnerDeath.as");
		talkie.AddScript("DoTicksInInventory.as");
		talkie.setInventoryName(player.getCharacterName()+"'s "+talkie.getInventoryName());
		talkie.Tag("supply thing");
	}
	if (gun is null) return;
	
	gun.AddScript("DieUponOwnerDeath.as");
	gun.AddScript("DoTicksInInventory.as");
	gun.setInventoryName(player.getCharacterName()+"'s "+gun.getInventoryName());
	gun.Tag("supply thing");
	//knife.AddScript("DieUponOwnerDeath.as");
	//knife.AddScript("DoTicksInInventory.as");
	gun.SetDamageOwnerPlayer(player);
	//knife.SetDamageOwnerPlayer(player);
		
	//this.set_u16("LMB_item_netid", knife.getNetworkID());
	this.set_string("main gun", gun.getName());
	//this.set_u16("LMB_item_netid", gun.getNetworkID());
	CBitStream params;
	params.write_u16(this.getNetworkID());
	params.write_u16(gun.getNetworkID());
	this.SendCommand(this.getCommandID("set item for LMB"), params);
	this.server_Pickup(gun);
	
	FirearmVars@ vars;
	if (!gun.get("firearm_vars", @vars)) return;
	int AltFire = gun.get_u8("override_alt_fire");
	if(AltFire == AltFire::Unequip)AltFire = vars.ALT_FIRE;
	
	bool giveGrenades = false;
	if(AltFire==AltFire::UnderbarrelNader&&vars.AMMO_TYPE.size()>1)
		giveGrenades = true;
	
	u8 ammoAmount = 1;
	u8 grenadesAmount = 0;
	if (giveGrenades)
		grenadesAmount = 2;
	for (int counter = 0; counter < ammoAmount+grenadesAmount; ++counter) {
		if (!getRules().get_bool("ammo_usage_enabled")) break;
		string currentAmmo = counter>=ammoAmount?vars.AMMO_TYPE[1]:vars.AMMO_TYPE[0];
		CBlob@ ammo = server_CreateBlob(currentAmmo, teamnum, this.getPosition());
		if (ammo is null) return;
		
		this.server_PutInInventory(ammo);
		
		if (XORRandom(100)<100) {
			ammo.AddScript("DieUponOwnerDeath.as");
			ammo.AddScript("DoTicksInInventory.as");
			ammo.SetDamageOwnerPlayer(player);
			ammo.Tag("supply thing");
		}
	}
		//this.server_PutInInventory(knife);
		//gun.SendCommand(gun.getCommandID("reload"));
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	if (this is byBlob) return false;
	
	return this.hasTag("dead") || this.hasTag("halfdead");
}

bool isInventoryAccessible( CBlob@ this, CBlob@ forBlob )
{
	return canBePickedUp(this, forBlob);
}

void DoPassiveHealing(CBlob@ this)
{
	if (!isServer()) return;
	if (this.hasTag("dead")) return;
	if (this.hasTag("halfdead")) return;
	if (this.getHealth()>=this.getInitialHealth()) return;
	
	u32 ticks_from_last_hit = getGameTime()-this.get_u32("last_hit_time");
	if (ticks_from_last_hit/getTicksASecond()>=10)
		this.server_Heal((ticks_from_last_hit-10*getTicksASecond())*0.00013);
}

void ChangeMinimapRenderLogic(CBlob@ this)
{
	CPlayer@ localplayer = getLocalPlayer();
	if (localplayer is null) return;
	
	CPlayer@ player = this.getPlayer();
	u8 team;
	if (player is null)
		team = this.getTeamNum();
	else
		team = player.getTeamNum();
	
	this.SetMinimapRenderAlways(localplayer.getTeamNum()==team);
}

void CheckForHalfDeadStatus(CBlob@ this)
{	
	const bool FLIP = this.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	
	if (this.getHealth()<=0) {
		string totem_name = "drug";
		bool we_die = false;
		
		if (this.getInventory().getItem(totem_name) is null) {
			we_die = true;
		} else {
			CBlob@ totem = this.getInventory().getItem(totem_name);
			if (totem !is null) totem.server_Die();
			
			if(isServer())
				this.SendCommand(this.getCommandID("set invincible"));
		}
		if (!we_die) return;
		
		if (!this.hasTag("halfdead")) {
			Sound::Play("ManArg3.ogg", this.getPosition(), 1, 1);
			this.server_DetachAll();
			ClearCarriedBlock(this);
			if (this.isMyPlayer())
				this.ClearMenus();
		}
		this.DisableKeys(key_pickup | key_inventory | key_use | key_action3 | key_eat);
		this.set_u32("last_hit_time", getGameTime());
		
		this.Tag("halfdead");
		
		CBlob@ attacker = getBlobByNetworkID(this.get_u16("last_hitter_id"));
		if (attacker is null) {
			@attacker = this;
		}
		
		if (attacker is null) return;
		
		//this only runs when there's a blob to hit us
		if (isClient()) {
			for (int idx = 0; idx < 8; ++idx) {
				CParticle@ p = ParticleBlood(this.getPosition()+Vec2f(0, 4), Vec2f(0,-(XORRandom(40))*0.075f).RotateBy(FLIP_FACTOR*-60+Maths::Sin((getGameTime()+idx)%90)*9), SColor(255, 126, 0, 0));
			}
		}
		
		if ((getGameTime()-this.get_u32("last_hit"))%120==0) {
			attacker.server_Hit(this, this.getPosition(), Vec2f(), 1.0f, 0);
			Sound::Play("ManArg6.ogg", this.getPosition(), 1, 1);
			//Sound::Play("ManArg"+(XORRandom(6)+1)+".ogg", this.getPosition(), 1, 1);
		}
		//this.Damage(0.15f, attacker);
	} else {
		if (this.hasTag("halfdead")) {
			this.DisableKeys(0);
		}
		this.Untag("halfdead");
	}
}

void CheckForTilesToAutojump(CBlob@ this)
{
	//disabled
	if (!this.isOnGround()||!this.wasOnGround()) return;
	const bool FLIP = this.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	HitInfo@[] hitInfos;
	if ((this.isKeyPressed(key_right)||this.isKeyPressed(key_left))&&!(this.isKeyPressed(key_up)||this.isKeyPressed(key_down)))
	{
		f32 stairs_angle = this.getVelocity().x>0?0:180;
		f32 moving_dir = this.getVelocity().x>0?1:this.getVelocity().x<0?-1:0;
		if (!FLIP||false&&this.isKeyPressed(key_right)&&!this.isKeyPressed(key_left))
			stairs_angle = 0;
		else if (true||this.isKeyPressed(key_left))
			stairs_angle = 180;
		bool tile_above = false;
		if (getMap().getHitInfosFromRay(this.getPosition()-Vec2f(0, 4), stairs_angle, 9, this, @hitInfos))
		{
			for (int counter = 0; counter < hitInfos.length; ++counter)
			{
				CBlob@ doomed = hitInfos[counter].blob;
				if (doomed !is null) {
					if (doomed.getShape().isStatic()&&doomed.getShape().getConsts().collidable) {
						tile_above = true;
						break;
					}
					continue;
				}
				
				tile_above = true;
				break;
			}
		}
		
		if (getMap().getHitInfosFromRay(this.getPosition()-Vec2f(4*FLIP_FACTOR, 10), stairs_angle, 9, this, @hitInfos))
		{
			for (int counter = 0; counter < hitInfos.length; ++counter)
			{
				CBlob@ doomed = hitInfos[counter].blob;
				if (doomed !is null) {
					if (doomed.getShape().isStatic()&&doomed.getShape().getConsts().collidable) {
						tile_above = true;
						break;
					}
					continue;
				}
				
				tile_above = true;
				break;
			}
		}
		
		if (!tile_above)
		if (getMap().getHitInfosFromRay(this.getPosition()+Vec2f(0, 1), stairs_angle, 9, this, @hitInfos))
		{
			for (int counter = 0; counter < hitInfos.length; ++counter)
			{
				CBlob@ doomed = hitInfos[counter].blob;
				if (doomed !is null) continue;
				
				//this.AddForce(Vec2f(0, -60));
				bool just_started_moving = Maths::Abs(this.getOldVelocity().x)<1;
				
				this.setPosition(this.getPosition()-Vec2f(just_started_moving?-6*FLIP_FACTOR:0, 9));
				
				if (!just_started_moving) {
					Vec2f old_vel = this.getOldVelocity();
					this.setVelocity(old_vel);
				}
			}
		}
	}
}

void CheckIfNeedGuns(CBlob@ this)
{
	if (!isServer()) return;
	
	//i hate i have to do this :<
	CPlayer@ owner = this.getPlayer();
	if (owner !is null && !this.exists("starter_items_given")) {
		if (this.hasTag("needs_weps")) {
			GiveGunAndStuff(this,owner);
		}
		this.set_bool("starter_items_given", true);
	} else {
		//this.Tag("bot");
	}
}

void UpdateBodySprites(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ torso = sprite.getSpriteLayer("torso");
	CSpriteLayer@ arms = sprite.getSpriteLayer("arms");
	CSpriteLayer@ legs = sprite.getSpriteLayer("legs");
	CSpriteLayer@ right_arm = sprite.getSpriteLayer("right_arm");
	bool limb_visibility = this.hasTag("dead") ? false : sprite.isVisible();
	if (torso !is null)
		torso.SetVisible(limb_visibility);
	if (arms !is null)
		arms.SetVisible(limb_visibility);
	if (legs !is null)
		legs.SetVisible(limb_visibility);
	if (right_arm !is null)
		right_arm.SetVisible(limb_visibility);
}

void CheckIfHoldingHealthyMan(CBlob@ this)
{
	CBlob@ carried = this.getCarriedBlob();
	if (carried is null) return;
	if (!carried.hasTag("player")) return;
	if (carried.getHealth()<0) return;
	
	carried.server_DetachFrom(this);
}

void onTick(CBlob@ this)
{	
	CheckForTilesToAutojump(this);
	
	CheckForHalfDeadStatus(this);
	
	DoPassiveHealing(this);
	
	ChangeMinimapRenderLogic(this);
	
	CheckIfNeedGuns(this);
	
	UpdateBodySprites(this);
	
	CheckIfHoldingHealthyMan(this);
	
	ThrowOrActivateLogic(this);
	
	CustomCameraSway(this);
}

void CustomCameraSway(CBlob@ this)
{
	CCamera@ localcamera = getCamera();
	if (localcamera is null) return;
	
	if (!this.isMyPlayer()) return;
	
	CBlob@ carried = this.getCarriedBlob();
	bool has_binos = carried !is null && carried.getConfig()=="bino" && this.isAttached();
	
	if (!(this.isKeyPressed(key_down)||has_binos)) {
		this.set_Vec2f("cam_pos", this.get_Vec2f("cam_pos")/(getGameTime()-this.get_u32("last_sway")));
		return;
	} else {
		this.set_u32("last_sway", getGameTime());
	}
	
	if (this.getAirTime()>5&&!has_binos) {
		this.set_Vec2f("cam_pos", this.get_Vec2f("cam_pos")/this.getAirTime());
		return;
	}
	
	const f32 SCALEX = getDriver().getResolutionScaleFactor();
	const f32 ZOOM = getCamera().targetDistance * SCALEX;
	
	Vec2f target_pos = getControls().getMouseScreenPos();
	Vec2f center_point = Vec2f(getDriver().getScreenWidth()/2, getDriver().getScreenHeight()/2);
	target_pos += this.getInterpolatedScreenPos();
	center_point *= 2;
	Vec2f dif = target_pos - center_point;
	f32 camvec_angle = -dif.Angle();
	f32 cam_speed = dif.Length()/10;
	//print("scalex "+ZOOM);
	
	if (dif.Length()>(5*ZOOM))
		this.set_Vec2f("cam_pos", this.get_Vec2f("cam_pos")+Vec2f(cam_speed, 0).RotateBy(camvec_angle));
	
	localcamera.setPosition(this.getInterpolatedPosition()+this.get_Vec2f("cam_pos"));
	localcamera.setRotation(0);
	//localcamera.setRotation(Maths::Sin(getGameTime()%10)*2);
}

void ThrowOrActivateLogic(CBlob@ this)
{
	if (this.isMyPlayer())
	{
		if (this.isKeyJustPressed(key_action3))
		{
			CBlob@ carried = this.getCarriedBlob();
			bool holding = carried !is null;
			
			if (holding)
			{
				client_SendThrowOrActivateCommand(this);
			}			
		}
	}	
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2 )
{
	if (blob !is null) {
		if(blob.getName()!="bandage"||!this.hasTag("halfdead")) return;
		
		blob.server_Die();
			
		if(isServer())
			this.SendCommand(this.getCommandID("set invincible"));
		
		return;
	}
	if (!solid) return;
	Vec2f vel = this.getOldVelocity();
	f32 vellen = vel.Length();
	if (vellen < 15) return;
	SetDazzled(this, 60);
	//print("vellen "+vellen);
}

void onChangeTeam( CBlob@ this, const int oldTeam )
{
	CSpriteLayer@ backpack = this.getSprite().getSpriteLayer("backpack");
	if (backpack is null) return;
	backpack.ReloadSprite(backpack.getFilename(), backpack.getFrameWidth(), backpack.getFrameHeight(), this.getTeamNum(), 0);
	
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

void changeBackpackState(CBlob@ this, CBlob@ blob)
{
	if (blob is null || this is null) return;
	if (blob.getName()!="masonhammer") return;
	//if (isServer()&&!isClient()) return;
	
	CSpriteLayer@ backpack = this.getSprite().getSpriteLayer("backpack");
	if (backpack is null) return;
	
	bool visibility = this.getBlobCount("masonhammer")>0;
	
	backpack.SetVisible(visibility);
}

void onAddToInventory( CBlob@ this, CBlob@ blob )
{
	changeBackpackState(this, blob);
}

void onRemoveFromInventory( CBlob@ this, CBlob@ blob )
{
	changeBackpackState(this, blob);
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	changeBackpackState(this, attached);
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{
	changeBackpackState(this, detached);
}