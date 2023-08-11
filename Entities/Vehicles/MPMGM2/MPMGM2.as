#include "KIWI_Hitters"
#include "FirearmVars"
#include "BulletCase"

string my_ammo = "highpow";
string my_sound = "turret_shot.ogg";

void onInit(CBlob@ this)
{
	this.addCommandID("play_shoot_sound");
	this.addCommandID("upgrade");
	//so zombies target it too
	this.Tag("materiel");
	
	this.set_u16("target", 0);
	this.set_u32("customData", 1);
	this.Sync("customData", true);
	
	this.Tag("NoAccuracyBonus");
	this.Tag("TankShellProj");
}

void onInit(CSprite@ this)
{
	this.SetZ(30.0f);
}

Vec2f head_offset = Vec2f(-7,-6);

void onTick(CBlob@ this)
{	
	//after turret settings
	FirearmVars vars = FirearmVars();
	vars.BUL_PER_SHOT				= 1;
	vars.B_SPREAD					= 8;
	vars.FIRE_AUTOMATIC				= true;
	vars.UNIFORM_SPREAD				= true;
	
	vars.B_GRAV						= Vec2f(0, 0.0006);
	vars.B_DAMAGE					= 2;
	vars.B_HITTER					= HittersKIWI::bullet_hmg;
	vars.B_TTL_TICKS				= 100;
	vars.B_KB						= Vec2f_zero;
	vars.B_SPEED					= 12;
	vars.B_PENETRATION				= 0;
	vars.BULLET_SPRITE				= "smg_bullet.png";
	vars.FIRE_SOUND					= "kastengewehr_shot";
	vars.FIRE_PITCH					= 0.8;
	vars.ONOMATOPOEIA				= "";
	vars.RANGE						= 3000;
	this.set("firearm_vars", @vars);
	this.set_Vec2f("gun_trans", Vec2f(26, 6));
	
	CSprite@ sprite = this.getSprite();
	const bool flip = this.isFacingLeft();
	const f32 flip_factor = flip ? -1 : 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	Vec2f rotoff = Vec2f(0, 0);
	
	CBlob@ tripod = null;
	CBlob@ tank = null;
	@tripod = getBlobByNetworkID(this.get_u16("tripod_id"));
	AttachmentPoint@ pilotpoint = this.getAttachments().getAttachmentPointByName("AMOGUS");
	AttachmentPoint@ gunpoint = null;
	if (tripod !is null) {
		@pilotpoint = tripod.getAttachments().getAttachmentPointByName("MACHINEGUNNER");
		@gunpoint = tripod.getAttachments().getAttachmentPointByName("GUNPOINT");
		@tank = getBlobByNetworkID(tripod.get_u16("tank_id"));
	} else {
		@pilotpoint = this.getAttachments().getAttachmentPointByName("PICKUP");
		@gunpoint = this.getAttachments().getAttachmentPointByName("PICKUP");
		@tripod = pilotpoint.getOccupied();
	}
	rotoff = Vec2f(gunpoint.offset.x,0);
	
	if (pilotpoint !is null) {
		CBlob@ driver = pilotpoint.getOccupied();
		if (driver !is null && tripod !is null) {
			f32 angle = 0;
			if (driver !is null) {
				//if (driver.getAimPos().y > driver.getPosition().y)
				//	angle = 18;
				//else
				//	angle = -18;
				if ((driver.getAimPos().x<driver.getPosition().x && this.isFacingLeft())
					|| (driver.getAimPos().x>driver.getPosition().x && !this.isFacingLeft())) {
					angle = getCannonAngle(this, driver);
				}
				//if tripod is attached to a vehicle tripod should face the same direction vehicle faces
				if (!tripod.isAttached()) {
					tripod.SetFacingLeft(driver.getAimPos().x<tripod.getPosition().x);
				} else {
					//CBlob@ tank = getBlobByNetworkID(tripod.get_u16("tank_id"));
					//tripod.SetFacingLeft(tank.isFacingLeft());
				}
				this.getCurrentScript().tickFrequency = 1;
			}
			
			//calculating after setting facing direction
			const bool flip = tripod.isFacingLeft();
			const f32 flip_factor = flip ? -1 : 1;
			const u16 angle_flip_factor = flip ? 180 : 0;
			f32 maxminangl = 18;
			angle = (Maths::Clamp(angle, -maxminangl, maxminangl));
			if (driver !is null)
				driver.set_f32("gunSpriteAngle", -angle*(angle<0?2:1));
			Vec2f diff = (tripod.getPosition()-this.getPosition()+rotoff*flip_factor);
			this.getSprite().ResetTransform();
			this.getSprite().RotateBy(angle+this.getAngleDegrees(), rotoff*flip_factor);
			
			u8 interval = this.get_u8("interval");
			
			if (interval > 0) {
				interval--;
			}
			else if (interval == 0)
			{
				if ((driver !is null && pilotpoint.isKeyPressed(key_action1)))
				{
					if (isServer()) {
						//print("heey");
						Vec2f muzzle = Vec2f(24*flip_factor, -1).RotateBy(angle+this.getAngleDegrees(), Vec2f_zero);
						
						shootGun(this.getNetworkID(), angle+this.getAngleDegrees(), this.getNetworkID(), this.getPosition() + muzzle);
						this.SendCommand(this.getCommandID("play_shoot_sound"));
						interval = 3;
						if (XORRandom(100)<66)
							this.TakeBlob(my_ammo, 1);
					}
					if (isClient() || (isClient() && isServer()))
						MakeEmptyShellParticle(this, vars.CART_SPRITE, 1, Vec2f(-69, -69), this);
				}
			}
			if (isServer())
				this.set_u8("interval", interval);
			this.Sync("interval", true);
		}
	} else if (tank !is null) {
		this.getCurrentScript().tickFrequency = 1;
		this.getSprite().RotateBy(tank.getAngleDegrees(), rotoff*flip_factor);
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
	return;
	if (this is null) return;
	CBlob@ blobus = this.getBlob();
	
	CBlob@ tripod = null;
	@tripod = getBlobByNetworkID(blobus.get_u16("tripod_id"));
	if (tripod !is null) {
		AttachmentPoint@ ap = tripod.getAttachments().getAttachmentPointByName("MACHINEGUNNER");
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

bool isInventoryAccessible( CBlob@ this, CBlob@ forBlob )
{
	return forBlob.getTeamNum() == this.getTeamNum() && !forBlob.isAttached();
}

f32 getCannonAngle( CBlob@ this, CBlob@ holder )
{
	CBlob@ tripod = null;
	@tripod = getBlobByNetworkID(this.get_u16("tripod_id"));
	if (tripod !is null) {
		const bool flip = tripod.isFacingLeft();
		const f32 flip_factor = flip ? -1 : 1;
		AttachmentPoint@ ap = tripod.getAttachments().getAttachmentPointByName("MACHINEGUNNER");
		Vec2f aimvector = holder.getAimPos() - tripod.getPosition()+Vec2f(ap.offset.x*flip_factor,-ap.offset.y);
		return constrainAngle(holder.isFacingLeft() ? -aimvector.Angle()+180.0f : -aimvector.Angle());
	} return 0;
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

void onCommand(CBlob@ this, u8 cmd, CBitStream @params) 
{
	if(cmd == this.getCommandID("play_shoot_sound")) 
	{
		//this.getSprite().PlaySound(my_sound, 3.0, float(120+XORRandom(21))*0.01f);
		CSpriteLayer@ head = this.getSprite().getSpriteLayer("head");
		if (head !is null) {
			head.SetAnimation("shooting");
			head.SetFrameIndex(0);
		}
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return true;
}