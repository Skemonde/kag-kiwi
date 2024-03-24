#include "SocialStatus"
#include "MakeSeed"
#include "MakeCrate"
#include "MakeScroll"
#include "BasePNGLoader"
#include "LoadWarPNG"
#include "RespawnCommon"
#include "SDF"
#include "EquipmentCommon"
#include "Skemlib"
#include "KIWI_RulesCore"
#include "KIWI_BalanceInfo"
#include "SoldatInfo"
#include "VarsSync"

void onInit(CRules@ this)
{
	this.addCommandID("send_chat_message");
	this.addCommandID("spawn");
	this.addCommandID("teleport");
	this.addCommandID("addbot");
	this.addCommandID("kickPlayer");
	this.addCommandID("mute_sv");
	this.addCommandID("mute_cl");
	this.addCommandID("playsound");
	this.addCommandID("SendChatWarning");

	if (isClient()) this.set_bool("log",false);//so no clients can get logs unless they do ~logging
	if (isServer()) this.set_bool("log",true);//server always needs to log anyway
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("send_chat_message"))
	{
		//here all the info from sender is received
		//so this part of the code runs on each client
		//helps to decide which messages certain player should get
		
		if (!isClient()) return;
		CPlayer@ receiver = getLocalPlayer();
		if (receiver is null) return;
		
		u16 sender_id; if (!params.saferead_u16(sender_id)) return;
		u8 chat_channel; if (!params.saferead_u8(chat_channel)) return;
		string text_out; if (!params.saferead_string(text_out)) return;
		
		CPlayer@ sender = getPlayerByNetworkId(sender_id);
		if (sender is null) return;
		
		const u8 SENDER_TEAM = sender.getTeamNum();
		
		CBlob@ sender_blob = sender.getBlob();
		CBlob@ receiver_blob = receiver.getBlob();
		
		const u8 CH_MAX = getRules().get_u8("wt_channel_max");
		const u8 CH_MIN = getRules().get_u8("wt_channel_min");
		
		bool global_chat = chat_channel == 0;
		bool team_chat = chat_channel == 1;
		bool dm_chat = chat_channel == 2;
		bool wt_chat = chat_channel >= CH_MIN && chat_channel <= CH_MAX;
		
		bool receive_global_chat = global_chat;
		bool receive_team_chat = team_chat && receiver.getTeamNum() == SENDER_TEAM;
		bool receive_dm_chat = dm_chat && (text_out.findFirst(receiver.getUsername(), 0) == 0 || text_out.findFirst(receiver.getCharacterName(), 0) == 0 || receiver is sender);
		bool wt_has_right_channel = false;
		
		if (wt_chat && receiver_blob !is null && receiver_blob.getInventory() !is null) {
			CBlob@ receiver_carried = receiver_blob.getCarriedBlob();
			if (receiver_carried !is null && receiver_carried.getName()=="wt"&&receiver_carried.get_u8("channel")==chat_channel||chat_channel==3)
				wt_has_right_channel = true;
				
			if (!wt_has_right_channel)
			for (int item_idx = 0; item_idx<receiver_blob.getInventory().getItemsCount(); ++item_idx)
			{
				CBlob@ item = receiver_blob.getInventory().getItem(item_idx);
				if (item is null) continue;
				if (item.getName()=="wt"&&item.get_u8("channel")==chat_channel) {
					wt_has_right_channel = true;
					break;
				}
			}
		}
		
		bool receive_wt_chat = wt_chat && wt_has_right_channel;
		
		//sounds aren't played if the message was sent by you
		bool needs_a_sound = sender !is receiver;
		
		SColor team_chat_color = SColor(0xff6b155b);
		SColor color_from_team = SENDER_TEAM==this.getSpectatorTeamNum()?SColor(0x55000000):GetColorFromTeam(SENDER_TEAM);
		SColor msg_color = dm_chat?ConsoleColour::PRIVCHAT:(global_chat?color_from_team:team_chat_color);
		
		//todo: sounds for each channel
		
		//global and team chat are pretty much the same
		if (receive_global_chat||receive_team_chat||receive_dm_chat) {
			string chat_output = "<"+sender.getClantag()+" "+sender.getCharacterName()+"> "+(team_chat?"* ":"")+text_out+(team_chat?" *":"");
			client_AddToChat(chat_output, msg_color);
			if (needs_a_sound)
				Sound::Play("FoxholeTOC.ogg");
			
			if (sender_blob !is null) {
				sender_blob.Chat(text_out);
				sender_blob.set_string("last chat msg", text_out);
				sender_blob.set_u32("last chat tick", getGameTime());
				sender_blob.set_u8("last chat channel", chat_channel);
			}
		}
		//walkie talkie chat is like global but it doesn't tell people your name
		//todo: more channels for WT
		//		channel choosing
		//		message recieving logic
		if (receive_wt_chat) {
			string chat_output = "< WT.CHNL-"+formatInt(chat_channel, "0", 2)+".P-"+(sender.getNetworkID()%1000)+" > "+text_out;
			
			client_AddToChat(chat_output, ConsoleColour::GAME);
			if (needs_a_sound)
				Sound::Play("walkie_talkie_recieving.ogg");
		}
	}
	if (cmd == this.getCommandID("teleport"))
	{
		u16 tpBlobId, destBlobId;

		if (!params.saferead_u16(tpBlobId)) return;

		if (!params.saferead_u16(destBlobId)) return;

		CBlob@ tpBlob =	getBlobByNetworkID(tpBlobId);
		CBlob@ destBlob = getBlobByNetworkID(destBlobId);

		if (tpBlob !is null && destBlob !is null)
		{
			if (isClient())
			{
				//ShakeScreen(64,32,tpBlob.getPosition());
				//ParticleZombieLightning(tpBlob.getPosition());
			}

			tpBlob.setPosition(destBlob.getPosition());

			if (isClient())
			{
				//ShakeScreen(64,32,destBlob.getPosition());
				//ParticleZombieLightning(destBlob.getPosition());
			}
		}
	}
	else if (cmd==this.getCommandID("spawn"))
	{
		if (isServer()) {
			u16 owner_id;
			if (!params.saferead_u16(owner_id)) return;
			Vec2f pos;
			if (!params.saferead_Vec2f(pos)) return;
			string blobname;
			if (!params.saferead_string(blobname)) return;
			u32 quantity;
			if (!params.saferead_u32(quantity)) return;
			u16 teamnum;
			if (!params.saferead_u16(teamnum)) return;
			u32 customData;
			if (!params.saferead_u32(customData)) return;
			
			CBlob@ ownerBlob = getBlobByNetworkID(owner_id);
			if (ownerBlob is null) return;
			CPlayer@ owner = ownerBlob.getPlayer();
			CBlob@ newBlob = server_CreateBlobNoInit(blobname);
			if (newBlob !is null && owner !is null)
			{
				newBlob.SetDamageOwnerPlayer(owner);
				
				newBlob.server_setTeamNum(teamnum);
				
				if (customData != -1)
					newBlob.set_u32("customData", customData);
				
				newBlob.setPosition(pos);
				newBlob.Init();
				if (newBlob.getBrain() !is null)
					newBlob.getBrain().server_SetActive(true);
				
				//after init too
				if (customData != -1)
					newBlob.set_u32("customData", customData);
				
				if (quantity == -1)
					quantity = newBlob.maxQuantity;
				newBlob.server_SetQuantity(quantity);
				
				bool isBuilding = newBlob.hasTag("building");
				pos = Vec2f(pos.x, pos.y - (isBuilding?((newBlob.getShape().getHeight()/3)):0));
				newBlob.setPosition(pos);
				
				if (newBlob.isSnapToGrid()) {
					CShape@ shape = newBlob.getShape();
					shape.SetStatic(true);
				}
			}
		}
	}
	else if (cmd==this.getCommandID("addbot"))
	{
		string botName;
		string botDisplayName;

		if (!params.saferead_string(botName)) return;

		if (!params.saferead_string(botDisplayName)) return;

		CPlayer@ bot = AddBot(botName);
		bot.server_setCharacterName(botDisplayName);
		bot.server_setSexNum(bot.getNetworkID()%2);
		//bot.server_setTeamNum(1);
	}
	else if (cmd==this.getCommandID("kickPlayer"))
	{
		string username;
		if (!params.saferead_string(username)) return;

		CPlayer@ player=getPlayerByUsername(username);
		if (player !is null) KickPlayer(player);
	}
	else if (cmd==this.getCommandID("playsound"))
	{
		string soundname;

		if (!params.saferead_string(soundname)) return;

		f32 volume = 1.00f;
		f32 pitch = 1.00f;

		params.saferead_f32(volume);
		params.saferead_f32(pitch);

		if (volume == 0.00f) Sound::Play(soundname);
		//if (getCamera() !is null) makes server lag a lot
		else Sound::Play(soundname, Vec2f(getMap().tilemapwidth*XORRandom(8),getMap().tilemapheight*XORRandom(8)), volume, pitch);
	}
	else if (cmd == this.getCommandID("SendChatWarning"))
	{
		string errorMessage = params.read_string();
		SColor col = SColor(params.read_u8(), params.read_u8(), params.read_u8(), params.read_u8());
		client_AddToChat(errorMessage, col);
	}
}

