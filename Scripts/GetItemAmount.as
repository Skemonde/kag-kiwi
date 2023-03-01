u16 GetItemAmount(CBlob@ this, const string item_name = "mat_stone")
{
	CInventory@ inv = this.getInventory();
	CBlob@ carried = this.getCarriedBlob();
	u16 quan = 0;
	if (inv != null)
	{
		for (int i = 0; i < inv.getItemsCount(); ++i) {
			if (inv.getItem(i) != null && inv.getItem(i).getName() == item_name)
				quan += inv.getItem(i).getQuantity();
		}
	}
	if (carried !is null && carried.getName() == item_name)
		quan += carried.getQuantity();
	
	return quan;

	return 0;
}