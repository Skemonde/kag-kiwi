// The Great Danger logic 

const u8 amount_of_shapes = 5;

void onInit( CBlob@ this )
{
	CSprite@ sprite = this.getSprite();
	Vec2f sprite_offset = sprite.getOffset();
	this.getShape().SetRotationsAllowed(false);
	this.getShape().getConsts().transports = true;
	//this.getShape().getConsts().collideWhenAttached = true;
	
	sprite.SetEmitSound("the_great_danger.ogg");
	sprite.SetEmitSoundPaused(false);
	sprite.SetEmitSoundVolume(1.0f);
	sprite.SetEmitSoundSpeed(1.0f);
		
	sprite.SetZ(-100.0f);
	
	// converting
	this.Tag("convert on sit");
	this.Tag("bullet_hits");
	this.Tag("non_pierceable");
	this.Tag("vehicle");
	this.Tag("collides_everything");
	
	if (isServer())
	{
		for (int id = 0; id < amount_of_shapes; ++id) {
			CBlob@ blob = server_CreateBlob("bossshape"+(id+1));
			if (blob !is null)
			{
				blob.server_setTeamNum(this.getTeamNum());
				blob.setInventoryName("");
				//blob.getShape().getConsts().collideWhenAttached = true;
				//
				this.server_AttachTo(blob, "SHAPE_"+(id+1));
				this.set_u16("shape_blob_number"+(id+1)+"_id", blob.getNetworkID());
				blob.set_u16("owner_blob_id", this.getNetworkID());
			}
		}
		CBlob@ blob = server_CreateBlob("donotspawnthiswithacommand_bt42turret");
		if (blob !is null && false)
		{
			blob.server_setTeamNum(this.getTeamNum());
			blob.setInventoryName("");
			//blob.getShape().getConsts().collideWhenAttached = true;
			blob.getShape().getConsts().transports = true;
			blob.getShape().SetRotationsAllowed(false);
			this.server_AttachTo(blob, "TURRET_1");
			this.set_u16("turret_blob_number1_id", blob.getNetworkID());
			blob.set_u16("tank_id", this.getNetworkID());
		}
	}
	
	//getMap().server_AddMovingSector(Vec2f(10.0f, -16.0f), Vec2f(20.0f, -96.0f), "ladder", this.getNetworkID());

	this.addCommandID("attach vehicle");
	
	// set up tracks (positions are relative to this blob's sprite texture)
	Vec2f[] tracks_points = {
		Vec2f(-96, -23),
		Vec2f(96, -23),
		Vec2f(103, -17),
		//Vec2f(113, -11.5),
		Vec2f(103, -5),
		Vec2f(96, 0),
		Vec2f(-96, 0),
		Vec2f(-103, -5),
		//Vec2f(-113, -11.5),
		Vec2f(-103, -17)
	};
	this.set("tracks_points", tracks_points);
	this.set_f32("tracks_distanced", 10.0f);
	this.set_Vec2f("tracks_rotation_center", Vec2f(0, -44)/2.0f);
	this.set_Vec2f("tracks_rotation_offset", Vec2f_zero);
	this.set_string("tracks_texture", "boss_track.png");
	// thats it
	
	CMap@ map = getMap();
	this.SetFacingLeft(this.getPosition().x/map.tilesize>map.tilemapwidth/2);
}

void onTick( CBlob@ this )
{	
	const bool FLIP = this.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	this.setVelocity(Vec2f(0.5f*FLIP_FACTOR, 0));
	CMap@ map = getMap();
	Vec2f pos = this.getPosition();
	for (int counter = 0; counter < 15; ++counter) {
		Vec2f target_pos = pos - Vec2f((-13*map.tilesize-this.getVelocity().x)*FLIP_FACTOR, 12*map.tilesize) + Vec2f(0, counter*map.tilesize);
		int hit = 0;
		while (map.isTileSolid(target_pos)&&hit<20) {			
			map.server_DestroyTile(target_pos, 1.0f);
			
			if (map.isTileBedrock(map.getTile(target_pos).type))
				map.server_SetTile(target_pos, CMap::tile_empty);
				
			++hit;
		}
	}
	CBlob@[] blobs;
	Vec2f tl_hitting = pos - Vec2f(-13*map.tilesize*FLIP_FACTOR, 12*map.tilesize);
	Vec2f br_hitting = pos + Vec2f((13*map.tilesize+this.getVelocity().x*2)*FLIP_FACTOR, 3*map.tilesize);
	map.getBlobsInBox(tl_hitting, br_hitting, @blobs);
	for (int blob_id = 0; blob_id<blobs.size(); ++blob_id) {
		CBlob@ current_blob = blobs[blob_id];
		if (current_blob is null) continue;
		//if (!current_blob.getShape().isStatic()) continue;
		if (current_blob.hasTag("invincible")) continue;
		
		current_blob.getSprite().Gib();
		current_blob.server_Die();
	}
	//to left
	if (this.getPosition().x/map.tilesize>map.tilemapwidth-this.getRadius()/map.tilesize)
		this.SetFacingLeft(true);
	//to right
	if (this.getPosition().x/map.tilesize<this.getRadius()/map.tilesize)
		this.SetFacingLeft(false);
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	//f(!Vehicle_AddFlipButton( this, caller))
	//	Vehicle_AddAttachButton( this, caller);
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("attach vehicle"))
	{
		CBlob@ vehicle = getBlobByNetworkID( params.read_netid() );
		if (vehicle !is null)
		{
			vehicle.server_AttachTo( this, "VEHICLE" );
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return true;
}

void onHealthChange( CBlob@ this, f32 oldHealth )
{
}

void RemoveAllShapeBlobs(CBlob@ this)
{
	if (!isServer()) return;
	
	for (int id = 0; id < amount_of_shapes; ++id) {
		CBlob@ shape = getBlobByNetworkID(this.get_u16("shape_blob_number"+(id+1)+"_id"));
		if (shape is null) continue;
		shape.server_Die();
	}
}

void onDie(CBlob@ this)
{
	RemoveAllShapeBlobs(this);
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
}

void onDetach( CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint )
{
}