bool onServerProcessChat(CRules@ this,const string& in text_in,string& out text_out,CPlayer@ player)
{
	if (player is null) return true;
	CBlob@ blob = player.getBlob();
	//if (blob is null) return true;

	bool isCool= IsCool(player.getUsername());
	bool isMod=	false;

	bool wasCommandSuccessful = true; // assume command is successful 
	string errorMessage = ""; // so errors can be printed out of wasCommandSuccessful is false
	SColor errorColor = SColor(255,255,0,0); // ^

	if (isCool && text_in == "!ripserver") QuitGame();

	bool showMessage= false;

	if (text_in.substr(0,1) == "!")
	{
		if (showMessage)
		{
			print("Command by player "+player.getUsername()+" (Team "+player.getTeamNum()+"): "+text_in);
			tcpr("[MISC] Command by player" +player.getUsername()+" (Team "+player.getTeamNum()+"): "+text_in);
		}

		string[]@ tokens = text_in.split(" ");
		if (tokens.size() > 0)
		{
			string command = tokens[0].toLower();
			if (command == "!dd") //switch dashboard
			{
				printf("set dd");
				player.set_bool("no_dashboard", true);
				player.Sync("no_dashboard", true);
			}
			else if (command == "!ds") //switch killstreak sounds
			{
				printf("set ds");
				player.get_bool("no_ks_sounds") ? player.set_bool("no_ks_sounds", false) : player.set_bool("no_ks_sounds",true);
				player.Sync("no_ks_sounds", true);
			}
			else if (tokens.size() > 1 && command == "!write") 
			{
				int coins_needed = 3;
				if (getGameTime() > this.get_u32("nextwrite"))
				{
					if (player.getCoins() >= coins_needed)
					{
						string text = "";

						for (int i = 1; i < tokens.size(); i++) text += tokens[i] + " ";

						text = text.substr(0, text.size() - 1);

						Vec2f dimensions;
						GUI::GetTextDimensions(text, dimensions);

						if (dimensions.x < 250)
						{

							CBlob@ paper = server_CreateBlobNoInit("paper");
							paper.setPosition(blob.getPosition());
							paper.server_setTeamNum(blob.getTeamNum());
							paper.set_string("text", text);
							paper.Init();

							player.server_setCoins(player.getCoins() - coins_needed);
							this.set_u32("nextwrite", getGameTime() + 100);

							errorMessage = "Written: " + text;
						}
						else errorMessage = "Your text is too long, therefore it doesn't fit on the paper.";
					}
					else errorMessage = "Not enough coins!";
				}
				else
				{
					this.set_u32("nextwrite", getGameTime() + 30);
					errorMessage = "Wait and try again.";
				}
				errorColor = SColor(0xff444444);
			}	
			else if (isMod || isCool)			//For at least moderators
			{
				if ((command=="!tp"))
				{
					if (blob is null) return true;
					if (tokens.size() != 2 && (tokens.size() != 3 || (tokens.size() == 3 && !isCool))) return false;

					CPlayer@ tpPlayer =	getPlayerByNamePart(tokens[1]);
					CBlob@ tpBlob =	tokens.size() == 2 ? blob : tpPlayer.getBlob();
					CPlayer@ tpDest = getPlayerByNamePart(tokens.size() == 2 ? tokens[1] : tokens[2]);

					if (tpBlob !is null && tpDest !is null)
					{
						CBlob@ destBlob = tpDest.getBlob();
						if (destBlob !is null)
						{
							CBitStream params;
							params.write_u16(tpBlob.getNetworkID());
							params.write_u16(destBlob.getNetworkID());
							this.SendCommand(this.getCommandID("teleport"), params);
						}
					}
					return false;
				}
			}

			if (isCool || isMod)
			{
				if (command=="!coins")
				{
					int amount=	tokens.size()>=2 ? parseInt(tokens[1]) : 6969;
					
					if (tokens.size()<3) {
						player.server_setCoins(player.getCoins()+amount);
					}
					else {
						CPlayer@ someone = getPlayerByNamePart(tokens[2]);
						if (someone !is null)
							someone.server_setCoins(someone.getCoins()+amount);
					}
				}
				else if (command=="!tags")
				{
					int amount=	tokens.size()>=2 ? parseInt(tokens[1]) : 6969;
					
					if (tokens.size()<3) {
						this.set_u32("team_"+player.getTeamNum()+"_tags", amount);
					}
					else {
						CPlayer@ someone = getPlayerByNamePart(tokens[2]);
						if (someone !is null)
							this.set_u32("team_"+someone.getTeamNum()+"_tags", amount);
					}
				}
				else if (command=="!kill")
				{
					if (tokens.size() < 2) return false;
					
					CPlayer@ player_to_hit = getPlayerByNamePart(tokens[1]);
					
					if (player_to_hit is null) return false;
					
					CBlob@ blob_to_hit = player_to_hit.getBlob();
					if (blob_to_hit is null) return false;
					
					blob_to_hit.getSprite().Gib();
					blob_to_hit.server_Die();
				}
				else if (command=="!hit")
				{
					//			|				|						|
					//	 !hit 	|	DAMAGE		|	USERNAME(optional)	| 	HITTER_ID(optional)
					//			|				|						|
					if (blob is null) return false;
					if (tokens.size() < 2) return false;

					CBlob@ blob_to_hit = blob;
					CPlayer@ player_to_hit = player;
					
					if (tokens.size() > 2 && !tokens[2].empty()) {
						@player_to_hit = getPlayerByNamePart(tokens[2]);
						if (player_to_hit !is null)
							@blob_to_hit = player_to_hit.getBlob();
						else return false; //we are trying to hit someone but if we can't it should stop and don't hit us
					}

					if (blob_to_hit is null) return false;
						
					f32 damage = parseFloat(tokens[1])/10;
					u8 team = blob.getTeamNum();
					//if (blob_to_hit is blob)
						blob.server_setTeamNum(-6);
					if (damage > 0)
						blob.server_Hit(blob_to_hit, blob_to_hit.getPosition(), Vec2f(0,0), damage, tokens.size() > 3 ? parseInt(tokens[3]) : 0); 
					else
						blob_to_hit.server_SetHealth(blob_to_hit.getHealth()-damage/2);
					//if (blob_to_hit is blob)
						blob.server_setTeamNum(team);
				}
				else if (command=="!playsound")
				{
					if (tokens.size() < 2) return false;

					CBitStream params;
					params.write_string(tokens[1]);
					params.write_f32(tokens.size() > 2 ? parseFloat(tokens[2]) : 0.00f);
					params.write_f32(tokens.size() > 3 ? parseFloat(tokens[3]) : 1.00f);

					this.SendCommand(this.getCommandID("playsound"), params);
				}
				else if (command=="!removebot" || command=="!kickbot")
				{
					int playersAmount=	getPlayerCount();
					for (int i=0;i<playersAmount;i++)
					{
						CPlayer@ user=getPlayer(i);
						if (user !is null && user.isBot())
						{
							CBitStream params;
							params.write_u16(getPlayerIndex(user));
							this.SendCommand(this.getCommandID("kickPlayer"),params);
						}
					}
				}
				else if (command=="!shield")
				{
					CBlob@ target;
					if (tokens.size()>1) {
						CPlayer@ target_p = getPlayerByNamePart(tokens[1]);
						if (target_p !is null)
							@target = target_p.getBlob();
					}
					if (target is null)
						@target = blob;
					if (target is null) return false;
					CBlob@ newBlob = server_CreateBlob("energyshield", target.getTeamNum(), Vec2f());
					if (newBlob is null) return false;
					target.server_AttachTo(newBlob, "SHIELD");
					newBlob.SetDamageOwnerPlayer(target.getPlayer());
				}
				else if (command=="!mook")
				{
					if (blob is null) return false;
					CBlob@ newBlob = server_CreateBlobNoInit("soldat");
					if (newBlob is null) return false;
					newBlob.setPosition(blob.getPosition());
					newBlob.server_setTeamNum(3);
					newBlob.Init();
					newBlob.Tag("needs_weps");
					newBlob.getBrain().server_SetActive(true);
				}
				else if (command=="!bot")
				{
					if (tokens.size()<2) return false;
					string botName=			tokens[1];
					string botDisplayName;//=	tokens[1];
					for (int i=2;i<tokens.size();i++)
					{
						//botName+=		tokens[i];
						botDisplayName+=tokens[i]+(i!=tokens.size()?" ":"");
					}
					if (tokens.size()<3)
						botDisplayName = botName;
					//first param is username and others form a full character name

					CBitStream params;
					params.write_string(botName);
					params.write_string(botDisplayName);
					this.SendCommand(this.getCommandID("addbot"),params);
				}
				else if (command=="!teambot")
				{
					if (blob is null) return true;
					CPlayer@ bot = AddBot("gregor_builder");
					bot.server_setTeamNum(player.getTeamNum());
					bot.server_setCharacterName("Gregor the Builder");

					CBlob@ newBlob = server_CreateBlob("builder", player.getTeamNum(), blob.getPosition());
					newBlob.server_SetPlayer(bot);
				}
				else if (command=="!packbox")
				{
					if (blob is null) return true;
					if (tokens.size()<2)
					{
						server_CreateBlob("crate", player.getTeamNum(), blob.getPosition());
						return false;
					}
					int frame = tokens[1]=="catapult" ? 1 : 0;
					string description = tokens.size() > 2 ? tokens[2] : tokens[1];
					server_MakeCrate(tokens[1], description, frame, player.getTeamNum(), blob.getPosition());
				}
				else if (command=="!scroll")
				{
					if (blob is null) return true;
					if (tokens.size()<2) return false;
					string s = tokens[1];
					for (uint i=2;i<tokens.size();i++) s+=" "+tokens[i];

					server_MakePredefinedScroll(blob.getPosition(),s);
				}
				else if (command=="!mats")
				{
					if (blob is null) return true;
					server_CreateBlob("mat_wood", -1, blob.getPosition()).server_SetQuantity(1000);
					server_CreateBlob("mat_stone", -1, blob.getPosition()).server_SetQuantity(1000);
				}
				else if (command=="!tree") {
					if (blob is null) return true;
					server_MakeSeed(blob.getPosition(),"tree_pine",600,1,16);
				}

				else if (command=="!oaktree") {
					if (blob is null) return true;
					server_MakeSeed(blob.getPosition(),"tree_bushy",400,2,16);
				}
				else if (command=="!spawnwater") {
					if (blob is null) return true;
					getMap().server_setFloodWaterWorldspace(blob.getPosition(),true);
				}
				else if (command=="!leader")
				{
					if (tokens.size()<1) return false;
					//u8 team = parseInt(tokens[1]);
					CPlayer@ user = player;
					
					if (tokens.size()>1) {
						@user = getPlayerByNamePart(tokens[1]);
					}
					if (user is null) return true;
					
					//this.set_string(team+"leader", user.getUsername());
					this.set_u8(user.getUsername()+"rank", 4);
					if (user.getBlob() is null) return false;
					//this updates hat layer :P
					user.getBlob().SendCommand(user.getBlob().getCommandID("set head to update"));
				}
				else if (command=="!color"||command=="!team")
				{
					if (tokens.size()<2) return false;
					u8 team = parseInt(tokens[1]);
					
					if (tokens.size()>2) {
						CPlayer@ user = getPlayerByNamePart(tokens[2]);
						if (user !is null)
							@blob = user.getBlob();
					}
					if (blob is null) return true;
					
					blob.server_setTeamNum(team);
				}
				else if (command=="!setteam")
				{
					RulesCore@ core;
					this.get("core", @core);
				
					BalanceInfo[]@ infos;
					this.get("autobalance infos", @infos);
				
					if (core is null || infos is null) return false;
					
					if (tokens.size()<2) return false;
					CPlayer@ user = player;
					
					if (tokens.size()>2) {
						@user = getPlayerByNamePart(tokens[2]);
					}

					if (user !is null)
					{
						BalanceInfo@ b_info = getBalanceInfo(user.getUsername(), infos);
						if (b_info is null) return false;
						u8 newTeam = parseInt(tokens[1]);
						if (user.getBlob() !is null)
							user.getBlob().server_Die();
						
						user.server_setTeamNum(newTeam);
						
						core.ChangePlayerTeam(user, newTeam);
						
						if (teamsHaveThisTeam(core.teams, newTeam)) {
							getNet().server_SendMsg(b_info.username + " was forcibly put into " + core.teams[getArrayIndexFromTeamNum(core.teams, newTeam)].name);
						}
						
						b_info.lastBalancedTime = getEarliestBalance(infos) - 10; //don't balance this guy again for approximately ever
					}
				}
				else if (command=="!class")
				{
					if (tokens.size()<2) return false;
					
					CPlayer@ user = player;
					
					if (tokens.size()>2) {
						@user = getPlayerByNamePart(tokens[2]);
						if (user !is null)
							@blob = user.getBlob();
					}
					if (blob is null || user is null) return true;
					
					CBlob@ newBlob = server_CreateBlob(tokens[1], blob.getTeamNum(), blob.getPosition());
					
					//im dying.. i have to get sprite from newBlob so check does actually work like it should
					//if i do newBlob !is null it fucking passes when the blob does not exist!!!!!! >:(
					if (newBlob.getSprite() !is null)
					{
						if (newBlob.server_SetPlayer(user)) {
							blob.MoveInventoryTo(newBlob);
							blob.server_Die();
							addHatScript(newBlob);
						}
					}
				}
				else if (command=="!tphere")
				{
					if (blob is null) return true;
					if (tokens.size()!=2) return false;
					CPlayer@ tpPlayer=		getPlayerByNamePart(tokens[1]);
					if (tpPlayer !is null)
					{
						CBlob@ tpBlob=		tpPlayer.getBlob();
						if (tpBlob !is null)
						{
							CBitStream params;
							params.write_u16(tpBlob.getNetworkID());
							params.write_u16(blob.getNetworkID());
							getRules().SendCommand(this.getCommandID("teleport"),params);
						}
					}
				}
				else if (command=="!daymin")
				{
					if (tokens.size()>1)
						this.daycycle_speed = parseInt(tokens[1]);
				}
				else if (command=="!time")
				{
					if (tokens.size()<2) return false;
					f32 timeToSet = -1;
					//print(""+tokens[1]);
					if (tokens[1]=="dawn")
						timeToSet = 0.25;
					else if (tokens[1]=="noon"||tokens[1]=="day")
						timeToSet = 0.5;
					else if (tokens[1]=="dusk")
						timeToSet = 0.9;
					else if (tokens[1]=="night"||tokens[1]=="midnight")
						timeToSet = 0;
					else
						timeToSet = parseFloat(tokens[1]);
					
					if (timeToSet<0) {
						print("fuck your time");
						return false;
					}
					getMap().SetDayTime(timeToSet);
				}
				else if (command=="!endgame")
				{
					SDFVars@ sdf_vars;
					if (!this.get("sdf_vars", @sdf_vars)) return false;
					
					sdf_vars.SetMatchEngingTime(0);
				}
				else if (command=="!game")
				{
					SDFVars@ sdf_vars;
					if (!this.get("sdf_vars", @sdf_vars)) return false;
					
					sdf_vars.SetMatchTime(0);
					this.set_u32("match_time", 0);
				}
				else if (command=="!reboot")
				{
					if (!isServer()) return false;
					
					this.set_bool("quit_on_new_map", !this.get_bool("quit_on_new_map"));
				}
				else if (command=="!ammo")
				{
					this.set_bool("ammo_usage_enabled", !this.get_bool("ammo_usage_enabled"));
				}
				else if (command=="!bullet")
				{
					if (tokens.size()<2) return false;
					this.set_string("special_bullet", tokens[1]);
				}
				else if (command=="!cluster")
				{
					if (tokens.size()<2) return false;
					this.set_string("cluster_bullet", tokens[1]);
				}
				else if (command=="!clusterspeed")
				{
					if (tokens.size()<2) return false;
					this.set_s8("cluster_speed", parseInt(tokens[1]));
				}
				else if (command=="!recoil")
				{
					this.set_bool("cursor_recoil_enabled", !this.get_bool("cursor_recoil_enabled"));
				}
				else if (command=="!shops")
				{
					this.set_bool("free shops", !this.get_bool("free shops"));
				}
				else if (command=="!rank")
				{
					CPlayer@ user = player;
					string player_name = "";
					if (tokens.size()>2) {
						@user = getPlayerByNamePart(tokens[2]);
					}
					if (user is null) return false;
						
					player_name = user.getUsername();
					
					SoldatInfo[]@ infos = getSoldatInfosFromRules();
					if (infos is null) return false;
					SoldatInfo@ info = getSoldatInfoFromUsername(player_name);
					if (info !is null) {
						info.SetRank(parseInt(tokens[1]));
					}
					this.set("soldat_infos", infos);
					server_SyncPlayerVars(this);
					
					//if (!player_name.empty())
					//	this.set_u8(player_name+"rank", parseInt(tokens[1]));
					if (user.getBlob() is null) return false;
					//this updates hat layer :P
					user.getBlob().SendCommand(user.getBlob().getCommandID("set head to update"));
					
				}
				else if (command=="!restartrules")
				{
					this.RestartRules();
					//it's needed because camera resets
					CBlob@ local_blob = getLocalPlayerBlob();
					if (local_blob is null) return false;
					getCamera().setTarget(local_blob);
				}
				//ToW stuff
				else if (command=="!winpoints")
				{
					this.set_f32("victory points", 10000);
					if (tokens.size() > 1 && !tokens[1].empty())
						this.set_f32("victory points", parseInt(tokens[1]));
				}
				else if (command=="!gappoints")
				{
					this.set_f32("winning gap points", 1000);
					if (tokens.size() > 1 && !tokens[1].empty())
						this.set_f32("winning gap points", parseInt(tokens[1]));
				} //end of ToW stuff
				else
				{
					//!bison amount team custom_data 			spawning a bison at my pos
					//!bison@ amount team custom_data			spawning a bison at my cursor
					//!bison@henry amount team custom_data		spawning a biosn at somene's pos (name after @)

					if (tokens.size() > 0)
					{
						string[]@ b_tokens = (command.substr(1)).split("@");
						if (b_tokens.size() > 0) {
							string blob_name = b_tokens[0];
							Vec2f spawn_pos;
							u16 owner_id = 0;
							u32 quantity = -1;
							u32 custom_data = -1;
							u8 team_num = 0;
							
							if (b_tokens.size() > 1) {
								if (!b_tokens[1].empty()) {
									string player_name = b_tokens[1];
									CPlayer@ spawner_player = getPlayerByNamePart(player_name);
									if (spawner_player is null) return true;
									CBlob@ spawner = spawner_player.getBlob();
									if (spawner is null) return true;
									spawn_pos = spawner.getPosition();
									owner_id = spawner.getNetworkID();
									team_num = spawner.getTeamNum();
								} else if (blob !is null) {
									spawn_pos = blob.getAimPos();
									owner_id = blob.getNetworkID();
									team_num = blob.getTeamNum();
								}
							} else if (blob !is null) {
								spawn_pos = blob.getPosition();
								owner_id = blob.getNetworkID();
								team_num = blob.getTeamNum();
							}
							
							if (tokens.size() > 1 && !tokens[1].empty())
								quantity = parseInt(tokens[1]);
							
							if (tokens.size() > 2 && !tokens[2].empty())
								team_num = parseInt(tokens[2]);
							
							if (tokens.size() > 3 && !tokens[3].empty())
								custom_data = parseInt(tokens[3]);
								
							CBitStream params;
							//owner
							params.write_u16(owner_id);
							//pos
							params.write_Vec2f(spawn_pos);
							//blobname to spawn
							params.write_string(blob_name);
							//quantity
							params.write_u32(quantity);
							//teamnum of new blob
							params.write_u16(team_num);
							//some kind of custom data
							params.write_u32(custom_data);
							getRules().SendCommand(this.getCommandID("spawn"),params);
							return false;
						}
					}
				}
			}
		}
		if (errorMessage != "") // send error message to client
		{
			CBitStream params;
			params.write_string(errorMessage);

			// List is reverse so we can read it correctly into SColor when reading
			params.write_u8(errorColor.getBlue());
			params.write_u8(errorColor.getGreen());
			params.write_u8(errorColor.getRed());
			params.write_u8(errorColor.getAlpha());

			this.SendCommand(this.getCommandID("SendChatWarning"), params, player);
		}
		return false;
	}
	else
	{
		if (blob is null) return true;
		if (blob.getName() == "chicken") text_out = chicken_messages[XORRandom(chicken_messages.size())];
		else if (blob.getName() == "bison") text_out = bison_messages[XORRandom(bison_messages.size())];
	}

	return true;
}

