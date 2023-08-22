#include "MakeDustParticle"
#include "MiningRigCommon"

void onInit(CSprite@ this)
{
	CSpriteLayer@ belt = this.addSpriteLayer("belt", "QuarryBelt.png", 32, 32);
	if (belt !is null)
	{
		//default anim
		{
			Animation@ anim = belt.addAnimation("default", 0, true);
			int[] frames = {
				0, 1, 2, 3,
				4, 5, 6, 7,
				8, 9, 10, 11,
				12, 13
			};
			anim.AddFrames(frames);
		}
		//belt setup
		belt.SetOffset(Vec2f(0.0f, 8.0f));
		belt.SetRelativeZ(1);
		belt.SetVisible(true);
	}
	this.SetEmitSound("/Quarry.ogg");
	this.SetEmitSoundPaused(true);
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	animateBelt(this, blob.hasTag("active"));
}

void animateBelt(CSprite@ this, bool isActive)
{
	//safely fetch the animation to modify
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	this.SetEmitSoundPaused(!isActive);
	CSpriteLayer@ belt = this.getSpriteLayer("belt");
	if (belt is null) return;
	Animation@ anim = belt.getAnimation("default");
	if (anim is null) return;

	//modify it based on activity
	if (isActive)
	{
		// slowly start animation
		if (anim.time == 0) anim.time = 10;
		if (anim.time > 5) anim.time--;
		if (isClient()&&blob.get_u32("last_produce")==getGameTime()+1) {
			anim.frame = 5;
		}
	}
	else
	{
		//(not tossing stone)
		if (anim.frame < 2 || anim.frame > 8)
		{
			// slowly stop animation
			if (anim.time == 6) anim.time = 0;
			if (anim.time > 0 && anim.time < 6) anim.time++;
		}
	}
}