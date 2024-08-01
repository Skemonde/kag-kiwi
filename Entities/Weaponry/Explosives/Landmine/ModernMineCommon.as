// Mine.as

#include "Hitters.as";
#include "KIWI_Hitters.as";
#include "KIWI_Locales.as";
#include "Explosion.as";
#include "MakeBangEffect.as";
#include "MakeExplodeParticles.as";
#include "Knocked"

const u8 MINE_PRIMING_TIME = 45;

const string MINE_STATE = "mine_state";
const string MINE_TIMER = "mine_timer";
const string MINE_PRIMING = "mine_priming";
const string MINE_PRIMED = "mine_primed";

enum State
{
	NONE = 0,
	PRIMED
};

void onInit(CBlob@ this)
{
	this.getShape().getVars().waterDragScale = 16.0f;

	this.set_f32("explosive_radius", 32.0f);
	this.set_f32("explosive_damage", 15.0f);
	this.set_f32("map_damage_radius", 32.0f);
	this.set_f32("map_damage_ratio", 0.5f);
	this.set_bool("map_damage_raycast", true);
	this.set_string("custom_explosion_sound", "");
	this.set_u8("custom_hitter", HittersKIWI::boom);

	this.Tag("ignore fall");
	this.Tag("ignore_saw");
	this.Tag("no_ram_damage");
	this.Tag("crate pickup");
	this.Tag("landmine");
	this.Tag("explosive");
	//this.Tag(MINE_PRIMING);
	
	if(this.getName()=="landmine") {
		this.setInventoryName(Names::land_mine);
	}
	else {
		this.Tag("heavy weight");
		this.setInventoryName(Names::tank_mine);
	}

	if (this.exists(MINE_STATE))
	{
		if (getNet().isClient())
		{
			CSprite@ sprite = this.getSprite();

			if (this.get_u8(MINE_STATE) == PRIMED)
			{
				sprite.SetFrameIndex(1);
			}
			else
			{
				sprite.SetFrameIndex(0);
			}
		}
	}
	else
	{
		this.set_u8(MINE_STATE, NONE);
	}

	this.set_u8(MINE_TIMER, 0);
	this.addCommandID(MINE_PRIMED);

	//this.getCurrentScript().tickIfTag = MINE_PRIMING;
}

void onInit(CSprite@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_not_attached | Script::tick_not_ininventory;

}

void onTick(CBlob@ this)
{
	if (getNet().isServer())
	{
		//tick down
		if (this.getVelocity().LengthSquared() < 1.0f && !this.isAttached() && this.hasTag(MINE_PRIMING))
		{
			u8 timer = this.get_u8(MINE_TIMER);
			timer++;
			this.set_u8(MINE_TIMER, timer);

			if (timer >= MINE_PRIMING_TIME)
			{
				this.Untag(MINE_PRIMING);
				SetPrimed(this);
				this.SendCommand(this.getCommandID(MINE_PRIMED));
			}
		}
		//reset if bumped/moved
		else if (this.hasTag(MINE_PRIMING))
		{
			this.set_u8(MINE_TIMER, 0);
		}
		
		CBlob@ activator = this.exists("the_one_who_activated_me") ? getBlobByNetworkID(this.get_u16("the_one_who_activated_me")) : null;
		bool activator_got_killed = activator is null && this.exists("the_one_who_activated_me");
		bool activator_stepped_off = activator !is null && !activator.isOverlapping(this);
		bool vehicle_against_landmine = activator !is null && activator.hasTag("vehicle") && this.getName()=="landmine";
		
		if ((this.get_u8(MINE_STATE) == PRIMED && (activator_got_killed || activator_stepped_off || vehicle_against_landmine)) && !this.hasTag("exploding"))
		{
			this.Tag("exploding");
			this.Sync("exploding", true);

			this.server_SetHealth(-1.0f);
			this.server_Die();
		}
	}
	if(isClient()) {
		this.getSprite().SetRelativeZ(0 + this.getPosition().y*0.01);
	}
}

void SetPrimed(CBlob@ this)
{
	if (this.isAttached()) return;

	if (this.isInInventory()) return;

	if (this.get_u8(MINE_STATE) == PRIMED) return;

	this.set_u8(MINE_STATE, PRIMED);
	this.setAngleDegrees(0);
	this.getShape().checkCollisionsAgain = true;
	//this.getShape().PutOnGround();
	this.Untag("crate pickup");

	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		sprite.SetFrameIndex(1);
		sprite.SetZ(-20);
		sprite.PlaySound("MineArmed.ogg");
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID(MINE_PRIMED))
	{
		SetPrimed(this);
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ attachedPoint)
{
	this.Untag(MINE_PRIMING);
	this.setAngleDegrees(0);

	if (this.get_u8(MINE_STATE) == PRIMED)
	{
		this.set_u8(MINE_STATE, NONE);
		this.Tag("crate pickup");
		this.getSprite().SetFrameIndex(0);
	}

	if (this.getDamageOwnerPlayer() is null || this.getTeamNum() != attached.getTeamNum())
	{
		CPlayer@ player = attached.getPlayer();
		if (player !is null)
		{
			this.SetDamageOwnerPlayer(player);
		}
	}
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	this.Untag(MINE_PRIMING);

	if (this.get_u8(MINE_STATE) == PRIMED)
	{
		this.set_u8(MINE_STATE, NONE);
		this.getSprite().SetFrameIndex(0);
	}

	if (this.getDamageOwnerPlayer() is null || this.getTeamNum() != inventoryBlob.getTeamNum())
	{
		CPlayer@ player = inventoryBlob.getPlayer();
		if (player !is null)
		{
			this.SetDamageOwnerPlayer(player);
		}
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	if (getNet().isServer() && (detached.hasTag("player")||detached.hasTag("turret")))
	{
		//only start priming it if it was dropped by player himself
		this.Untag("crate pickup");
		this.Tag(MINE_PRIMING);
		this.set_u8(MINE_TIMER, 0);
	}
}

void onThisRemoveFromInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	if (getNet().isServer() && !this.isAttached())
	{
		this.Tag("crate pickup");
		//this.Tag(MINE_PRIMING);
		this.set_u8(MINE_TIMER, 0);
	}
}

