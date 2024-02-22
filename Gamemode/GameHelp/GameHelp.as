//thanks to GingerBeard <3

#define CLIENT_ONLY

bool mousePress = false;
u8 page = 0;

const u8 pages = 4;

void onInit(CRules@ this)
{
	//this.set_bool("show_gamehelp", true);
	CFileImage@ image = CFileImage("HelpBackground.png");
	const Vec2f imageSize = Vec2f(image.getWidth(), image.getHeight());
	AddIconToken("$HELP$", "HelpBackground.png", imageSize, 0);
}

void onTick(CRules@ this)
{
	CPlayer@ player = getLocalPlayer();
	if (player is null) return;
	
	CControls@ controls = getControls();
	if (controls.isKeyJustPressed(controls.getActionKeyKey(AK_MENU)))
	{
		this.set_bool("show_gamehelp", !this.get_bool("show_gamehelp"));
	}
}

void onRender(CRules@ this)
{
	if (!this.get_bool("show_gamehelp")) return;
	
	CPlayer@ player = getLocalPlayer();
	if (player is null) return;
	
	Vec2f center = getDriver().getScreenCenterPos();
	
	//background
	Vec2f imageSize;
	GUI::GetIconDimensions("$HELP$", imageSize);
	GUI::DrawIconByName("$HELP$", Vec2f(center.x - imageSize.x, center.y - imageSize.y));
	
	//pages
	managePages(imageSize, center);
	
	//clickable buttons
	CControls@ controls = getControls();
	const Vec2f mousePos = controls.getMouseScreenPos();
	makeExitButton(this, Vec2f(center.x + imageSize.x - 20, center.y - imageSize.y + 20), controls, mousePos);
	makePageChangeButton(Vec2f(center.x+22, center.y + imageSize.y + 30), controls, mousePos, true);
	makePageChangeButton(Vec2f(center.x-22, center.y + imageSize.y + 30), controls, mousePos, false);
	//makeWebsiteLink(Vec2f(center.x+250, center.y + imageSize.y + 10), "Discord", "https://discord.gg/V29BBeba3C", controls, mousePos);
	//makeWebsiteLink(Vec2f(center.x+160, center.y + imageSize.y + 10), "Github", "https://github.com/Gingerbeard5773/Zombies_Reborn", controls, mousePos);
	
	//page num
	drawTextWithFont((page+1)+"/"+pages, center + imageSize - Vec2f(30, 25), "readable");
	
	mousePress = controls.mousePressed1; 
}

void managePages(Vec2f&in imageSize, Vec2f&in center)
{
	switch(page)
	{
		case 0: drawPage(imageSize, center, "Kaiser's Ingenious Warring Invention", Vec2f(center.x - imageSize.x/2, center.y - imageSize.y/8));
			break;
		case 1: drawPage(imageSize, center, "Tips", Vec2f(center.x - imageSize.x/2, center.y - imageSize.y/8));
			break;
		case 2: drawPage(imageSize, center, "Tank oddities", Vec2f(center.x - imageSize.x/2, center.y - imageSize.y/8));
			break;
		case 3: drawPage(imageSize, center, "Your character", Vec2f(center.x - imageSize.x/2, center.y - imageSize.y/8));
			break;
		case 4: drawPage(imageSize, center, "Tips", Vec2f(center.x + imageSize.x/4, center.y));
			break;
		case 5: drawPage(imageSize, center, "Tips", Vec2f(center.x - imageSize.x + 150, center.y - imageSize.y/3));
			break;
		case 6: drawPage(imageSize, center, "Tips", Vec2f(center.x - imageSize.x + 150, center.y - imageSize.y/3));
			break;
	};
}

void drawPage(Vec2f&in imageSize, Vec2f&in center, const string&in header, Vec2f&in imagePos)
{
	GUI::DrawIcon("Page"+(page+1)+".png", imagePos, 0.25f);
	drawTextWithFont(header, center - Vec2f(0, imageSize.y - 50), "military");
	drawTextWithFont(page_tips[page], center - Vec2f(0, imageSize.y - 140), "readable");
}

