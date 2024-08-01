shared const string Translate(const string&in words)
{
	string[]@ tokens = words.split("\\");
	if (g_locale == "ru" && tokens.length > 1 && !tokens[1].empty()) 	//russian
		return tokens[1];
	if (g_locale == "de" && tokens.length > 2 && !tokens[2].empty()) 	//german
		return tokens[2];
	if (g_locale == "es" && tokens.length > 3 && !tokens[3].empty()) 	//spanish
		return tokens[3];
	if (g_locale == "jp" && tokens.length > 4 && !tokens[4].empty()) 	//japanese
		return tokens[4];
		
	return tokens[0];													//english
}

namespace en
{
	const string
	
	//	NAMES
	n_team_skyblue			= "Cletta",
	n_team_red              = "Imperata",
	//Lorraine Military Army Union
	
	//	weps
	n_anti_tank_rifle		=	"Anti-Tank Rifle",
	n_assault_rifle			=	"Assault Rifle",
	n_auto_shotgun			=	"Auto Shotgun",
	n_bazooka				=	"Bazooka",
	n_drum_smg				=	"Drum SMG",
	n_pocket_smg			=	"Pocket SMG",
	n_pump_shotgun			=	"Pump Shotgun",
	n_revolver				=	"Revolver",
	n_semi_auto_pistol		=	"Semi-Auto Pistol",
	n_semi_auto_rifle		=	"Semi-Auto Rifle",
	n_single_shot_nader		=	"Single Shot 'Nader",
	n_sniper_rifle			=	"Sniper Rifle",
	
	//	structures
	n_armory                = "Armory",
	n_campfire              = "Campfire",
	
	//	food
	n_fried_steak           = "Fried Steak",
	n_cooked_fish           = "Cooked Fish",
	n_healing_potion        = "Healing Potion",
	n_bread_loaf            = "Loaf of Bread",
	n_cherry_cake           = "Cherry Cake",
	n_burgir                = "Burgir",
	n_beer_mug              = "Maßkrug of Bier",
	n_sushi                 = "Sushi",
	
	//	ammo
	n_lowcal                = "Lowcal Ammo",
	n_highpow               = "Highpow Ammo",
	n_shotgunshells         = "Shotgun Shells",
	n_fuel_canister			= "Fuel Canister",
	n_draground				= "Dragunov Round",
	n_tank_shell			= "Tank Shell",
	
	//	explosives
	n_frag_grenade			= "Hand Grenade \"Froggy\"",
	n_molotov				= "Cocktail for Molotov",
	n_aerial_bomb			= "Aerial Bomb",
	n_land_mine				= "Anti-Personnel Mine",
	n_tank_mine				= "Anti-Tank Mine",
	
	//	items
	n_bayonet				= "Bayonet",
	n_laser_pointer			= "Laser Pointer",
	n_underbarrel_nader		= "Underbarrel 'Nader",
	n_shovel				= "Trench Shovel",
	n_wrench				= "Steel Wrench",
	n_mason_hammer			= "Brick Hammer",
	n_steel_crate			= "Steel Crate",
	n_knight_shield			= "Knight Shield",
	n_riot_shield			= "Riot Shield",
	n_combat_helmet			= "Combat Helmet",
	n_heavy_helmet			= "Heavy Helmet",
	n_medic_helmet			= "Medic Helmet",
	n_bandage				= "Bandage",
	n_amogus                = "Amogus Plush <3",
	n_binoculars			= "Binoculars",
	n_food					= "Burger",	
	
	//	ui 
	n_headtab               = "Headstuff",
	n_headcfg               = "Head Configure",
	
	//	DESCRIPTIONS
	
	//	weps
	d_anti_tank_rifle		= 	n_anti_tank_rifle
								+"\n"
								+"\n"
								+"Stops enemy's vehicles with a successful hit.\n"
								+"Infantry caught in the line of fire turn into a red mist of blood.\n"
								+"Has insane knockback which will send you flying upon firing the gun.\n"
								+"\n"
								+"Uses  $draground$ as ammo.",
	
