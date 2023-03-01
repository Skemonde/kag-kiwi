void onInit(CRules@ this)
{
	this.set_string("version", "v0.13");
	sv_contact_info = "Skemonde#7001 at Discord";
	
	print("\n KIWI INFO "+"\n" +
		  "\n  - Version: "+this.get_string("version") +
		  "\n  - Contacts: "+sv_contact_info +
		  "\n  - Test mode: "+sv_test +
		  "\n  - Localhost: "+(isClient() && isServer())+"\n", 0xff68b229); //spinach color

	ReloadIcons(this);
	ReloadFonts(this);
	ReloadColors(this);
}

void onReload(CRules@ this)
{
	ReloadIcons(this);
	ReloadFonts(this);
	ReloadColors(this);
}

void ReloadIcons(CRules@ this)
{
	print(" ADDING KIWI ICON TOKENS", 0xff68b229);
	
	//GUI
	AddIconToken("$icon_dogtag$", "dogtag.png", Vec2f(11, 14), 0);
	AddIconToken("$icon_locked$", "InteractionIcons.png", Vec2f(32, 32), 2);
	AddIconToken("$icon_unlocked$", "InteractionIcons.png", Vec2f(32, 32), 3);
	
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
		
	//10px
		GUI::LoadFont("smallest", CFileMatcher("smallest_pixel-7.ttf").getFirst(), 20, true); //cyrillic, latin
		
	//12px
	
	//16px
	GUI::LoadFont("typewriter", CFileMatcher("BitTypeWriter.ttf").getFirst(), 32, true); //latin 
	GUI::LoadFont("legend", CFileMatcher("Legendaria.ttf").getFirst(), 32, true); //latin 
	GUI::LoadFont("lunch", CFileMatcher("lunchds.ttf").getFirst(), 32, true); //latin
	GUI::LoadFont("military", CFileMatcher("EDITIA__.ttf").getFirst(), 32, true); //latin
	GUI::LoadFont("readable", CFileMatcher("Readable9x4.ttf").getFirst(), 32, true); //latin
		GUI::LoadFont("kapel", CFileMatcher("Kapel.ttf").getFirst(), 32, true); //cyrillic, latin
		
	//20px
		GUI::LoadFont("computer", CFileMatcher("computer_pixel-7.ttf").getFirst(), 40, true); //cyrillic, latin
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