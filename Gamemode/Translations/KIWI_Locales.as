#include "locale_en"
#include "locale_ru"
#include "locale_de"

// thanks to GingerBeard <3

// works by seperating each language by token '\\'
// all translations are only set on startup, therefore changing language mid-game will not update the strings

// English is the main language
// Этот мод имеет перевод на русский (this mod has a translation to russian)
// Diese Mod hat eine Übersetzung ins Deutsche (this mod has a translation to german)

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

//	English 	- Skemonde, Pirate-Rob
//	Russian 	- Skemonde
//	German		- superhempfi
//	Spanish		
//	Japanese		

namespace Descriptions
{
	const string
	
	//	structs
	armory     	      	   	= Translate(
										en::d_armory
										+"\\"+
										ru::d_armory
										),
	
	//	bombs
	froggy					= Translate(
										en::d_froggy
										+"\\"+
										ru::d_froggy
										),
	flashy					= Translate(
										en::d_flashy
										+"\\"+
										ru::d_flashy
										),
	
	//	items
	amogus					= Translate(
										en::d_amogus
										+"\\"+
										ru::d_amogus
										),
	
	//	ammo
	lowcal		  	       	= Translate(
										en::d_lowcal
										+"\\"+
										ru::d_lowcal
										),
	highpow					= Translate(
										en::d_highpow
										+"\\"+
										ru::d_highpow
										),
	shotgunshells			= Translate(
										en::d_shotgunshells
										+"\\"+
										ru::d_shotgunshells
										),
	
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
	
	//	uis
	choose_headpack			= Translate(
										en::d_choose_headpack
										+"\\"+
										ru::d_choose_headpack
										),
	choose_head				= Translate(
										en::d_choose_head
										+"\\"+
										ru::d_choose_head
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
	
	empty 					= "";
}

namespace Names
{
	const string
	
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
	
	//	structs
	armory					= Translate(
										en::n_armory
										+"\\"+
										ru::n_armory
										),
	campfire				= Translate(
										en::n_campfire
										+"\\"+
										ru::n_campfire
										),
	
	//	items
	lowcal					= Translate(en::n_lowcal+"\\"+ru::n_lowcal),
	highpow					= Translate(en::n_highpow+"\\"+ru::n_highpow),
	shotgunshells			= Translate(en::n_shotgunshells+"\\"+ru::n_shotgunshells),
	froggy					= Translate(en::n_froggy+"\\"+ru::n_froggy),
	flashy					= Translate(en::n_flashy+"\\"+ru::n_flashy),
	amogus					= Translate(en::n_amogus+"\\"+ru::n_amogus),
	
	//	foodz
	fried_steak				= Translate(en::n_fried_steak+"\\"+ru::n_fried_steak),
	cooked_fish				= Translate(en::n_cooked_fish+"\\"+ru::n_cooked_fish),
	healing_potion			= Translate(en::n_healing_potion+"\\"+ru::n_healing_potion),
	bread_loaf				= Translate(en::n_bread_loaf+"\\"+ru::n_bread_loaf),
	cherry_cake				= Translate(en::n_cherry_cake+"\\"+ru::n_cherry_cake),
	burgir					= Translate(en::n_burgir+"\\"+ru::n_burgir),
	beer_mug				= Translate(en::n_beer_mug+"\\"+ru::n_beer_mug),
	sushi					= Translate(en::n_sushi+"\\"+ru::n_sushi),
	
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

	//	uis
	headtab					= Translate(en::n_headtab+"\\"+ru::n_headtab),
	headcfg					= Translate(en::n_headcfg+"\\"+ru::n_headcfg),
	
	empty					= "";
}
