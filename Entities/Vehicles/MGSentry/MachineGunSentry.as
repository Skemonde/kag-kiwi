#include "KIWI_Hitters"
#include "FirearmVars"
#include "BulletCase"
#include "Requirements"

class TurretSettings
{
	uint8 LVL;
	uint8 DAMAGE;
	uint8 FIRE_RATE;	
	uint8 SPREAD;
	uint8 CONSUMPTION_CHANCE;
	
	TurretSettings()
	{
		LVL = 1;
		DAMAGE = 10;
		FIRE_RATE = 15;
		SPREAD = 18;
		CONSUMPTION_CHANCE = 100;
	}
};

TurretSettings@ setLevelTwo()
{
	TurretSettings@ settings = TurretSettings();
	settings.LVL = 2;
	settings.DAMAGE = 11;
	settings.FIRE_RATE = 7;
	settings.SPREAD = 12;
	settings.CONSUMPTION_CHANCE = 100;
	return settings;
}

TurretSettings@ setLevelThree()
{
	TurretSettings@ settings = TurretSettings();
	settings.LVL = 3;
	settings.DAMAGE = 13;
	settings.FIRE_RATE = 4;
	settings.SPREAD = 8;
	settings.CONSUMPTION_CHANCE = 66;
	return settings;
}

string my_ammo = "highpow";
string my_sound = "turret_shot.ogg";

void onInit(CBlob@ this)
{
	TurretSettings@ settings = TurretSettings();
	this.addCommandID("play_shoot_sound");
	this.addCommandID("upgrade");
	//so zombies target it too
	this.Tag("materiel");
	
	this.set_u16("target", 0);
	this.set_u32("customData", 1);
	this.Sync("customData", true);
	
	this.Tag("NoAccuracyBonus");
	this.Tag("TankShellProj");
	this.Tag("builder always hit");
	this.Tag("bullet_hits");
	this.Tag("non_pierceable");
	this.Tag("has damage owner");
}

void onInit(CSprite@ this)
{
	this.SetRelativeZ(-20.0f);
	CSpriteLayer@ head = this.addSpriteLayer("head", "MGS_Head.png", 56, 16);
	if (head !is null)
	{
		Animation@ default_anim = head.addAnimation("default", 1, false);
		int[] default_frames = {0};
		default_anim.AddFrames(default_frames);
		Animation@ shooting_anim = head.addAnimation("shooting", 2, false);
		int[] shooting_frames = {2,3,1};
		shooting_anim.AddFrames(shooting_frames);
		head.SetOffset(head_offset);
		head.SetRelativeZ(-19.0f);
		head.SetVisible(true);
	}
	CSpriteLayer@ gun = this.addSpriteLayer("gun", "MGS_Gun.png", 56, 16);
	if (gun !is null)
	{
		gun.SetOffset(head_offset);
		gun.SetRelativeZ(-19.0f);
		gun.SetVisible(true);
	}
}

Vec2f head_offset = Vec2f(-7,-6);

