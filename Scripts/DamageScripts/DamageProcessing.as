#include "Hitters"
#include "KIWI_Hitters"
#include "ParticleSparks"
#include "CommonHitFXs"
#include "FleshHitFXs"
#include "StoneHitFXs"
#include "SteelHitFXs"
#include "Logging"
#include "Skemlib"
#include "VarsSync"

//unlike SteelHit, StoneHit and WoodenHit this script actually deals the damage to a blob after those scripts have calculated the damage amount
//add this at the very end of blob config so it dies properly after SteelHit or other hitting scripts

f32 getGibHealth(CBlob@ this)
{
	if (this.exists("gib health"))
	{
		return this.get_f32("gib health");
	}

	return 0.0f;
}

void onInit(CBlob@ this)
{
	this.set_f32("endured_damage", 0);
}

void onTick(CBlob@ this)
{
	this.Sync("endured_damage", true);
	f32 endured_damage = this.get_f32("endured_damage");
	u32 ticks_from_hit = getGameTime()-this.get_u32("last_hit");
	if (ticks_from_hit > 15)
		this.set_f32("endured_damage", 0);
	
	if (getGameTime()-this.get_u32("last_hit") > 1 && endured_damage != 0 && endured_damage < 10) {
		//print("end damage " + endured_damage);
		//makeDamageIndicator(this,endured_damage);
	}
}

void onDie(CBlob@ this)
{
	f32 endured_damage = this.get_f32("endured_damage");
	//print("death damage " + endured_damage);
	
	if (endured_damage != 0 && endured_damage < 10) {
		//makeDamageIndicator(this,endured_damage);
	}
}

void onRender( CSprite@ this )
{
	CBlob@ blob = this.getBlob();
	
	bool needs_damage_indicators = blob.hasTag("flesh")||blob.hasTag("dummy")||blob.hasTag("tank")||blob.hasTag("vehicle");
	if (!needs_damage_indicators) return;
	
	Vec2f blob_world_pos = getDriver().getScreenPosFromWorldPos(blob.get_Vec2f("hitpoint"))-Vec2f(0, 16)*0;
	f32 endured_damage = blob.get_f32("endured_damage")*10;
	u32 ticks_from_hit = getGameTime()-blob.get_u32("last_hit");
	blob_world_pos.y -= ticks_from_hit/0.8f;
	//blob_world_pos.x += (XORRandom(100)-50)*0.1f;
	if (ticks_from_hit > 12) return;
	
	if (endured_damage < 1) return;
	
	GUI::SetFont("newspaper");
	string format_damage = formatFloat(endured_damage, "", 0, 0);
	f32 parsed_damage = parseFloat(format_damage);
	string fancied_string = splitNumberEachThreeDigits(parsed_damage);
	GUIDrawTextCenteredOutlined(fancied_string, blob_world_pos, SColor(255, 255, Maths::Max(0, 255-endured_damage), 64), SColor(128, 0, 0, 0));
	GUI::SetFont("menu");
}

