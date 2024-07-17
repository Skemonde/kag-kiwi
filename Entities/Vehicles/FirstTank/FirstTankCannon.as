#include "FirearmVars"
#include "KIWI_Locales"

void onInit(CBlob@ this)
{
	this.setInventoryName("");
	this.Tag("has_zoom");
	this.Tag("heavy weight");
	//this.Tag("cant have gun attachments");
	this.Tag("shot_force");
	OnClientShot@ shot_funcdef = @onClientShot;
	this.set("onClientShot handle", @shot_funcdef);
	
	
	FirearmVars vars = FirearmVars();
	//GUN
	vars.C_TAG						= "advanced_gun";
	vars.MUZZLE_OFFSET				= Vec2f(-34, -4);
	vars.SPRITE_TRANSLATION			= Vec2f(8, 0);
	//AMMO
	vars.CLIP						= 1; 
	vars.TOTAL						= 0; 
	vars.AMMO_TYPE.push_back("draground");
	//RELOAD
	vars.RELOAD_HANDFED_ROUNDS		= 0; 
	vars.EMPTY_RELOAD				= false;
	vars.RELOAD_TIME				= 7*getTicksASecond();
	vars.RELOAD_ANGLE				= -10;
	//FIRING
	vars.FIRE_INTERVAL				= 90; 
	vars.FIRE_AUTOMATIC				= true; 
	vars.ONOMATOPOEIA				= "foom";
	vars.FLASH_SPRITE				= "from_bullet";
	//EJECTION
	vars.SELF_EJECTING				= true; 
	vars.CART_SPRITE				= "DragunovCase"; 
	vars.CLIP_SPRITE				= "";
	//MULTISHOT
	vars.BURST						= 0;
	vars.BURST_INTERVAL				= 2;
	vars.BUL_PER_SHOT				= 1; 
	vars.B_SPREAD					= 0; 
	vars.UNIFORM_SPREAD				= false;
	//TRAJECTORY
	vars.B_GRAV						= Vec2f(0, 0.02);
	vars.B_SPEED					= 30; 
	vars.B_SPEED_RANDOM				= 0;
	vars.RANGE						= 900*getMap().tilesize;
	//DAMAGE
	vars.B_DAMAGE					= 512; 
	vars.B_HITTER					= HittersKIWI::apc_cannon;
	vars.B_PENETRATION				= 0;
	//BULLET SOUNDS
	vars.S_FLESH_HIT				= "ArrowHitFlesh.ogg";
	vars.S_OBJECT_HIT				= "BulletImpact.ogg"; 
	//GUN SOUNDS
	vars.FIRE_SOUND					= "PatriotExplosion.ogg";
	vars.FIRE_PITCH					= 1.5f;
	vars.CYCLE_SOUND				= "tank_unload.ogg";
	vars.CYCLE_PITCH				= 1.6f;
	vars.LOAD_SOUND					= "smg_load.ogg";
	vars.LOAD_PITCH					= 0.4f;
	vars.RELOAD_SOUND				= "rifle_cycle.ogg";
	vars.RELOAD_PITCH				= 0.5f;
	//BULLET SPRITES
	vars.BULLET_SPRITE				= "smg_bullet";
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
	angle = this.getAngleDegrees();
	Vec2f dir = Vec2f(25*FLIP_FACTOR, -10).RotateBy(angle);
	pos = this.getPosition()+dir;
	Vec2f vel = Vec2f(40*FLIP_FACTOR, 0).RotateBy(angle);;

	for (int i = 0; i < 16; i++)
	{
		ParticleAnimated("LargeSmokeGray", pos, shape_vel + getRandomVelocity(0.0f, XORRandom(45) * 0.005f, 360) + vel/(10+XORRandom(24)), float(XORRandom(360)), 0.5f + XORRandom(40) * 0.01f, 2 + XORRandom(2), -0.0031f, true);
	}

	bool apc = true;

	for (int i = 0; i < 4; i++)
	{
		if (!apc)
		{
			float angle = Maths::ATan2(vel.y, vel.x) + 20;
			ParticleAnimated("LargeSmoke", pos, shape_vel + Vec2f(Maths::Cos(angle), Maths::Sin(angle))/2, float(XORRandom(360)), 0.4f + XORRandom(40) * 0.01f, 4 + XORRandom(3), -0.0031f, true);
			float angle2 = Maths::ATan2(vel.y, vel.x) - 20;
			ParticleAnimated("LargeSmoke", pos, shape_vel + Vec2f(Maths::Cos(angle2), Maths::Sin(angle2))/2, float(XORRandom(360)), 0.4f + XORRandom(40) * 0.01f, 4 + XORRandom(3), -0.0031f, true);
		}

		ParticleAnimated("LargeSmokeGray", pos, shape_vel + getRandomVelocity(0.0f, XORRandom(45) * 0.005f, 360) + vel/(40+XORRandom(24)), float(XORRandom(360)), 0.5f + XORRandom(40) * 0.01f, 6 + XORRandom(3), -0.0031f, true);
		ParticleAnimated("Explosion", pos, shape_vel + getRandomVelocity(0.0f, XORRandom(45) * 0.005f, 360) + vel/(40+XORRandom(24)), float(XORRandom(360)), 0.5f + XORRandom(40) * 0.01f, 2, -0.0031f, true);
	}
}