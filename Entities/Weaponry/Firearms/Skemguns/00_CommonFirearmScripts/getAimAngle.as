#include "FirearmVars.as";

f32 getAimAngle( CBlob@ this, CBlob@ holder, Vec2f muzzle_offset = Vec2f(-69, -69) )
{
	const bool flip = this.isFacingLeft();
	const f32 flip_factor = flip ? -1: 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	const Vec2f shoulder_joint = Vec2f(-3 * flip_factor, -3);
	
	FirearmVars@ vars;
	this.get("firearm_vars", @vars);
	
	// находим координату дула пушки
	muzzle_offset =
		// условие...
		(muzzle_offset == Vec2f(-69, -69)
			// ...верно?
			? Vec2f(flip_factor*this.get_Vec2f("gun_trans").x*0,
				(this.get_Vec2f("gun_trans").y+vars.MUZZLE_OFFSET.y))
			// если нет, то используем параметр, который получили при вызове функции
			: muzzle_offset);
	
	// вращаем конец ствола пушки вокруг плеча персонажа через угол между курсором и этим самым плечом
	// но из-за этого не выходит избежать погрешности, пуля отходит от направления, но это едва заметно :P
	// получи пушку "uzi" и убедись, как здорово работает эта формула!!
	Vec2f pos = this.getPosition() + muzzle_offset.RotateBy(
	constrainAngle(angle_flip_factor-((holder.getAimPos() - holder.getPosition()).Angle())), shoulder_joint);
	
 	Vec2f aimvector = holder.getAimPos() - pos;
	f32 angle = aimvector.Angle() + this.getAngleDegrees();
    return constrainAngle(angle_flip_factor-(angle+flip_factor))*flip_factor;
}

f32 constrainAngle(f32 x)
{
	x = (x + 180) % 360;
	if (x < 0) x += 360;
	return x - 180;
}