	d_assault_rifle			=	n_assault_rifle
								+"\n"
								+"\n"
								+"Shoots bursts of 3 bullets, has a laser pointer and an underbarrel 'nader.\n"
								+"The more bullets that hit from a burst, the more damage each does successively.\n"
								+"\n"
								+"Uses  $highpow$ as ammo.\n"
								+"And $froggy$ for the 'nader.",
								
	d_auto_shotgun			=	n_auto_shotgun
								+"\n"
								+"\n"
								+"Can shoot a whopping 8 rounds with good firerate at decent range.\n"
								+"\n"
								+"Uses  $shells$ as ammo.",
								
	d_bazooka				=	n_bazooka
								+"\n"
								+"\n"
								+"A single shot launcher that fires rockets.\n"
								+"\n"
								+"Uses  $froggy$ as ammo.",
								
	d_drum_smg				=	n_drum_smg
								+"\n"
								+"\n"
								+"Provides a lot of suppressive fire for a decent period of time.\n"
								+"Has a 40 round magazine. Useful at mid ranges.\n"
								+"\n"
								+"Uses  $lowcal$ as ammo.",
								
	d_pocket_smg			=	n_pocket_smg
								+"\n"
								+"\n"
								+"The longer you fire the more inaccurate this becomes.\n"
								+"It's recommended to only fire the gun in small bursts.\n"
								+"Has a 20 round mag and an insane firerate.\n"
								+"\n"
								+"Uses  $lowcal$ as ammo.",
								
	d_pump_shotgun			=	n_pump_shotgun
								+"\n"
								+"\n"
								+"A powerful weapon which is the best when it comes to near-melee combat.\n"
								+"Is able to one-shot a soldat with no helmet.\n"
								+"\n"
								+"Uses  $shells$ as ammo.",
								
	d_revolver				=	n_revolver
								+"\n"
								+"\n"
								+"Don't let the cute look of this gun make you think it's useless.\n"
								+"If you manage to land all the shots on a target they won't be very alive.\n"
								+"\n"
								+"Uses  $lowcal$ as ammo.",
								
	d_semi_auto_pistol		=	n_semi_auto_pistol
								+"\n"
								+"\n"
								+"Has enough power to kill a soldat, Has a quick reload time.\n"
								+"Uses cheap ammo and takes little space.\n"
								+"\n"
								+"Uses  $lowcal$ as ammo.",
								
	d_semi_auto_rifle		=	n_semi_auto_rifle
								+"\n"
								+"\n"
								+"Damage of this rifle scales with the distance its bullets fly.\n"
								+"It's recommended to shoot from a great distance.\n"
								+"\n"
								+"Uses  $highpow$ as ammo.",
								
	d_single_shot_nader		=	n_single_shot_nader
								+"\n"
								+"\n"
								+"Launches grenades, with excellent range.\n"
								+"Grenades have an arc trajectory.\n"
								+"\n"
								+"Uses  $froggy$ as ammo.",
								
	d_sniper_rifle			=	n_sniper_rifle
								+"\n"
								+"\n"
								+"A rifle so strong that headshots can kill a soldat.\n"
								+"Has a slow firerate and only 3 round mag.\n"
								+"\n"
								+"Uses  $highpow$ as ammo.",
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
	d_rank                  = "Rank",
	d_nickname              = "Nickname",
	d_username              = "KAG Username",
	d_ping                  = "Ping",
	d_kills                 = "Kills",
	
	//	ui
	d_choose_headpack       = "Select a headpack you want to use",
	d_choose_head           = "Select a head you want to use",
	d_lockpickup            = "Lock autopickup",
	d_unlockpickup          = "Unlock autopickup",
	
	empty 					= "";
}

namespace Names
{
	const string
	
