#include "TugOfWarPoints"
#include "Skemlib"

u8 zone_count = 5;

f32 step_var = 0;

void onTick(CRules@ rules)
{
	if (rules.get_bool("RCTF"))
	{
		return;
	}

	if (!isServer()) return;

	if(getGameTime() == 45)
	{
		CMap@ map = getMap();
		f32 map_width = map.tilemapwidth*map.tilesize;
		
		// redzone
		f32 x1 = rules.get_f32("barrier_x1");
		f32 x2 = rules.get_f32("barrier_x2");

		f32 distance = x2 - x1;

		f32 step = distance / zone_count;

		for (int i=0; i<=zone_count; ++i)
		{
			rules.set_f32("towzone" + i, x1 + (i * step));
			rules.Sync("towzone" + i, true);
		}

		for (int i=0; i<zone_count; ++i)
		{
			rules.set_u16("towzone" + i + "team", 255);
			rules.Sync("towzone" + i + "team", true);
		}
		for (int i=0; i<zone_count; ++i)
		{
			rules.set_u16("towzone" + i + "power", 0);
			rules.Sync("towzone" + i + "power", true);
		}

		for (int i=0; i<=zone_count; ++i)
		{
			printf("hi" + rules.get_f32("towzone" + i));
		}
	}

	// Zone control system

	u8 zone1_b = 0;
	u8 zone1_r = 0;

	u8 zone2_b = 0;
	u8 zone2_r = 0;

	u8 zone3_b = 0;
	u8 zone3_r = 0;

	u8 zone4_b = 0;
	u8 zone4_r = 0;

	u8 zone5_b = 0;
	u8 zone5_r = 0;

	// Count amount of blue & red in each zone
	for (int i=0; i<getPlayersCount(); ++i)
	{
		CPlayer@ p = getPlayer(i);

		if (p.getTeamNum() != 0 && p.getTeamNum() != 1) continue;

		if (p.getBlob() is null) continue;

		f32 xpos = p.getBlob().getPosition().x;

		u16 team_num = p.getTeamNum();

		for (int k=0; k<zone_count; ++k)
		{
			f32 left = rules.get_f32("towzone" + k);
			f32 right = rules.get_f32("towzone" + (k+1));

			bool is_in_zone = (xpos >=left && xpos <=right);

			if (k==0 && is_in_zone) { if (team_num == 0) ++zone1_b; else ++zone1_r; }
			if (k==1 && is_in_zone) { if (team_num == 0) ++zone2_b; else ++zone2_r; }
			if (k==2 && is_in_zone) { if (team_num == 0) ++zone3_b; else ++zone3_r; }
			if (k==3 && is_in_zone) { if (team_num == 0) ++zone4_b; else ++zone4_r; }
			if (k==4 && is_in_zone) { if (team_num == 0) ++zone5_b; else ++zone5_r; }
		}
	}

	// Check if we're capturing any zones right now
	if (getGameTime() % 30 == 0)
	{
		for (int k=0; k<zone_count; ++k)
		{
			u16 zone_team_num = rules.get_u16("towzone"+k+"team");

			u16 most_team = 69;

			if (k==0)
			{
				if (zone1_b > zone1_r) most_team = 0;
				if (zone1_r > zone1_b) most_team = 1;
				if (zone1_r == zone1_b) most_team = 255;
			}
			if (k==1)
			{
				if (zone2_b > zone2_r) most_team = 0;
				if (zone2_r > zone2_b) most_team = 1;
				if (zone2_r == zone2_b) most_team = 255;
			}
			if (k==2)
			{
				if (zone3_b > zone3_r) most_team = 0;
				if (zone3_r > zone3_b) most_team = 1;
				if (zone3_r == zone3_b) most_team = 255;
			}
			if (k==3)
			{
				if (zone4_b > zone4_r) most_team = 0;
				if (zone4_r > zone4_b) most_team = 1;
				if (zone4_r == zone4_b) most_team = 255;
			}
			if (k==4)
			{
				if (zone5_b > zone5_r) most_team = 0;
				if (zone5_r > zone5_b) most_team = 1;
				if (zone5_r == zone5_b) most_team = 255;
			}

			if (most_team != 255)
			{
				if (rules.get_u16("towzone"+k+"power") > 0 && most_team != zone_team_num) rules.sub_u16("towzone"+k+"power", 1);

				else if (rules.get_u16("towzone"+k+"power") == 0 && most_team != zone_team_num) {
					if (most_team != rules.get_u16("towzone"+k+"team")) {
						//getMap().MakeMiniMap();
					}
					rules.set_u16("towzone"+k+"team", most_team);
				}

				else if (rules.get_u16("towzone"+k+"power") < 5 && most_team == zone_team_num) rules.add_u16("towzone"+k+"power", 1);

				rules.Sync("towzone"+k+"team", true);
				rules.Sync("towzone"+k+"power", true);
			}
		}
	}
}