void KillOwnedItems(CBlob@ blob)
{
	CPlayer@ victim = blob.getPlayer();
	if (victim is null) return;
	
	CInventory@ inv = blob.getInventory();
	//print("i "+inv.getItemsCount());
	
	for (int idx = 0; idx < inv.getItemsCount(); ++idx)
	{
		CBlob@ cur_blob = inv.getItem(idx);
		if (cur_blob is null) continue;
		if (!cur_blob.exists("item_owner_id")) continue;
		if (cur_blob.get_u16("item_owner_id")!=victim.getNetworkID()) continue;
		
		//print("whaaaat");
		cur_blob.server_RemoveFromInventories();
		cur_blob.server_Die();
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	//shittest thing i've ever done about syncing
	if (isServer()) {
		this.set_f32("synced_damage", damage);
		this.Sync("synced_damage", true);
	} else if (isClient()) {
		damage = this.get_f32("synced_damage");
	}
	string tickets_prop = "tickets_"+this.getTeamNum();
				
	switch (customData)
	{
		case Hitters::suicide:
			if (this.hasTag("no suicide")||this.hasTag("halfdead")) return 0;
			this.getSprite().Gib();
			this.Tag("do gib");
			KillOwnedItems(this);
			this.server_Die();
			if (false) { //HACK i give the tickets back
				getRules().add_s32(tickets_prop, 1);
				getRules().Sync(tickets_prop, true);
			}
			//print("suicided! HA");
			return 0;
		case HittersKIWI::cos_will:
			if (!this.hasTag("player")&&this.getTeamNum()==hitterBlob.getTeamNum())
				return 0;
			break;
	}
	
	//no damage to drivers
	bool needs_hit_effect = true;
	if (this.hasTag("isInVehicle") || this.hasTag("invincible")) {
		damage *= 0;
		needs_hit_effect = false;
	}
	
	//don't deal more damage than necessary to kill a person
	if (this.getHealth()>0&&this.hasTag("player")&&damage<50)
		damage = Maths::Min(damage, 2*this.getHealth());
	
	if (damage > 0) {
	
	} else if (needs_hit_effect) {
		shieldHit(damage, this.getVelocity(), worldPoint);
	}
	
	f32 endured_damage = this.get_f32("endured_damage");
	//if (getGameTime()-this.get_u32("last_hit") > 1 && endured_damage != 0 && endured_damage < 10) {
	//	//makeDamageIndicator(this,endured_damage);
	//}else
		this.add_f32("endured_damage", damage);
	
	this.set_Vec2f("hitpoint", worldPoint);
	this.set_u32("last_hit", getGameTime());
	this.set_u16("last_hitter_id", hitterBlob.getNetworkID());
	
	f32 old_health = this.getHealth();
	
	if (!this.hasTag("dummy")) {
		this.Damage(damage, hitterBlob);
	}
	CBlob@ carried = this.getCarriedBlob();
	// gib if health below gibHealth
	f32 gibHealth = getGibHealth(this);
	// kill the blob if it should
	if (this.getHealth() <= gibHealth)
	{
		if (carried !is null)
		{
			carried.server_DetachFrom(this);
		}
		this.Tag("died naturally");
		this.getSprite().Gib();
		KillOwnedItems(this);
		this.server_Die();
	}
	
	f32 lowest_health = this.getHealth()<gibHealth?gibHealth:this.getHealth();
	f32 true_damage = old_health-lowest_health;
	//print("DMG "+true_damage*20);
	
	if (this.hasTag("player")||this.hasTag("vehicle")) {
		if (true_damage<0)
			print("PISDETZ: "+true_damage);
		if (this.getTeamNum()!=hitterBlob.getTeamNum() && true_damage>=0) {
			//defenders get 100% of poins
			f32 defender_perc = 1.00f;
			getRules().add_u32("team_"+this.getTeamNum()+"_tags", defender_perc*20*true_damage+0.05f);
			//attackers only 75%
			f32 attacker_perc = 0.75f;
			getRules().add_u32("team_"+hitterBlob.getTeamNum()+"_tags", attacker_perc*20*true_damage+0.05f);
		}
		server_SyncGamemodeVars();
		
		CPlayer@ damaged_p = this.getPlayer();
		CPlayer@ hitter_p = hitterBlob.getPlayer();
		if (hitter_p is null)
			@hitter_p = hitterBlob.getDamageOwnerPlayer();

		if (this.hasTag("player") && true_damage>=0)
		{
			f32 damaged_perc = 0.90f;
			if (damaged_p !is null && hitter_p !is null && hitterBlob !is this && hitter_p.getTeamNum() != damaged_p.getTeamNum())
				damaged_p.server_setCoins(damaged_p.getCoins()+damaged_perc*10*(true_damage+0.05f));
				
			f32 hitter_perc = 0.33f;
			if (hitter_p !is null && hitterBlob !is this && hitterBlob.getTeamNum() != this.getTeamNum())
				hitter_p.server_setCoins(hitter_p.getCoins()+hitter_perc*10*(true_damage+0.05f));
		}
	}
	
	return 0;
}

u16 getItemAmount(CBlob@ this, const string item_name = "highpow")
{
	CInventory@ inv = this.getInventory();
	CBlob@ carried = this.getCarriedBlob();
	u16 quan = 0;
	if (inv != null)
	{
		for (int i = 0; i < inv.getItemsCount(); ++i) {
			if (inv.getItem(i) != null && inv.getItem(i).getName() == item_name)
				quan += inv.getItem(i).getQuantity();
		}
	}
	if (carried !is null && carried.getName() == item_name)
		quan += carried.getQuantity();
	
	return quan;
}