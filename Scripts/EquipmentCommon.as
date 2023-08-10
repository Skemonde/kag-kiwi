bool addHatScript(CBlob@ blob, string associated_script = "")
{
	if (blob is null) return false;
	CPlayer@ player = blob.getPlayer();
	if (player is null) return false;
	string player_name = player.getUsername();
	CRules@ rules = getRules();
	
	if (associated_script.empty())
		associated_script = rules.get_string(player_name + "hat_script");
	
	if (!associated_script.empty()) {
		rules.set_string(player_name + "hat_script", associated_script);
		if (!blob.hasScript(associated_script))
			blob.AddScript(associated_script);
		CSprite@ sprite  = blob.getSprite();
		if (sprite !is null && !sprite.hasScript(associated_script))
			sprite.AddScript(associated_script);
	} else
		return false;
	return true;
}

bool removeHatScript(CBlob@ blob, string associated_script = "")
{
	if (blob is null) return false;
	CPlayer@ player = blob.getPlayer();
	if (player is null) return false;
	string player_name = player.getUsername();
	CRules@ rules = getRules();
	
	if (associated_script.empty())
		associated_script = rules.get_string(player_name + "hat_script");
	
	if (!associated_script.empty()) {
		rules.set_string(player_name + "hat_script", "");
		if (blob.hasScript(associated_script))
			blob.RemoveScript(associated_script);
		CSprite@ sprite  = blob.getSprite();
		if (sprite !is null && sprite.hasScript(associated_script))
			sprite.RemoveScript(associated_script);
	} else
		return false;
	return true;
}