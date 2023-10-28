#include "FirearmVars"
#include "ExplosionAtPos"

void onInit(CBlob@ this)
{  
	this.Tag("no auto pickup");
	this.Tag("medium weight");
	this.Tag("explosive");
	
	this.maxQuantity = 1;
	this.server_setTeamNum(-1);
	this.setAngleDegrees(XORRandom(360));


	FirearmVars vars = FirearmVars();
	vars.BUL_PER_SHOT = 40;
	vars.B_SPREAD = 720;
	vars.B_HITTER = HittersKIWI::shag;
	vars.FIRE_AUTOMATIC = false;
	vars.UNIFORM_SPREAD = false;
	vars.MUZZLE_OFFSET = Vec2f_zero;
	vars.B_SPEED = 4;
	vars.B_SPEED_RANDOM	= 24; 
	vars.B_DAMAGE = 63;
	vars.RANGE = 120*getMap().tilesize; 
	vars.FIRE_SOUND	= "";
	vars.ONOMATOPOEIA = "";
	vars.BULLET = "bullet";
	vars.BULLET_SPRITE = "x";
	this.set("firearm_vars", @vars);
	
	
	this.addCommandID("play_load_sound");
	
	//this.getCurrentScript().runFlags |= Script::remove_after_this;
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return !isVanished(this);
}

bool canBePutInInventory( CBlob@ this, CBlob@ inventoryBlob )
{
	return !isVanished(this);
}

void onTick(CSprite@ this)
{
	this.SetVisible(!isVanished(this.getBlob()));
}

bool isVanished(CBlob@ this)
{
	return this.getHealth()!=this.getInitialHealth();
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return (!(blob.hasTag("flesh") || blob.hasTag("vehicle")) || blob.hasTag("collides_everything"))&&!isVanished(this);
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if(cmd == this.getCommandID("play_load_sound")) 
	{
		Sound::Play("tank_load.ogg", this.getPosition(), 1, 1.0f+XORRandom(100)*0.001-0.1);
	}
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2 )
{
	if (isVanished(this)) return;
	const f32 vellen = this.getOldVelocity().Length();
	if (solid) {			
		if (vellen > 1.7f)
		{
			Sound::Play("GrenadeDrop1", this.getPosition(), 1, 0.3f + XORRandom(2)*0.1);
		}
		if (vellen > 7.3f)
		{
			print("vellen "+vellen);
			this.server_Hit(this, this.getPosition(), Vec2f(), 0.1f, 0);
		}
	}
	if (blob !is null) {
		CBlob@ tank = getBlobByNetworkID(blob.get_u16("tank_id"));
		if (tank is null) return;
		bool right_spot = (blob.getPosition()+Vec2f(-16*(blob.get_bool("facingLeft")?-1:1), -1).RotateBy(tank.getAngleDegrees())-point2).Length()<8;
		bool right_direction = this.getVelocity().x>0&&!blob.get_bool("facingLeft")||this.getVelocity().x<0&&blob.get_bool("facingLeft");
		bool case_ejected = blob.get_bool("case is ejected");
		if (case_ejected && right_direction && right_spot && blob.getName()=="donotspawnthiswithacommand_bt42turret" && !blob.get_bool("shell in chamber")) {
			if (isServer())
				this.SendCommand(this.getCommandID("play_load_sound"));
			blob.set_u32("last_shot", getGameTime());
			blob.Sync("last_shot", true);
			blob.set_u8("interval", 15);
			blob.Sync("interval", true);
			blob.set_bool("shell in chamber", true);
			blob.Sync("shell in chamber", true);
			this.server_Die();
		}
	}
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	damage = 0.1f;
	
	this.setInventoryName("");
	this.server_SetTimeToDie(2);
	this.Untag("explosive");
	this.Tag("invincible");
	Sound::Play("cluster_bullet_blast", this.getPosition(), 2.0, 0.35f + XORRandom(3)*0.1);
	DestroyTilesInRadius(this.getPosition(), 2);
	
	//it's stupid but you want to keep this blob alive for some time after creating bullets as guncode kills all the bullets if their creator is dead
	if (isServer()) {
		shootGun(this.getNetworkID(), (worldPoint-this.getPosition()).getAngleDegrees(), this.getNetworkID(), this.getPosition());
		this.server_DetachFromAll();
	}
			
	return damage;
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	const bool FLIP = this.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	this.setAngleDegrees(-90*FLIP_FACTOR);
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