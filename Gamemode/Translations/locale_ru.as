// name the namespace after the language for clarity
// ru for russian
namespace ru
{
	const string
	
	//	NAMES
	n_team_skyblue			= "Клета",
	n_team_red              = "Императа",
	//Lorraine Military Army Union
	
	//	weps
	n_anti_tank_rifle		=	"Противотанковое ружьё",
	n_assault_rifle			=	"Штурмовая винтовка",
	n_auto_shotgun			=	"Автоматический дробовик",
	n_bazooka				=	"Базука",
	n_drum_smg				=	"Барабанный ПП",
	n_pocket_smg			=	"Карманный ПП",
	n_pump_shotgun			=	"Помповый дробовик",
	n_revolver				=	"Револьвер",
	n_semi_auto_pistol		=	"Самозарядный пистолет",
	n_semi_auto_rifle		=	"Самозарядная винтовка",
	n_single_shot_nader		=	"Однозарядный гранатомёт",
	n_sniper_rifle			=	"Снайперская винтовка",
	
	//	structures
	n_armory                = "Оружейная",
	n_campfire              = "Костёр",
	
	//	food
	n_fried_steak           = "Прожаренный стейк",
	n_cooked_fish           = "Приготовленная рыба",
	n_healing_potion        = "Исцеляющее зелье",
	n_bread_loaf            = "Буханка хлеба",
	n_cherry_cake           = "Вишнёвый пирог",
	n_burgir                = "Бургир",
	n_beer_mug              = "Бокал пива",
	n_sushi                 = "Суши",
	
	//	ammo
	n_lowcal                = "Малокалиберные патроны",
	n_highpow               = "Высокомощные патроны",
	n_shotgunshells         = "Дробовые патроны",
	n_fuel_canister			= "Канистра топлива",
	n_draground				= "Патрон Драгунова",
	n_tank_shell			= "Танковый cнаряд",
	
	//	explosives
	n_frag_grenade			= "Ручная граната \"Froggy\"",
	n_molotov				= "Коктейль для Молотова",
	n_aerial_bomb			= "Авиационная бомба",
	n_land_mine				= "Противопехотная мина",
	n_tank_mine				= "Противотанковая мина",
	
	//	items
	n_bayonet				= "Штык-нож",
	n_laser_pointer			= "Лазерный указатель",
	n_underbarrel_nader		= "Подствольник",
	n_shovel				= "Окопная Лопата",
	n_wrench				= "Стальной ключ",
	n_mason_hammer			= "Молот каменщика",
	n_steel_crate			= "Стальной ящик",
	n_knight_shield			= "Рыцарский щит",
	n_riot_shield			= "Полицейский щит",
	n_combat_helmet			= "Солдатская каска",
	n_heavy_helmet			= "Тяжёлый шлем",
	n_medic_helmet			= "Каска медика",
	n_bandage				= "Бинты",
	n_amogus                = "Плюшевый АМОГУС <3",
	n_binoculars			= "Бинокль",
	n_food					= "Бургер",	
	
	//	ui 
	n_headtab               = "Головы",
	n_headcfg               = "Настроить голову",
	
	//	DESCRIPTIONS
	
	//	weps
	d_anti_tank_rifle		= 	n_anti_tank_rifle
								+"\n"
								+"\n"
								+"Станит вражескую технику удачным попаданием.\n"
								+"Пехота попавшая на линию огня превратится в кроварый пар.\n"
								+"Имеет чудовищную отдачу, которая подкидывает в воздух при выстреле.\n"
								+"\n"
								+"Использует  $draground$ в качестве патронов.",
	
	d_assault_rifle			=	n_assault_rifle
								+"\n"
								+"\n"
								+"Стреляет очередями по три пули, имеет лазерный указатель и подствольник.\n"
								+"Чем больше пуль из одной очереди попало в цель, тем больше каждая из них нанесёт.\n"
								+"\n"
								+"Использует  $highpow$ в качестве патронов.\n"
								+"И $froggy$ для подствольника.",
								