void onTick(CBlob@ this)
{
	TurretSettings@ settings = TurretSettings();
	if (this.exists("customData")) {
		switch (this.get_u32("customData")) {
			case 2:
				@settings = setLevelTwo(); break;
			case 3:
				@settings = setLevelThree(); break;
		}
	}
	
	//after turret settings
	FirearmVars vars = FirearmVars();
	vars.BUL_PER_SHOT				= 1;
	vars.B_SPREAD					= settings.SPREAD;
	
	vars.B_GRAV						= Vec2f(0, 0.0006);
	vars.B_DAMAGE					= settings.DAMAGE;
	vars.B_HITTER					= HittersKIWI::sentry;
	vars.B_TTL_TICKS				= 100;
	vars.B_KB						= Vec2f_zero;
	vars.B_SPEED					= 12;
	vars.B_PENETRATION				= 0;
	vars.BULLET_SPRITE				= "smg_bullet";
	vars.ONOMATOPOEIA				= "";
	vars.FIRE_SOUND					= my_sound;
	vars.RANGE			 			= 3000;
	this.set("firearm_vars", @vars);
	
	if (settings is null) return;
	CSprite@ sprite = this.getSprite();
	const bool flip = this.isFacingLeft();
	const f32 flip_factor = flip ? -1 : 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	Vec2f rotoff = Vec2f(0, -4);
	
	CSpriteLayer@ head = sprite.getSpriteLayer("head");
	CSpriteLayer@ gun = sprite.getSpriteLayer("gun");
	
	CBitStream missing;
	CBitStream shot_reqs = getShotReqs();
	
	if (head !is null || gun !is null)
	{
		//because of sprite indexing starting from 0 instead of 1
		gun.SetFrame(settings.LVL-1);
		if (!hasRequirements(this.getInventory(), null, shot_reqs, missing)) {
			head.SetAnimation("default");
			//no ammo? no shooting!!!
			print("hey");
			return;
		} else {
			head.SetAnimation("shooting");
		}
	}
	
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("AMOGUS");
	
	if (ap !is null) {
		CBlob@ driver = ap.getOccupied();
		CMap@ map = getMap();
		CBlob@[] blobs;
		map.getBlobsInRadius(this.getPosition(), 400, @blobs);
	
		int index = -1;
		f32 s_dist = 900000.00f;
		u8 myTeam = this.getTeamNum();
	
		for (int i = 0; i < blobs.length; i++)
		{
			CBlob@ b = blobs[i];
			u8 team = b.getTeamNum();
	
			f32 dist = (b.getPosition() - this.getPosition()).LengthSquared();
			
			if (team != myTeam && dist < s_dist && b.hasTag("flesh") && !b.hasTag("dead") && !b.hasTag("migrant") && isVisible(this, b))
			{
				s_dist = dist;
				index = i;
			}
		}
		
		CPlayer@ guy = getPlayerByUsername(this.get_string("host_username"));
		if (guy !is null)
			this.SetDamageOwnerPlayer(guy);
		CPlayer@ host = this.getDamageOwnerPlayer();
	
		if (index != -1)
		{
			CBlob@ target = blobs[index];
			if (target !is null)
			{
				this.getCurrentScript().tickFrequency = 1;
	
				if (target.getNetworkID() != this.get_u16("target"))
				{
					if (host !is null && target !is host.getBlob())
						this.getSprite().PlaySound("ScopeFocus.ogg", 4.00f, 1.00f);
				}
	
				this.set_u16("target", target.getNetworkID());
			}
		}
		else
		{
			this.getCurrentScript().tickFrequency = 10;
		}
		
		CBlob@ t = getBlobByNetworkID(this.get_u16("target"));
		if (t !is null)
		{
			this.SetFacingLeft((t.getPosition().x - this.getPosition().x) < 0);
	
			CPlayer@ _target = t.getPlayer();
			if (host !is null && _target is host) //recognizes host and changes team
			{
				//this.server_setTeamNum(_target.getTeamNum());
				//this.getSprite().PlaySound("party_join.ogg");
				//@t = null;
			}
		}
		if (t is null || !isVisible(this, t) || ((t.getPosition() - this.getPosition()).LengthSquared() > 450.00f * 450.00f) || t.hasTag("dead") || !t.isActive() || t.getTeamNum() == this.getTeamNum()) //if blob doesn't exist or gone out of tracking range or LoS
		{
			this.set_u16("target", 0); //then reset targetting
		}
		
		if (this.get_u16("target") != 0 || driver !is null) {
			f32 angle = 0;
			if (driver !is null) {
				CPlayer@ host = driver.getPlayer();
				if (host !is null) {
					this.set_string("host_username", host.getUsername());
				}
				angle = getCannonAngle(this, driver);
				this.SetFacingLeft(driver.getAimPos().x<driver.getPosition().x);
				this.getCurrentScript().tickFrequency = 1;
			} else {
				this.SetFacingLeft(t.getPosition().x<this.getPosition().x);
				if (t !is null) {
					Vec2f dir = t.getPosition()+Vec2f(0,t.getRadius()/2) - (this.getPosition() - Vec2f(0, 3));
					dir.Normalize();
					angle = -dir.Angle() + (this.isFacingLeft() ? 180 : 0);
				}
			}
			
			//calculating after setting facing direction
			const bool flip = this.isFacingLeft();
			const f32 flip_factor = flip ? -1 : 1;
			const u16 angle_flip_factor = flip ? 180 : 0;
			
			CSpriteLayer@ head = sprite.getSpriteLayer("head");
			CSpriteLayer@ gun = sprite.getSpriteLayer("gun");
			if (head !is null || gun !is null)
			{
				head.ResetTransform();
				head.RotateBy(angle+this.getAngleDegrees(), Vec2f(-head_offset.x*flip_factor,-head_offset.y)+rotoff);
				gun.ResetTransform();
				gun.RotateBy(angle+this.getAngleDegrees(), Vec2f(-head_offset.x*flip_factor,-head_offset.y)+rotoff);
			}
			
			u8 interval = this.get_u8("interval");
			
			if (interval > 0) {
				//print("interval: "+interval);
				interval--;
			}
			else if (interval == 0)
			{
				//it either controlled by script itself or a player can shoot it
				if ((t !is null && driver is null) || (driver !is null && ap.isKeyPressed(key_action1)))
				{					
					if (isServer()) {
						Vec2f muzzle = Vec2f(20*flip_factor,-8.5).RotateBy(angle+this.getAngleDegrees(), rotoff);
						
						shootGun(this.getNetworkID(), angle+this.getAngleDegrees(), this.getNetworkID(), this.getPosition() + muzzle);
						this.SendCommand(this.getCommandID("play_shoot_sound"));
						interval = settings.FIRE_RATE;
						if (XORRandom(100)<settings.CONSUMPTION_CHANCE)
							//this.TakeBlob(my_ammo, 1);
							server_TakeRequirements(this.getInventory(), null, shot_reqs);
					}
					if (isClient())
						MakeEmptyShellParticle(this, vars.CART_SPRITE, 1, Vec2f(-69, -69), this);
				}
			}
			if (isServer())
				this.set_u8("interval", interval);
			this.Sync("interval", true);
			
			//these two for empty cases animation only
			this.set_f32("gunangle", angle+this.getAngleDegrees());
			this.set_Vec2f("gun_trans", Vec2f(24, -3));
		}
	}
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
	if (this.getInventory().isFull() || blob is null) return;
	if (blob.getName() == my_ammo) {
		this.server_PutInInventory(blob);
	}
}

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	this.getSprite().PlaySound("thud.ogg", 4.0f);
}

