#include "FirearmVars"
#include "KIWI_Locales"
#include "MaterialCommon"
#include "MakeBangEffect"

void onInit(CBlob@ this)
{
	this.setInventoryName("Officer Saber");
	this.Tag("melee");
	this.set_u8("alt_fire_item", AltFire::Bayonet);
	this.set_u16("alt_fire_interval", 20);
	
	
	FirearmVars vars = FirearmVars();
	vars.B_HITTER					= HittersKIWI::bayonet;
	this.set("firearm_vars", @vars);
	
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (point is null) return;
	this.set_Vec2f("default_pickup", point.offset);
    this.addCommandID("make_slash");
	
	CSprite@ sprite = this.getSprite();
	
	CSpriteLayer@ chop = sprite.addSpriteLayer("chop", "KnightMale.png", 32, 32, 0, 0);
	if (chop !is null)
	{
		Animation@ anim = chop.addAnimation("default", 2, false);
		anim.AddFrame(35);
		anim.AddFrame(43);
		anim.AddFrame(63);
		anim.AddFrame(20);
		chop.SetVisible(false);
		chop.SetRelativeZ(1000.0f);
	}
}

void onTick(CBlob@ this)
{
	if (this.get_u32("timer") > 0)
		this.sub_u32("timer", 1);
		
	//print("timer "+this.get_u32("timer"));
		
	CSprite@ sprite = this.getSprite();
	const bool FLIP = this.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (point is null) return;
	//point.offsetZ = -302;
	CBlob@ holder = point.getOccupied();
	if (holder is null) return;
	
	f32 aimangle = getAimAngle(this,holder), sprite_angle = 0;
	
	bool can_slash = this.get_u32("timer") < 1;
	bool slashing = this.get_u32("timer") > 20;
	
	this.server_DetachFrom(holder);
	
	AttachmentPoint@ holder_point = holder.getAttachments().getAttachmentPointByName("PICKUP");
	holder_point.offsetZ = slashing?0:-3;
	
	Vec2f shoulder_joint = Vec2f(3, 0);
	//shoulder_joint += Vec2f(-this.get_Vec2f("gun_trans_from_carrier").x, this.get_Vec2f("gun_trans_from_carrier").y);
	point.offset = (Vec2f(this.get_Vec2f("default_pickup").y, this.get_Vec2f("default_pickup").x*(slashing?-1:1))+Vec2f(3, -this.get_Vec2f("gun_trans_from_carrier").y)).RotateBy(
		slashing?180+aimangle*FLIP_FACTOR:20, shoulder_joint);
	
	//this.getSprite().SetZ(point.offsetZ);
	holder.server_AttachTo(this, "PICKUP");
	
	CBitStream params;
	params.write_netid(holder.getNetworkID());
	params.write_f32(aimangle-90*FLIP_FACTOR*0);
	params.write_Vec2f(this.getPosition()+holder.getVelocity());
	params.write_f32(32);
	params.write_f32(5*getMap().tilesize);
	
	if (this.get_u32("timer") == 28) this.SendCommand(this.getCommandID("make_slash"), params);
	
	if (holder.isMyPlayer()&&holder.isKeyPressed(key_action1)&&can_slash) {
		this.set_u32("timer", 30);
	}
		
	CSpriteLayer@ chop = sprite.getSpriteLayer("chop");
	if (chop !is null && this.get_u32("timer") == 29) chop.SetFrameIndex(0);
	if(chop !is null) {
		chop.SetVisible(false);
	}
	if(chop != null){
        chop.ResetTransform();//we don't change flash with any kickbacks so it's init right here
		chop.ScaleBy(1.4f, 0.4f);
		chop.SetFacingLeft(!FLIP);
		chop.TranslateBy(Vec2f(-20*FLIP_FACTOR, 0));
		chop.SetVisible(true);
    }
	
	this.setAngleDegrees(slashing?-180+aimangle-90*FLIP_FACTOR:((-200)*FLIP_FACTOR+(holder.getAngleDegrees())));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params) 
{
	FirearmVars@ vars;
	if (!this.get("firearm_vars", @vars)) return;
	
	const bool FLIP = this.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	if(cmd == this.getCommandID("make_slash"))
	{
		CBlob@ holder = getBlobByNetworkID(params.read_netid());
		if (holder is null) return;
		f32 aimangle = params.read_f32();
		Vec2f pos = params.read_Vec2f();
		f32 arc_angle = params.read_f32();
		f32 range = params.read_f32();
		f32 damage = 110;
		
		if(!isServer()) return;
		
        HitInfo@[] hitInfos;
		u16[] TargetsPierced;
        CMap@ map = getMap();
        if (map.getHitInfosFromArc(pos, aimangle+ANGLE_FLIP_FACTOR, arc_angle, range, holder, @hitInfos)) {
            for (int counter = 0; counter < hitInfos.length; ++counter) {
                CBlob@ doomed = hitInfos[counter].blob;
                if (doomed !is null && TargetsPierced.find(doomed.getNetworkID()) <= -1) {
					if(holder.getTeamNum() == doomed.getTeamNum() && !doomed.hasTag("dummy") || doomed.hasTag("vehicle") || doomed.hasTag("tree") || doomed.hasTag("invincible") || doomed.getName()=="sandbag") continue;
					
					bool fighting_undeads = doomed.hasTag("undead");
					bool intended_target = doomed.hasTag("player") || doomed.hasTag("dummy");
					
					if (vars.B_HITTER==HittersKIWI::shovel) {
						damage = 25;
					} else
					if (holder.getVelocity().y > 2.0f && intended_target) {
						//print("vel y "+holder.getVelocity().y);
						damage = 160;
						MakeBangEffect(doomed, "crit", 1.0f, false, Vec2f((XORRandom(10)-5) * 0.1, -(3/2)), Vec2f(XORRandom(11)-5,-XORRandom(4)-1));
					}
					
					holder.server_Hit(doomed, hitInfos[counter].hitpos, Vec2f_zero, damage/10, HittersKIWI::bayonet, true);
					this.set_u32("last_shot_time", getGameTime());
					TargetsPierced.push_back(doomed.getNetworkID());
					//print("making slash hit");
					if (doomed.hasTag("player")) break;
					else continue;
                    //holder.server_Hit(doomed, doomed.getPosition(), Vec2f_zero, damage/10, HittersKIWI::bayonet, true);
					//print("hellow from 'for'");
                } else {
					//tile hit
					Vec2f hitpos = hitInfos[counter].hitpos;
					TileType tile_type = map.getTile(hitpos).type;
					if (vars.B_HITTER==HittersKIWI::bayonet) {
						if (map.isTileWood(tile_type)) {
							map.server_DestroyTile(hitpos, 1.0f);
							break;
						}
					} else if (vars.B_HITTER==HittersKIWI::shovel) {
						if (map.isTileGroundStuff(tile_type)||map.isTileWood(tile_type)) {
							map.server_DestroyTile(hitpos, 1.0f);
							Material::fromTile(holder, tile_type, 1.0f);
							if (counter>0)// shovel hits 2 tiles
								break;
						}
					}
					//break;
				}
            }
        }
	}
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	bool slashing = this.get_u32("timer") > 20;
	if (slashing) return;
	AttachmentPoint@ holder_point = attached.getAttachments().getAttachmentPointByName("PICKUP");
	holder_point.offsetZ = -3;
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{
	bool slashing = this.get_u32("timer") > 20;
	if (slashing) return;
	AttachmentPoint@ holder_point = detached.getAttachments().getAttachmentPointByName("PICKUP");
	holder_point.offsetZ = 0;
}