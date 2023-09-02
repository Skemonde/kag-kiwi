//Join and leave hooks for rulescore

#include "RulesCore.as"
#include "KIWI_RulesCore.as"
#include "KIWI_Players&Teams.as"

void onInit(CRules@ this)
{
	this.addCommandID("send playerinfo");
	this.addCommandID("sync playerinfos");
	this.addCommandID("clear client playerinfos");
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	KIWICore@ core;
	this.get("core", @core);

	if (core !is null)
	{
		core.AddPlayer(player);
		server_SendInfosToJoinedClient(this, player);
	}
}

void onTick(CRules@ this)
{
	server_SyncInfosValues(this);
}

void server_SendInfosToJoinedClient(CRules@ this, CPlayer@ joined_player)
{
	if (!isServer()||isClient()) return;
	KIWICore@ core;
	if (!this.get("core", @core)) return;

	//{
	//	CBitStream params;
	//	params.write_string(joined_player.getUsername());
	//	this.SendCommand(this.getCommandID("clear client playerinfos"), params);
	//}
	
	for (int p_idx = 0; p_idx < getPlayerCount(); ++p_idx) {
		CPlayer@ player = getPlayer(p_idx);
		if (player is null) continue;
		CBitStream params;
		params.write_string(joined_player.getUsername());
		params.write_string(player.getUsername());
		this.SendCommand(this.getCommandID("send playerinfo"), params);
	}
}

void server_SyncInfosValues(CRules@ this)
{
	if (!isServer()||isClient()) return;
	KIWICore@ core;
	if (!this.get("core", @core)) return;
	
	for (int p_idx = 0; p_idx < getPlayerCount(); ++p_idx) {
		CPlayer@ player = getPlayer(p_idx);
		if (player is null) continue;
		
		KIWIPlayerInfo@ info = core.getKIWIInfoFromPlayer(player);
		if (info is null) return; //don't sync if there's no info for this player on server (zamn..)
		
		CBitStream info_params;
		info_params.write_string(player.getUsername());
		info.serialize(info_params, false);
		this.SendCommand(this.getCommandID("sync playerinfos"), info_params);
	}
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	KIWICore@ core;
	this.get("core", @core);

	if (core !is null)
	{
		core.RemovePlayer(player);
	}
}

void onCommand( CRules@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("send playerinfo"))
	{
		if (!isClient()||isServer()) return;
		KIWICore@ core;
		if (!this.get("core", @core)) return;
		
		string my_username; if (!params.saferead_string(my_username)) return;
		string current_username; if (!params.saferead_string(current_username)) return;

		CPlayer@ local = getPlayerByUsername(my_username);
		if (local is null) return;
		if (!local.isMyPlayer()) return;
		
		CPlayer@ current_p = getPlayerByUsername(current_username);
		if (current_p is null) return;
				
		KIWIPlayerInfo@ info = core.getKIWIInfoFromPlayer(current_p);
		
		if (info is null) {
			core.AddPlayer(current_p);
			if (g_debug>0)
				print("added info for "+current_p.getCharacterName()+" into "+local.getCharacterName()+" client's array!!");
		}
		else {
			if (g_debug>0)
				print("we've got the "+current_p.getCharacterName()+"'s info on "+local.getCharacterName()+" client already!!");
			
			CBitStream info_params;
			info_params.write_string(current_p.getUsername());
			info.serialize(info_params, false);
			this.SendCommand(this.getCommandID("sync playerinfos"), info_params);
		}
	}
	if (cmd == this.getCommandID("sync playerinfos"))
	{
		if (!isClient()||isServer()) return;
		
		KIWICore@ core;
		if (!this.get("core", @core)) return;
		
		string username; if (!params.saferead_string(username)) return;
		CPlayer@ current_player = getPlayerByUsername(username);
		if (current_player is null) return;
		
		KIWIPlayerInfo@ info = core.getKIWIInfoFromPlayer(current_player);
		if (info is null) return;
		
		info.SyncFromParams(params);
	}
	if (cmd == this.getCommandID("clear client playerinfos"))
	{
		if (!isClient()||isServer()) return;
		
		KIWICore@ core;
		if (!this.get("core", @core)) return;
		
		string username; if (!params.saferead_string(username)) return;
		CPlayer@ local = getPlayerByUsername(username);
		if (local is null) return;
		if (!local.isMyPlayer()) return;
		
		core.players.clear();
	}
}