bool explodeOnCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if(this.getName()=="landmine") {
		return this.getTeamNum() != blob.getTeamNum() &&
		(blob.hasTag("player") || blob.hasTag("vehicle"));
	}else{
		return this.getTeamNum() != blob.getTeamNum() &&
		(blob.hasTag("vehicle"));
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{	
	// don't want to collide anything right after creation
	if (blob.getTickSinceCreated() < 10)
		return false;
	bool enemy_col = this.getTeamNum()!=blob.getTeamNum();
	return blob.getShape().isStatic() && blob.isCollidable()
		|| (this.getName()=="tankmine" && blob.hasTag("flesh"))
		|| (this.getName()=="landmine" && blob.hasTag("vehicle"))
		|| blob.hasTag("landmine")
		|| (this.get_u8(MINE_STATE) != PRIMED && enemy_col);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null)
	{
		if (explodeOnCollideWithBlob(this, blob) && !this.exists("the_one_who_activated_me") && this.get_u8(MINE_STATE) == PRIMED) {
			this.set_u16("the_one_who_activated_me", blob.getNetworkID());
			//if(this.getName()=="tankmine")
				this.getSprite().PlaySound("ArmRemoteBomb.ogg", 3, 1.5f);
			if (this.getName()=="landmine") {
				blob.setVelocity(Vec2f());
			}
			if (blob.hasTag("player")&&(blob.getCarriedBlob() is null || (blob.getCarriedBlob() !is null && !blob.getCarriedBlob().hasTag("shield"))))
				SetKnocked(blob, 45);
			
		}
	}
}

void onDie(CBlob@ this)
{
	if (this.hasTag("exploding"))
	{
		if (isServer()) {
			const Vec2f POSITION = this.getPosition();
			int damage = (150+XORRandom(49))/10;
			if(this.getName()=="tankmine") {
				damage = 150+XORRandom(150)/10;
			}
			
			CBlob@[] blobs;
			getMap().getBlobsInRadius(POSITION, this.getRadius() + (this.getName()=="tankmine"?32:8), @blobs);
			for(u16 i = 0; i < blobs.length; i++)
			{
				CBlob@ target = blobs[i];
				const bool flip = target.getPosition().x > this.getPosition().x;
				const f32 flip_factor = flip ? -1 : 1;
				if (target.getPlayer() is this.getDamageOwnerPlayer() || explodeOnCollideWithBlob(this, target))
				{
					this.server_Hit(target, POSITION, Vec2f_zero, damage, this.getName()=="tankmine"?HittersKIWI::tankmine:HittersKIWI::landmine, true);
					//tankmine adds force so tank jumps a bit after explosion
					if (this.getName()=="tankmine")
						target.AddForceAtPosition((Vec2f(-3*flip_factor, -2)*target.getMass()).RotateBy(0), target.getPosition() + Vec2f(100*flip_factor, 5));
				}
			}
		}
		{
			string sound = "GrenadeExplosion.ogg";
			
			if(this.getName()=="tankmine") {
				sound = "Dynamite.ogg";
			}
			this.getSprite().PlaySound(sound);
			if (this.getName()=="tankmine") {
				u8 particle_amount = 6;
				MakeBangEffect(this, "bakoom", 4.0);
				
				for (int j = 0; j < particle_amount; ++j)
				{
					MakeExplodeParticles(this, Vec2f( XORRandom(64) - 32, XORRandom(64) - 32), getRandomVelocity(360/particle_amount*j, XORRandom(220) * 0.01f, 90));
				}
				
			} else {
				MakeExplodeParticles(this, Vec2f_zero, Vec2f_zero);
				MakeBangEffect(this, "blam", 2.0);
			}
		}
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ blob)
{
	return this.get_u8(MINE_STATE) != PRIMED || this.getTeamNum() == blob.getTeamNum();
	return (this.get_u8(MINE_STATE) != PRIMED || (this.getDamageOwnerPlayer() is blob.getPlayer())) && this.getTeamNum() == blob.getTeamNum();
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	return customData == Hitters::builder ? this.getInitialHealth() / 2 : damage;
}

void onRender(CSprite@ this)
{
	return;
	if (g_videorecording) return;

	//hover over primed mine to check if its my mine
	CBlob@ blob = this.getBlob();
	if (blob.getDamageOwnerPlayer() is getLocalPlayer())
	{
		Vec2f mouseWorldPos = getControls().getMouseWorldPos();
		Vec2f minePos = blob.getPosition();

		float radius = 10.0f;
		float distanceSq = (mouseWorldPos - minePos).LengthSquared();

		if (distanceSq < radius * radius)
		{
			blob.RenderForHUD(Vec2f_zero, RenderStyle::outline_front);
		}
	}
}