	//	weps
	anti_tank_rifle			= Translate(
										en::n_anti_tank_rifle
										+"\\"+
										ru::n_anti_tank_rifle
										+"\\"+
										de::n_anti_tank_rifle
										),
	assault_rifle			= Translate(
										en::n_assault_rifle
										+"\\"+
										ru::n_assault_rifle
										+"\\"+
										de::n_assault_rifle
										),
	auto_shotgun			= Translate(
										en::n_auto_shotgun
										+"\\"+
										ru::n_auto_shotgun
										+"\\"+
										de::n_auto_shotgun
										),
	bazooka					= Translate(
										en::n_bazooka
										+"\\"+
										ru::n_bazooka
										+"\\"+
										de::n_bazooka
										),
	drum_smg				= Translate(
										en::n_drum_smg
										+"\\"+
										ru::n_drum_smg
										+"\\"+
										de::n_drum_smg
										),
	pocket_smg				= Translate(
										en::n_pocket_smg
										+"\\"+
										ru::n_pocket_smg
										+"\\"+
										de::n_pocket_smg
										),
	pump_shotgun			= Translate(
										en::n_pump_shotgun
										+"\\"+
										ru::n_pump_shotgun
										+"\\"+
										de::n_pump_shotgun
										),
	revolver				= Translate(
										en::n_revolver
										+"\\"+
										ru::n_revolver
										+"\\"+
										de::n_revolver
										),
	semi_auto_pistol		= Translate(
										en::n_semi_auto_pistol
										+"\\"+
										ru::n_semi_auto_pistol
										+"\\"+
										de::n_semi_auto_pistol
										),
	semi_auto_rifle			= Translate(
										en::n_semi_auto_rifle
										+"\\"+
										ru::n_semi_auto_rifle
										+"\\"+
										de::n_semi_auto_rifle
										),
	single_shot_nader		= Translate(
										en::n_single_shot_nader
										+"\\"+
										ru::n_single_shot_nader
										+"\\"+
										de::n_single_shot_nader
										),
	sniper_rifle			= Translate(
										en::n_sniper_rifle
										+"\\"+
										ru::n_sniper_rifle
										+"\\"+
										de::n_sniper_rifle
										),
	//	end of weps
	
	
	//	teams
	team_skyblue			= Translate(
										en::n_team_skyblue
										+"\\"+
										ru::n_team_skyblue
										+"\\"+
										de::n_team_skyblue
										),
	team_red				= Translate(
										en::n_team_red
										+"\\"+
										ru::n_team_red
										+"\\"+
										de::n_team_red
										),
	//	end of teams
	
	//	structures
	armory					= Translate(
										en::n_armory
										+"\\"+
										ru::n_armory
										+"\\"+
										de::n_armory
										),
	campfire				= Translate(
										en::n_campfire
										+"\\"+
										ru::n_campfire
										+"\\"+
										de::n_campfire
										),
	//	end of structures
	
	//	food
	fried_steak				= Translate(
										en::n_fried_steak
										+"\\"+
										ru::n_fried_steak
										+"\\"+
										de::n_fried_steak
										),
	cooked_fish				= Translate(
										en::n_cooked_fish
										+"\\"+
										ru::n_cooked_fish
										+"\\"+
										de::n_cooked_fish
										),
	healing_potion			= Translate(
										en::n_healing_potion
										+"\\"+
										ru::n_healing_potion
										+"\\"+
										de::n_healing_potion
										),
	bread_loaf				= Translate(
										en::n_bread_loaf
										+"\\"+
										ru::n_bread_loaf
										+"\\"+
										de::n_bread_loaf
										),
	cherry_cake				= Translate(
										en::n_cherry_cake
										+"\\"+
										ru::n_cherry_cake
										+"\\"+
										de::n_cherry_cake
										),
	burgir					= Translate(
										en::n_burgir
										+"\\"+
										ru::n_burgir
										+"\\"+
										de::n_burgir
										),
	beer_mug				= Translate(
										en::n_beer_mug
										+"\\"+
										ru::n_beer_mug
										+"\\"+
										de::n_beer_mug
										),
	sushi					= Translate(
										en::n_sushi
										+"\\"+
										ru::n_sushi
										+"\\"+
										de::n_sushi
										),
	//	end of food
	
	//	ammo
	lowcal					= Translate(
										en::n_lowcal
										+"\\"+
										ru::n_lowcal
										+"\\"+
										de::n_lowcal
										),
	highpow					= Translate(
										en::n_highpow
										+"\\"+
										ru::n_highpow
										+"\\"+
										de::n_highpow
										),
	shotgunshells			= Translate(
										en::n_shotgunshells
										+"\\"+
										ru::n_shotgunshells
										+"\\"+
										de::n_shotgunshells
										),
	fuel_canister			= Translate(
										en::n_fuel_canister
										+"\\"+
										ru::n_fuel_canister
										+"\\"+
										de::n_fuel_canister
										),
	draground				= Translate(
										en::n_draground
										+"\\"+
										ru::n_draground
										+"\\"+
										de::n_draground
										),
	tank_shell				= Translate(
										en::n_tank_shell
										+"\\"+
										ru::n_tank_shell
										+"\\"+
										de::n_tank_shell
										),
	//	end of ammo
	
