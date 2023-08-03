string getStatus(string &in username, u32 &out col, string &out portrait_name = "face_builder")
{
	//CopyToClipboard(""+"USER_NAME".getHash());
	//type text above in HOME console (don't forget to put the username)
	switch(username.getHash())
	{
		case 1785258408: //skemon
		{
			col = 0xff279AF1; //dodger blue
			portrait_name = "face_vash";
			return "Idea Author";
		}
		case 285285759: //xeno <3
		{
			col = 0xffFF1053; //radical red
			portrait_name = "AmogusIcon";
			return "Sussiest Baka";
		}
		case -1573475899: //ferre
		{
			portrait_name = "face_ferre";
			break;
		}
		case 1139101686: //pirate rob
		{
			portrait_name = "face_piraterob";
			break;
		}
		case -1577822265://goldenguy
		{
			portrait_name = "face_golden";
			break;
		}
		case 1664473851: //dragonfriend
		{
		
		}
		
		default: {
			portrait_name = "face_knight";
			return "";
		}
	}
	return "";
}

bool susBadge(string username)
{
	return 	username=="PURPLExeno";						// xeno <3
}

bool kiwiBadge(string username)
{
	return 	username=="GoldenGuy"||						// B)
			username=="MrHobo"||						// ginger
			username=="Pirate-Rob"||					// rob
			
			username=="TheCustomerMan";					// skemon
}

bool IsCool(string username)
{
	return 	username=="TheCustomerMan"||				// skemon
			username=="PURPLExeno"||					// xeno <3
			username=="GoldenGuy"||						// B)
			
			(isServer()&&isClient()||sv_test); 			//**should** return true only on localhost or if sv_test
}