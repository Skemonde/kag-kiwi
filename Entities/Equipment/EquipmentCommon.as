#include "SoldatInfo"
#include "VarsSync"

void PutHatOn(CBlob@ hat, CBlob@ guy, bool check_inventory_opened = false)
{
	
	if (hat is null) return;
	if (guy is null) return;
	CPlayer@ player = guy.getPlayer();
	if (player is null) return;
	if (!player.isMyPlayer()) return;
	if (guy.hasTag("has_inventory_opened")&&check_inventory_opened) return;
	
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
	CSprite@ sprite  = blob.getSprite();
	if (sprite is null) return false;
	CPlayer@ player = blob.getPlayer();
	if (player is null) return false;
	string player_name = player.getUsername();
	CRules@ rules = getRules();
	
	//the whole array
	SoldatInfo[]@ infos = getSoldatInfosFromRules();
	if (infos is null) return false;
	//our exact object in it
	SoldatInfo our_info = getSoldatInfoFromUsername(player_name);
	if (our_info is null) return false;
	//get our idx in the whole array
	int info_idx = getInfoArrayIdx(our_info);
	
	string[] hat_scripts = infos[info_idx].hat_scripts;
	
	if (associated_script.empty()&&hat_scripts.size()>0) {
		associated_script = hat_scripts[0];
	}
	//check if it's empty AGAIN
	if (!associated_script.empty()) {
		//rules.set_string(player_name + "hat_script", associated_script);
		infos[info_idx].clearHatScripts();
		infos[info_idx].hat_scripts.push_back(associated_script);
		//adding script to blob
		if (!blob.hasScript(associated_script))
			blob.AddScript(associated_script);
		//adding script to sprite
		if (!sprite.hasScript(associated_script))
			sprite.AddScript(associated_script);
	} else
		return false;
	
	//so once we've done all the neccessary things to our soldatinfo obj
	//we save the whole array
	getRules().set("soldat_infos", infos);
	//and send those new values to all the clients
	server_SyncPlayerVars();
	
	//and now we can finally return true for the successfully executed func YIPPEEE
	return true;
}

bool removeHatScript(CBlob@ blob, string associated_script = "")
{
	if (blob is null) return false;
	CSprite@ sprite  = blob.getSprite();
	if (sprite is null) return false;
	CPlayer@ player = blob.getPlayer();
	if (player is null) return false;
	string player_name = player.getUsername();
	CRules@ rules = getRules();
	
	//the whole array
	SoldatInfo[]@ infos = getSoldatInfosFromRules();
	if (infos is null) return false;
	//our exact object in it
	SoldatInfo our_info = getSoldatInfoFromUsername(player_name);
	if (our_info is null) return false;
	//get our idx in the whole array
	int info_idx = getInfoArrayIdx(our_info);
	
	string[] hat_scripts = infos[info_idx].hat_scripts;
	
	if (associated_script.empty()&&hat_scripts.size()>0) {
		associated_script = hat_scripts[0];
	}
	
	if (!associated_script.empty()) {
		infos[info_idx].clearHatScripts();
		//removing script from blob
		if (blob.hasScript(associated_script))
			blob.RemoveScript(associated_script);
		//removing script from sprite
		if (sprite.hasScript(associated_script))
			sprite.RemoveScript(associated_script);
	} else
		return false;
		
	getRules().set("soldat_infos", infos);
	server_SyncPlayerVars();
	
	return true;
}