#include "ShopCommon"

Vec2f getShopMenuHeight(CBlob@ this, const int SHOP_MENU_WIDTH = 5)
{
	ShopItem[]@ shop_items;
	
	if (!this.get(SHOP_ARRAY, @shop_items))
	{
		return Vec2f_zero;
	}
	if (shop_items.length<1) return Vec2f_zero;
	int squared_inventory_space = 0;
	for (int counter = 0; counter < shop_items.length; ++counter) {
		ShopItem@ item = @shop_items[counter];
		if (item is null) { continue; }
		if (item.customButton)
			squared_inventory_space += item.buttonwidth * item.buttonheight;
		else {
			string icon_name = item.iconName;
			Vec2f icon_dims(1, 1);
			u8 slot_size = 24;
			GUI::GetIconDimensions(icon_name, icon_dims);
			icon_dims = Vec2f(Maths::Ceil(icon_dims.x/slot_size), Maths::Ceil(icon_dims.y/slot_size));
			squared_inventory_space += icon_dims.x * icon_dims.y;
			if ((icon_dims.x * icon_dims.y)>4) {
				print("big icon? square="+(icon_dims.x * icon_dims.y)+"\nname: "+icon_name);
			}
		}
	}
	return Vec2f(SHOP_MENU_WIDTH, Maths::Floor(squared_inventory_space/SHOP_MENU_WIDTH)+(squared_inventory_space%SHOP_MENU_WIDTH==0?0:1));
}