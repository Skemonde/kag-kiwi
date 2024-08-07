#include "CustomBlocks"

void onInit(CRules@ this)
{
	this.set_string("version", "0r2426p0"); //r stands for releases (will do once i do git releases) and p for patches (i change it whenever i feel like to tho)
	this.server_setShowHoverNames(false);
	sv_contact_info = "Discord - @skemonde; Twitter - @skemonde_";
	
	print("\n KIWI INFO "+"\n" +
		  "\n  - Version: "+this.get_string("version") +
		  "\n  - Contacts: "+sv_contact_info +
		  "\n  - Test mode: "+(sv_test?"true":"false") +
		  "\n  - Localhost: "+((isClient() && isServer())?"true":"false")+"\n", 0xff68b229); //spinach color

	loadStuff(this);
}

void loadStuff(CRules@ this)
{
	ReloadFonts(this);
	ReloadColors(this);
	ReloadIcons(this);
}

void onReload(CRules@ this)
{
	loadStuff(this);
	
	ResetChatLayout();
	//Vec2f screen_dims = Vec2f(getScreenWidth(), getScreenHeight());
	//SetChatLayout(Vec2f(screen_dims.x-235, screen_dims.y-4-120), Vec2f(screen_dims.x, screen_dims.y-4));
}

void ReloadIcons(CRules@ this)
{
	print(" ADDING KIWI ICON TOKENS", 0xff68b229);
	
	//GUI
	AddIconToken("$icon_dogtag$", "dogtag_xenocrisislike.png", Vec2f(19, 18), 0);
	
	//Interaction Buttons
	AddIconToken("$attach$", "InteractionIcons.png", Vec2f(32, 32), 0);
	AddIconToken("$dettach$", "InteractionIcons.png", Vec2f(32, 32), 1);
	AddIconToken("$lock$", "InteractionIcons.png", Vec2f(32, 32), 2);
	AddIconToken("$unlock$", "InteractionIcons.png", Vec2f(32, 32), 3);
	AddIconToken("$arrow_botleft$", "InteractionIcons.png", Vec2f(32, 32), 4);
	AddIconToken("$arrow_topleft$", "InteractionIcons.png", Vec2f(32, 32), 5);
	AddIconToken("$arrow_topright$", "InteractionIcons.png", Vec2f(32, 32), 6);
	AddIconToken("$arrow_botright$", "InteractionIcons.png", Vec2f(32, 32), 7);
	AddIconToken("$swap$", "InteractionIcons.png", Vec2f(32, 32), 8);
	AddIconToken("$disable$", "InteractionIcons.png", Vec2f(32, 32), 9);
	AddIconToken("$caution$", "InteractionIcons.png", Vec2f(32, 32), 10);
	AddIconToken("$star$", "InteractionIcons.png", Vec2f(32, 32), 11);
	AddIconToken("$change_class$", "InteractionIcons.png", Vec2f(32, 32), 12, 2);
	AddIconToken("$storage_with_items$", "InteractionIcons.png", Vec2f(32, 32), 13, 3);
	AddIconToken("$question_mark$", "InteractionIcons.png", Vec2f(32, 32), 14);
	AddIconToken("$building_hammer$", "InteractionIcons.png", Vec2f(32, 32), 15);
	AddIconToken("$arrow_up$", "InteractionIcons.png", Vec2f(32, 32), 16);
	AddIconToken("$arrow_right$", "InteractionIcons.png", Vec2f(32, 32), 17);
	AddIconToken("$arrow_left$", "InteractionIcons.png", Vec2f(32, 32), 18);
	AddIconToken("$arrow_down$", "InteractionIcons.png", Vec2f(32, 32), 19);
	AddIconToken("$empty_storage$", "InteractionIcons.png", Vec2f(32, 32), 20, 3);
	AddIconToken("$double_building_hammer$", "InteractionIcons.png", Vec2f(32, 32), 21);
	AddIconToken("$eating$", "InteractionIcons.png", Vec2f(32, 32), 22);
	AddIconToken("$turn_on$", "InteractionIcons.png", Vec2f(32, 32), 23);
	AddIconToken("$crate$", "InteractionIcons.png", Vec2f(32, 32), 24);
	AddIconToken("$shop_icon$", "InteractionIcons.png", Vec2f(32, 32), 25);
	AddIconToken("$coin_slot$", "InteractionIcons.png", Vec2f(32, 32), 26);
	AddIconToken("$turn_off$", "InteractionIcons.png", Vec2f(32, 32), 27);
	AddIconToken("$store_inventory$", "InteractionIcons.png", Vec2f(32, 32), 28);
	AddIconToken("$sleep$", "InteractionIcons.png", Vec2f(32, 32), 29);
	AddIconToken("$dialogue$", "InteractionIcons.png", Vec2f(32, 32), 30);
	
	//killfeed
	AddIconToken("$KNIFE$", "Bayonet.png", Vec2f(14, 6), 0);
	AddIconToken("$SHAG$", "shaggy.png", Vec2f(20, 8), 0);
	AddIconToken("$REG$", "nagant.png", Vec2f(11, 7), 0);
	AddIconToken("$SPP$", "ppsh.png", Vec2f(19, 10), 0);
	AddIconToken("$USAR$", "svt.png", Vec2f(24, 8), 0);
	AddIconToken("$TESR$", "m16.png", Vec2f(24, 10), 0);
	AddIconToken("$KEP$", "uzi.png", Vec2f(18, 11), 0);
	AddIconToken("$PTZ$", "PTZ.png", Vec2f(23, 8), 0);
	AddIconToken("$MIZ$", "c96.png", Vec2f(14, 8), 0);
	AddIconToken("$ROCKETER$", "RocketLauncher.png", Vec2f(24, 11), 0);
	AddIconToken("$MGS$", "MGS_Icon.png", Vec2f(24, 24), 0);
	AddIconToken("$LANDMINE$", "AntiPersonnelMine.png", Vec2f(16, 8), 0);
	AddIconToken("$TANKMINE$", "AntiMaterielMine.png", Vec2f(16, 8), 0);
	AddIconToken("$FROG$", "FragGrenade.png", Vec2f(8, 10), 0);
	AddIconToken("$NUKA$", "Nyuka.png", Vec2f(16, 16), 0);
	AddIconToken("$PLANE_BOMB$", "PlaneBomb.png", Vec2f(16, 16), 0);
	AddIconToken("$ATR$", "ATR.png", Vec2f(48, 16), 0);
	AddIconToken("$HORD$", "Niper.png", Vec2f(32, 9), 0);
	AddIconToken("$HMG$", "Teragun.png", Vec2f(23, 13), 0);
	AddIconToken("$HIGH_MG$", "high_mg_icon.png", Vec2f(48, 18), 0);
	AddIconToken("$TANK$", "kiwi_minimap_icons.png", Vec2f(16, 16), 0);
	AddIconToken("$SHOVEL$", "Shovel.png", Vec2f(18, 7), 0);
	AddIconToken("$BLEED$", "bleed_hitter.png", Vec2f(24, 16), 0);
	AddIconToken("$FLYING$", "flying_hitter.png", Vec2f(32, 16), 0);
	AddIconToken("$TANKSHELL$", "TankShells.png", Vec2f(24, 8), 0);
	
	//food
	AddIconToken("$fried_steak_icon$", 				"Food.png", 			Vec2f(16, 16), 0);
	AddIconToken("$food_0$", 						"Food.png", 			Vec2f(16, 16), 0);
	AddIconToken("$cooked_fish_icon$", 				"Food.png", 			Vec2f(16, 16), 1);
	AddIconToken("$food_1$", 						"Food.png", 			Vec2f(16, 16), 1);
	AddIconToken("$healing_potion_icon$", 			"Food.png", 			Vec2f(16, 16), 2);
	AddIconToken("$food_2$", 						"Food.png", 			Vec2f(16, 16), 2);
	AddIconToken("$bread_loaf_icon$", 				"Food.png", 			Vec2f(16, 16), 3);
	AddIconToken("$food_3$", 						"Food.png", 			Vec2f(16, 16), 3);
	AddIconToken("$cherry_cake_icon$", 				"Food.png", 			Vec2f(16, 16), 4);
	AddIconToken("$food_4$", 						"Food.png", 			Vec2f(16, 16), 4);
	AddIconToken("$burgir_icon$", 					"Food.png", 			Vec2f(16, 16), 5);
	AddIconToken("$food_5$", 						"Food.png", 			Vec2f(16, 16), 5);
	AddIconToken("$beer_mug_icon$", 				"Food.png", 			Vec2f(16, 16), 6);
	AddIconToken("$food_6$", 						"Food.png", 			Vec2f(16, 16), 6);
	AddIconToken("$sushi_icon$", 					"Food.png", 			Vec2f(16, 16), 7);
	AddIconToken("$food_7$", 						"Food.png", 			Vec2f(16, 16), 7);
	
	//blocks
	AddIconToken("$steel_block$", "Sprites/World.png", Vec2f(8, 8), CMap::tile_steel_1x1);
	AddIconToken("$steel_beam$", "Sprites/World.png", Vec2f(8, 8), CMap::tile_bgsteelbeam);
	AddIconToken("$window_tile$", "Sprites/World.png", Vec2f(8, 8), CMap::tile_window);
	AddIconToken("$dirt_tile$", "Sprites/World.png", Vec2f(8, 8), CMap::tile_ground);
	
	AddIconToken("$draground_icon$", "Draground.png", Vec2f(16, 16), 0);
	
	//heads
	AddIconToken("$head_builder_normal$", "Heads.png", Vec2f(16, 16), 120);
	
	//gun addons
	AddIconToken("$gun_addons_workbench$", "gun_addons_workbench.png", Vec2f(1, 1), 0);
	AddIconToken("$gun_addons_workbench_active$", "gun_addons_workbench.png", Vec2f(1, 1), 0);
	AddIconToken("$gun_addons_nader$", "gun_addons_workbench.png", Vec2f(1, 1), 0);
	AddIconToken("$gun_addons_nader_active$", "gun_addons_workbench.png", Vec2f(1, 1), 0);
	AddIconToken("$gun_addons_pointer$", "gun_addons_workbench.png", Vec2f(1, 1), 0);
	AddIconToken("$gun_addons_pointer_active$", "gun_addons_workbench.png", Vec2f(1, 1), 0);
	
	AddIconToken("$gun_addons_1$", "gun_addons_slot_1.png", Vec2f(24, 28), 0);
	
	AddIconToken("$gun_addons_2$", "gun_addons_slot_2.png", Vec2f(24, 28), 0);
	AddIconToken("$gun_addons_2_active$", "gun_addons_slot_2.png", Vec2f(24, 28), 1);
	
	AddIconToken("$gun_addons_3$", "gun_addons_slot_3.png", Vec2f(24, 28), 0);
	AddIconToken("$gun_addons_3_active$", "gun_addons_slot_3.png", Vec2f(24, 28), 1);
	
	AddIconToken("$gun_addons_4$", "gun_addons_slot_4.png", Vec2f(24, 28), 0);
	
	AddIconToken("$gun_addons_5$", "gun_addons_slot_5.png", Vec2f(24, 28), 0);
	AddIconToken("$gun_addons_5_active$", "gun_addons_slot_5.png", Vec2f(24, 28), 1);
	
	AddIconToken("$gun_addons_6$", "gun_addons_slot_6.png", Vec2f(24, 28), 0);
	AddIconToken("$gun_addons_6_active$", "gun_addons_slot_6.png", Vec2f(24, 28), 1);
	
	//armory
	AddIconToken("$GUNS_TIER_1$", "TradingMenuGunsTier1.png", Vec2f(168, 28), 0);
	AddIconToken("$GUNS_TIER_2$", "TradingMenuGunsTier2.png", Vec2f(168, 28), 0);
	AddIconToken("$AMMUNITION$", "TradingMenuAmmo.png", Vec2f(168, 28), 0);
	
	//workshops
	for (int teamnum = 0; teamnum <= 7; ++teamnum) {
		AddIconToken("$amogus_icon"+teamnum+"$", 			"AmogusIcon.png", 			Vec2f(24, 24), 0, 69);
		AddIconToken("$landmine_icon"+teamnum+"$", 			"AntiPersonnelMine.png", 	Vec2f(16, 8), 0, teamnum);
		AddIconToken("$tankmine_icon"+teamnum+"$", 			"AntiMaterielMine.png", 	Vec2f(16, 8), 0, teamnum);
		AddIconToken("$radio_icon"+teamnum+"$", 			"WalkieTalkie.png", 		Vec2f(9, 16), 0, teamnum);
		AddIconToken("$boombox_icon"+teamnum+"$", 			"Boombox.png", 				Vec2f(16, 16), 0, teamnum);
		AddIconToken("$medhelm_icon"+teamnum+"$", 			"MedicHelm.png", 			Vec2f(16, 16), 0, teamnum);
		AddIconToken("$crate_icon"+teamnum+"$", 			"Crate.png", 				Vec2f(32, 16), 0, teamnum);
		AddIconToken("$steelcrate_icon"+teamnum+"$", 		"Crate.png", 				Vec2f(32, 16), 2, teamnum);
		AddIconToken("$knightshield_icon"+teamnum+"$", 		"KagKnightShield.png", 		Vec2f(24, 24), 1, teamnum);
		AddIconToken("$hoverbike_icon"+teamnum+"$", 		"kiwi_vehicle_icons.png", 	Vec2f(16, 16), 3, teamnum);
		AddIconToken("$apc_icon"+teamnum+"$", 				"kiwi_vehicle_icons.png", 	Vec2f(16, 16), 2, teamnum);
		AddIconToken("$car_icon"+teamnum+"$", 				"kiwi_vehicle_icons.png", 	Vec2f(16, 16), 1, teamnum);
		//AddIconToken("$tank_icon"+teamnum+"$", 				"kiwi_vehicle_icons.png", 	Vec2f(16, 16), 0, teamnum);
		AddIconToken("$wrench_icon"+teamnum+"$", 			"Wrench.png", 				Vec2f(10, 16), 0, teamnum);
		AddIconToken("$tank_icon"+teamnum+"$", 				"TankIcon.png", 			Vec2f(72, 48), 0, teamnum);
		AddIconToken("$mortar_icon"+teamnum+"$", 			"MortarIcon.png", 			Vec2f(48, 48), 0, teamnum);
		AddIconToken("$tripod_icon"+teamnum+"$", 			"high_mg_icon.png", 		Vec2f(48, 18), 0, teamnum);
	}
}