void onRender(CRules@ rules)
{
	v_showminimap = false;
	if (rules.get_bool("RCTF"))
	{
		return;
	}

	CPlayer@ my_player = getLocalPlayer();
	if (my_player is null) return;
	if (!rules.exists("towzone0")) return;
	if (getGameTime() < 45) return;
	//u8 team = my_player.getTeamNum();

	const f32 scalex = getDriver().getResolutionScaleFactor();
	f32 zoom = getCamera().targetDistance * scalex;

	CMap@ map = getMap();
	f32 map_height = map.tilemapheight*map.tilesize;

	SColor color_b = SColor(40, 229, 212, 27);

	u8 opacity = 55;

	if (rules.exists("opacity"))
	{
		opacity = 255 * rules.get_s32("opacity") * 0.01;
	}

	SColor blue = SColor(opacity, 115, 167, 184);
	SColor red = SColor(opacity, 193, 58, 69);
	SColor white = SColor(opacity, 255, 255, 255);

	f32 x1 = rules.get_f32("barrier_x1");
	f32 x2 = rules.get_f32("barrier_x2");

	f32 distance = x2 - x1;
	f32 step = distance / zone_count;

	for (int i=0; i<zone_count; ++i)
	{
		u16 team_num = 255;
		u16 power = rules.get_u16("towzone"+i+"power");

		if (power > 0)

		team_num = rules.get_u16("towzone"+i+"team");
		u8 icon_num = power;
		if (team_num == 255)
			icon_num = 0;

		SColor cock;

		if (team_num == 0) cock = blue;
		else if (team_num == 1) cock = red;
		else cock = white;

		Vec2f upperleft_1 = getDriver().getScreenPosFromWorldPos(Vec2f(rules.get_f32("towzone" + i) + 0.0, 0));
		Vec2f lowerright_1 = getDriver().getScreenPosFromWorldPos(Vec2f(rules.get_f32("towzone" + i) + 0.5, getDriver().getScreenHeight()));
		GUI::DrawRectangle(upperleft_1, lowerright_1, cock);

		Vec2f upperleft_2 = getDriver().getScreenPosFromWorldPos(Vec2f(rules.get_f32("towzone" + i) + step - 0.5, 0));
		Vec2f lowerright_2 = getDriver().getScreenPosFromWorldPos(Vec2f(rules.get_f32("towzone" + i) + step + 0, getDriver().getScreenHeight()));

		GUI::DrawRectangle(upperleft_2, lowerright_2, cock);
		
		const f32 scalex = getDriver().getResolutionScaleFactor();
		const f32 zoom = getCamera().targetDistance * scalex;
		if (true) {
			GUI::DrawIcon("TOWZones.png", icon_num, Vec2f(24,24),getDriver().getScreenPosFromWorldPos(Vec2f(Maths::Floor((x1+i*step+step/4+16)/map.tilesize)*map.tilesize+map.tilesize/2, (map.tilemapheight-3)*map.tilesize)), 2*zoom, Maths::Min(7,team_num));
		} else {
			GUI::DrawIcon("Emblems.png", team_num, Vec2f(32,32),getDriver().getScreenPosFromWorldPos(Vec2f(Maths::Floor((x1+i*step+step/4+32)/map.tilesize)*map.tilesize, map.tilemapheight*map.tilesize-170)), 1*zoom, Maths::Min(7,team_num));
		}
	}
	
	//making bars for progress
	Vec2f pane_dims(200, 20);
	Vec2f screen(getScreenWidth(), getScreenHeight());
	
	u8 min_progress_width = 7;
	Vec2f progress_bar_pos(screen.x/2,70);
	f32 min_progress_width_perc = min_progress_width/pane_dims.x;
	
	f32 victory_points = rules.get_f32("victory points");
	f32 blue_points = rules.get_f32("blue points");
	f32 red_points = rules.get_f32("red points");
	f32 winning_gap_points = rules.get_f32("winning gap points");
	f32 points_diff = Maths::Min(Maths::Abs(blue_points-red_points), winning_gap_points);
	
	f32 blue_perc = Maths::Clamp(blue_points/victory_points, min_progress_width_perc, 1.0f);
	f32 red_perc = Maths::Clamp(red_points/victory_points, min_progress_width_perc, 1.0f);
	
	SColor blue_team_col = GetColorFromTeam(0);
	SColor red_team_col = GetColorFromTeam(1);
	
	Vec2f blue_bar_tl = Vec2f(progress_bar_pos.x-pane_dims.x, progress_bar_pos.y);
	Vec2f blue_bar_br = Vec2f(progress_bar_pos.x, progress_bar_pos.y+pane_dims.y);
	Vec2f blue_progress_tl = blue_bar_tl;
	Vec2f blue_progress_br = Vec2f(progress_bar_pos.x-pane_dims.x+pane_dims.x*blue_perc, progress_bar_pos.y+pane_dims.y);
	//add a pixel so the seam between progress bars in the middle of the screen looks nice
	blue_bar_br 		+= Vec2f(1,0);
	blue_progress_br 	+= Vec2f(1,0);
	
	Vec2f red_bar_tl = Vec2f(progress_bar_pos.x, progress_bar_pos.y);
	Vec2f red_bar_br = Vec2f(progress_bar_pos.x+pane_dims.x, progress_bar_pos.y+pane_dims.y);
	Vec2f red_progress_tl = Vec2f(progress_bar_pos.x+pane_dims.x*(1.0f-red_perc), progress_bar_pos.y);
	Vec2f red_progress_br = red_bar_br;
	//add a pixel so the seam between progress bars in the middle of the screen looks nice
	red_bar_tl 			-= Vec2f(1,0);
	red_progress_tl 	-= Vec2f(1,0);
	
	//a pane behind all the progress bars
	GUI::DrawFramedPane(blue_bar_tl-Vec2f(4,4), red_bar_br+Vec2f(4,4));
	if (blue_points<victory_points&&red_points<victory_points) {
		//blue
		GUI::DrawPane(blue_bar_tl, blue_bar_br);
		GUI::DrawPane(blue_progress_tl, blue_progress_br, blue_team_col);
		GUI::DrawTextCentered(""+rules.get_f32("blue points"), blue_bar_tl+Vec2f(blue_bar_br.x-blue_bar_tl.x, blue_bar_br.y-blue_bar_tl.y)/2, color_white);
		//red
		GUI::DrawPane(red_bar_tl, red_bar_br);
		GUI::DrawPane(red_progress_tl, red_progress_br, red_team_col);
		GUI::DrawTextCentered(""+rules.get_f32("red points"), red_bar_tl+Vec2f(red_bar_br.x-red_bar_tl.x, red_bar_br.y-red_bar_tl.y)/2, color_white);
		
		GUI::DrawTextCentered(""+rules.get_f32("victory points"), blue_bar_tl+Vec2f(blue_bar_br.x-blue_bar_tl.x, (blue_bar_br.y-blue_bar_tl.y)/2), color_white);
	} else {
		GUI::DrawPane(blue_bar_tl, red_bar_br);
		f32 diff_percentage = 1-(Maths::Clamp(points_diff/winning_gap_points, min_progress_width/(pane_dims.x*2), 1.0f));
		
		if (blue_points-red_points>0) {
			//if blue is winning
			GUI::DrawPane(blue_bar_tl, red_bar_br-Vec2f(diff_percentage*(red_bar_br.x-blue_bar_tl.x),0), blue_team_col);
		} else {
			//if red is winning
			GUI::DrawPane(blue_bar_tl+Vec2f(diff_percentage*(red_bar_br.x-blue_bar_tl.x),0), red_bar_br, red_team_col);
		}
		
		if (points_diff<winning_gap_points) {
			GUI::DrawTextCentered("Point advantage "+points_diff+"/"+winning_gap_points, blue_bar_tl+Vec2f(blue_bar_br.x-blue_bar_tl.x, (blue_bar_br.y-blue_bar_tl.y)/2), color_white);
		}
		if(getRules().isGameOver()) {
			GUI::DrawIcon("Emblems.png", getRules().getTeamWon(), Vec2f(32, 32), blue_bar_tl+Vec2f(blue_bar_br.x-blue_bar_tl.x, (blue_bar_br.y-blue_bar_tl.y)/2)+Vec2f(-32, -24), 1.0f, getRules().getTeamWon());
		}
	}
	GUI::DrawTextCentered(getPointsPerTick_Zones(0, 5)/10+" zones captured", blue_bar_tl+Vec2f(blue_bar_br.x-blue_bar_tl.x, blue_bar_br.y-blue_bar_tl.y)/2+Vec2f(0, 20), blue_team_col);
	GUI::DrawTextCentered(getPointsPerTick_Zones(1, 5)/10+" zones captured", red_bar_tl+Vec2f(red_bar_br.x-red_bar_tl.x, red_bar_br.y-red_bar_tl.y)/2+Vec2f(0, 20), red_team_col);
}