	d_auto_shotgun			=	n_auto_shotgun
								+"\n"
								+"\n"
								+"Может сделать целых 8 выстрелов с хорошей скорострельностью на неплохое расстояние.\n"
								+"\n"
								+"Использует  $shells$ в качестве патронов.",
								
	d_bazooka				=	n_bazooka
								+"\n"
								+"\n"
								+"Однозарядная пусковая установка, стреляющая ракетами.\n"
								+"\n"
								+"Использует  $froggy$ в качестве патронов.",
								
	d_drum_smg				=	n_drum_smg
								+"\n"
								+"\n"
								+"Обеспечивает хорошую плотность огня в течение приличного периода времени.\n"
								+"Имеет магазин на 40 патронов. Полезен на средних дистанциях.\n"
								+"\n"
								+"Использует  $lowcal$ в качестве патронов.",
								
	d_pocket_smg			=	n_pocket_smg
								+"\n"
								+"\n"
								+"Чем дольше вы стреляете, тем менее точной становится стрельба.\n"
								+"Рекомендуется стрелять только небольшими очередями.\n"
								+"Имеет магазин на 20 патронов и безумную скорость стрельбы.\n"
								+"\n"
								+"Использует  $lowcal$ в качестве патронов.",
								
	d_pump_shotgun			=	n_pump_shotgun
								+"\n"
								+"\n"
								+"Мощное оружие, которое лучше всего подходит для ближнего боя.\n"
								+"Способно с одного выстрела сразить солдата без шлема.\n"
								+"\n"
								+"Использует  $shells$ в качестве патронов.",
								
	d_revolver				=	n_revolver
								+"\n"
								+"\n"
								+"Не позволяйте милашному виду пистолета заставить вас думать, что это мусор.\n"
								+"Не позавидуешь тому, в кого попадут все 6 выстрелов этого револьвера.\n"
								+"\n"
								+"Использует  $lowcal$ в качестве патронов.",
								
	d_semi_auto_pistol		=	n_semi_auto_pistol
								+"\n"
								+"\n"
								+"Вполне способен убить обмундированного солдата. Имеет небольшое время перезарядки.\n"
								+"Использует дешёвые патроны и не занимает много места.\n"
								+"\n"
								+"Использует  $lowcal$ в качестве патронов.",
								
	d_semi_auto_rifle		=	n_semi_auto_rifle
								+"\n"
								+"\n"
								+"Урон этой винтовки зависит от пройденного пулей расстояния.\n"
								+"Рекомендуется вести огонь на большие дистанции.\n"
								+"\n"
								+"Использует  $highpow$ в качестве патронов.",
								
	d_single_shot_nader		=	n_single_shot_nader
								+"\n"
								+"\n"
								+"Запускает гранаты на большие расстояния.\n"
								+"Гранаты летят по дуге.\n"
								+"\n"
								+"Использует  $froggy$ в качестве патронов.",
								
	d_sniper_rifle			=	n_sniper_rifle
								+"\n"
								+"\n"
								+"Настолько сильная винтовка, что одного хэдшота достаточно для убийства.\n"
								+"Имеет маленькую скорострельность и всего лишь 3 патрона в магазине.\n"
								+"\n"
								+"Использует  $highpow$ в качестве патронов.",
	//	end of weps
	
	//	structures
	d_armory				=	"You can buy items and GUNS for money and gold here  ",
	
	//	ammo
	d_lowcal                = 	"\"Low Caliber Ammo\""
								+"\n"
								+"\nAmmo for handguns and submachine guns  ",
								
	d_highpow               = 	"\"High Power Ammo\""
								+"\n"
								+"\nAmmo for rifles and heavy machine guns  ",
								
	d_shotgunshells         = 	"Shotgun shells for shotguns, bingo!  ",
	
	d_fuel_canister         = 	"Fuel for a Flamethrower"
								+"\n"
								+"\nBe careful! It's flammable!!  ",
								
