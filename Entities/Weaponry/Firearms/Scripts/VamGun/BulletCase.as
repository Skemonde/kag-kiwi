#include "FirearmVars"
//Bullet case effect upon shooting

void MakeEmptyShellParticle (CBlob@ this, string fileName, u8 stored_carts = 1, const Vec2f vel = Vec2f(-69, -69), CBlob@ shooter = null)
{
	if (this is null) return;
	FirearmVars@ vars;
	this.get("firearm_vars", @vars);
	bool flip = this.isFacingLeft();
	u8 team = this.getTeamNum();
	if (shooter !is null) {
		flip = shooter.isFacingLeft();
		team = shooter.getTeamNum();
	}
	const f32 flip_factor = flip ? -1: 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	f32 speed_mod = Maths::Pow(vars.B_DAMAGE, 2);
	
	stored_carts = Maths::Min(8, stored_carts); //not going to make more than 8 empty cases a time
	
	for (u8 i = 0; i < stored_carts; ++i)
	{
		u16 sound_rnd = XORRandom(2) + 1;
		u16 clamped_speed = Maths::Min(speed_mod, 6);
		Vec2f imageSize;
		GUI::GetImageDimensions(fileName, imageSize);
		// particle of an empty round case
		makeGibParticle(
			//
			fileName,
			Vec2f(this.getPosition().x,this.getPosition().y)
				+ Vec2f(
					(this.getSprite().getFrameWidth()*0.5 - (this.get_Vec2f("gun_trans").x + this.getSprite().getOffset().x))*flip_factor,
						vars.MUZZLE_OFFSET.y + this.get_Vec2f("gun_trans").y + this.getSprite().getOffset().y)
				.RotateBy( this.get_f32("gunangle"), Vec2f()),  	// position   
			//
			(vel == Vec2f(-69, -69) ?
				//case 1
					/*X*/Vec2f(flip_factor * (-Maths::Abs(clamped_speed*0.75 + XORRandom(10)*0.1) * (!vars.SELF_EJECTING ? 0.05 * (i + 1) : 1)),
					/*Y*/-clamped_speed/stored_carts+(-1.5+XORRandom(3))*0.2)
				//case 2
				: Vec2f(vel.x*flip_factor, vel.y)),
			//
			0,                              						// column
			0,                                  					// row
			imageSize,                      						// frame size
			1.0f,                               					// scale?
			0,                                  					// ?
			"empty_bullet_case",//"ShellDrop" + sound_rnd,                      			// sound
			team										// team number
		);
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