void ReloadFonts(CRules@ this)
{
	print(" ADDING KIWI FONTS", 0xff68b229);
	//those fonts that support cyrillic alphabet are added with a tab for a readability
	//
	//initial size of the fonts is actually twice as smaller we just double the sises of some fonts for a convenience
	//
	//7px --- initial size
		GUI::LoadFont("casio", CFileMatcher("casio-fx-9860gii.ttf").getFirst(), 14, true); //cyrillic, latin
	
	//8px
	GUI::LoadFont("bold_pixeled", CFileMatcher("04B_11__.ttf").getFirst(), 8, true); //latin 
		GUI::LoadFont("pixeled", CFileMatcher("uni05_53.ttf").getFirst(), 16, true); //cyrillic, latin
		GUI::LoadFont("chava", CFileMatcher("Chava-Regular.ttf").getFirst(), 16, false); //cyrillic, latin
		GUI::LoadFont("minecraftia", CFileMatcher("Minecraftia-Regular.ttf").getFirst(), 16, true); //cyrillic, latin
		
	//9px
	GUI::LoadFont("newspaper", CFileMatcher("ADDSBP__.ttf").getFirst(), 18, true); //latin 
		
	//10px
		GUI::LoadFont("smallest", CFileMatcher("smallest_pixel-7.ttf").getFirst(), 20, true); //cyrillic, latin
		
	//12px
	GUI::LoadFont("military", CFileMatcher("EDITIA__.ttf").getFirst(), 24, true); //latin
		GUI::LoadFont("neue", CFileMatcher("NeuePixelSans.ttf").getFirst(), 12, true); //cyrillic, latin
	
	//16px
	GUI::LoadFont("typewriter", CFileMatcher("BitTypeWriter.ttf").getFirst(), 32, true); //latin 
	GUI::LoadFont("legend", CFileMatcher("Legendaria.ttf").getFirst(), 32, true); //latin 
	GUI::LoadFont("lunch", CFileMatcher("lunchds.ttf").getFirst(), 32, true); //latin
		GUI::LoadFont("readable", CFileMatcher("Readable9x4.ttf").getFirst(), 32, true); //cyrillic, latin
		GUI::LoadFont("kapel", CFileMatcher("Kapel.ttf").getFirst(), 32, true); //cyrillic, latin
		
	//20px
		GUI::LoadFont("computer", CFileMatcher("computer_pixel-7.ttf").getFirst(), 40, true); //cyrillic, latin
		
	//non-pixel
		GUI::LoadFont("genjyuu", CFileMatcher("Gen Jyuu Gothic Monospace Bold.ttf").getFirst(), 13, true); //cyrillic, latin, japanese
}

