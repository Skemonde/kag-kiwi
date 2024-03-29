// Princess brain

#include "Hitters"
#include "KIWI_Hitters"
#include "Explosion"
#include "FireParticle"
#include "FireCommon"
#include "RunnerCommon"
#include "ThrowCommon"
#include "KnightCommon"
#include "ShieldCommon"
#include "Knocked"
#include "Help"
#include "FirearmVars"
#include "ParticleSparks"
#include "SoldatInfo"
#include "Gunlist"

void knight_actorlimit_setup(CBlob@ this)
{
	u16[] networkIDs;
	this.set("LimitedActors", networkIDs);
}

bool knight_has_hit_actor(CBlob@ this, CBlob@ actor)
{
	u16[]@ networkIDs;
	this.get("LimitedActors", @networkIDs);
	return networkIDs.find(actor.getNetworkID()) >= 0;
}

u32 knight_hit_actor_count(CBlob@ this)
{
	u16[]@ networkIDs;
	this.get("LimitedActors", @networkIDs);
	return networkIDs.length;
}

void knight_add_actor_limit(CBlob@ this, CBlob@ actor)
{
	this.push("LimitedActors", actor.getNetworkID());
}

void knight_clear_actor_limits(CBlob@ this)
{
	this.clear("LimitedActors");
}

void onInit(CBlob@ this)
{
	KnightInfo knight;
	knight.state = KnightStates::normal;
	knight.swordTimer = 0;
	knight.slideTime = 0;
	knight.doubleslash = false;
	knight.tileDestructionLimiter = 0;
	this.set("knightInfo", @knight);

	CSprite@ sprite = this.getSprite();

	this.Tag("player");
	this.Tag("flesh");
	this.Tag("human");
	this.Tag("grunt");
	
	/* u8 type = XORRandom(2);
	switch (type)
	{
		case 0: this.Tag("grunt"); break;
		case 1: this.Tag("commander"); break;
	} */
	
	this.push("names to activate", "keg");
	this.push("names to activate", "mat_waterbombs");
	
	this.getCurrentScript().tickFrequency = 1;

	this.getShape().SetRotationsAllowed(false);
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;
	this.set_Vec2f("inventory offset", Vec2f(0.0f, 0.0f));
	this.set_f32("gib health", -5.0f);
	this.set_f32("death health", -5.0f);

	//this.getCurrentScript().runFlags |= Script::tick_not_attached;

	this.SetLight(false);
	this.SetLightRadius(64.0f);
	this.SetLightColor(SColor(255, 10, 250, 200));

	this.set_u32("timer", 0);
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if(cmd == this.getCommandID("set head to update"))
	{
		if (!isClient()) return;
		this.Tag("needs a head update");
		//CSprite@ sprite = this.getSprite();
		//if (sprite is null) return;
		
		//sprite.RemoveSpriteLayer("head");
		//sprite.RemoveSpriteLayer("hat");
	}
	if(cmd == this.getCommandID("add force"))
	{
		Vec2f force; if (!params.saferead_Vec2f(force)) return;
		
		this.AddForce(force);
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

void DeleteRespawnSupplies(CBlob@ this)
{
	if (!isServer()) return;
	CInventory@ inv = this.getInventory();
	if (inv is null) return;
	u32 items = inv.getItemsCount();
	for (int idx = 0; idx < items; ++idx) {
	//print("hey");
		CBlob@ cur_item = inv.getItem(idx);
		if (cur_item is null) continue;
		if (!cur_item.hasTag("supply thing")) continue;
		
		cur_item.server_Die();
	}
}

void onDie(CBlob@ this)
{
	//DeleteRespawnSupplies(this);
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
	CBlob@ gun = server_CreateBlob(/*"cross"*/gunids[Maths::Min(gunid, gunids.size()-2)], teamnum, this.getPosition());
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
	this.set_u16("LMB_item_netid", gun.getNetworkID());
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

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null) player.SetScoreboardVars("ScoreboardIcons.png", 15, Vec2f(16, 16));
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

void changeMinimapRenderLogic(CBlob@ this)
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
	return;
	const bool FLIP = this.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	HitInfo@[] hitInfos;
	if ((this.isKeyPressed(key_right)||this.isKeyPressed(key_left))&&!this.isKeyPressed(key_down))
	{
		f32 stairs_angle = this.getVelocity().x>0?0:180;
		if (this.isKeyPressed(key_right)&&!this.isKeyPressed(key_left))
			stairs_angle = 0;
		else if (this.isKeyPressed(key_left))
			stairs_angle = 180;
		bool tile_above = false;
		if (getMap().getHitInfosFromRay(this.getPosition()-Vec2f(0, 4), stairs_angle, 9, this, @hitInfos))
		{
			for (int counter = 0; counter < hitInfos.length; ++counter)
			{
				CBlob@ doomed = hitInfos[counter].blob;
				if (doomed !is null) continue;
				
				tile_above = true;
			}
		}
		
		if (!tile_above&&this.getVelocity().y>-2.0)
		if (getMap().getHitInfosFromRay(this.getPosition()+Vec2f(0, 5.5), stairs_angle, 8, this, @hitInfos))
		{
			for (int counter = 0; counter < hitInfos.length; ++counter)
			{
				CBlob@ doomed = hitInfos[counter].blob;
				if (doomed !is null) continue;
				
				this.AddForce(Vec2f(0, -60));
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
	if (this.get_u32("timer") > 1) this.set_u32("timer", this.get_u32("timer") - 1);
	
	CheckForTilesToAutojump(this);
	
	CheckForHalfDeadStatus(this);
	
	DoPassiveHealing(this);
	
	changeMinimapRenderLogic(this);
	
	CheckIfNeedGuns(this);
	
	UpdateBodySprites(this);
	
	CheckIfHoldingHealthyMan(this);

	RunnerMoveVars@ moveVars;
	if (!this.get("moveVars", @moveVars))
	{
		return;
	}
	
	u8 knocked = getKnocked(this);
	
	if (this.isInInventory())
		return;

	if (!this.get("moveVars", @moveVars))
	{
		return;
	}

	Vec2f pos = this.getPosition();
	Vec2f aimpos = this.getAimPos();
	const bool inair = (!this.isOnGround() && !this.isOnLadder());

	CMap@ map = getMap();

	bool pressed_a1 = this.isKeyPressed(key_action1) && !this.hasTag("noLMB");
	bool pressed_a2 = this.isKeyPressed(key_action2);
	bool walking = (this.isKeyPressed(key_left) || this.isKeyPressed(key_right));

	const bool myplayer = this.isMyPlayer();

	if (myplayer)
	{
		if (this.isKeyJustPressed(key_action3))
		{
			client_SendThrowOrActivateCommand(this);
		}
	}

	moveVars.walkFactor *= 1.000f;
	moveVars.jumpFactor *= 0.900f;
	
	/* CBlob@ carried = this.getCarriedBlob();
	if (carried !is null)
	if (carried.getName()=="wrench") {
		bool ready = carried.get_u32("next attack") < getGameTime();
		if (!ready) {
			moveVars.walkFactor *= 0;
			moveVars.jumpFactor *= 0;
		}
	} */

	if (knocked > 0)
	{
		pressed_a1 = false;
		pressed_a2 = false;
		walking = false;
		
		return;
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
}

void changeBackpackState(CBlob@ this, CBlob@ blob)
{
	return;
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

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.isCollidable()&&!blob.hasTag("player");
	return this.getTeamNum() != blob.getTeamNum() || blob.isCollidable();
}