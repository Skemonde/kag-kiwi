void print_log(string text)
{
	if(isServer())
	{
		tcpr("[LOG] " + text);
	}
}

void print_log(CBlob@ blob, string text)
{
	if(isServer())
	{
		if (blob !is null)
		{
			CPlayer@ player = blob.getPlayer();
			if (player !is null)
			{
				tcpr("[PPL] <" + player.getUsername() + "; " + blob.getName() + "; team " + blob.getTeamNum() + "> " + text);
			}
			else
			{
				print_log("[BPL] <" + blob.getName() + "; team " + blob.getTeamNum() + "> " + text);
			}
		}		
	}

}

void print_log(CPlayer@ player, string text)
{
	if(isServer())
	{
		if (player !is null)
		{
			CBlob@ blob = player.getBlob();
			if (blob !is null)
			{
				print_log("[PPL] <" + player.getUsername() + "; " + blob.getName() + "; team " + player.getTeamNum() + "> " + text);
			}
			else
			{
				print_log("[BPL] <" + player.getUsername() + "; team " + player.getTeamNum() + "> " + text);
			}
		}
	}
}

void print_damagelog(CBlob@ blob, f32 damage)
{
	// printing amount of damage dealt to a blob
	// if blob is player - display character name(cl_name) and username
	// if blob is dead(is a corpse) - display "dead" before blobname
	print("dealt " + damage + " HP of damage (it's " + damage/2 + " hearts of damage) to "
			+ (blob.getPlayer() is null ? "the "
			: blob.getPlayer().getCharacterName() + " (username: " + blob.getPlayer().getUsername() + ") the ")
			+ (blob.hasTag("dead") ? "dead " : "")
			+ blob.getName());
}