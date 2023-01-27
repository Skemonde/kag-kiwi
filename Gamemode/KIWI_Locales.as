// thanks to GingerBeard <3

// works by seperating each language by token '\\'
// all translations are only set on startup, therefore changing language mid-game will not update the strings

shared const string Translate(const string&in words)
{
	string[]@ tokens = words.split("\\");
	if (g_locale == "ru" && tokens.length > 1 && !tokens[1].empty()) 	//russian
		return tokens[1];	
	if (g_locale == "de" && tokens.length > 2 && !tokens[2].empty()) 	//german
		return tokens[2];
	if (g_locale == "br" && tokens.length > 3 && !tokens[3].empty()) 	//porteguese
		return tokens[3];
	if (g_locale == "pl" && tokens.length > 4 && !tokens[4].empty()) 	//polish
		return tokens[4];
	if (g_locale == "fr" && tokens.length > 5 && !tokens[5].empty()) 	//french
		return tokens[5];
	if (g_locale == "es" && tokens.length > 6 && !tokens[6].empty()) 	//spanish
		return tokens[6];
		
	return tokens[0];													//english
}

//	English 	- Skemonde
//	Russian 	- Skemonde
//	German
//	Porteguese	
//	Polish		
//	French		
//	Spanish		

namespace Descriptions
{
	const string
	
	//Structures
	armory     	      	   	= Translate(" Hachi from Orange Star sends his greetings  \\ Хачи из Оранжевой Звезды передаёт привет  "),
	
	//Items
	lowcal		  	       	= Translate(" Ammo for handguns and submachine guns  \\ Патроны для пистолетов и пистолетов-пулемётов  "),
	highpow					= Translate(" Ammo for rifles and heavy machine guns  \\ Патроны для винтовок и крупнокалиберных пулемётов "),
	shotgunshells			= Translate(" Shotgun shells for shotguns, bingo!  \\ Дробовые патроны для дробовиков, бинго!  "),
	froggy					= Translate(" A handgrenade with a cute nickname can easily rip off limbs of your enemies or make a blood downpour  \\ Ручная граната с милым прозвищем может легко отрывать руки врагов или устроить кровавый душ  "),
	flashy					= Translate(" Holy moly!\n Watch your eyes!!  \\ Батюшки-светы!\n Береги глаза!!  "),
	amogus					= Translate(" bruh\n you lookin' real sussy over there\n did you take the fortnite card for me bruh?\n imma need that fortnite card back\n but you're sussy and i'm coming to get it\n imma BLOCK you go\n B L O C C"),
	
