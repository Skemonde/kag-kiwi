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
	tl = Vec2f(128, 70);
	if (coins > 0)
	{
		GUI::DrawIconByName("$icon_dogtag$", tl + Vec2f(0 + slot * 40, 4));
		GUI::SetFont("menu");
		GUI::DrawText("" + coins, tl + Vec2f(24 + slot * 40 , 0), color_white);
	}
}
