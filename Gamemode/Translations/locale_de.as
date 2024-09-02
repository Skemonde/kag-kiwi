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
	n_armory                = "Arsenal",
	n_campfire              = "Lagerfeuer",
	
	//	food
	n_fried_steak           = "Gebratenes Steak",
	n_cooked_fish           = "Gebratener Fisch",
	n_healing_potion        = "Heiltrank",
	n_bread_loaf            = "Brot",
	n_cherry_cake           = "Kirschkuchen",
	n_burgir                = "Hamburgir",
	n_beer_mug              = "Seidel",
	n_sushi                 = "Sushi",
	
	//	ammo
	n_lowcal                = "Lowcal Munition",
	n_highpow               = "Highpow Munition",
	n_shotgunshells         = "Shrotpatronen",
	n_fuel_canister			= "Krafstoffkanister",
	n_draground				= "Dragunov Kugel",
	n_tank_shell			= "Panzer Kugel",
	
	//	explosives
	n_frag_grenade			= "Handgranate \"Froggy\"",
	n_molotov				= "Molotov Cocktail",
	n_aerial_bomb			= "Luftbombe",
	n_land_mine				= "Landmine",
	n_tank_mine				= "Panzerabwehrmine",
	
	//	items
	n_bayonet				= "Bajonett",
	n_laser_pointer			= "Laserpointer",
	n_underbarrel_nader		= "Unterlauf Granatwerfer",
	n_shovel				= "Grabenschaufel",
	n_wrench				= "Schraubenschlüssel",
	n_mason_hammer			= "Maurerhammer",
	n_steel_crate			= "Stahlkiste",
	n_knight_shield			= "Ritterschild",
	n_riot_shield			= "Schutzschild",
	n_combat_helmet			= "Kampfhelm",
	n_heavy_helmet			= "Explosionhelm",
	n_medic_helmet			= "Sanitäterhelm",
	n_bandage				= "Verband",
	n_amogus                = "Amogus Plüsch <3",
	n_binoculars			= "Fehrnglas",
	n_food					= "Burger",	
	
	//	ui 
	n_headtab               = "Headstuff",
	n_headcfg               = "Kopf konfigurieren",
	
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
	d_armory				=	"Hier können Sie Gegenstände und Waffen für Münzen und Gold kaufen  ",
	
	//	ammo
	d_lowcal                = 	"\"Munition mit geringem Kaliber\""
								+"\n"
								+"\nMunition für Handfeuerwaffen und Maschinenpistolen  ",
								
	d_highpow               = 	"\"Hochleistungsmunition\""
								+"\n"
								+"\nMuntion für Gewehre  und schwere  Maschinengewehre  ",
								
	d_shotgunshells         = 	"Schrotpratonen für Schrotflinten, JAWOLL!  ",
	
	d_fuel_canister         = 	"Treibstoff für einen Flammenwerfer"
								+"\n"
								+"\nHANZ GETZ ZE FLAMMENWERFER!!  ",
								
	d_draground				=	n_draground
								+"\n"
								+"\nUrsprünglich entwickelt, um die Lücke zwischen Handfeuerwaffen und Panzerkanonen zu schließen  "
								+"\n"
								+"\nObwohl später einige schwere Gewehre hergestellt wurden, um diese riesige Patrone zu verwenden  ",
								
	d_tank_shell			=	n_tank_shell
								+"\n"
								+"\nDiese riesigen Granaten werden von großen Kanonen verwendet  "
								+"\nWenn Sie nicht vorsichtig genug sind, kann es explodieren und Sie verletzen  ",
	//	end of ammo
	
	//	explosives
	d_frag_grenade			=	"Du kennst die Regeln? Geh niemals ohne eine Granate auf deine Mission!  ",
	
	d_molotov				=	"Sehr effektiv gegen Schilde! Sogar gegen einige Panzer.  ",
	
	d_aerial_bomb			=	"Es wurde für Sturzbomber entwickelt, kann aber auch mit einem Mörser verwendet werden.  ",
	
	d_land_mine				=	"Wird nur aktiviert wenn ein Opfer draufläuft.  ",
	
	d_tank_mine				=	"Riesige Landmine, zur Bekämpfung feindlicher Fahrzeuge"
								+"\n"
								+"\nWird nicht aktiviert, wenn ein Solat drauftritt.  ",
	//	end of explosives
	
	//	items
	d_bayonet				=	"Du kannst damit Menschen abstechen"
								+"\n"
								+"\nDu kannst es auch an einer Waffe befestigen.  ",
	
	d_laser_pointer			=	"Deine Katze wird es lieben!"
								+"\n"
								+"\nDu kannst es auch an einer Waffe befestigen.  ",
	
	d_underbarrel_nader		=	"Addon für eine Waffe"
								+"\n"
								+"\nDu kannst auch daraus schießen, aber das ist keine sehr gute Idee.  ",
								
	d_shovel				=	"Damit kannst du Steine und Erde umgraben"
								+"\n"
								+"\nSCHLAG DIE GEGNER DAMIT IN DEN BODEN!  ",
	
	d_wrench				=	"Wird zur Reparatur von Fahrzeugen verwendet."
								+"\n"
								+"\nWenn das Fahrzeug neulich getroffen wurde, wird es weniger repariert.  ",
	
	d_mason_hammer			=	"Hiermit kannst du Blöcke zerstören und neue Sachen bauen.  ",
	
	d_steel_crate			=	"Sehr schwere Stahlkiste. Diese ist sehr viel haltbarer als das Holzmodell"
								+"\n"
								+"\nFeinde können darauf nicht zugreifen.  ",
								
	d_knight_shield			=	"Schützt vor Schäden"
								+"\n"
								+"\nDrück S um in Deckung zu gehen"
								+"\n"
								+"\n - Hat einen guten Dash"
								+"\n - Nicht sehr langlebig  ",
								
	d_riot_shield			=	"Schützt vor jeglichem Schaden"
								+"\n"
								+"\nDrück S um in Deckung zu gehen"
								+"\n"
								+"\n - Bash verursacht Schaden"
								+"\n - Mittleres Gewicht  ",
								
	d_combat_helmet			=	n_combat_helmet
								+"\n"
								+"\n - Kopftreffer verursachen keinen kritischen Schaden"
								+"\n - 5 weniger Schussschaden  ",
	
	d_heavy_helmet			=	n_heavy_helmet
								+"\n"
								+"\n - Schützt nicht vor Schüssen"
								+"\n - 50 weniger Explosionsschaden  ",
								
	d_medic_helmet			=	n_medic_helmet
								+"\n"
								+"\n - Du kannst Heilgranaten herstellen  ",
								
	d_bandage				=	"Wirf einem Freund einen Verband zu,  wenn er am Boden liegt! Damit fühlen sie sich vielleicht besser.  ",
	
	d_amogus                =	"bruh"
								+"\n you lookin' real sussy over there"
								+"\n did you take the fortnite card for me bruh?"
								+"\n imma need that fortnite card back"
								+"\n but you're sussy and i'm coming to get it"
								+"\n imma BLOCK you go"
								+"\n B L O C C  ",
	
	d_binoculars			=	"Benutz das wenn du eine dynamische Kamera in Fahrzeugen willst.  ",
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