const string[] page_tips =
{
	"\nTake a gun, go commit a crime :3\nEventually I'll add everything you need\nto know as pages here\nYou can open this menu with a Misc Menu key\n(it's often binded to BACKSPACE)",
	"Head shots deal additional damage.\n\nStanding near sandbags or wearing\na helmet removes additional head damage\nand decreases damage you take from gunfire by 5 pts",
	"Sticking out of a turret hatch allows you\nto use binoculars but you can be hurt as well\n\nThrow a tank shell into a small hatchet\nat the back of the turret to reload your cannon",
	"Kneeling pose is for aiming a gun or using binoculars\nIt also lifts you gun so you can shoot from a cover\n\nLying prone allows you dodge bullets\nIt restricts your aim angle",
	"Head shots deal additional damage.",
	"If there is not many zombies, a trader will visit at mid-day.",
	"Respawns are instant if there is no zombies during day light."
};

void drawTextWithFont(const string&in text, const Vec2f&in pos, const string&in font)
{
	GUI::SetFont(font);
	GUI::DrawTextCentered(text, pos, color_black);
}

void makeExitButton(CRules@ this, Vec2f&in pos, CControls@ controls, Vec2f&in mousePos)
{
	Vec2f tl = pos + Vec2f(-20, -20);
	Vec2f br = pos + Vec2f(20, 20);
	
	const bool hover = (mousePos.x > tl.x && mousePos.x < br.x && mousePos.y > tl.y && mousePos.y < br.y);
	if (hover)
	{
		GUI::DrawButton(tl, br);
		
		if (controls.mousePressed1 && !mousePress)
		{
			Sound::Play("option");
			this.set_bool("show_gamehelp", false);
		}
	}
	else
	{
		GUI::DrawPane(tl, br, 0xffcfcfcf);
	}
	GUI::DrawIcon("MenuItems", 29, Vec2f(32,32), Vec2f(pos.x-32, pos.y-32), 1.0f);
}

void makePageChangeButton(Vec2f&in pos, CControls@ controls, Vec2f&in mousePos, const bool&in right)
{
	Vec2f tl = pos + Vec2f(-20, -20);
	Vec2f br = pos + Vec2f(20, 20);
	
	const bool hover = (mousePos.x > tl.x && mousePos.x < br.x && mousePos.y > tl.y && mousePos.y < br.y);
	if (hover)
	{
		GUI::DrawButton(tl, br);
		
		if (controls.mousePressed1 && !mousePress)
		{
			Sound::Play("option");
			if (right)
				page = page == pages - 1 ? 0 : page + 1;
			else
				page = page == 0 ? pages - 1 : page - 1;
		}
	}
	else
	{
		GUI::DrawPane(tl, br, 0xffcfcfcf);
	}
	GUI::DrawIconByName(right?"$arrow_right$":"$arrow_left$", Vec2f(pos.x-32, pos.y-32), 1.0f);
}

void makeWebsiteLink(Vec2f pos, const string&in text, const string&in website, CControls@ controls, Vec2f&in mousePos)
{
	Vec2f dim;
	GUI::GetTextDimensions(text, dim);

	const f32 width = dim.x + 20;
	const f32 height = 40;
	const Vec2f tl = Vec2f(getScreenWidth() - width - pos.x, pos.y);
	const Vec2f br = Vec2f(getScreenWidth() - pos.x, tl.y + height);

	const bool hover = (mousePos.x > tl.x && mousePos.x < br.x && mousePos.y > tl.y && mousePos.y < br.y);
	if (hover)
	{
		GUI::DrawButton(tl, br);

		if (controls.mousePressed1 && !mousePress)
		{
			Sound::Play("option");
			OpenWebsite(website);
		}
	}
	else
	{
		GUI::DrawPane(tl, br, 0xffcfcfcf);
	}

	GUI::DrawTextCentered(text, Vec2f(tl.x + (width * 0.50f), tl.y + (height * 0.50f)), 0xffffffff);
}