	d_draground				=	n_draground
								+"\n"
								+"\nOriginally designed to cover the gap between handheld guns and tank cannons"
								+"\n"
								+"\nAlthough some heavy rifles were made later to use this huge round  ",
								
	d_tank_shell			=	n_tank_shell
								+"\n"
								+"\nThis huge shells is used by big cannons"
								+"\nIf you're not careful enough, it can explode and hurt you  ",
	//	end of ammo
	
	//	explosives
	d_frag_grenade			=	"You know the rules? Never go on a mission without grenades!  ",
	
	d_molotov				=	"It's super effective against shielders! Even some tanks.  ",
	
	d_aerial_bomb			=	"It was designed for diving bombers, but you can use it with a mortar.  ",
	
	d_land_mine				=	"Goes off only when a victim steps off it.  ",
	
	d_tank_mine				=	"Huge land mine which is designed to fight enemy vehicles"
								+"\n"
								+"\nWon't go off if a soldat steps on it.  ",
	//	end of explosives
	
	//	items
	d_bayonet				=	"You can hit people with it"
								+"\n"
								+"\nYou can also attach it to a gun.  ",
	
	d_laser_pointer			=	"Your cat will love it!"
								+"\n"
								+"\nYou can also attach it to a gun.  ",
	
	d_underbarrel_nader		=	"Addon for a gun"
								+"\n"
								+"\nYou can also shoot from it but it's not a very good idea.  ",
								
	d_shovel				=	"You can dig stone and soil with this one"
								+"\n"
								+"\nYOU CAN ALSO PUT YOUR ENEMIES SIX FEET UNDER!!!  ",
	
	d_wrench				=	"Used to repair vehicles."
								+"\n"
								+"\nThe more recently your target was hit, the less you would repair it.  ",
	
	d_mason_hammer			=	"You can hit tiles and build stuff with this one.  ",
	
	d_steel_crate			=	"Very heavy steel crate. This one is much much more durable than the wooden one"
								+"\n"
								+"\nEnemies can not access its storage.  ",
								
	d_knight_shield			=	"Saves from any damage"
								+"\n"
								+"\nPress S to increase your shielding zone"
								+"\n"
								+"\n - Has better bash dash"
								+"\n - Not very durable  ",
								
	d_riot_shield			=	"Saves from any damage"
								+"\n"
								+"\nPress S to increase your shielding zone"
								+"\n"
								+"\n - Bash deals damage"
								+"\n - Medium Weight  ",
								
	d_combat_helmet			=	n_combat_helmet
								+"\n"
								+"\n - Head hits don't deal crit damage"
								+"\n - 5 less gunfire damage  ",
	
	d_heavy_helmet			=	n_heavy_helmet
								+"\n"
								+"\n - Head hits don't deal crit damage"
								+"\n - 40 less gunfire damage  "
								+"\n - Good against single hits but bad against continuous damage  ",
								
	d_medic_helmet			=	n_medic_helmet
								+"\n"
								+"\n - You can create healing grenades  ",
								
	d_bandage				=	"Throw a bandage on a friend when they're down! It will makes them feel better.  ",
	
	d_amogus                =	"bruh"
								+"\n you lookin' real sussy over there"
								+"\n did you take the fortnite card for me bruh?"
								+"\n imma need that fortnite card back"
								+"\n but you're sussy and i'm coming to get it"
								+"\n imma BLOCK you go"
								+"\n B L O C C  ",
	
	d_binoculars			=	"Use this when you want a dynamic camera inside vehicles.  ",
	//	end of items
	
	//	scoreboard
	d_rank                  = "Звание",
	d_nickname              = "Никнейм",
	d_username              = "Имя пользователя",
	d_ping                  = "Пинг",
	d_kills                 = "Убийств",
	
	//	ui
	d_choose_headpack       = "Выберите пак с головами, который хотите использовать",
	d_choose_head           = "Выберите голову, которую хотите использовать",
	d_lockpickup            = "Запретить автоподбор предметов",
	d_unlockpickup          = "Разрешить автоподбор предметов",
	
	empty 					= "";
}