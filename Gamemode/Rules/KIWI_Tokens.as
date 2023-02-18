void onInit(CRules@ this)
{
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
	print("--- ADDING KIWI ICON TOKENS ----");
	
	//GUI
	AddIconToken("$icon_dogtag$", "dogtag.png", Vec2f(11, 14), 0);
	AddIconToken("$icon_locked$", "InteractionIcons.png", Vec2f(32, 32), 2);
	AddIconToken("$icon_unlocked$", "InteractionIcons.png", Vec2f(32, 32), 3);
	AddIconToken("$change_class$", "/GUI/InteractionIcons.png", Vec2f(32, 32), 12, 2);
}

void ReloadFonts(CRules@ this)
{
	print("--- ADDING KIWI FONTS ----");
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
	print("--- ADDING KIWI COLOR TOKENS ----");
	
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