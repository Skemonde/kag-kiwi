#include "FirearmVars"

void onInit(CBlob@ this)
{
	this.getShape().SetGravityScale(0.0f);
	this.getShape().SetStatic(true);
	this.server_SetTimeToDie(15);
    this.addCommandID("make_hit_particle");
	
	this.Tag("firearm");
}

void onTick(CBlob@ this)
{
	if (!isServer()) return;
	if (this.hasTag("made_a_shot")) return;
	
	CPlayer@ owner = this.getDamageOwnerPlayer();
	CBlob@ owner_blob = owner is null ? null : owner.getBlob();
	u16 holder_id = owner_blob is null ? this.getNetworkID() : owner_blob.getNetworkID();
	holder_id = this.getNetworkID();
	
	shootGun(this.getNetworkID(), this.get_f32("angle"), holder_id, this.getPosition());
	this.Tag("made_a_shot");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params) 
{
	if(cmd == this.getCommandID("make_hit_particle"))
	{
		if (!isClient()) return;
		if (v_fastrender) return;
		
		Vec2f world_pos; if (!params.saferead_Vec2f(world_pos)) return;
		string file_name; if (!params.saferead_string(file_name)) return;
		
		if (!CFileMatcher(file_name).hasMatch())
			file_name = "smg_bullet_hit.png";
			
		CParticle@ b_hit = ParticleAnimated(file_name, world_pos, Vec2f_zero, XORRandom(360), 1.0f, 2, 0, true);
		if (b_hit !is null) {
			b_hit.deadeffect = -1;
			b_hit.Z = 1500;
		}
	}
}

void onDie(CBlob@ this)
{
}

void shootGun(const u16 gunID, const f32 aimangle, const u16 hoomanID, const Vec2f pos, const bool altfire = false) 
{
	CRules@ rules = getRules();
	CBitStream params;

	params.write_netid(hoomanID);
	params.write_netid(gunID);
	params.write_f32(aimangle);
	params.write_Vec2f(pos);
	params.write_bool(altfire);
	rules.SendCommand(rules.getCommandID("fireGun"), params);
}