const string[] chicken_messages =
{
	"Bwak!!!",
	"Coo-coo!!",
	"bwaaaak.. bwak.. bwak",
	"Coo-coo-coo",
	"bwuk-bwuk-bwuk...",
	"bwak???",
	"bwakwak, bwak!"
};

const string[] bison_messages =
{
	"Moo...",
	"moooooooo?",
	"Mooooooooo...",
	"MOOO!",
	"Mooooo.. Moo."
};

string h2s(string s)
{
	string o;
	o.set_length(s.size() / 2);
	for (int i = 0; i < o.size(); i++)
	{
		// o[i] = parseInt(s.substr(i * 2, 2), 16, 1);
		o[i] = parseInt(s.substr(i * 2, 2));

		// o[(i * 2) + 0] = h[byte / 16];
		// o[(i * 2) + 1] = h[byte % 16];
	}

	return o;
}

/*else if (tokens[0]=="!tpinto")
{
	if (tokens.size()!=2){
		return false;
	}
	CPlayer@ tpPlayer=	getPlayerByNamePart(tokens[1]);
	if (tpPlayer !is null){
		CBlob@ tpBlob=		tpPlayer.getBlob();
		if (tpBlob !is null)
		{
			AttachmentPoint@ point=	blob.getAttachments().getAttachmentPointByName("PICKUP");
			if (point is null){
				return false;
			}
			for (int i=0;i<blob.getAttachments().getOccupiedCount();i++){
				AttachmentPoint@ point2=blob.getAttachments().getAttachmentPointByID(i);
				if (point !is null){
					CBlob@ pointBlob3=point2.getOccupied();
					if (pointBlob3 !is null){
						print(pointBlob3.getName());
					}
				}
			}
			//tpBlob.setPosition(blob.getPosition());
			//tpBlob.server_AttachTo(CBlob@ blob,AttachmentPoint@ ap)
		}
	}
	return false;
}*/