	//	explosives
	frag_grenade			= Translate(
										en::n_frag_grenade
										+"\\"+
										ru::n_frag_grenade
										+"\\"+
										de::n_frag_grenade
										),
	molotov					= Translate(
										en::n_molotov
										+"\\"+
										ru::n_molotov
										+"\\"+
										de::n_molotov
										),
	aerial_bomb				= Translate(
										en::n_aerial_bomb
										+"\\"+
										ru::n_aerial_bomb
										+"\\"+
										de::n_aerial_bomb
										),
	land_mine				= Translate(
										en::n_land_mine
										+"\\"+
										ru::n_land_mine
										+"\\"+
										de::n_land_mine
										),
	tank_mine				= Translate(
										en::n_tank_mine
										+"\\"+
										ru::n_tank_mine
										+"\\"+
										de::n_tank_mine
										),
	//	end of explosives

	//	items
	bayonet					= Translate(
										en::n_bayonet
										+"\\"+
										ru::n_bayonet
										+"\\"+
										de::n_bayonet
										),
	laser_pointer			= Translate(
										en::n_laser_pointer
										+"\\"+
										ru::n_laser_pointer
										+"\\"+
										de::n_laser_pointer
										),
	underbarrel_nader		= Translate(
										en::n_underbarrel_nader
										+"\\"+
										ru::n_underbarrel_nader
										+"\\"+
										de::n_underbarrel_nader
										),
	shovel					= Translate(
										en::n_shovel
										+"\\"+
										ru::n_shovel
										+"\\"+
										de::n_shovel
										),
	wrench					= Translate(
										en::n_wrench
										+"\\"+
										ru::n_wrench
										+"\\"+
										de::n_wrench
										),
	mason_hammer			= Translate(
										en::n_mason_hammer
										+"\\"+
										ru::n_mason_hammer
										+"\\"+
										de::n_mason_hammer
										),
	steel_crate				= Translate(
										en::n_steel_crate
										+"\\"+
										ru::n_steel_crate
										+"\\"+
										de::n_steel_crate
										),
	knight_shield			= Translate(
										en::n_knight_shield
										+"\\"+
										ru::n_knight_shield
										+"\\"+
										de::n_knight_shield
										),
	riot_shield				= Translate(
										en::n_riot_shield
										+"\\"+
										ru::n_riot_shield
										+"\\"+
										de::n_riot_shield
										),
	combat_helmet			= Translate(
										en::n_combat_helmet
										+"\\"+
										ru::n_combat_helmet
										+"\\"+
										de::n_combat_helmet
										),
	heavy_helmet			= Translate(
										en::n_heavy_helmet
										+"\\"+
										ru::n_heavy_helmet
										+"\\"+
										de::n_heavy_helmet
										),
	medic_helmet			= Translate(
										en::n_medic_helmet
										+"\\"+
										ru::n_medic_helmet
										+"\\"+
										de::n_medic_helmet
										),
	bandage					= Translate(
										en::n_bandage
										+"\\"+
										ru::n_bandage
										+"\\"+
										de::n_bandage
										),
	amogus					= Translate(
										en::n_amogus
										+"\\"+
										ru::n_amogus
										+"\\"+
										de::n_amogus
										),
	binoculars				= Translate(
										en::n_binoculars
										+"\\"+
										ru::n_binoculars
										+"\\"+
										de::n_binoculars
										),
	food					= Translate(
										en::n_food
										+"\\"+
										ru::n_food
										+"\\"+
										de::n_food
										),
	//	end of items
	
	//	ui
	headtab					= Translate(
										en::n_headtab
										+"\\"+
										ru::n_headtab
										+"\\"+
										de::n_headtab
										),
	headcfg					= Translate(
										en::n_headcfg
										+"\\"+
										ru::n_headcfg
										+"\\"+
										de::n_headcfg
										),
	//	end of ui
	
	
	
