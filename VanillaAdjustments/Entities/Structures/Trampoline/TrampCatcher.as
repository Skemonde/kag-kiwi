
namespace Trampoline
{
	const string TIMER = "trampoline_timer";
	const u16 COOLDOWN = 25;
	const u8 SCALAR = 10;
	const bool SAFETY = true;
	const int COOLDOWN_LIMIT = 8;
}

void onInit(CBlob@ this)
{
	this.getShape().getConsts().collideWhenAttached = true;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return false;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2)
{
	if (blob is null || blob.isAttached() || blob.getShape().isStatic()) return;

	AttachmentPoint@ t_point = this.getAttachments().getAttachmentPointByName("TRAMP");
	CBlob@ tramp = t_point.getOccupied();
	
	if (tramp is null) {
		this.server_Die();
		return;
	}

	//choose whether to jump on team trampolines
	if (blob.hasTag("player")) return;
	
	if (blob.getOldVelocity().Length()<5) return;

	//get angle difference between entry angle and the facing angle
	Vec2f pos_delta = (blob.getPosition() - tramp.getPosition()).RotateBy(90);
	float delta_angle = Maths::Abs(-pos_delta.Angle() - this.getAngleDegrees());
	if (delta_angle > 180)
	{
		delta_angle = 360 - delta_angle;
	}
	//if more than 90 degrees out, no bounce
	if (delta_angle > 90)
	{
		return;
	}

	bool block = false;
	
	if (!block)
	{
		Vec2f velocity_old = blob.getOldVelocity();
		if (velocity_old.Length() < 1.0f) return;

		float angle = tramp.getAngleDegrees();

		Vec2f direction = Vec2f(0.0f, -1.0f);
		direction.RotateBy(angle);

		float velocity_angle = direction.AngleWith(velocity_old);

		if (Maths::Abs(velocity_angle) > 90)
		{
			Vec2f velocity = Vec2f(0, -Trampoline::SCALAR);
			velocity.RotateBy(angle);
			
			f32 force_modifier = 1.07f;
			f32 force_value = Maths::Max(6, velocity_old.Length()*force_modifier);
			blob.setVelocity(Vec2f(0,-force_value).RotateBy(angle));

			CSprite@ sprite = tramp.getSprite();
			if (sprite !is null)
			{
				sprite.SetAnimation("default");
				sprite.SetAnimation("bounce");
				sprite.PlaySound("TrampolineJump.ogg");
			}
		}
	}
}