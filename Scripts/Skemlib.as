//various stuff
//script by Skemonde uwu

//functions					- camelCase(returns something)/PascalCase(void)
//classes 					- PascalCase
//consts					- SCREAMING_SNAKE_CASE
//variables 				- snake_case
//objects(class instance)	- snake_case
//so basically names are camelCase and things that can be changed are snake_case

const bool SERVER = isServer();
const bool CLIENT = isClient();
const bool LOCALHOST = SERVER && CLIENT;

//plays sounds for everyone, pitch and sound depends of distance from your camera to sound origin
void PlayDistancedSound(string sound_name, f32 volume, f32 pitch, Vec2f sound_pos, f32 pitch_range = 0.01f, f32 min_volume = 0.1f, f32 min_pitch = 0.2f, f32 range_mod = 1.0f)
{
	CCamera@ localcamera = getCamera();
	if (localcamera is null) return;
	pitch_range = Maths::Max(pitch_range, 0.01f);
	
	Vec2f cam_pos = localcamera.getPosition();
	f32 dist = (cam_pos-sound_pos).Length();
	f32 rnd_scale = 10000;
	u32 rnd_pitch = rnd_scale*pitch_range;
	range_mod = Maths::Max(range_mod, 0.01f);
	f32 dist_mod = dist/((getMap().tilemapwidth*getMap().tilesize)/range_mod);
	f32 rnd_mod = XORRandom(rnd_pitch)*(1/rnd_scale)-rnd_pitch*(0.5f/rnd_scale);
	
	f32 fin_vol = volume-dist_mod;
	f32 fin_pitch = pitch-dist_mod+rnd_mod;
	
	if (fin_vol < 0.05f || fin_pitch < 0.05f) return;
	
	Sound::Play(
		sound_name,
		cam_pos,
		Maths::Max(min_volume, fin_vol),
		Maths::Max(min_pitch, fin_pitch)
		);
}

string getMachineType() {
	return (SERVER?(!CLIENT?"Server":"Localhost"):"Client");
}

//returns a digit from a given number by the number position
//eg. FindDigit(10783, 2) would give you 7
//				  |
//digit ids---->43210
//				  ^
//				  |
//you can additionally change number system base if you want to get digits from hex or something
//it's 10 by default
//TODO: make it support hex

u16 FindDigit(u16 number, u16 digit_position, const u8 number_system_base = 10)
{
	u16 mlt = Maths::Pow(number_system_base, digit_position);
    return Maths::Floor(
        (number-Maths::Round(number/(mlt*number_system_base))*(mlt*number_system_base))/mlt);
}

u16 GetItemAmount(CBlob@ this, const string item_name = "highpow")
{
	CInventory@ inv = this.getInventory();
	CBlob@ carried = this.getCarriedBlob();
	u16 quan = 0;
	if (inv != null)
	{
		for (int i = 0; i < inv.getItemsCount(); ++i) {
			if (inv.getItem(i) != null && inv.getItem(i).getName() == item_name)
				quan += inv.getItem(i).getQuantity();
		}
	}
	if (carried !is null && carried.getName() == item_name)
		quan += carried.getQuantity();
	
	return quan;

	return 0;
}

SColor GetColorFromTeam(u8 teamnum = 7, const u8 opacity = 255, const u8 index = 0)
{
	CFileImage team_texture("TeamPalette.png");
	if (teamnum > 6)
		teamnum = 7;
	if (team_texture.canRead()) {
		team_texture.setPixelPosition(Vec2f(teamnum, index));
		SColor color = team_texture.readPixel();
		return SColor(opacity, color.getRed(), color.getGreen(), color.getBlue());
	}
	return SColor(255, 0, 0, 0);
}

Vec2f getUnifiedTileWorldpos(Vec2f world_pos)
{
	CMap@ map = getMap();
	Vec2f unified_pos = (world_pos / map.tilesize);
    unified_pos.x = Maths::Floor(unified_pos.x);
    unified_pos.y = Maths::Floor(unified_pos.y);
    unified_pos = (unified_pos * map.tilesize) + Vec2f(map.tilesize / 2, map.tilesize / 2);
	
	return unified_pos;
}

// turns 0.45 into 45% string

