void drawProgressBar(CBlob@ blob, f32 percentage = 0.5f)
{
	AddIconToken("$progress_bar$", "Entities/Special/CTF/FlagProgressBar.png", Vec2f(30, 8), 0);
	Vec2f pos = blob.getPosition() + Vec2f(-30.0f, -40.0f);
	Vec2f dimension = Vec2f(60.0f - 8.0f, 8.0f);
		
	//GUI::DrawIcon(
	//			"FlagProgressBar.png",
	//			0,
	//			Vec2f(30, 8),
	//			pos,
	//			1.0f);
	GUI::DrawIconByName("$progress_bar$", pos);
	
	Vec2f bar = Vec2f(pos.x + (dimension.x * percentage), pos.y + dimension.y);
	
	if (true)
	{
		GUI::DrawRectangle(pos + Vec2f(4, 4), bar + Vec2f(4, 4), SColor(255, 59, 20, 6));
		GUI::DrawRectangle(pos + Vec2f(6, 6), bar + Vec2f(2, 4), SColor(255, 148, 27, 27));
		GUI::DrawRectangle(pos + Vec2f(6, 6), bar + Vec2f(2, 2), SColor(255, 183, 51, 51));
	}
	else
	{
		GUI::DrawRectangle(pos + Vec2f(4, 4), bar + Vec2f(4, 4), SColor(255, 58, 63, 21));
		GUI::DrawRectangle(pos + Vec2f(6, 6), bar + Vec2f(2, 4), SColor(255, 99, 112, 95));
		GUI::DrawRectangle(pos + Vec2f(6, 6), bar + Vec2f(2, 2), SColor(255, 125, 139, 120));
	}
}