	empty					= "";
}

namespace Descriptions
{
	const string
	
	//	weps
	anti_tank_rifle			= Translate(
										en::d_anti_tank_rifle
										+"\\"+
										ru::d_anti_tank_rifle
										+"\\"+
										de::d_anti_tank_rifle
										),
	assault_rifle			= Translate(
										en::d_assault_rifle
										+"\\"+
										ru::d_assault_rifle
										+"\\"+
										de::d_assault_rifle
										),
	auto_shotgun			= Translate(
										en::d_auto_shotgun
										+"\\"+
										ru::d_auto_shotgun
										+"\\"+
										de::d_auto_shotgun
										),
	bazooka					= Translate(
										en::d_bazooka
										+"\\"+
										ru::d_bazooka
										+"\\"+
										de::d_bazooka
										),
	drum_smg				= Translate(
										en::d_drum_smg
										+"\\"+
										ru::d_drum_smg
										+"\\"+
										de::d_drum_smg
										),
	pocket_smg				= Translate(
										en::d_pocket_smg
										+"\\"+
										ru::d_pocket_smg
										+"\\"+
										de::d_pocket_smg
										),
	pump_shotgun			= Translate(
										en::d_pump_shotgun
										+"\\"+
										ru::d_pump_shotgun
										+"\\"+
										de::d_pump_shotgun
										),
	revolver				= Translate(
										en::d_revolver
										+"\\"+
										ru::d_revolver
										+"\\"+
										de::d_revolver
										),
	semi_auto_pistol		= Translate(
										en::d_semi_auto_pistol
										+"\\"+
										ru::d_semi_auto_pistol
										+"\\"+
										de::d_semi_auto_pistol
										),
	semi_auto_rifle			= Translate(
										en::d_semi_auto_rifle
										+"\\"+
										ru::d_semi_auto_rifle
										+"\\"+
										de::d_semi_auto_rifle
										),
	single_shot_nader		= Translate(
										en::d_single_shot_nader
										+"\\"+
										ru::d_single_shot_nader
										+"\\"+
										de::d_single_shot_nader
										),
	sniper_rifle			= Translate(
										en::d_sniper_rifle
										+"\\"+
										ru::d_sniper_rifle
										+"\\"+
										de::d_sniper_rifle
										),
	//	end of weps
	
	//	structures
	armory     	      	   	= Translate(
										en::d_armory
										+"\\"+
										ru::d_armory
										+"\\"+
										de::d_armory
										),
	//	end of structures
	
	//	ammo
	lowcal		  	       	= Translate(
										en::d_lowcal
										+"\\"+
										ru::d_lowcal
										+"\\"+
										de::d_lowcal
										),
	highpow					= Translate(
										en::d_highpow
										+"\\"+
										ru::d_highpow
										+"\\"+
										de::d_highpow
										),
	shotgunshells			= Translate(
										en::d_shotgunshells
										+"\\"+
										ru::d_shotgunshells
										+"\\"+
										de::d_shotgunshells
										),
	fuel_canister			= Translate(
										en::d_fuel_canister
										+"\\"+
										ru::d_fuel_canister
										+"\\"+
										de::d_fuel_canister
										),
	draground				= Translate(
										en::d_draground
										+"\\"+
										ru::d_draground
										+"\\"+
										de::d_draground
										),
	tank_shell				= Translate(
										en::d_tank_shell
										+"\\"+
										ru::d_tank_shell
										+"\\"+
										de::d_tank_shell
										),
	//	end of ammo
	
	//	explosives
	frag_grenade			= Translate(
										en::d_frag_grenade
										+"\\"+
										ru::d_frag_grenade
										+"\\"+
										de::d_frag_grenade
										),
	molotov					= Translate(
										en::d_molotov
										+"\\"+
										ru::d_molotov
										+"\\"+
										de::d_molotov
										),
	aerial_bomb				= Translate(
										en::d_aerial_bomb
										+"\\"+
										ru::d_aerial_bomb
										+"\\"+
										de::d_aerial_bomb
										),
	land_mine				= Translate(
										en::d_land_mine
										+"\\"+
										ru::d_land_mine
										+"\\"+
										de::d_land_mine
										),
	tank_mine				= Translate(
										en::d_tank_mine
										+"\\"+
										ru::d_tank_mine
										+"\\"+
										de::d_tank_mine
										),
	//	end of explosives
	
