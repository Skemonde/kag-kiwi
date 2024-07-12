#include "BulletCommon"

void onInit(CRules@ this)
{
    if (isClient())
	{
		
		if (!this.exists("VertexBook"))
		{
			// Client vertex book used to grab bullet texture to batch render
			string[] book;
			this.set("VertexBook", @book);
		}
		else
		{
			string[]@ book;
			this.get("VertexBook", @book);

			if (book is null)
			{
				string[] book;
				this.set("VertexBook", @book);
			}
		}
		Render::addScript(Render::layer_postworld, "BulletMain", "SeeMeFlyyyy", 0.0f);
	}
    
    Reset(this);
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void onTick(CRules@ this)
{
	bullet_holder.FakeOnTick(this);
}

void Reset(CRules@ this)
{
    r.Reset(12345);
    FireGunID     = this.addCommandID("fireGun");
	this.addCommandID("fire_gun_client");
	this.addCommandID("fire_gun_from_server");
}

void SeeMeFlyyyy(int id)//New onRender
{
    CRules@ rules = getRules();

    bullet_holder.FillVertexBook();

    string[]@ vertex_book;
    rules.get("VertexBook", @vertex_book);
    
    for (int a = vertex_book.length()-1; a >= 0; a--)
    {
        Vertex[]@ bulletVertex;
        string texture = vertex_book[a];
        rules.get(texture, @bulletVertex);

        // Sending empty vertex just eats performance because engine does not check :)
        if (bulletVertex.length() < 1) continue;

        Render::SetAlphaBlend(true);
        Render::RawQuads(texture, bulletVertex);
        Render::SetAlphaBlend(false);

        bulletVertex.clear();
    }
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params) {
	if(cmd == FireGunID)
    {
		u16 holder_id; if (!params.saferead_netid(holder_id)) return;
		u16 gun_id; if (!params.saferead_netid(gun_id)) return;
		
        f32 angle; if (!params.saferead_f32(angle)) return;
        Vec2f pos; if (!params.saferead_Vec2f(pos)) return;
		bool do_altfire; if (!params.saferead_bool(do_altfire)) return;
		
		server_MakeBulletCommand(holder_id, gun_id, angle, pos, do_altfire);
    }
	if (cmd == this.getCommandID("fire_gun_from_server"))
	{
		if (!isClient()) return;
		
		u16 holder_id; if (!params.saferead_netid(holder_id)) return;
		u16 gun_id; if (!params.saferead_netid(gun_id)) return;
		
        f32 angle; if (!params.saferead_f32(angle)) return;
        Vec2f pos; if (!params.saferead_Vec2f(pos)) return;
		bool do_altfire; if (!params.saferead_bool(do_altfire)) return;
		
		CBlob@ holder = getBlobByNetworkID(holder_id);
		if (holder is null) return;
		
		if (!holder.isMyPlayer()) return;
		
		this.SendCommand(FireGunID, params);
	}
	if (cmd == this.getCommandID("fire_gun_client"))
	{
		if (!isClient()) return;
		
		u16 holder_id; if (!params.saferead_netid(holder_id)) return;
		u16 gun_id; if (!params.saferead_netid(gun_id)) return;
		
        f32 angle; if (!params.saferead_f32(angle)) return;
        Vec2f pos; if (!params.saferead_Vec2f(pos)) return;
		bool do_altfire; if (!params.saferead_bool(do_altfire)) return;
		
		f32[] bullet_angles;
		f32[] bullet_speeds;
		
		CBlob@ gunBlob = getBlobByNetworkID(gun_id);
		if (gunBlob is null) return;
		FirearmVars@ vars;
		if (!gunBlob.get("firearm_vars", @vars))
		{
			print("vars obj is null "+getMachineType());
			return;
		}
		
		//print("hello from client command");
		
		//!params.isBufferEnd()
		for (int idx = 0; idx < vars.BUL_PER_SHOT; ++idx) {
			f32 bullet_angle; if (!params.saferead_f32(bullet_angle)) return;
			bullet_angles.push_back(bullet_angle);
		}
		
		for (int idx = 0; idx < vars.BUL_PER_SHOT; ++idx) {
			f32 bullet_speed; if (!params.saferead_f32(bullet_speed)) return;
			bullet_speeds.push_back(bullet_speed);
		}
		
		HandleBulletCreation(holder_id, gun_id, angle, pos, do_altfire, bullet_angles, bullet_speeds);
	}
}