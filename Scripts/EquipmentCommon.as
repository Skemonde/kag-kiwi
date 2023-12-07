void PutHatOn(CBlob@ hat, CBlob@ guy, bool putting_on = true)
{
	if (guy is null) return;
	CPlayer@ player = guy.getPlayer();
	if (player is null) return;
	string player_name = player.getUsername();
	
	string player_hat = getRules().get_string(player_name+"hat_name");
	bool player_got_hat = !player_hat.empty();
	
	//if we already got it why would we replace it like that?
	//nuh uh
	if (player_got_hat && putting_on) return;
	
	getRules().set_string(player_name+"hat_name", putting_on?hat.getName():"");
	getRules().set_bool(player_name + "helm", putting_on);
	guy.SendCommand(guy.getCommandID("set head to update"));
	
	hat.server_Die();
}

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