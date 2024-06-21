#include "MakeDustParticle"
#include "SteelCrusherCommon"
#include "Skemlib"

void onInit(CSprite@ this)
{
	CSpriteLayer@ head = this.addSpriteLayer("head", "CrusherHead.png" , 24, 56, -1, -1);
	CSpriteLayer@ pillar = this.addSpriteLayer("pillar", "CrusherPillar.png" , 24, 56, -1, -1);
	if (pillar !is null) {
		pillar.SetRelativeZ(-2);
		pillar.SetOffset(Vec2f(0, -25));
	}
}

void onTick(CSprite@ this)
{
	updateHeadLayer(this);
}

void updateHeadLayer(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	CSpriteLayer@ head = this.getSpriteLayer("head");
	if (head is null) return;
	
	head.SetRelativeZ(-1);
	
	if (!getRules().isMatchRunning()) return;
	
	const u32 LAST_PRODUCE = blob.get_u32("last_produce");
	const u16 PRODUCING_INTERVAL = getProducingInterval();
	
	//devides producing interval by 2 smaller intervals in first of which head is going up and in second one head is going down
	//head is going down faster so the interval for this is the charge_difference
	f32 charge_difference = 0.04f;
	f32 hit_height = 16.0f;
	bool going_down = LAST_PRODUCE-getGameTime()<charge_difference*PRODUCING_INTERVAL;
	
	if (isClient()) {
		if (LAST_PRODUCE-getGameTime()<2) {
			MakeDustParticle(blob.getPosition()+Vec2f(0, -16), XORRandom(2)==1?"dust.png":"dust2.png");
			head.SetOffset(Vec2f_zero);
			
			//this.PlaySound("catapult_destroy.ogg", 0.8f, 0.3f);
			PlayDistancedSound("catapult_destroy.ogg", 0.8f, 0.3f, blob.getPosition(), 0.01f, 0, 0);
			//this.PlaySound("rock_hit2.ogg", 0.8f, 0.3f);
			PlayDistancedSound("rock_hit2.ogg", 0.8f, 0.3f, blob.getPosition(), 0.01f, 0, 0);
			//this.PlaySound("long_range_mortar_shot.ogg", 0.4f, 1.3f);
			PlayDistancedSound("long_range_mortar_shot.ogg", 0.4f, 1.3f, blob.getPosition(), 0.01f, 0, 0);
		}
		if (going_down) {
			head.SetOffset(head.getOffset()+Vec2f(0, hit_height/PRODUCING_INTERVAL*(1.0f/charge_difference)));
			head.SetOffset(Vec2f(head.getOffset().x, Maths::Min(head.getOffset().y, 0.5f)));
		} else {
			head.SetOffset(head.getOffset()-Vec2f(0, hit_height/PRODUCING_INTERVAL*(1.0f/(1.0f-charge_difference))));
			head.SetOffset(Vec2f(head.getOffset().x, Maths::Max(head.getOffset().y, -hit_height)));
		}
	}
}