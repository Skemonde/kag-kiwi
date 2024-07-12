#include "FirearmVars"
#include "ExplosionAtPos"
#include "Explosion"
#include "MakeExplodeParticles"
#include "Skemlib"

void onInit(CBlob@ this)
{  
	this.Tag("no auto pickup");
	this.Tag("medium weight");
	this.Tag("explosive");
	this.Tag("self explosion immune");
	this.Tag("bullet_hits");
	
	this.maxQuantity = 1;
	//this.server_setTeamNum(-3);
	this.setAngleDegrees(XORRandom(360));	
	
	this.addCommandID("play_load_sound");
	
	this.SetMapEdgeFlags(u8(CBlob::map_collide_none | CBlob::map_collide_left | CBlob::map_collide_right | CBlob::map_collide_nodeath));
	//this.getCurrentScript().runFlags |= Script::remove_after_this;
}

void onDie(CBlob@ this)
{
	if (!this.hasTag("died naturally")) return;
	
	bool FLIP = this.isFacingLeft();;
	f32 FLIP_FACTOR = FLIP ? -1 : 1;
	u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	//PlayDistancedSound("cluster_bullet_blast", 1.0f, 0.35f, this.getPosition(), 0.1, 0.1, 0.1);
	
	if (!isServer()) return;
	CBlob@ cluster = server_CreateBlob("bulletcluster", -3, this.getPosition());
	if (cluster is null) return;
	
	cluster.SetDamageOwnerPlayer(this.getDamageOwnerPlayer());
	cluster.set_f32("angle", -this.getAngleDegrees());
	return;
	
	FirearmVars vars = FirearmVars();
	vars.BUL_PER_SHOT = 60;
	vars.B_SPREAD = 180;
	vars.B_HITTER = HittersKIWI::tank_mg;
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
	cluster.set("firearm_vars", @vars);
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

void onTick(CBlob@ this)
{
	return;
	//we do a bit of collision checking after detach
	if ((getGameTime()-this.get_u32("last detach"))>4) return;
	CShape@ shape = this.getShape();
	
	shape.checkCollisionsAgain = true;
}

bool isVanished(CBlob@ this)
{
	return false;
	return this.getHealth()!=this.getInitialHealth();
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return this.getVelocity().Length()>=0.5f;
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
			Sound::Play("BombBounce", this.getPosition(), 1, 0.3f + XORRandom(2)*0.1);
		}
		if (vellen > 7.3f)
		{
			//print("vellen "+vellen);
			this.server_Hit(this, this.getPosition(), Vec2f(), 0.1f, 0);
		}
	}
	if (blob !is null) {
		CBlob@ tank = getBlobByNetworkID(blob.get_u16("tank_id"));
		if (tank is null) return;
		bool right_spot = (blob.getPosition()+Vec2f(-16*(blob.get_bool("facingLeft")?-1:1), -1).RotateBy(tank.getAngleDegrees())-point2).Length()<10;
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

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	const bool FLIP = this.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	this.setAngleDegrees(-90*FLIP_FACTOR);
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{
	this.set_u32("last detach", getGameTime());
}