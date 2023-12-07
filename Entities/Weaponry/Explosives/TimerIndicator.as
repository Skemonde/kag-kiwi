//Script by Skemonde
//If you want explosives have this timer simply add this script to explosives' config and...
//...add 'this.set_u16("death_timer", INSERT_YOUR_TIME_IN_SECONDS);' into their script
//
//
//updated by Skemonde to show numbers up to 999 hol ycow
#include "Skemlib"
#include "CExplosion"

void onInit(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	this.set_Vec2f("personal_timer_offset", Vec2f(0, -8));
	Vec2f timer_offset = this.get_Vec2f("personal_timer_offset");
	Vec2f digit = Vec2f(5, 7);
	f32 digit_z = 2000;

	CSpriteLayer@ timer_units = sprite.addSpriteLayer("timer_units", "digits.png", digit.x, digit.y);
	timer_units.SetFrameIndex(0);
	if (timer_units !is null)
	{
		timer_units.SetOffset(timer_offset);
		timer_units.setRenderStyle(RenderStyle::outline);
		timer_units.SetRelativeZ(digit_z);
		timer_units.SetVisible(false);
	}
	CSpriteLayer@ timer_tens = sprite.addSpriteLayer("timer_tens", "digits.png", digit.x, digit.y);
	timer_tens.SetFrameIndex(0);
	if (timer_tens !is null)
	{
		timer_tens.SetOffset(Vec2f(timer_offset.x + 4, timer_offset.y));
		timer_tens.setRenderStyle(RenderStyle::outline);
		timer_tens.SetRelativeZ(digit_z);
		timer_tens.SetVisible(false);
	}
	CSpriteLayer@ timer_hundreds = sprite.addSpriteLayer("timer_hundreds", "digits.png", digit.x, digit.y);
	timer_hundreds.SetFrameIndex(0);
	if (timer_hundreds !is null)
	{
		timer_hundreds.SetOffset(Vec2f(timer_offset.x + 8, timer_offset.y));
		timer_hundreds.setRenderStyle(RenderStyle::outline);
		timer_hundreds.SetRelativeZ(digit_z);
		timer_hundreds.SetVisible(false);
	}
}

void onTick( CBlob@ this )
{
	u8 amount_of_digits = 0;
	if (this.exists("death_timer") && !this.exists("death_date")) {
		this.set_u32("death_date", getGameTime() + (this.get_u16("death_timer") * getTicksASecond()));
		
		//for (int idx = 0; idx < 20; ++idx)
		//	AddToProcessor(this.getNetworkID(), this.get_u32("death_date"), 1);
	}
	if (!this.exists("death_date")) return;
	
	CSpriteLayer@ timer_units = this.getSprite().getSpriteLayer("timer_units");
	CSpriteLayer@ timer_tens = this.getSprite().getSpriteLayer("timer_tens");
	CSpriteLayer@ timer_hundreds = this.getSprite().getSpriteLayer("timer_hundreds");
	
	CPlayer@ localplayer = getLocalPlayer();
	bool visible_for_ownder = localplayer !is null && localplayer is this.getDamageOwnerPlayer();
		
	if (this.get_u32("death_date") >= getGameTime() && timer_units !is null && timer_tens !is null && timer_hundreds !is null)
	{
		//don't allow numbers to rotate
		timer_units.SetFacingLeft(false);
		timer_tens.SetFacingLeft(false);
		timer_hundreds.SetFacingLeft(false);
		
		u32 remaining_time = (this.get_u32("death_date") + getTicksASecond() - getGameTime())/getTicksASecond();
		
		u8 timer_units_frames = FindDigit(remaining_time, 0);
		u8 timer_tens_frames = FindDigit(remaining_time, 1);
		u8 timer_hundreds_frames = FindDigit(remaining_time, 2);
	
		if (remaining_time > 0)
		{
			timer_units.SetVisible(visible_for_ownder);
			++amount_of_digits;
			timer_units.SetFrameIndex(timer_units_frames);
			if (remaining_time > 9)
			{
				timer_tens.SetVisible(visible_for_ownder);
				++amount_of_digits;
				timer_tens.SetFrameIndex(timer_tens_frames);
				
				if (remaining_time > 99)
				{
					timer_hundreds.SetVisible(visible_for_ownder);
					++amount_of_digits;
					timer_hundreds.SetFrameIndex(timer_hundreds_frames);
				}
				else
				{
					timer_hundreds.SetVisible(false);
					--amount_of_digits;
				}
			}
			else
			{
				timer_tens.SetVisible(false);
				--amount_of_digits;
			}
		}
		else
		{
			timer_units.SetVisible(false);
			--amount_of_digits;
		}
		
		this.set_Vec2f("personal_timer_offset", Vec2f(-(amount_of_digits * 3 - (amount_of_digits - 1) - 1) / 2, -8));
		Vec2f timer_offset = this.get_Vec2f("personal_timer_offset");
		timer_units.SetOffset(timer_offset);
		timer_tens.SetOffset(Vec2f(timer_offset.x + 4, timer_offset.y));
		timer_hundreds.SetOffset(Vec2f(timer_offset.x + 4 * 2, timer_offset.y));
	}// else this.server_Die();
}