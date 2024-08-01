//#include "KIWI_Locales"
#include "KIWI_Hitters"
#include "MaterialCommon"

void onInit(CBlob@ this)
{
	//this.setInventoryName(Names::shovel);
	this.addCommandID("make_slash");
	this.addCommandID("make_slash_client");
}

bool isSubGun(CBlob@ this)
{
	if (!this.exists("gun_id")) return false;
	
	if (this.get_u16("gun_id")!=0) return true;
	
	return false;
	//return !this.exists("gun_id")||this.get_u16("gun_idx")==0;
}

void onTick(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	
	AttachmentPoint@ pickup_point = this.getAttachments().getAttachmentPointByName("PICKUP");
	CBlob@ holder = pickup_point.getOccupied();
	
	CSpriteLayer@ chop = sprite.getSpriteLayer("chop");
	if(chop !is null) {
		chop.SetVisible(false);
	}
	
	bool sub_gun = isSubGun(this);
	
	if (sub_gun)
	{
		CBlob@ main_gun = getBlobByNetworkID(this.get_u16("gun_id"));
		if (main_gun !is null)
		{
			AttachmentPoint@ main_gun_pickup_ap = main_gun.getAttachments().getAttachmentPointByName("PICKUP");
			CBlob@ occupied = main_gun_pickup_ap.getOccupied();
			if (occupied !is null)
			{
				//print("hey "+this.getName());
				if (occupied.isAttachedTo(this))
					@holder = occupied;
			}
		}
		else
		{
			this.clear("gun_id");
		}
	}
	
	if (holder is null) return;
	
	bool lmb_auto = holder.isKeyPressed(key_action1)&&!sub_gun;
	bool rmb_auto = holder.isKeyPressed(key_action3)&&sub_gun;
	u32 time_from_last_slash = getGameTime()-this.get_u32("last_slash");
	bool can_slash_again = time_from_last_slash > 19;
	bool still_hitting = time_from_last_slash < 5;
	
	f32 perc = 1.0f-1.0f*time_from_last_slash/6;
	if (time_from_last_slash<7&&!sub_gun)
		sprite.SetOffset(Vec2f(-5*perc, 0));
	else
		sprite.SetOffset(Vec2f(0, 0));
			
	if(chop != null)
	{
        chop.ResetTransform();//we don't change flash with any kickbacks so it's init right here
		chop.ScaleBy(1.4f, 0.3f);
		chop.SetOffset(sprite.getOffset()+Vec2f(7, -1));
		chop.SetVisible(true);
	}
	
	if (can_slash_again&&isServer()) {
		this.Untag("made_a_hit");
	}
	
	
	if (isClient()&&(still_hitting||((lmb_auto||rmb_auto)&&can_slash_again)))
	{
		CBitStream params;
		params.write_u16(holder.getNetworkID());
		params.write_bool(still_hitting);

		if (!still_hitting) {
			this.set_u32("last_slash", getGameTime());
			if (chop !is null) {
				chop.SetFrameIndex(0);
			}
			sprite.PlaySound("SwingHeavy"+(XORRandom(4)+1)+".ogg");
		}
		
		if (holder.isMyPlayer()) {
			this.SendCommand(this.getCommandID("make_slash"), params);
		}
	}
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	if (blob.hasTag("player"))
	{
		if (blob.getTeamNum()==this.getTeamNum()) return false;
		return this.getVelocity().Length()>3;
	}
	else
		return true;
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2 )
{
	if (blob is null) return;
	if (!blob.hasTag("flesh")) return;
	if (blob.getTeamNum()==this.getTeamNum()) return;
	if (this.getOldVelocity().Length()<4) return;
	
	CPlayer@ owner = this.getDamageOwnerPlayer();
	CBlob@ owner_blob = owner.getBlob();
	CBlob@ hitter_blob = owner_blob is null ? blob : owner_blob;
	
	this.server_Hit(blob, point1, this.getOldVelocity(), this.getOldVelocity().Length()*0.75f+Maths::Max(0, this.getAirTime()-30), HittersKIWI::bayonet, true);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params) 
{
	if(cmd == this.getCommandID("make_slash_client"))
	{
		if (!isClient()) return;
		
		bool made_it; if (!params.saferead_bool(made_it)) return;
		bool flesh_hit; if (!params.saferead_bool(flesh_hit)) return;
	}
	if(cmd == this.getCommandID("make_slash"))
	{
		CBlob@ holder = getBlobByNetworkID(params.read_netid());
		if (holder is null) return;
		CBlob@ carried = holder.getCarriedBlob();
		if (carried is null) return;
		
		bool non_commanded_hit = params.read_bool();
		
		if (!non_commanded_hit)
			this.set_u32("last_slash", getGameTime());
		
		const bool FLIP = this.isFacingLeft();
		const f32 FLIP_FACTOR = FLIP ? -1 : 1;
		const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
		
		f32 arc_angle = 20;
		f32 range = 24;
		f32 damage = 40;
		
		bool is_subwep = this.isAttached() && this.getAttachments().getAttachmentPointByName("PICKUP").getOccupied() is null;
		
		f32 angle = this.getAngleDegrees()+ANGLE_FLIP_FACTOR;
		Vec2f pos = carried.getPosition();
		if (is_subwep)
		{
			//pos += -Vec2f(16, 2*FLIP_FACTOR).RotateBy(angle);
			range += 16;
		}

		if (this.hasTag("made_a_hit")) return;
		//this.set_u32("last_slash", getGameTime());
		
        HitInfo@[] hitInfos;
        CMap@ map = getMap();
        if (map.getHitInfosFromArc(pos, angle, arc_angle, range, holder, @hitInfos)) {
            for (int counter = 0; counter < hitInfos.length; ++counter) {
                CBlob@ doomed = hitInfos[counter].blob;
                if (doomed !is null) {
					if(holder.getTeamNum() == doomed.getTeamNum() && !doomed.hasTag("dummy") || /* doomed.hasTag("tree") || */ doomed.hasTag("invincible")) continue;
					
					bool fighting_undeads = doomed.hasTag("undead");
					bool intended_target = doomed.hasTag("player") || doomed.hasTag("dummy");
					
					if (doomed.hasTag("door")&&doomed.hasTag("steel"))
						damage/=40;
					
					holder.server_Hit(doomed, hitInfos[counter].hitpos, Vec2f(FLIP_FACTOR, 0), damage/10, HittersKIWI::shovel, true);
					//Material::fromBlob(this, doomed, 0.5f, this);
					
					this.Tag("made_a_hit");
					CBitStream param_hit;
					param_hit.write_bool(true);
					param_hit.write_bool(true);
					//this.SendCommand(this.getCommandID("make_slash_client"), param_hit);
					
					if (doomed.hasTag("player"))
						break;
					else continue;
                } else {
					//tile hit
					this.Tag("made_a_hit");
					CBitStream param_hit;
					param_hit.write_bool(true);
					param_hit.write_bool(false);
					//this.SendCommand(this.getCommandID("make_slash_client"), param_hit);
					Vec2f hitpos = hitInfos[counter].hitpos;
					TileType tile_type = map.getTile(hitpos).type;
					if (false) {
						if (map.isTileWood(tile_type)) {
							map.server_DestroyTile(hitpos, 1.0f);
							break;
						}
					} else if (true) {
						if (map.isTileGroundStuff(tile_type)||map.isTileWood(tile_type)) {
							
							u8 times = 2;
							if (map.isTileWood(tile_type)) times = 3;
							for (int idx = 0; idx < times; ++idx)
							{
								Material::fromTile(holder, map.getTile(hitpos).type, 1.0f);
								map.server_DestroyTile(hitpos, 1.0f);
							}
							
							if (counter>0)// shovel hits 2 tiles
							{
								break;
							}
						}
					}
				}
            }
        }
	}
}