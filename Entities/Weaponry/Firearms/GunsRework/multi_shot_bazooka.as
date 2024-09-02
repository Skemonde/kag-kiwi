#include "FirearmVars"
#include "KIWI_Locales"

void onInit(CBlob@ this)
{
	this.setInventoryName("Multi-shot Rocket Launcher");
	//this.Tag("has_zoom");
	this.Tag("medium weight");
	//
	OnClientShot@ shot_funcdef = @onClientShot;
	this.set("onClientShot handle", @shot_funcdef);
	
	
	FirearmVars vars = FirearmVars();
	//GUN
	vars.T_TO_DIE 					= -1;
	vars.C_TAG						= "advanced_gun";
	vars.MUZZLE_OFFSET				= Vec2f(-18,-2);
	vars.SPRITE_TRANSLATION			= Vec2f(-5, 1);
	vars.BULLET						= "rocket";
	vars.TRENCH_AIM					= 1;
	//AMMO
	vars.CLIP						= 4; 
	vars.TOTAL						= 0; 
	vars.AMMO_TYPE.push_back("froggy");
	//RELOAD
	vars.RELOAD_HANDFED_ROUNDS		= 4; 
	vars.EMPTY_RELOAD				= false;
	vars.RELOAD_TIME				= 255;
	vars.RELOAD_ANGLE				= 50;
	//FIRING
	vars.FIRE_INTERVAL				= 15; 
	vars.FIRE_AUTOMATIC				= true; 
	vars.ONOMATOPOEIA				= "";
	vars.FLASH_SPRITE				= "";
	vars.RECOIL						= 0;
	//EJECTION
	vars.SELF_EJECTING				= true; 
	vars.CART_SPRITE				= ""; 
	vars.CLIP_SPRITE				= "";
	//MULTISHOT
	vars.BURST						= 1;
	vars.BURST_INTERVAL				= vars.FIRE_INTERVAL;
	vars.BUL_PER_SHOT				= 1; 
	vars.B_SPREAD					= 15; 
	vars.UNIFORM_SPREAD				= false;
	//TRAJECTORY
	vars.B_GRAV						= Vec2f(0, 0.033);
	vars.B_SPEED					= 12; 
	vars.B_SPEED_RANDOM				= 0;
	vars.RANGE						= vars.B_SPEED*22; //rocket has fuel for 22.5 ticks roughly
	//DAMAGE
	vars.B_DAMAGE					= 400; 
	vars.B_HITTER					= HittersKIWI::bazooka;
	//EXPLOSIVE LOGIC
	vars.EXPLOSIVE					= true;
	vars.EXPL_RADIUS 				= 64;
	vars.EXPL_DAMAGE 				= 24;
	vars.EXPL_MAP_RADIUS 			= 40;
	vars.EXPL_MAP_DAMAGE 			= 0.4;
	vars.EXPL_RAYCAST 				= false;
	vars.EXPL_TEAMKILL 				= false;
	//BULLET SOUNDS
	vars.S_FLESH_HIT				= "ArrowHitFlesh.ogg";
	vars.S_OBJECT_HIT				= "BulletImpact.ogg"; 
	//GUN SOUNDS
	vars.FIRE_SOUND					= "PatriotExplosion.ogg";
	vars.FIRE_PITCH					= 1.0f;
	vars.CYCLE_SOUND				= "";
	vars.CYCLE_PITCH				= 1.0f;
	vars.LOAD_SOUND					= "rocketer_cycle.ogg";
	vars.LOAD_PITCH					= 0.8f;
	vars.RELOAD_SOUND				= "";
	vars.RELOAD_PITCH				= 1.0f;
	//BULLET SPRITES
	vars.BULLET_SPRITE				= "";
	vars.FADE_SPRITE				= "";
	this.set("firearm_vars", @vars);
}

void onClientShot(u16 gun_id, f32 angle, u16 gunner_id, Vec2f pos)
{	
	CBlob@ this = getBlobByNetworkID(gun_id);
	if (this is null) return;
	CShape@ shape = this.getShape();
	if (shape is null) return;
	
	const bool FLIP = this.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	
    Vec2f shape_vel = shape.getVelocity();
	angle = this.getAngleDegrees()+180;
	Vec2f dir = Vec2f(15*FLIP_FACTOR, 0).RotateBy(angle);
	pos = this.getPosition()+dir;
	Vec2f vel = Vec2f(40*FLIP_FACTOR, 0).RotateBy(angle);
	
	f32 particle_z = 251;

	for (int i = 0; i < 16; i++)
	{
		CParticle@ p = ParticleAnimated("LargeSmokeGray", pos, shape_vel + getRandomVelocity(0.0f, XORRandom(45) * 0.005f, 360) + vel/(10+XORRandom(24)), float(XORRandom(360)), 0.5f + XORRandom(40) * 0.01f, 2 + XORRandom(2), -0.0031f, true);
		if (p !is null)
		{
			p.Z = particle_z;
		}
	}

	for (int i = 0; i < 4; i++)
	{
		{
			CParticle@ p = ParticleAnimated("LargeSmokeGray", pos, shape_vel + getRandomVelocity(0.0f, XORRandom(45) * 0.005f, 360) + vel/(40+XORRandom(24)), float(XORRandom(360)), 0.5f + XORRandom(40) * 0.01f, 6 + XORRandom(3), -0.0031f, true);
			if (p !is null)
			{
				p.Z = particle_z;
			}
		}
		{
			CParticle@ p = ParticleAnimated("Explosion", pos, shape_vel + getRandomVelocity(0.0f, XORRandom(45) * 0.005f, 360) + vel/(40+XORRandom(24)), float(XORRandom(360)), 0.5f + XORRandom(40) * 0.01f, 2, -0.0031f, true);
			if (p !is null)
			{
				p.Z = particle_z;
			}
		}
	}
}