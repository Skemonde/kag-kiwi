const string[] rank_short_forms =
{
	//soldiers ranks
	"CF",	 								//0
	"2GM",	 								//1
	"1GM",	 								//2
	"AGM",	 								//3
	"",		 								//4
	//officers
	"2LT", 									//5
	"1LT",									//6
	"CPT", 									//7
	"MAJ", 									//8
	"",										//9
	//generals
	"",										//10
	"",										//11
	"",										//12
	"",										//13
	"",										//14
	
	"" //rank_short_forms.length
};

const string[] rank_long_forms =
{
	//soldiers ranks
	"Cannon Fodder",	 					//0
	"Second Gunman",		 				//1
	"First Gunman",		 					//2
	"Ace Gunman",		 					//3
	"wip",									//4
	//officers
	"Second Leutnant", 						//5
	"First Leutnant",						//6
	"Captain", 								//7
	"Major", 								//8
	"N/A",									//9
	//generals
	"Generalmajor",							//10
	"Generalleutnant",						//11
	"General",								//12
	"Generaloberts",						//13
	"N/A",									//14
	
	"" //rank_long_forms.length
};

const string[] ranknames =
{
	//soldiers ranks
	rank_long_forms[0]+" ("+rank_short_forms[0]+")",	 	//0
	rank_long_forms[1]+" ("+rank_short_forms[1]+")",	 	//1
	rank_long_forms[2]+" ("+rank_short_forms[2]+")",	 	//2
	rank_long_forms[3]+" ("+rank_short_forms[3]+")",	 	//3
	"wip",													//4	
	//officers	
	rank_long_forms[5]+" ("+rank_short_forms[5]+")",	 	//5
	rank_long_forms[6]+" ("+rank_short_forms[6]+")",	 	//6
	rank_long_forms[7]+" ("+rank_short_forms[7]+")",	 	//7
	rank_long_forms[8]+" ("+rank_short_forms[8]+")",	 	//8
	"N/A",													//9
	//generals				
	"Generalmajor",											//10
	"Generalleutnant",										//11
	"General",												//12
	"Generaloberts",										//13
	"N/A",													//14
	
	"stalin" //ranknames.length
};