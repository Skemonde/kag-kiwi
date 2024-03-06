#include "SoldatInfo"

void PutHatOn(CBlob@ hat, CBlob@ guy, bool putting_on = true)
{
	if (!isServer()) return;
	
	if (hat is null) return;
	if (guy is null) return;
	CPlayer@ player = guy.getPlayer();
	if (player is null) return;
	
	SoldatInfo[]@ infos = getSoldatInfosFromRules();
	if (infos is null) return;
	SoldatInfo our_info = getSoldatInfoFromUsername(player.getUsername());
	if (our_info is null) return;
	int info_idx = getInfoArrayIdx(our_info);
	
	string player_hat = infos[info_idx].hat_name;
	bool has_helm = !player_hat.empty();
	
	if (has_helm) return;
	
	CBitStream params;
	params.write_string(player.getUsername());
	params.write_u16(hat.getNetworkID());
	params.write_bool(false);
	
	guy.SendCommand(guy.getCommandID("equip item"), params);
	
	return;/* 
	
	if (guy is null) return;
	CPlayer@ player = guy.getPlayer();
	if (player is null) return;
	string player_name = player.getUsername();
	
	SoldatInfo[]@ infos = getSoldatInfosFromRules();
	if (infos is null) return;
	SoldatInfo our_info = getSoldatInfoFromUsername(player_name, infos);
	if (our_info is null) return;
	int info_idx = getInfoArrayIdx(our_info);
	
	string player_hat = infos[info_idx].hat_name;
	bool player_got_hat = !player_hat.empty();
	
	//if we already got it why would we replace it like that?
	//nuh uh
	if (player_got_hat && putting_on) return;
	
	infos[info_idx].hat_name = putting_on?hat.getName():"";
	
	getRules().set("soldat_infos", infos);
	
	guy.getSprite().PlaySound("CycleInventory");
	
	guy.SendCommand(guy.getCommandID("set head to update"));
	
	hat.server_Die(); */
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