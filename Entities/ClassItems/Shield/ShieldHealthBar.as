#include "Skemlib"

const string linadj_hp = "linear adjustment";

void onInit(CBlob@ this)
{
	// Set to current/init hp
	this.set_f32(linadj_hp, this.getHealth());
}

void onTick(CBlob@ this)
{
	if (g_videorecording) return;
	
	// Get init hp
	const f32 initialHealth = this.getInitialHealth();
	u32 ticks_since_last_hit = getGameTime()-this.get_u32("last_hit");

	// Slowly match to real hp
	if ((this.get_f32(linadj_hp) != this.getHealth()))
	{
		if (this.get_f32(linadj_hp) + 0.075 < this.getHealth())
		{
			this.set_f32(linadj_hp, this.get_f32(linadj_hp) + (this.getHealth()-this.get_f32(linadj_hp)));
		}
		else if (this.get_f32(linadj_hp) - 0.075 > this.getHealth())
		{
			this.set_f32(linadj_hp, this.get_f32(linadj_hp) - 0.075 * ticks_since_last_hit / 10);
		}
	}
}

void onRender(CSprite@ this)
{
	if (g_videorecording) return;

	CBlob@ blob = this.getBlob();
	CPlayer@ local = getLocalPlayer();
	if (local !is null)
	{
		if (local.getBlob() !is null)
		{
			if (local.getBlob().getTeamNum() != blob.getTeamNum())
			{
				if (blob.get_u32("disguise") > getGameTime()) return;
			}
		}
	}
	
	AttachmentPoint@ pickup_point = blob.getAttachments().getAttachmentPointByName("PICKUP");
	CBlob@ holder = pickup_point.getOccupied();
	if (holder is null || holder !is null && !holder.isMyPlayer()) return;

	Vec2f center = blob.getPosition();
	Vec2f mouseWorld = getControls().getMouseWorldPos();

	//Vec2f pos2d = blob.getScreenPos() + Vec2f(0, 55 - (blob.getName() == "bradleyturret" ? 30 : 0));
	Vec2f oldpos = blob.getOldPosition();
	Vec2f pos = blob.getPosition();
	Vec2f pos2d = holder.getInterpolatedScreenPos() + Vec2f(0, 55);
	Vec2f dim = Vec2f(55, 12);
	const f32 y = blob.getHeight() * 1.0f;
	const f32 initialHealth = blob.getInitialHealth();

	CMap@ map = getMap();
	bool inGround = map.isTileSolid(blob.getPosition());

	if (blob.hasTag("dead"))
		{ return; }

	if (inGround)
		{ return; }

	const f32 renderRadius = (blob.getRadius()) * 3.0f;
	bool mouseOnBlob = (mouseWorld - center).getLength() < renderRadius || true;
	
	const f32 perc  = blob.getHealth() / initialHealth;
	const f32 perc2 = blob.get_f32(linadj_hp) / initialHealth;

	CBlob@ localblob = getLocalPlayerBlob();

	if (mouseOnBlob && (localblob is null || (localblob !is null && localblob.getDistanceTo(blob) < 312.0f)))
	{
		if (initialHealth > 0.0f)
		{
			u8 team = 5;
			SColor color_light = GetColorFromTeam(team, 255, 0);
			SColor color_mid = GetColorFromTeam(team, 255, 1);
			SColor color_dark = GetColorFromTeam(team, 255, 2);

			if (perc >= 0.0f)
			{
				// Border
				GUI::DrawRectangle(Vec2f(pos2d.x - dim.x - 1,                        pos2d.y + y - 1),
								   Vec2f(pos2d.x + dim.x + 1,                        pos2d.y + y + dim.y + 0));

				

				// Red portion
				GUI::DrawRectangle(Vec2f(pos2d.x - dim.x + 2,                        pos2d.y + y + 0),
								   Vec2f(pos2d.x + dim.x - 1,                        pos2d.y + y + dim.y - 1), color_dark);
				//      tracer thing   perc2
				GUI::DrawRectangle(Vec2f(pos2d.x - dim.x + 1,                        pos2d.y + y + 0),
								   Vec2f(pos2d.x - dim.x + perc2 * 2.0f * dim.x - 3, pos2d.y + y + dim.y - 2), SColor(0xffdeba76)); //0xffdeba76



				// whiteness
				GUI::DrawRectangle(Vec2f(pos2d.x - dim.x + 0,                        pos2d.y + y + 0),
								   Vec2f(pos2d.x - dim.x + perc  * 2.0f * dim.x + 0, pos2d.y + y + dim.y - 2), SColor(0xffffffff));


				// Health meter trim
				GUI::DrawRectangle(Vec2f(pos2d.x - dim.x + 1,                        pos2d.y + y + 0),
								   Vec2f(pos2d.x - dim.x + perc  * 2.0f * dim.x - 1, pos2d.y + y + dim.y - 2), color_mid);
				// Health meter inside
				GUI::DrawRectangle(Vec2f(pos2d.x - dim.x + 5,                        pos2d.y + y + 0),
								   Vec2f(pos2d.x - dim.x + perc  * 2.0f * dim.x - 5, pos2d.y + y + dim.y - 3), color_light);

				//GUI::DrawShadowedText(Maths::Ceil((blob.getHealth() / blob.getInitialHealth()) * (blob.getInitialHealth() * 100)) + "/" + blob.getInitialHealth() * 100, Vec2f(pos2d.x - dim.x + 3, pos2d.y + y - 3), SColor(0xffffffff));

				GUI::SetFont("text");
				GUI::DrawShadowedText(blob.getInventoryName(), Vec2f(pos2d.x - dim.x + 3, pos2d.y + y - 3), SColor(0xffffffff));
			}
		}
	}
}