// name the namespace after the language for clarity
// en for english
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
