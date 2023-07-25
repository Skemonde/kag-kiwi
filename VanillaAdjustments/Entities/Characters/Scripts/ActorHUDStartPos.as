//for use with DefaultActorHUD.as based HUDs

f32 getHUDX()
{
	return getScreenWidth() / 3;
}

f32 getHUDY()
{
	return getScreenHeight();
}

// compatibility - prefer to use getHUDX() and getHUDY() as you are rendering, because resolution may dynamically change (from asu's staging build onwards)
const f32 HUD_X = getHUDX();
const f32 HUD_Y = getHUDY();

Vec2f getActorHUDStartPosition(CBlob@ blob, const u8 bar_width_in_slots)
{
	f32 width = bar_width_in_slots * 40.0f;
	return Vec2f(getHUDX() + 180 + 50 + 8 - width, getHUDY() - 40);
}

void DrawInventoryOnHUD(CBlob@ this, Vec2f tl)
{
	if (isPlayerListShowing()) return;
	SColor col;
	u16 slot_size = 24*2;
	u16 inventory_gui_width = slot_size * 2;
	CInventory@ inv = this.getInventory();
	string[] drawn;
	for (int i = 0; i < inv.getItemsCount(); i++)
	{
		CBlob@ item = inv.getItem(i);
		const string name = item.getName();
		
		u16 item_width = item.getSprite().getFrameWidth()*2;
		//f32 item_height = Maths::Max(Maths::Ceil((item.getSprite().getFrameHeight()*2)/slot_size)*slot_size, slot_size);
		u16 item_height = item.getSprite().getFrameHeight()*2;
		
		if (drawn.find(name) == -1)
		{
			const int quantity = this.getBlobCount(name);
			drawn.push_back(name);
			
			GUI::DrawIcon(
				"inventory_gui_tab",
				0,
				Vec2f(inventory_gui_width, slot_size),
				tl + Vec2f(0, (drawn.length) * slot_size - slot_size/2 - 6*(drawn.length)),
				0.5f);

			GUI::DrawIcon(
				item.inventoryIconName,
				item.inventoryIconFrame,
				item.inventoryFrameDimension,
				tl + Vec2f((inventory_gui_width - item_width)/2, (drawn.length) * slot_size - (item_height)/2 - 6*(drawn.length)),
				1.0f,
				this.getTeamNum());

			f32 ratio = float(quantity) / float(item.maxQuantity);
			col = ratio > 0.4f ? SColor(255, 255, 255, 255) :
			      ratio > 0.2f ? SColor(255, 255, 255, 128) :
			      ratio > 0.1f ? SColor(255, 255, 128, 0) : SColor(255, 255, 0, 0);

			GUI::SetFont("menu");
			Vec2f dimensions(0,0);
			string disp = "" + quantity;
			GUI::GetTextDimensions(disp, dimensions);
			
			GUI::DrawText(
				disp,
				tl + Vec2f(inventory_gui_width, (drawn.length) * slot_size - (item_height)/2 - 6*(drawn.length)),
				col);
		}
	}
}

void DrawCoinsOnHUD(CBlob@ this, const int coins, Vec2f tl, const int slot)
{
	tl = this.get_Vec2f("healthRightSide");
	tl+=Vec2f(260,0);
	Vec2f br(getDriver().getScreenWidth(), getDriver().getScreenHeight());
	if (coins > 0)
	{
		GUI::DrawIconByName("$icon_dogtag$", tl + Vec2f(16, 16));
		GUI::SetFont("menu");
		GUI::DrawText("" + coins + " tags\n\n(1 kill gives you 1 tag)", tl + Vec2f(60, 16), color_white);
	}
	f32 daytime = getMap().getDayTime();
	f32 hours_in_day = 24;
	f32 minutes_in_hour = 60;
	f32 minutes_in_day = hours_in_day*minutes_in_hour;
	f32 float_in_day = 1.0f;
	f32 float_in_min = float_in_day/(minutes_in_day);
	f32 current_hour = daytime/float_in_min/60;
	
	GUI::DrawText(formatFloat(Maths::Floor(current_hour%12)==0?12:Maths::Floor(current_hour%12), "0", 2, 0)+":00 "+(current_hour/12>1?"PM":"AM"),
		Vec2f(br.x, tl.y) + Vec2f(-220, 24), color_white);
	const u16 MAX_U16 = -1;
	GUI::DrawText(getRules().daycycle_speed==MAX_U16?"Time's stopped":"Time's going",
		Vec2f(br.x, tl.y) + Vec2f(-220, 64), color_white);
	
	GUI::DrawText(!getRules().get_bool("ammo_usage_enabled")?"Reloading takes NO ammo":"Reloading requires ammo",
		Vec2f(br.x, tl.y) + Vec2f(-220, 44), color_white);
}
