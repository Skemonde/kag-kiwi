//various stuff
//script by Skemonde uwu

//functions					- camelCase/PascalCase
//classes 					- camelCase/PascalCase
//consts					- SCREAMING_SNAKE_CASE
//variables 				- snake_case
//objects(class instance)	- snake_case
//so basically names are camelCase and things that can be changed are snake_case

const bool SERVER = isServer();
const bool CLIENT = isClient();
const bool LOCALHOST = SERVER && CLIENT;

string getMachineType() {
	return (SERVER?(!CLIENT?"Server":"Localhost"):"Client");
}

//return a digit from a given number and its position
//eg. FindDigit(10783, 2) would give you 7
//				  |
//digit ids---->43210
//				  ^
//				  |
//you can additionally change number system base if you want to get digits from hex or something
//it's 10 by default
u16 FindDigit(u16 number, u16 digit_position, const u8 number_system_base = 10)
{
	u16 mlt = Maths::Pow(number_system_base, digit_position);
    return Maths::Floor(
        (number-Maths::Round(number/(mlt*number_system_base))*(mlt*number_system_base))/mlt);
}

u16 GetItemAmount(CBlob@ this, const string item_name = "highpow")
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