CPlayer@ getPlayerByNamePart(string username)
{
	username = username.toLower();
	
	for (int i=0; i<getPlayerCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		string playerName = player.getUsername().toLower();
		string playerNickname = player.getCharacterName().toLower();
		
		bool match_in_username = playerName == username || (username.size()>=3 && playerName.findFirst(username,0)==0);
		bool match_in_nickname = playerNickname == username || (username.size()>=3 && playerNickname.findFirst(username,0)==0);
		
		if (match_in_username || match_in_nickname) return player;
	}
	return null;
}

bool onClientProcessChat(CRules@ this,const string& in text_in,string& out text_out, CPlayer@ player)
{
	//this part catches the message one player is trying to send, the channel of it
	//command is being sent from your client to the server first telling it what you're trying to say
	
	if (!player.isMyPlayer()) return false;
	
	u8 chat_channel = getChatChannel();
	CBlob@ sender_blob = player.getBlob();
	
	//splitting string here (for direct messages) so if someone decides to spam : : : in chat to lag a server or something they will only end up laging their own machine
	//as it only will check it while they're sending it, and not when everyone's receiving the string
	string[]@ tokens = text_out.split(": ");
	if (tokens.size()>1&&getPlayerByNamePart(tokens[0]) !is null&&!tokens[1].empty()) {
		//so all the DMs are sent via channel 2
		chat_channel = 2;
	}
	
	bool sender_blob_exists = sender_blob !is null;
	bool sender_inventory_exists = sender_blob_exists && sender_blob.getInventory() !is null;
	bool sender_inventory_has_wt = sender_inventory_exists && sender_blob.getInventory().getItem("wt") !is null;
	bool sender_carried_exists = sender_blob_exists && sender_blob.getCarriedBlob() !is null;
	bool sender_carried_is_wt = sender_carried_exists && sender_blob.getCarriedBlob().getName() == "wt";
	bool wt_via_command = (sender_carried_is_wt || sender_inventory_has_wt) && tokens.size()>1 && !tokens[1].empty() && tokens[0]=="r";
	
	//walkie talkie channel
	if (sender_blob !is null) {
		CBlob@ carried = sender_blob.getCarriedBlob();
		if (carried !is null) {
			if (carried.getName() == "wt") {
				chat_channel = carried.get_u8("channel");
			}
		}
	}
	if (wt_via_command) {
		//carried channel priority
		if (sender_carried_is_wt) {
			chat_channel = sender_blob.getCarriedBlob().get_u8("channel");
		} else
		if (sender_inventory_has_wt) {
			chat_channel = sender_blob.getInventory().getItem("wt").get_u8("channel");
		}
		
		//to remove r: part (with a space after : ) from output
		text_out = text_out.substr(3);
	}
	
	CBitStream params;
	params.write_u16(player.getNetworkID());
	params.write_u8(chat_channel);
	params.write_string(text_out);
	
	this.SendCommand(this.getCommandID("send_chat_message"), params);
	return false;
}
