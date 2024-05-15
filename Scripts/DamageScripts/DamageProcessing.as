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
	
	bool needs_damage_indicators = blob.hasTag("flesh")||blob.hasTag("dummy")||blob.hasTag("tank");
	if (!needs_damage_indicators) return;
	
	Vec2f blob_world_pos = getDriver().getScreenPosFromWorldPos(blob.get_Vec2f("hitpoint"))-Vec2f(0, 16)*0;
	f32 endured_damage = blob.get_f32("endured_damage")*10;
	u32 ticks_from_hit = getGameTime()-blob.get_u32("last_hit");
	blob_world_pos.y -= ticks_from_hit/0.5f;
	//blob_world_pos.x += (XORRandom(100)-50)*0.1f;
	if (ticks_from_hit > 12) return;
	
	if (endured_damage < 1) return;
	
	GUI::SetFont("casio");
	string format_damage = formatFloat(endured_damage, "", 0, 0);
	f32 parsed_damage = parseFloat(format_damage);
	string fancied_string = splitNumberEachThreeDigits(parsed_damage);
	GUIDrawTextCenteredOutlined(fancied_string, blob_world_pos, SColor(255, 255, Maths::Max(0, 255-endured_damage), 64), SColor(128, 0, 0, 0));
	GUI::SetFont("menu");
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
	
	switch (customData)
	{
		case Hitters::suicide:
			if (this.hasTag("no suicide")||this.hasTag("halfdead")) return 0;
			this.server_Die();
			this.getSprite().Gib();
			this.Tag("do gib");
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
	if (this.getHealth()>0&&this.hasTag("player"))
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
	
	// gib if health below gibHealth
	f32 gibHealth = getGibHealth(this);
	// kill the blob if it should
	if (this.getHealth() <= gibHealth)
	{
		this.Tag("died naturally");
		this.getSprite().Gib();
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
			getRules().add_u32("team_"+this.getTeamNum()+"_tags", 1.00f*20*true_damage+0.05f);
			//attackers only 75%
			getRules().add_u32("team_"+hitterBlob.getTeamNum()+"_tags", 0.75f*20*true_damage+0.05f);
		}
		server_SyncGamemodeVars();
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