void ReloadColors(CRules@ this)
{
	print(" ADDING KIWI COLOR TOKENS", 0xff68b229);
	
	//color names from coolors.co (not an initial source i believe)
	AddColorToken("$col-white$", SColor(0xffffffff));
	AddColorToken("$col-floral_white$", SColor(0xfffffcf0));
	AddColorToken("$col-rich_black$", SColor(0xff0c1618));
	AddColorToken("$col-lapis_lazuli$", SColor(0xff1c5d99));
	AddColorToken("$col-sky_blue_crayola$", SColor(0xff1be7ff));
	AddColorToken("$col-dodger_blue$", SColor(0xff279af1));
	AddColorToken("$col-radical_red$", SColor(0xffff1053));
	AddColorToken("$col-crimson$", SColor(0xffdc143c));
	AddColorToken("$col-liver_chestnut$", SColor(0xff987456));
	
	//nature embrace 55 by grafxkid
	AddColorToken("$col-tomato$", SColor(0xffe25322));
	AddColorToken("$col-caramel$", SColor(0xffffbf89));
	AddColorToken("$col-chocolate$", SColor(0xffd08058));
	AddColorToken("$col-cheese$", SColor(0xffffc95c));
	AddColorToken("$col-spinach$", SColor(0xff68b229));
	AddColorToken("$col-mint$", SColor(0xff7becbf));
	AddColorToken("$col-water$", SColor(0xff2096cd));
	AddColorToken("$col-thistle$", SColor(0xffa3ccff));
	AddColorToken("$col-lilac$", SColor(0xffefa1ce));
	AddColorToken("$col-rose$", SColor(0xffea6d9d));
	AddColorToken("$col-cherry$", SColor(0xffeb7171));
	AddColorToken("$col-ancient$", SColor(0xffe3c4b0));
	AddColorToken("$col-green_tea$", SColor(0xffdfdd9a));
	AddColorToken("$col-powder$", SColor(0xffb8d8d1));
	AddColorToken("$col-tarmac$", SColor(0xff918692));
	AddColorToken("$col-void$", SColor(0xfffdf5f1));
}