	//Guns
	revolver     	   		= Translate(" Simple but still dangerous - the handgun is a good choice for those who's tired of fighting with their bare hands\n\nUses  $lowcal$ as ammo.\\ Простенький, но всё же опасный - револьвер, это прекрасный выбор для тех, кто устал сражаться голыми руками.\n\nИспользует  $lowcal$ в качестве патронов."),
	smg						= Translate(" Amazing choice for those who got themselves in a meele fight where you don't have time for aiming and reloading\n\nUses  $lowcal$ as ammo.\\ Великолепный выбор для тех, кто попал в бой на близкой дистанции: где нет времени на прицельную стрельбу и перезарядку.\n\nИспользует  $lowcal$ в качестве патронов."),
	rifle 					= Translate(" Power and accuracy are both a brilliant choice for shooting foes who keep themselves afar.\n\nUses  $highpow$ as ammo.\\ Сила и точность - чудесный выбор для стрельбы по врагу, что предпочитает держаться на расстоянии.\n\nИспользует  $highpow$ в качестве патронов."),
	mp						= Translate(" Superior compared to a revolver the firearm's construction allows you to shoot without thinking of reloading each shot however it's a handgun after all so you can barely aim it.\n\nUses  $lowcal$ as ammo.\\ Превосходящая револьверную кострукция пистолета позволяет не задумываться о перезарядке каждого выстрела, однако это всё же пистолет, и вам будет трудно совладать с ним.\n\nИспользует  $lowcal$ в качестве патронов."),
	shotgun					= Translate(" Everyone loves powerful guns!!\n\nUses  $shells$ as ammo.\\ Всем нравятся мощные пушки!!\n\nИспользует  $shells$ в качестве патронов."),
	fa_shotgun				= Translate(" God mothaducking dammmn.\n\nUses  $shells$ as ammo.\\ *непереводимое удивление*\n\nИспользует  $shells$ в качестве патронов."),
	sniper 					= Translate(" What seems an ordinary gun with an only difference in an increased damage happens to be an one you guessed it is however it has a very cool projectile (it pierces 3 targets before fading)\n\nUses  $highpow$ as ammo.\\ Что кажется заурядной винтовкой с банально увеличенным уроном такой, к сожалению, и оказывается, однако у неё классный снаряд (пробивает 3 цели перед распадом)\n\nИспользует  $highpow$ в качестве патронов."),
	kushana					= Translate(" If you've seen Nausicaa of Miyadzaki Hayao you probably are familiar the handgun.\n\nUses  $lowcal$ as ammo.\\ Если вы смотрели 'Навсикая из долины ветров' Миядзаки Хаяо, вы, должно быть, знакомы с этим пистолетом.\n\nИспользует  $lowcal$ в качестве патронов."),
	ruhm 					= Translate(" VALKYRIA CHRONICLES 1 !!!!!!!!!!!!\nSelvaria Bles is best girl!!!\n\nUses  $highpow$ as ammo.\\ ХРОНИКИ ВАЛЬКИРИИ 1 !!!!!!!!!!!!\nСельвария Блес - лучшая девочка!!!\n\nИспользует  $highpow$ в качестве патронов."),
	
	//UI Descriptions
	choose_headpack			= Translate("Select a headpack you want to use\\Выберите пак с головами, который хотите использовать"),
	choose_head				= Translate("Select a head you want to use\\Выберите голову, которую хотите использовать"),
	lockpickup				= Translate("Lock autopickup\\Запретить автоподбор предметов"),
	unlockpickup			= Translate("Unlock autopickup\\Разрешить автоподбор предметов"),
	
	empty 					= "";
}

namespace Names
{
	const string
	
	//Structures
	armory					= Translate("Armory\\Оружейная"),
	
	//Items
	lowcal					= Translate("Lowcal Ammo\\Малокалиберные патроны"),
	highpow					= Translate("Highpow Ammo\\Патроны высокой мощности"),
	shotgunshells			= Translate("Shotgun Shells\\Дробовые патроны"),
	froggy					= Translate("Hand Grenade 'Froggie'\\Ручная граната 'Лягушечка'"),
	flashy					= Translate("Flash Grenade 'Flashie'\\Световая граната 'Вспышечка'"),
	amogus					= Translate("Amogus Plush <3\\Плюшевый Амогусик <3"),
	
	//Guns
	revolver				= Translate("Revolver\\Револьвер"),
	smg						= Translate("SMG\\Пистолет-пулемёт"),
	rifle 					= Translate("Rifle\\Винтовка"),
	mp						= Translate("Machine Pistol\\Самозарядный пистолет"),
	shotgun					= Translate("Shotgun\\Дробовик"),
	fa_shotgun				= Translate("Full-Auto Shotgun\\Автоматический дробовик"),
	sniper 					= Translate("Sniper Rifle\\Снайперская винтовка"),
	kushana					= Translate("Kushana's Blaster\\Бластер Кушаны"),
	ruhm 					= Translate("Sniper Machine Gun 'Ruhm'\\Снайперский пулемёт 'Рум'"),
	
	//UI Names
	headtab					= Translate("Headstuff\\Головы"),
	headcfg					= Translate("Head Configure\\Настроить голову"),
	
	empty					= "";
}
