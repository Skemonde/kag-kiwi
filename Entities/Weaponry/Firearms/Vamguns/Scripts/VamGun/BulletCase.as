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
        p.bounce = 0.25;
        p.freerotation = true;
        p.fastcollision = true;
        p.lighting = true;
        p.lighting_delay = 0;
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