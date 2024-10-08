string getStatus(string &in username, u32 &out col, string &out portrait_name = "face_builder")
{
	//CopyToClipboard(""+"USER_NAME".getHash());
	//type text above in HOME console (don't forget to put the username)
	switch(username.getHash())
	{
		case 1785258408: //skemon
		{
			col = 0xff279AF1; //dodger blue
			portrait_name = "face_keak";
			return "Idea Author";
		}
		case 285285759: //xeno <3
		{
			col = 0xffFF1053; //radical red
			portrait_name = "face_xeno";
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
			//people with no portrait are doomed as the portrait is binded to their hash which does NOT change
			//unlike netID
			//so some people shall always have builder and some some shall get a knight portrait
			if (Maths::Abs(username.getHash())%512<256)
				portrait_name = "face_builder.png";
			else
				portrait_name = "face_knight.png";
			return "";
		}
	}
	return "";
}

bool susBadge (string username)
{
	return 	username=="PURPLExeno";						// xeno <3
}

bool translatorBadgeGerman(string username)
{
	return 	username=="superhenry";						// SUPER
}

bool translatorBadgeRussian(string username)
{
	return 	username=="GameMeteor";						// doridos
}

bool kiwiBadge (string username)
{
	return 		username=="GoldenGuy"					// B)
			||	username=="MrHobo"						// ginger
			||	username=="Pirate-Rob"					// rob
			||	username=="LorderPlay"					// лёня
			||	username=="LhaBald"						// person X
				
			||	username=="TheCustomerMan"				// skemon
			;
}

bool IsCool(string username)
{
	CPlayer@ player = getPlayerByUsername(username);
	if (player is null) return false;
	
	return 		username=="TheCustomerMan"				// skemon
			||	username=="GoldenGuy"					// B)
			||	username=="Pirate-Rob"					// rob
			||	username=="LhaBald"						// person X
			//||	username=="PURPLExeno"					// xeno <3
			
			||	(isServer()&&isClient())		 		//**should** return true only on localhost
			||	getRules().get_bool("free shops") && player.isMod()
			;
}