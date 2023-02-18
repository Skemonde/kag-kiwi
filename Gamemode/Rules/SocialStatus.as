string getStatus(string &in username, u32 &out col, CPlayer@ p)
{
	switch(username.getHash())
	{
		case 1785258408: //skemon
		{
			//col = 0xff1C5D99; //lapis lazuli
			//col = 0xff1BE7FF; //sky blue crayola
			col = 0xff279AF1; //dodger blue
			return "Idea Author"; break;
		}
		case 285285759: //xeno <3
		{
			//col = 0xffDC143C; //crimson
			col = 0xffFF1053; //radical red
			return "Sussiest Baka"; break;
		}
		
		default: {
			return "";
		}
	}
	return "";
}

bool IsCool(string username)
{
	return 	username=="TheCustomerMan"||				// skemon
			username=="PURPLExeno"||					// xeno <3
			
			(isServer()&&isClient()); 					//**should** return true only on localhost
}