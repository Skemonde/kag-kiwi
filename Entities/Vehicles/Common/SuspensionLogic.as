
void onInit(CBlob@ this)
{
    f32 susheight = this.exists("suspension_height") ? this.get_f32("suspension_height") : 3;

    this.set_f32("suspension_height", susheight);
}

void onTick(CBlob@ this)
{
    UpdateSuspension(this, this.get_f32("suspension_height"));
	//RotateToGround(this);
}

void RotateToGround(CBlob@ this)
{
	const bool FLIP = this.getVelocity().x<0;
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	f32 our_angl = this.getAngleDegrees();
	//print("AA "+our_angl);
	//if (our_angl > 40 || (our_angl < 360-40 && !FLIP)) return;
	//our_angl = 0;
	
	//if (Maths::Abs(this.getVelocity().x)>15) return;
	
	CMap@ map = getMap();
	Vec2f hitpos1;
	bool hashit1 = false;
	if (map.rayCastSolid(this.getPosition()+Vec2f(this.getWidth()/2*FLIP_FACTOR, 0), this.getPosition()+Vec2f(this.getWidth()/2*FLIP_FACTOR, 0)+Vec2f(0, 48).RotateBy(our_angl), hitpos1))
	{
		hashit1 = true;
	}
	f32 len1 = (hitpos1-(this.getPosition()+Vec2f(this.getWidth()/2*FLIP_FACTOR, 0))).Length();
	
	Vec2f hitpos2;
	bool hashit2 = false;
	if (map.rayCastSolid(this.getPosition()-Vec2f(this.getWidth()/2*FLIP_FACTOR, 0), this.getPosition()-Vec2f(this.getWidth()/2*FLIP_FACTOR, 0)+Vec2f(0, 48).RotateBy(our_angl), hitpos2))
	{
		hashit2 = true;
	}
	f32 len2 = (hitpos2-(this.getPosition()-Vec2f(this.getWidth()/2*FLIP_FACTOR, 0))).Length();
	
	f32 len_factor = len2<len1?-1:1;
	
	//this.setAngleDegrees(this.getAngleDegrees()+(len1-len2)/15*FLIP_FACTOR);
	//this.AddForceAtPosition(Vec2f(0, Maths::Min(8, (len1-len2))), this.getPosition()-Vec2f(this.getWidth()/2*FLIP_FACTOR, 0));
	this.AddTorque(-Maths::Min(180, (len1*FLIP_FACTOR-len2*FLIP_FACTOR))*Maths::Max(1, 8-Maths::Abs(this.getVelocity().x))*len_factor);
}

void UpdateSuspension(CBlob@ this, f32 susheight)
{
	if (!isClient() || !this.isOnScreen()) return;

	CSprite@ sprite = this.getSprite();
	uint sprites = sprite.getSpriteLayerCount();

	CSpriteLayer@[]@ wheels;
	Vec2f[]@ offsets;
	Vec2f[]@ new_offsets;

	if (!this.get("wheel_offsets", @offsets))
	{
		Vec2f[] set_offsets;
		CSpriteLayer@[] wheel_spritelayers;

		for (uint i = 0; i < sprites; i++)
		{
			CSpriteLayer@ current_wheel = sprite.getSpriteLayer(i);
			if (current_wheel.name.substr(0, 2) == "!w") // this is a wheel
			{
				set_offsets.push_back(current_wheel.getOffset());
				wheel_spritelayers.push_back(@current_wheel);
			}
		}

		Vec2f[] temp_offsets = set_offsets;

		this.set("wheel_offsets", @set_offsets);
		this.set("wheel_spritelayers", @wheel_spritelayers);
		this.set("wheel_new_offsets", @temp_offsets);
	}

	if (this.get("wheel_spritelayers", @wheels)
		&& this.get("wheel_new_offsets", @new_offsets)
		&& wheels !is null
		&& offsets !is null
		&& new_offsets !is null
		&& wheels.length == offsets.length
		&& wheels.length == new_offsets.length)
	{
		Vec2f[] temp_offsets;

		Vec2f pos = this.getPosition();
		CMap@ map = getMap();
		if (map is null) return;
		for (u8 i = 0; i < wheels.length; i++)
		{
			CSpriteLayer@ wheel = wheels[i];
			if (wheel is null) continue;

			bool fl = this.isFacingLeft();
			f32 rot = this.getAngleDegrees();
			Vec2f init_offset = offsets[i];
			Vec2f current_offset = new_offsets[i];
			Vec2f cast_pos = Vec2f(0,8).RotateBy(rot);
			Vec2f wpos = pos+Vec2f(fl?init_offset.x:-init_offset.x, init_offset.y).RotateBy(rot);
			
			Vec2f hitpos;
			bool hashit = false;
			if (map.rayCastSolid(wpos, wpos+cast_pos, hitpos))
			{
				hashit = true;
			}

			f32 len = Maths::Min(susheight, (hitpos-wpos).Length());
			if (!hashit) wheel.SetOffset(Vec2f_lerp(current_offset, init_offset+Vec2f(0,len), 0.33f));
			else wheel.SetOffset(Vec2f_lerp(current_offset, init_offset, 0.33f));

			temp_offsets.push_back(wheel.getOffset());
		}

		this.set("wheel_new_offsets", @temp_offsets);
	}
}