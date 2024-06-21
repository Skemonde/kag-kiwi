// Tank logic 

void onInit( CBlob@ this )
{
	CSprite@ sprite = this.getSprite();
	
	this.Tag("vehicle");
	this.Tag("ground_vehicle");
	this.Tag("tank");
	this.Tag("non_pierceable");
	this.Tag("convert on sit");
	this.Tag("bullet_hits");
	this.Tag("no team lock");
	
	this.set_f32("move_speed", 120);
	this.set_f32("turn_speed", 20);
	this.set_string("movement_sound", "med_tank_tracks1.ogg");
	
	this.getSprite().SetZ(-1);
	
	{
		CBlob@ blob = server_CreateBlobNoInit("firsttankturret");
		if (blob !is null)
		{
			blob.server_setTeamNum(this.getTeamNum());
			blob.setInventoryName(this.getInventoryName() + "'s Turret");
			//blob.getSprite().SetRelativeZ(40);
			this.set_u16("turret_id", blob.getNetworkID());
			blob.set_u16("mothertank_id", this.getNetworkID());
			blob.Init();
			this.server_AttachTo(blob, "TURRET");
			blob.getShape().getConsts().collideWhenAttached = true;
		}
	}
	
	CSpriteLayer@ tracks = sprite.addSpriteLayer("tracks", "FirstTankTracks.png", 64, 32);
	if (tracks !is null)
	{
		Animation@ anim = tracks.addAnimation("default", 1, true);
		int[] frames = { 0, 1, 2, 3, 4, 5, 6, 7, 8 };
		anim.AddFrames(frames);
		Animation@ rev = tracks.addAnimation("reverse", 1, true);
		int[] rev_frames = { 8, 7, 6, 5, 4, 3, 2, 1, 0 };
		rev.AddFrames(rev_frames);
		tracks.SetRelativeZ(0.0f);
		tracks.SetOffset(sprite.getOffset());
		tracks.SetVisible(true);
	}
}

void sprite_ManageTrackSprite(CSprite@ this)
{
	CSpriteLayer@ tracks = this.getSpriteLayer("tracks");
	if (tracks is null) return;
	Animation@ def_anim = tracks.getAnimation("default");
	if (def_anim is null) return;
	Animation@ rev_anim = tracks.getAnimation("reverse");
	if (rev_anim is null) return;
	Animation@ anim = null;
	
	CBlob@ blob = this.getBlob();
	
	if (Maths::Abs(blob.getVelocity().x)<0.1)
	{
		def_anim.time = 0;
		rev_anim.time = 0;
		return;
	}
	
	if ((blob.getVelocity().x>0&&!blob.isFacingLeft())||(blob.getVelocity().x<=0&&blob.isFacingLeft()))
	{
		tracks.SetAnimation(def_anim);
		@anim = def_anim;
	}
	else
	{
		tracks.SetAnimation(rev_anim);
		@anim = rev_anim;
	}
	
	if (anim is null) return;
	
	//print(""+(blob.getVelocity().x));
	f32 anim_delta = 1/Maths::Abs(blob.getVelocity().x);
	if (anim_delta>=1)
		anim.time = Maths::Max(1, anim_delta);
	else
	{
		anim.time = 0;
		int frames_per_tick = Maths::Ceil(Maths::Abs(blob.getVelocity().x));
		int frames_amount = anim.getFramesCount();
		
		if (getGameTime()%frames_per_tick==0)
		{
			int frame_to_set = 0;
			bool overlaping_frame_count = (anim.frame+frames_per_tick)>=frames_amount;
			if (overlaping_frame_count)
				frame_to_set = (anim.frame+frames_per_tick)-frames_amount;
			else
				frame_to_set = anim.frame+frames_per_tick;
			anim.SetFrameIndex(frame_to_set);
		}
	}
	//if (Maths::Abs(blob.getVelocity().x)<0.1) anim.time = 0;
}

void sprite_ManageInterior(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	
	AttachmentPoint@ dp = blob.getAttachments().getAttachmentPointByName("DRIVER");
	if (dp is null) return;
	
	CBlob@ driver = dp.getOccupied();
	if (driver is null) {
		
		if (isClient())
		{
			this.SetFrame(0);
			dp.offsetZ=-10.0f;
		}
		return;
	}
	
	CBlob@ turret = getBlobByNetworkID(blob.get_u16("turret_id"));
	if (turret is null) return;
	
	AttachmentPoint@ tp = turret.getAttachments().getAttachmentPointByName("TURRET_GUNNER");
	if (tp is null) return;
	
	CBlob@ turret_gunner = tp.getOccupied();
	
	if (!(driver.isMyPlayer()||turret_gunner !is null && turret_gunner.isMyPlayer())) {
		
		if (isClient())
		{
			this.SetFrame(0);
			dp.offsetZ=-10.0f;
		}
		return;
	}
	
	this.SetFrame(1);
	dp.offsetZ=-2.0f;
}

void onTick(CSprite@ this)
{
	sprite_ManageTrackSprite(this);
	sprite_ManageInterior(this);
}

void onDie(CBlob@ this)
{
	CBlob@ turret = getBlobByNetworkID(this.get_u16("turret_id"));
	if (turret !is null)
		turret.server_Die();		
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	//return Vehicle_doesCollideWithBlob_ground( this, blob );
	//print("speed"+(this.getVelocity().Length()));
	bool fren = blob.getTeamNum() == this.getTeamNum();
	
	return ((!fren && this.getVelocity().Length() > 0.2) ||
		(blob.isKeyPressed(key_up) && blob.getVelocity().y>0) ||
		blob.hasTag("vehicle") && !fren ||
		blob.hasTag("dead") ||
		blob.hasTag("scenary") ||
		blob.getName().find("tree")>-1 ||
		(blob.getPosition().y<this.getPosition().y-this.getHeight()*0.75f&&!blob.isKeyPressed(key_down)));
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	if (attached.hasTag("flesh")) {
		attached.Tag("isInVehicle");
	}
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{
	if (detached.hasTag("flesh")) {
		detached.Untag("isInVehicle");
	}
}