void onRender(CSprite@ this)
{
	if (this is null) return;
	CBlob@ blobus = this.getBlob();
	
	AttachmentPoint@ ap = blobus.getAttachments().getAttachmentPointByName("AMOGUS");
	
	if (ap !is null) {
		CBlob@ driver = ap.getOccupied();
		if (driver !is null) {
			Vec2f pos = blobus.getInterpolatedScreenPos();
			GUI::SetFont("menu");
			GUI::DrawTextCentered("Ammo left: "+GetItemAmount(blobus), Vec2f(pos.x, pos.y + Maths::Sin(getGameTime() / 5.0f) * 5.0f), (GetItemAmount(blobus) > 0 ? SColor(0xfffffcf0) : SColor(0xffe25322)));
		}
	}
}

u16 GetItemAmount(CBlob@ this, const string item_name = "highpow")
{
	//if (this.getTeamNum() == 250) return 50;

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

	return 0;
}

bool isVisible(CBlob@ this, CBlob@ target)
{
	Vec2f col;
	return !getMap().rayCastSolidNoBlobs(this.getPosition(), target.getPosition(), col);
}

bool isInventoryAccessible( CBlob@ this, CBlob@ forBlob )
{
	return forBlob.getTeamNum() == this.getTeamNum() && !forBlob.isAttached();
}

f32 getCannonAngle( CBlob@ this, CBlob@ holder )
{
 	Vec2f aimvector = holder.getAimPos() - this.getPosition()+Vec2f(0,8.5);
    return holder.isFacingLeft() ? -aimvector.Angle()+180.0f : -aimvector.Angle();
}

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

CBitStream getUpgradeReqs()
{
	CBitStream upgrade_reqs;
	upgrade_reqs.write_string("blob");
	upgrade_reqs.write_string("mat_steel");
	upgrade_reqs.write_string("friendlyName");
	upgrade_reqs.write_u16(8);
	return upgrade_reqs;
}

CBitStream getShotReqs()
{
	CBitStream upgrade_reqs;
	upgrade_reqs.write_string("blob");
	upgrade_reqs.write_string("highpow");
	upgrade_reqs.write_string("friendlyName");
	upgrade_reqs.write_u16(1);
	return upgrade_reqs;
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBlob@ carried = caller.getCarriedBlob();
	if (caller is null || this.get_u32("customData") > 2)
		return;

	CBitStream params;
	params.write_u16(caller.getNetworkID());
	CButton@ button = caller.CreateGenericButton("$arrow_topleft$", Vec2f(0, -8), this, this.getCommandID("upgrade"), "Upgrade for 8 steel bars", params);
	if (button !is null) {
		CBitStream missing;
		CBitStream upgrade_reqs = getUpgradeReqs();
		button.SetEnabled(hasRequirements(caller.getInventory(), this.getInventory(), upgrade_reqs, missing));
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params) 
{
	if(cmd == this.getCommandID("play_shoot_sound")) 
	{
		CSpriteLayer@ head = this.getSprite().getSpriteLayer("head");
		if (head !is null) {
			head.SetAnimation("shooting");
			head.SetFrameIndex(0);
		}
	}
	if(cmd == this.getCommandID("upgrade")) 
	{
		if (this.get_u32("customData") > 2) return;
		u16 caller_id;
		if (!params.saferead_u16(caller_id)) return;
		CBlob@ caller = getBlobByNetworkID(caller_id);
		
		this.add_u32("customData", 1);
		this.getSprite().PlaySound("upgrade", 1.0, 1.0);
		
		CBitStream missing;
		CBitStream upgrade_reqs = getUpgradeReqs();
		server_TakeRequirements(caller.getInventory(), this.getInventory(), upgrade_reqs);
		//caller.TakeBlob("mat_steel", 8);
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return true;
}