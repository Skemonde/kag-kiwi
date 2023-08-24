//Join and leave hooks for rulescore

#include "RulesCore.as"

void onInit(CRules@ this)
{
	this.addCommandID("sync playerinfo");
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	RulesCore@ core;
	this.get("core", @core);

	if (core !is null)
	{
		core.AddPlayer(player);

		CBitStream params;
		params.write_string(player.getUsername());
		params.write_bool(true);
		this.SendCommand(this.getCommandID("sync playerinfo"), params);
	}
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	RulesCore@ core;
	this.get("core", @core);

	if (core !is null)
	{
		core.RemovePlayer(player);

		CBitStream params;
		params.write_string(player.getUsername());
		params.write_bool(false);
		this.SendCommand(this.getCommandID("sync playerinfo"), params);
	}
}

void onCommand( CRules@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("sync playerinfo") && isClient())
	{
		string username = params.read_string();
		bool joining = params.read_bool();

		CPlayer@ p = getPlayerByUsername(username);
		if (p !is null)
		{
			RulesCore@ core;
			this.get("core", @core);

			if (core !is null)
			{
				if (joining)
					core.AddPlayer(p);

				else 
					core.RemovePlayer(p);
			}
		}
	}
}