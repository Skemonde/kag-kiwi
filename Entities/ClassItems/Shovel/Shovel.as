#include "KIWI_Locales"
#include "KIWI_Hitters"
#include "MaterialCommon"

void onInit(CBlob@ this)
{
	this.setInventoryName("M53 Shovel");
	this.addCommandID("make_slash");
}

void onTick(CBlob@ this)
{
	AttachmentPoint@ pickup_point = this.getAttachments().getAttachmentPointByName("PICKUP");
	CBlob@ holder = pickup_point.getOccupied();
	
	bool sub_gun = this.exists("gun_id");
	
	if (sub_gun)
	{
		CBlob@ main_gun = getBlobByNetworkID(this.get_u16("gun_id"));
		if (main_gun !is null && main_gun.isAttachedTo(this))
		{
			AttachmentPoint@ main_gun_pickup_ap = main_gun.getAttachments().getAttachmentPointByName("PICKUP");
			if (main_gun_pickup_ap.getOccupied() !is null)
			{
				//print("hey "+this.getName());
				@holder = main_gun_pickup_ap.getOccupied();
			}
		}
		else
		{
			this.clear("gun_id");
		}
	}
	
	if (holder is null) return;
	
	bool lmb_auto = holder.isKeyPressed(key_action1)&&!sub_gun;
	bool rmb_auto = holder.isKeyPressed(key_action2)&&sub_gun;
	u32 time_from_last_slash = getGameTime()-this.get_u32("last_slash");
	bool can_slash_again = time_from_last_slash>19;
	bool still_hitting = time_from_last_slash < 8;
	
	CSprite@ sprite = this.getSprite();
	
	f32 perc = 1.0f-1.0f*time_from_last_slash/6;
	if (time_from_last_slash<7)
		sprite.SetOffset(Vec2f(-5*perc, 0));
	else
		sprite.SetOffset(Vec2f(0, 0));
	
	if (!still_hitting&&this.hasTag("made_a_hit")) {
		this.Untag("made_a_hit");
		this.Sync("made_a_hit", true);		
	}
	
	if (isClient()&&((lmb_auto||rmb_auto)&&can_slash_again||still_hitting))
	{
		CBitStream params;
		params.write_u16(holder.getNetworkID());
		if (holder.isMyPlayer()&&!this.hasTag("made_a_hit"))
			this.SendCommand(this.getCommandID("make_slash"), params);
		
		if (!still_hitting) {
			this.set_u32("last_slash", getGameTime());
		}
	}
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2 )
{
	if (blob is null) return;
	if (!blob.hasTag("flesh")) return;
	if (blob.getTeamNum()==this.getTeamNum()) return;
	if (this.getVelocity().Length()<4) return;
	
	CPlayer@ owner = this.getDamageOwnerPlayer();
	CBlob@ owner_blob = owner.getBlob();
	CBlob@ hitter_blob = owner_blob is null ? blob : owner_blob;
	
	this.server_Hit(blob, point1, this.getVelocity(), Maths::Min(19.9f, this.getVelocity().Length()*1.5f), HittersKIWI::shovel, true);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params) 
{
	if(cmd == this.getCommandID("make_slash"))
	{
		CBlob@ holder = getBlobByNetworkID(params.read_netid());
		if (holder is null) return;
		
		const bool FLIP = this.isFacingLeft();
		const f32 FLIP_FACTOR = FLIP ? -1 : 1;
		const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
		
		f32 arc_angle = 50;
		f32 range = 20;
		f32 damage = 110;
		
		f32 angle = this.getAngleDegrees()+ANGLE_FLIP_FACTOR;
		Vec2f pos = this.getPosition();
		
		if (!isServer()) return;
		if (this.hasTag("made_a_hit")) return;
		
        HitInfo@[] hitInfos;
        CMap@ map = getMap();
        if (map.getHitInfosFromArc(pos, angle, arc_angle, range, holder, @hitInfos)) {
            for (int counter = 0; counter < hitInfos.length; ++counter) {
                CBlob@ doomed = hitInfos[counter].blob;
                if (doomed !is null) {
					if(holder.getTeamNum() == doomed.getTeamNum() && !doomed.hasTag("dummy") || /* doomed.hasTag("tree") || */ doomed.hasTag("invincible") || doomed.getName()=="sandbag") continue;
					
					bool fighting_undeads = doomed.hasTag("undead");
					bool intended_target = doomed.hasTag("player") || doomed.hasTag("dummy");
					
					if (true) {
						damage = 67;
					} else
					if (holder.getVelocity().y > 2.0f && intended_target) {
						damage = 160;
						//MakeBangEffect(doomed, "crit", 1.0f, false, Vec2f((XORRandom(10)-5) * 0.1, -(3/2)), Vec2f(XORRandom(11)-5,-XORRandom(4)-1));
					}
					
					if (doomed.hasTag("door"))
						damage/=40;
					
					holder.server_Hit(doomed, hitInfos[counter].hitpos, Vec2f(FLIP_FACTOR, 0), damage/10, HittersKIWI::shovel, true);
					Material::fromBlob(this, doomed, 0.5f, this);
					
					this.Tag("made_a_hit");
					
					if (doomed.hasTag("player"))
						break;
					else continue;
                } else {
					//tile hit
					this.Tag("made_a_hit");
					Vec2f hitpos = hitInfos[counter].hitpos;
					TileType tile_type = map.getTile(hitpos).type;
					if (false) {
						if (map.isTileWood(tile_type)) {
							map.server_DestroyTile(hitpos, 1.0f);
							break;
						}
					} else if (true) {
						if (map.isTileGroundStuff(tile_type)||map.isTileWood(tile_type)) {
							
							u8 times = 1;
							if (map.isTileWood(tile_type)) times = 3;
							for (int idx = 0; idx < times; ++idx)
							{
								map.server_DestroyTile(hitpos, 1.0f);
								Material::fromTile(holder, tile_type, 1.0f);
							}
							
							if (counter>0)// shovel hits 2 tiles
							{
								break;
							}
						}
					}
				}
            }
			this.Sync("made_a_hit", true);
        }
		//this.set_u32("last_slash", getGameTime());
	}
}