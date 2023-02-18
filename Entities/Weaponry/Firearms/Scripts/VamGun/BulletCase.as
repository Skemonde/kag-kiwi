//Bullet case effect upon shooting

void ParticleCase2(const string particlePic,const Vec2f pos, const f32 angle)
{
    u16 sound_rnd = XORRandom(2) + 1;
    
    Vec2f imageSize;
    GUI::GetImageDimensions(particlePic, imageSize);
    CParticle@ p = makeGibParticle(particlePic, pos, getRandomVelocity(angle, 2.5f, 20.0f)+Vec2f(0,-1), RenderStyle::normal, 0, imageSize, 2.0f, 3, "ShellDrop" + sound_rnd);
    if(p !is null)
    {
        p.fadeout = true;
        p.mass = 50;
        p.bounce = 1;
        p.freerotation = true;
        p.fastcollision = true;
        p.lighting = true;
        p.lighting_delay = 0;
    }
}

void MakeEmptyShellParticle (CBlob@ this, string fileName, const bool self_ejecting = false, u8 stored_carts = 1, const Vec2f vel = Vec2f(-69, -69))
{
	const bool flip = this.isFacingLeft();
	const f32 flip_factor = flip ? -1: 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	f32 speed_mod = Maths::Pow(this.get_f32("damage"),2);
	
	stored_carts = Maths::Min(8, stored_carts); //not going to make more than 8 empty cases a time
	
	for (u8 i = 0; i < stored_carts; ++i)
	{
		u16 sound_rnd = XORRandom(2) + 1;
		// particle of an empty round case
		makeGibParticle(
			//
			fileName,
			Vec2f(this.getPosition().x,this.getPosition().y)
				+ Vec2f(
					(this.getSprite().getFrameWidth()*0.5 - (this.get_Vec2f("gun_trans").x + this.getSprite().getOffset().x))*flip_factor,
						this.get_Vec2f("muzzle_offset").y + this.get_Vec2f("gun_trans").y + this.getSprite().getOffset().y)
				.RotateBy( this.get_f32("gunangle"), Vec2f()),  	// position   
			//
			(vel == Vec2f(-69, -69) ? (Vec2f(													// velocity
				flip_factor * (-Maths::Abs(Maths::Min(speed_mod, 6) + XORRandom(4))),
				self_ejecting && stored_carts != 1 ? 0 : -Maths::Min(speed_mod, 6)) * (!self_ejecting ? (0.03 * (i + 1)) : 1)) : vel),
			//
			0,                              						// column
			0,                                  					// row
			Vec2f(8, 8),                      						// frame size
			1.0f,                               					// scale?
			0,                                  					// ?
			"ShellDrop" + sound_rnd,                      			// sound
			this.getTeamNum()										// team number
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