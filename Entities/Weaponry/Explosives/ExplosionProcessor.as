#include "Explosion"
#include "CExplosion"

void onTick(CRules@ this)
{
	if (!isServer()) return;
	
    Holder@ holder;
    if (!this.get("explosion processor", @holder)) return;
	
	if (holder.list.size()<1) return;
	
	if (getGameTime()%120==0)
		print("got there and size is "+holder.list.size());
	
	const u32 TIME = getGameTime();
	
	for (int blast_id = 0; blast_id < holder.list.size(); ++blast_id) {
		CExplosion@ boom = holder.list[blast_id];
		if (boom is null) continue;
		if (TIME < boom.time) continue;
		else if (TIME > boom.time) {
			RemoveFromProcessor(blast_id);
			continue;
		}
		print("owner id "+boom.owner_id);
		
		CBitStream params;
		params.write_u16(boom.owner_id);
		print("BOOM\n\n");
		this.SendCommand(this.getCommandID("make explosion"), params);
		
		RemoveFromProcessor(blast_id);
	}
}

void onCommand( CRules@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("make explosion")) {
		u16 owner_id; if(!params.saferead_u16(owner_id)) return;
		CBlob@ hitter = getBlobByNetworkID(owner_id);
		if (hitter is null) return;
		
		Explode(hitter, hitter.get_f32("explosion blob radius"), 16.0f);
		
		hitter.server_Die();
	}
}

void onInit(CRules@ this)
{
    Holder holder;
    this.set("explosion processor", holder);
	
	this.addCommandID("make explosion");
}