string getPercentStringFromFloat(f32 number)
{
	return ""+formatFloat(number*100, "", 3, 0)+"%";
}

// turns a number from something like 1740320 into something like 1,740,320

string splitNumberEachThreeDigits(u32 initial_number, string splitter = ",")
{
	const int CHAR_AMOUNT = 3; //amount of characters we split the initial_number on
	//f32 decimal_thing = initial_number % 1.0;
	//print("decimal thing "+decimal_thing);
	//int new_number = initial_number-decimal_thing;
	
	string temp = formatInt(initial_number, "", 0);
	
	string new_string = "";
	int init_length = temp.size(), new_length = init_length+Maths::Floor(init_length/CHAR_AMOUNT);
	//print("init len"+init_length);
	
	for (int i = 0; i < init_length; ++i) {
		//print(i+" char "+temp[i]);
		new_string+=temp.substr(i, 1);
		if ((init_length-i-1) % CHAR_AMOUNT == 0 && new_string.size() < new_length && i != init_length-1) {
			new_string+=splitter;
		}
	}
	//new_string+=formatFloat(decimal_thing, "", 3).substr(1, -1);
	
	return new_string;
}

Vec2f getGridMenuDims(CGridMenu@ menu)
{
	Vec2f tl = menu.getUpperLeftPosition();
	Vec2f br = menu.getLowerRightPosition();
	return Vec2f((br.x-tl.x)/48, (br.y-tl.y)/48);
}

u32 getGridMenuSlotCount(CGridMenu@ menu)
{
	Vec2f menu_dims = getGridMenuDims(menu);
	return menu_dims.x*menu_dims.y;
}

void GUIDrawTextCenteredOutlined(string text, Vec2f pos, SColor text_color, SColor outline_color, u8 outline_width = 2)
{
	GUI::DrawTextCentered(text, pos+Vec2f(-outline_width, +outline_width), 	outline_color);
	GUI::DrawTextCentered(text, pos+Vec2f(-outline_width, -outline_width), 	outline_color);
	GUI::DrawTextCentered(text, pos+Vec2f(-outline_width,  0),   			outline_color);
	GUI::DrawTextCentered(text, pos+Vec2f( outline_width, +outline_width), 	outline_color);
	GUI::DrawTextCentered(text, pos+Vec2f( outline_width, -outline_width), 	outline_color);
	GUI::DrawTextCentered(text, pos+Vec2f( outline_width,  0),   			outline_color);
	GUI::DrawTextCentered(text, pos+Vec2f( 0,			  +outline_width), 	outline_color);
	GUI::DrawTextCentered(text, pos+Vec2f( 0,			  -outline_width), 	outline_color);
	//draw it last so it's above the black ones
	GUI::DrawTextCentered(text, pos+Vec2f( 0,			   0), 				text_color);
}

bool isNumberEven(int number)
{
	// :tc2_hehe:
	if (number == 1) return false;
	else if (number == 2) return true;
	else if (number == 3) return false;
	else if (number == 4) return true;
	else if (number == 5) return false;
	else if (number == 6) return true;
	else if (number == 7) return false;
	else if (number == 8) return true;
	else if (number == 9) return false;
	else if (number == 10) return true;
	else if (number == 11) return false;
	else if (number == 12) return true;
	else if (number == 13) return false;
	else if (number == 14) return true;
	else if (number == 15) return false;
	else if (number == 16) return true;
	else if (number == 17) return false;
	else if (number == 18) return true;
	else if (number == 19) return false;
	else if (number == 20) return true;
	else if (number == 21) return false;
	else if (number == 22) return true;
	else if (number == 23) return false;
	else if (number == 24) return true;
	else if (number == 25) return false;
	else if (number == 26) return true;
	else if (number == 27) return false;
	else if (number == 28) return true;
	else if (number == 29) return false;
	else if (number == 30) return true;
	else if (number == 31) return false;
	else if (number == 32) return true;
	else if (number == 33) return false;
	else if (number == 34) return true;
	else if (number == 35) return false;
	else if (number == 36) return true;
	else if (number == 37) return false;
	else if (number == 38) return true;
	else if (number == 39) return false;
	else if (number == 40) return true;
	else return number%2==0;
}