#include "FirearmVars"
//Bullet case effect upon shooting
Vec2f default_velocity = Vec2f(-69, -69);
void MakeEmptyShellParticle (CBlob@ this, string fileName, u8 stored_carts = 1, const Vec2f vel = default_velocity, CBlob@ shooter = null, string sound_name = "empty_bullet_case")
{
	if (this is null) return;
	FirearmVars@ vars;
	this.get("firearm_vars", @vars);
	bool flip = this.isFacingLeft();
	u8 team = this.getTeamNum();
	Vec2f holder_speed = Vec2f_zero;
	if (shooter !is null) {
		flip = shooter.isFacingLeft();
		team = shooter.getTeamNum();
		holder_speed = shooter.getVelocity();
	}
	const f32 flip_factor = flip ? -1: 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	f32 speed_mod = (2+(vars.B_DAMAGE+vars.BUL_PER_SHOT*4)*0.2)/5;
	
	stored_carts = Maths::Min(8, stored_carts); //not going to make more than 8 empty cases a time
	
	for (u8 i = 0; i < stored_carts; ++i)
	{
		u16 sound_rnd = XORRandom(2) + 1;
		u16 clamped_speed = Maths::Min(speed_mod, 6);
		Vec2f imageSize;
		//has to be clientonly otherwise it crashes server with imagesize of 0,0 xDD
		if (isClient())
			GUI::GetImageDimensions(fileName, imageSize);
			
		string kys = getNet().joined_ip;
		if (isServer())
		if (!(kys == "26.220.91.10"+":50301" //ohio
			//|| kys == "127.0.0.1"+":50301" //localhost
			)&&XORRandom(300)<1)
		{
			//imageSize = Vec2f_zero;
		}
			
		// particle of an empty round case
		CParticle@ p = makeGibParticle(
			//
			fileName,
			Vec2f(this.getPosition().x,this.getPosition().y)
				+ Vec2f(
					(this.getSprite().getFrameWidth()*0.3 - (-vars.SPRITE_TRANSLATION.x + this.get_Vec2f("gun_trans").x + this.getSprite().getOffset().x))*flip_factor,
						vars.SPRITE_TRANSLATION.y + vars.MUZZLE_OFFSET.y + this.get_Vec2f("gun_trans").y + this.getSprite().getOffset().y)
				.RotateBy( this.get_f32("gunangle"), Vec2f()),  	// position   
			//
			(vel == default_velocity ?
				//case true
					/*X*/Vec2f(flip_factor * (-Maths::Abs(clamped_speed*0.75 + XORRandom(10)*0.1) * (!vars.SELF_EJECTING ? 0.05 * (i + 1) : 1)),
					/*Y*/-clamped_speed/stored_carts+(-1.5+XORRandom(3))*0.2) + holder_speed
				//case false
				: Vec2f(vel.x*flip_factor, vel.y)),
			//
			0,                              						// column
			0,                                  					// row
			imageSize,                      						// frame size
			1.0f,                               					// scale?
			0,                                  					// ?
			fileName=="ShellCase"?"empty_shell_case":sound_name,	// sound
			team													// team number
		);
		if (p !is null) {
			p.collides = true;
			p.Z = 190;
			p.deadeffect = -1;
		}
	}
}

void ParticleBullet(Vec2f CurrentPos, Vec2f Velo)
{
    CParticle@ p = ParticlePixel(CurrentPos, getRandomVelocity(-Velo.Angle(), 3.0f, 40.0f), SColor(255,244, 220, 66),true);
    if(p !is null)
    {
        p.fastcollision = true;
        p.bounce = 0.4f;
        p.alivetime = 120;
        p.lighting = true;
        p.lighting_delay = 0;
        p.lighting_force_original_color = true;
    }
}

void ParticleFromBullet(const string particlePic,const Vec2f pos, const f32 angle)
{
    CParticle@ p = ParticleAnimated(particlePic, pos, Vec2f(5,0), angle, 1.0f, 1, 0.0f, true);
    if(p !is null)
    {
        p.bounce = 0.5;
        p.damping = 0.5;
        p.mass = 200;
        p.fastcollision = true;
        p.lighting_delay = 0;
        p.lighting_force_original_color = true;
    }
}