	//	items
	bayonet					= Translate(
										en::d_bayonet
										+"\\"+
										ru::d_bayonet
										+"\\"+
										de::d_bayonet
										),
	laser_pointer			= Translate(
										en::d_laser_pointer
										+"\\"+
										ru::d_laser_pointer
										+"\\"+
										de::d_laser_pointer
										),
	underbarrel_nader		= Translate(
										en::d_underbarrel_nader
										+"\\"+
										ru::d_underbarrel_nader
										+"\\"+
										de::d_underbarrel_nader
										),
	shovel					= Translate(
										en::d_shovel
										+"\\"+
										ru::d_shovel
										+"\\"+
										de::d_shovel
										),
	wrench					= Translate(
										en::d_wrench
										+"\\"+
										ru::d_wrench
										+"\\"+
										de::d_wrench
										),
	mason_hammer			= Translate(
										en::d_mason_hammer
										+"\\"+
										ru::d_mason_hammer
										+"\\"+
										de::d_mason_hammer
										),
	steel_crate				= Translate(
										en::d_steel_crate
										+"\\"+
										ru::d_steel_crate
										+"\\"+
										de::d_steel_crate
										),
	knight_shield			= Translate(
										en::d_knight_shield
										+"\\"+
										ru::d_knight_shield
										+"\\"+
										de::d_knight_shield
										),
	riot_shield				= Translate(
										en::d_riot_shield
										+"\\"+
										ru::d_riot_shield
										+"\\"+
										de::d_riot_shield
										),
	combat_helmet			= Translate(
										en::d_combat_helmet
										+"\\"+
										ru::d_combat_helmet
										+"\\"+
										de::d_combat_helmet
										),
	heavy_helmet			= Translate(
										en::d_heavy_helmet
										+"\\"+
										ru::d_heavy_helmet
										+"\\"+
										de::d_heavy_helmet
										),
	medic_helmet			= Translate(
										en::d_medic_helmet
										+"\\"+
										ru::d_medic_helmet
										+"\\"+
										de::d_medic_helmet
										),
	bandage					= Translate(
										en::d_bandage
										+"\\"+
										ru::d_bandage
										+"\\"+
										de::d_bandage
										),
	amogus					= Translate(
										en::d_amogus
										+"\\"+
										ru::d_amogus
										+"\\"+
										de::d_amogus
										),
	binoculars				= Translate(
										en::d_binoculars
										+"\\"+
										ru::d_binoculars
										+"\\"+
										de::d_binoculars
										),
	//	end of item
	
	//	scoreboard
	rank					= Translate(
										en::d_rank
										+"\\"+
										ru::d_rank
										+"\\"+
										de::d_rank
										),
	nickname				= Translate(
										en::d_nickname
										+"\\"+
										ru::d_nickname
										+"\\"+
										de::d_nickname
										),
	username				= Translate(
										en::d_username
										+"\\"+
										ru::d_username
										+"\\"+
										de::d_username
										),
	ping					= Translate(
										en::d_ping
										+"\\"+
										ru::d_ping
										+"\\"+
										de::d_ping
										),
	kills					= Translate(
										en::d_kills
										+"\\"+
										ru::d_kills
										+"\\"+
										de::d_kills
										),
	//	end of scoreboard
	
	//	ui
	choose_headpack			= Translate(
										en::d_choose_headpack
										+"\\"+
										ru::d_choose_headpack
										+"\\"+
										de::d_choose_headpack
										),
	choose_head				= Translate(
										en::d_choose_head
										+"\\"+
										ru::d_choose_head
										+"\\"+
										de::d_choose_head
										),
	
	lockpickup				= Translate(
										en::d_lockpickup
										+"\\"+
										ru::d_lockpickup
										+"\\"+
										de::d_lockpickup
										),
	unlockpickup			= Translate(
										en::d_unlockpickup
										+"\\"+
										ru::d_unlockpickup
										+"\\"+
										de::d_unlockpickup
										),
	//	end of ui
	
	empty 					= "";
}
