// name the namespace after the language for clarity
// de for deutsch
namespace de
{
	const string
	
	//	NAMES
	n_team_skyblue			= "Kletta",
	n_team_red              = "Impera",
	//Lorraine Military Army Union
	
	//	weps
	n_anti_tank_rifle		=	"Panzerbüchse",
	n_assault_rifle			=	"Sturmgewehr",
	n_auto_shotgun			=	"Automatische Schrotflinte",
	n_bazooka				=	"Raketenwerfer",
	n_drum_smg				=	"Trommel MG",
	n_pocket_smg			=	"Taschen MG",
	n_pump_shotgun			=	"Schrotflinte",
	n_revolver				=	"Revolver",
	n_semi_auto_pistol		=	"Selbstladepistole",
	n_semi_auto_rifle		=	"Selbstladegewehr",
	n_single_shot_nader		=	"Granatwerfer",
	n_sniper_rifle			=	"Scharfschützengewehr",
	
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
								+"Hält bei einem erfolgreichen Treffer gegnerische Fahrzeuge kurz auf.\n"
								+"Fußsoldaten die in die Schusslinie geraten werden in einen Blutnebel verwandelt.\n"
								+"Extrem starker Rückstoß der dich in die Luft schießt.\n"
								+"\n"
								+"Benutzt $draground$ als Munition.",
	
	d_assault_rifle			=	n_assault_rifle
								+"\n"
								+"\n"
								+"Bringt den Feind mit Salven von 3 Kugeln zum Bersten. Hat einen Laserpointer und einen Unterlauf-Granatenwerfer.\n"
								+"Jede Kugel aus einer Salve die trifft erhöht den Schaden der nachfolgenden Kugeln.\n"
								+"\n"
								+"Benutzt $highpow$ als Munition.\n"
								+"Und $froggy$ für den Granatenwerfer.",
								
	d_auto_shotgun			=	n_auto_shotgun
								+"\n"
								+"\n"
								+"Schießt 8 Geschosse auf einmal mit einer guten Schussrate und akzeptabler Reichweite.\n"
								+"\n"
								+"Benutzt $shells$ als Munition.",
								
	d_bazooka				=	n_bazooka
								+"\n"
								+"\n"
								+"Bringt mit jedem Schuss eine Träume-vernichtende Rakete zum Feind.\n"
								+"\n"
								+"Benutzt $froggy$ als Munition.",
								
	d_drum_smg				=	n_drum_smg
								+"\n"
								+"\n"
								+"Birgt eine  unterdrückende Feuerkraft über einen kurzen Zeitraum.\n"
								+"Ist mit einem 40 Kugeln großem Magazin nützlich über mittlere Entfernungen.\n"
								+"\n"
								+"Benutzt $lowcal$ als Munition.",
								
	d_pocket_smg			=	n_pocket_smg
								+"\n"
								+"\n"
								+"Je länger du schießt, desto ungenauer wird sie.\n"
								+"Deswegen ist es empfohlen die Waffe nur in kurzen Salven zu benutzen.\n"
								+"Das Magazin hält 20 Kugeln mit einer unfassbar hohen Schussrate.\n"
								+"\n"
								+"Benutzt $lowcal$ als Munition.", 
								
	d_pump_shotgun			=	n_pump_shotgun
								+"\n"
								+"\n"
								+"Eine allmächtige Waffe im Nahkampf.\n"
								+"Kann einen Soldaten ohne Helm mit einem Schuss niederstrecken.\n"
								+"\n"
								+"Benutzt $shells$ als Munition.",
								
	d_revolver				=	n_revolver
								+"\n"
								+"\n"
								+"Lass dich nicht von dem simplen Äußeren dieser Waffe täuschen.\n"
								+"Denn gelingt es dir alle Schüsse auf deinem Ziel zu landen, so wird dieses nicht mehr über deinen Kleinen lachen können.\n"
								+"\n"
								+"Benutzt $lowcal$ als Munition.",
								
	d_semi_auto_pistol		=	n_semi_auto_pistol
								+"\n"
								+"\n"
								+"Hat genug Feuerkraft um einen Mann schnell und effizient zu töten .\n"
								+"Lässt sich schnell nachladen.\n"
								+"\n"
								+"Benutzt $lowcal$ als Munition.",
								
	d_semi_auto_rifle		=	n_semi_auto_rifle
								+"\n"
								+"\n"
								+"Der Schaden des Gewehrs erhöht sich desto länger das Geschoss fliegt.\n"
								+"Es ist also empfohlen auf weit entfernte Gegner zu zielen.\n"
								+"\n"
								+"Benutzt $highpow$ als Munition.",
								
	d_single_shot_nader		=	n_single_shot_nader
								+"\n"
								+"\n"
								+"Katapultiert Granaten auf weite Entfernungen.\n"
								+"Granaten fliegen in einer gebogenen Flugbahn.\n"
								+"\n"
								+"Benutzt $froggy$ als Munition.",
								
	d_sniper_rifle			=	n_sniper_rifle
								+"\n"
								+"\n"
								+"Ein Gewehr, dass mit nur einem Kopfschuss töten kann.\n"
								+"Hat eine sehr langsame Schussrate und nur 3 Schuss pro Magazin.\n"
								+"\n"
								+"Benutzt $highpow$ als Munition",
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
	d_rank 					= "Rang",
	d_nickname 				= "Spitzname",
	d_username 				= "KAG Nutzername",
	d_ping 					= "Ping",
	d_kills 				= "Abschüsse",
	
	//	ui
	d_choose_headpack       = "Select a headpack you want to use",
	d_choose_head           = "Select a head you want to use",
	d_lockpickup			= "Aktiviert automatisches Aufheben",
	d_unlockpickup			= "Deaktiviert automatisches Aufheben",
	
	empty 					= "";
}