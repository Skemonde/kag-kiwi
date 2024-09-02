
#include "Hitters"
#include "KIWI_Hitters"
#include "Explosion"
#include "MakeBangEffect"
#include "MakeExplodeParticles"
#include "Skemlib"

const u32 FUEL_TIMER_MAX =  5.500f * getTicksASecond();

void onInit(CSprite@ this)
{
	this.SetEmitSoundPaused(false);
}

void onInit(CBlob@ this)
{
	this.Tag("bullet_hits");
	this.Tag("non_pierceable");
	this.Tag("heavy weight");
	//this.Tag("bomb");
	
	this.server_setTeamNum(-3);
	this.getShape().getConsts().transports = true;
}

void onTick(CBlob@ this)
{
	if (this.getVelocity().Length()>0.1f)
		this.setAngleDegrees(-this.getVelocity().getAngle()+90);
	
	CShape@ shape = this.getShape();
	CSprite@ sprite = this.getSprite();
	shape.SetGravityScale(0);
	
	f32 launch_factor = (this.getPosition().x<=getMap().tilemapwidth/2*getMap().tilesize)?1:-1;
	
	sprite.SetEmitSound("Rocket_Idle.ogg");
	sprite.SetEmitSoundSpeed(0.4f);
    sprite.SetEmitSoundVolume(4.0f);
	
	if (FUEL_TIMER_MAX<this.getTickSinceCreated())
	{
		shape.SetGravityScale(Maths::Min((this.getTickSinceCreated()-FUEL_TIMER_MAX)/10, 0.4));
		sprite.SetEmitSoundPaused(true);
	}
	else if (this.getTickSinceCreated()>1)
	{
		sprite.SetEmitSoundPaused(false);
		Vec2f dir = Vec2f(0, 1.0f+this.getTickSinceCreated()/40);
		dir.RotateBy(180.0f+1.0f*this.getTickSinceCreated()/20*launch_factor);
		this.setVelocity(dir);
		MakeParticle(this, -dir, "LargeSmokeGray", true);
		MakeParticle(this, -dir, "LargeSmokeGray", false);
		
		if (true) {
			for (int idx = 0; idx < 1; ++idx)
			{
				Vec2f offset = -this.getVelocity()/1*idx+Vec2f((getGameTime()%4)*8-this.getWidth()/2, this.getHeight()/2+this.getWidth()/2).RotateBy(this.getAngleDegrees());
				CBlob@ fire = server_CreateBlob("napalm", this.getTeamNum(), this.getPosition()+offset);
				fire.setVelocity(this.getVelocity().RotateBy(180)*3);
				fire.server_SetTimeToDie(Maths::Max(1.0f/30, getGameTime()%8<4?(0.01f):(0.3f+(0.001f*XORRandom(10)))));
			}
		}
	}
}


f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData==Hitters::fall) return 0;
	if (damage>this.getHealth()*2||damage>5.0f) {
		this.Tag("DoExplode");
		this.server_Die();
	}
	return damage;
}

void MakeHugeHole(CBlob@ this)
{
	CMap@ map = getMap();
	Vec2f hit_pos = this.getPosition();
	Vec2f map_dims = Vec2f(map.tilemapwidth, map.tilemapheight);
	Vec2f tilespace_pos = map.getTileSpacePosition(hit_pos);
	
	int depth = (map_dims.y);
	int width = 40;
	
	for (int x_idx = -width/2; x_idx < width/2; ++x_idx)
	{
		for (int y_idx = 0; y_idx < depth; ++y_idx)
		{
			Vec2f final_pos = Vec2f(hit_pos.x, 0) + Vec2f(x_idx, y_idx)*map.tilesize;
			map.server_DestroyTile(final_pos, 100);
			for (int idx = 0; idx < 100; idx++)
			{
				if (!map.isTileSolid(final_pos))
					break;
				map.server_DestroyTile(final_pos, 1);
			}
		}
	}
}

void onDie(CBlob@ this)
{
	//if (!this.hasTag("DoExplode")) return;
	this.set_string("custom_explosion_sound", "handgrenade_blast");
	this.set_f32("map_damage_radius", 128);
	this.set_f32("map_damage_ratio", 30);
	this.set_f32("explosion blob radius", 260);
	this.set_u8("custom_hitter", HittersKIWI::handgren);
	
	PlayDistancedSound("Antimatter_Kaboom.ogg", 3.0f, 1.0f, this.getPosition(), 0.01f, 0, 0, 0.5f);
	
	if (isServer())
	{
		MakeHugeHole(this);
		Explode(this, this.get_f32("explosion blob radius"), 80);
	}
	
	CBlob@ localBlob = getLocalPlayerBlob();
	if (localBlob !is null)
	{
		const f32 dist = (localBlob.getPosition() - this.getPosition()).getLength();
		const f32 flash_distance = 1024;

		if (dist <= flash_distance)
		{
			f32 flashMod = Maths::Sqrt(1.00f - (dist / flash_distance));
			print("" + flashMod);
			SetScreenFlash(255 * Maths::Min(flashMod * 2, 1), 255, 255, 255, 5 * flashMod);
		}
	}
	
	this.set_s32("custom flare amount", 7);
	kiwiExplosionEffects(this);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if (blob !is null ? !blob.isCollidable() : !solid)
	{
		return;
	}

	f32 vellen = this.getOldVelocity().Length();
	if (vellen >= 9.0f && !this.hasTag("dead") && this.getOldVelocity().y>6) 
	{
		Vec2f dir = Vec2f(-normal.x, normal.y);
		
		this.Tag("DoExplode");
		this.set_u32("death_time", getGameTime()+(2.0f*getTicksASecond()));
		this.set_f32("death_angle", this.getAngleDegrees());
		this.getSprite().SetOffset(this.getSprite().getOffset()+Vec2f(0, 4));
		this.setVelocity(Vec2f());
		this.getSprite().SetEmitSoundPaused(true);
		//this.getShape().SetGravityScale(0);
		this.Tag("dead");
	}
}

void MakeParticle(CBlob@ this, const Vec2f vel, const string filename = "SmallSteam", bool white = false)
{
	if (!isClient()) return;
	const bool flip = this.getVelocity().x<0;
	const f32 flip_factor = flip ? -1 : 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	int sus = Maths::Max(2, this.getVelocity().Length()/5);

	for(int counter = 0; counter < sus; ++counter) {
		f32 speed_mod = this.getVelocity().Length();
		Vec2f offset = Vec2f(-XORRandom(speed_mod), 0).RotateBy(this.getAngleDegrees());
		offset = -this.getVelocity()/sus*counter+Vec2f(0, this.getHeight()/2-this.getWidth()/4).RotateBy(this.getAngleDegrees());
		CParticle@ p = ParticleAnimated(filename, this.getPosition() + offset, vel, float(XORRandom(360)), 5.0f, white?1:6, 0, false);
		if (p !is null) {
			p.growth = -0.005;
			p.Z = white?250:200;
			p.deadeffect = -1;
			p.scale = 1.0f*(40.0f/p.framesize);
			if (white)
				p.setRenderStyle(RenderStyle::additive);
		}
	}
}