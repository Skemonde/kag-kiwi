#include "RunnerCommon.as"
#include "SocialStatus.as"

// Made by GoldenGuy 

void onInit(CInventory@ this)
{
	CBlob@ blob = this.getBlob();
	blob.addCommandID("cheat_reqs");
	blob.addCommandID("editor_mode");
	blob.addCommandID("godmode");
}

const u8 GRID_SIZE = 48;
const u8 GRID_PADDING = 12;

void onCreateInventoryMenu(CInventory@ this, CBlob@ forBlob, CGridMenu@ gridmenu)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	if (blob.getPlayer() is null || !blob.isMyPlayer() ) return;
	CPlayer@ player = getLocalPlayer();
	if (player is null) return;
	if (!IsCool(player.getUsername())) return;
	//if (player.getUsername()!="TheCustomerMan") return;
	
	Vec2f dashboard_dims(1, 1);
	Vec2f dashboard_pos = Vec2f(gridmenu.getLowerRightPosition().x+dashboard_dims.x*GRID_SIZE/2+GRID_PADDING+GRID_SIZE*3, gridmenu.getUpperLeftPosition().y+dashboard_dims.y*GRID_SIZE/2);
	
	CGridMenu@ cheat_dashboard = CreateGridMenu(dashboard_pos, blob, dashboard_dims, "SUS?");
	
	if (cheat_dashboard is null) return;
	
	cheat_dashboard.SetCaptionEnabled(false);
	cheat_dashboard.deleteAfterClick = false;

	CBitStream params;
	params.Clear();
	
	CGridButton@ reqs_b = cheat_dashboard.AddButton("", 0, Vec2f(16, 16), "", blob.getCommandID("cheat_reqs"), Vec2f(1, 1), params);
	if(reqs_b is null) return;
	reqs_b.SetHoverText("Make all shop items "+(blob.hasTag("cheater")?"paid":"free"));
	return;
	CGridButton@ god_b = cheat_dashboard.AddButton("", 0, Vec2f(16, 16), "", blob.getCommandID("godmode"), Vec2f(1, 1), params);
	if(god_b is null) return;
	god_b.SetHoverText("Become "+(blob.hasTag("invincible")?"human":"god"));
}

void tryToClearMenus(CBlob@ local, CBlob@ blob)
{
	if (local is blob && isClient()) {
		blob.ClearMenus();
	}
}

void onCommand(CInventory@ this, u8 cmd, CBitStream@ params)
{
	CBlob@ local = getLocalPlayerBlob();
	CBlob@ blob = this.getBlob();
		
	if (cmd == blob.getCommandID("cheat_reqs"))
	{
		if(blob.hasTag("cheater")) {
			blob.Untag("cheater");
		}
		else {
			blob.Tag("cheater");
		}
		tryToClearMenus(local, blob);
	}
	else if (cmd == blob.getCommandID("godmode"))
	{
		if(blob.hasTag("invincible")) {
			blob.RemoveScript("IgnoreDamage.as");
			blob.Untag("invincible");
		}
		else {
			blob.AddScript("IgnoreDamage.as");
		}
		tryToClearMenus(local, blob);
	}
}