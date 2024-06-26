#include "BulletTrails"
#include "BulletClass"
#include "BulletCase"
#include "FirearmVars"
#include "Hitters"
#include "Skemlib"

Random@ r = Random(12345);//amazing
//used to sync numbers between clients *assuming* they have run it the same amount of times 
//as everybody else
//(which they should UNLESS kag breaks with bad deltas or other weird net issues)

BulletHolder@ bullet_holder = BulletHolder();

void HandleBulletCreation(u16 hoomanBlobId, u16 gunBlobId, f32 angle, Vec2f pos, bool do_altfire = false)
{
	CBlob@ holder = getBlobByNetworkID(hoomanBlobId);
	CBlob@ gunBlob    = getBlobByNetworkID(gunBlobId);
	
	if (holder is null || gunBlob is null) return;
	
	//doesn't shoot if lagging player sends 90000 commands
	//i mean it still will shoot like uhhh needed amount of times hopefully
	//won't be THAT bad
	//if (gunBlob.get_u8("clip") < 1 && gunBlob.hasTag("firearm")) return;
	
	CSpriteLayer@ flash = gunBlob.getSprite().getSpriteLayer("m_flash");
	FirearmVars@ vars;
	gunBlob.get("firearm_vars", @vars);
	if (vars is null) {
		error("Firearm vars is null! at line 303 of BulletMain.as");
		return;
	}
	//print("what went wrong?");
	const bool flip = holder.isFacingLeft();
	const f32 flip_factor = flip ? -1: 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	
	const u8 b_count = vars.BUL_PER_SHOT;
	f32 spread = getSpreadFromData(gunBlob);
	//spread *= (holder.hasTag("commander")?0.25:1);
	u16 shot_count = gunBlob.get_u16("shotcount");
	
	//if (b_count == 1 && (!gunBlob.hasTag("NoAccuracyBonus") && vars.FIRE_AUTOMATIC) && !vars.UNIFORM_SPREAD)
	if (vars.COOLING_INTERVAL>0)
	{
		spread = getSpreadFromShotsInTime(gunBlob);
	}
	
	Vec2f trench_aim = Vec2f(2, -3);
	Vec2f muzzle_pos = Vec2f(flip_factor*(-vars.MUZZLE_OFFSET.x-getMap().tilesize),vars.MUZZLE_OFFSET.y).RotateBy(angle, Vec2f_zero);
	Vec2f dir = Vec2f(flip_factor, 0.0f).RotateBy(angle);
	Vec2f shoulder_world = holder.get_Vec2f("sholder_join_world")+dir*3;
	bool muzzle_blocked = getMap().rayCastSolidNoBlobs(shoulder_world, holder.getPosition()+gunBlob.get_Vec2f("fromBarrel"));
	
	//if (!holder.isAttachedTo(gunBlob))
	//	pos += holder.getPosition()-gunBlob.getPosition();
	
	CBlob@ holder_vehicle = getBlobByNetworkID(holder.get_u16("my vehicle"));
	if (holder_vehicle !is null && (holder.isAttachedTo(holder_vehicle)||holder_vehicle.isAttachedTo(holder)))
		pos += holder_vehicle.getVelocity()*4;
	
	f32 bulletAngle = 0;
	for(int counter = 0; counter < b_count; ++counter) {
		//handling a bullet angle
		//then we see what kind of gun do we have for calculating the angle of the each bullet in the loop properly
		if(vars.UNIFORM_SPREAD && b_count >= 1) {
			//and this one for automatic guns (non-shotguns, that's important!)
			if (vars.FIRE_AUTOMATIC && (b_count < 2 || gunBlob.hasTag("not_a_shotgun"))) {
				f32 frequency = 4;
				f32 wave = Maths::Sin(getGameTime()/9.5f*frequency)*spread/2;
				bulletAngle = wave;
			} else {
				//formula for shotguns
				bulletAngle = (-spread/2+spread/Maths::Max(1,b_count-1)*counter)*flip_factor;
				//print("shotgun bullet #"+(counter+1)+" angle "+bulletAngle);
			}
		} else {
			//if spread isn't uniform - it's completely random (thanks, Cap)
			u8 rnd_scale = 4;
			bulletAngle = (-spread/2*rnd_scale+r.NextRanged(spread*rnd_scale))/rnd_scale*flip_factor;
		}
		if (gunBlob.hasTag("circlespread") && b_count >= 1) {
			Vec2f radius = Vec2f(7,0);
			pos = pos + radius.RotateByDegrees(360/b_count*counter);
			bulletAngle = 0;
		}
		//adding initial angle
		bulletAngle += angle;
		
		if (gunBlob.getName()=="hmg") {
			pos += Vec2f(0, (r.NextRanged(spread)-spread/2)*2).RotateBy(angle);
			//bulletAngle = angle;
		}
		
		//deciding what we're going to spawn
		string blobName = "";
		f32 blobSpeed = 0;
		bool addHolderVel = false;
		blobName = vars.BULLET;
		
		if (blobName=="aks_bullet")
			blobName=getRules().get_string("special_bullet");
		
		if (blobName!="bullet"&&blobName!="raycast") {
			blobSpeed = vars.B_SPEED;
		}
		//attachment type
		int AltFire = gunBlob.get_u8("override_alt_fire");
		if(AltFire == AltFire::Unequip)AltFire = vars.ALT_FIRE;
		if (do_altfire) {
			switch (AltFire) {
				case AltFire::UnderbarrelNader:{
					blobName = "grenade";
					blobSpeed = 17;
				break;}
			}
		}
		
		//making bullet with data we've handled in a code above
		if (blobName == "bullet") {
			BulletObj@ bullet = BulletObj(hoomanBlobId,gunBlobId,bulletAngle,pos+holder.getVelocity(),holder.getTeamNum(), holder.isFacingLeft(), vars);
			bullet_holder.AddNewObj(bullet);
		}
		//making a ray like in good ol times
		else if (blobName == "raycast") {
			makeRayBullet(gunBlob, holder, bulletAngle, pos+holder.getVelocity(), counter);
		}
		//this for shooting blobs
		else if (isServer()){
			if (vars.BULLET=="blobconsuming") {
				blobName = "";
				blobName = findAmmo(holder, vars);
				if (!holder.hasTag("bot")) {
					holder.TakeBlob(blobName, 1);
				}
			}
			if (blobName.empty()) return;
			bulletAngle += holder.isFacingLeft() ? 180 : 0;
			CBlob@ bullet_blob = server_CreateBlobNoInit(blobName);
			if (bullet_blob !is null) {
				//
				if (blobName=="arrow"){
					bullet_blob.set_u8("arrow type", vars.B_DAMAGE);
					addHolderVel = true;
				}
				if (blobName=="clusterbullet") {
					blobSpeed = 1;
				}
				Vec2f velocity(1,0);
				velocity.RotateBy(bulletAngle);
				velocity *= blobSpeed;
				if (addHolderVel)
					velocity.x += holder.getVelocity().x;
				
				bullet_blob.setVelocity(velocity);
				bullet_blob.server_setTeamNum(holder.getTeamNum());
				bullet_blob.IgnoreCollisionWhileOverlapped(holder);
				bullet_blob.setPosition(holder.getPosition()); //only for sounds, so they are played in approximately right spot
				bullet_blob.SetDamageOwnerPlayer(holder.getPlayer());
				if (blobName=="froggy"||blobName=="molotov") {
					bullet_blob.set_u32("death_date", getGameTime()+60);
					
					CShape@ shape = bullet_blob.getShape();
					if (shape !is null)
						shape.SetGravityScale( 0.8 );
				}
				
				
				bullet_blob.Init();
				
				Vec2f shoulder_world = holder.get_Vec2f("sholder_join_world")+dir*bullet_blob.getWidth()*0.75;
				if (!holder.hasTag("player"))
					shoulder_world = holder.getPosition();
				
				bullet_blob.setPosition(shoulder_world);
				bullet_blob.setAngleDegrees(bulletAngle+90);
				bullet_blob.set_Vec2f("start_pos", bullet_blob.getPosition());
			}
		}
		
		bool kinda_dead = holder.hasTag("dead")||holder.hasTag("halfdead");
		bool we_pron = lyingProne(holder);
		if (gunBlob.hasTag("shot_force"))
			holder.AddForce(Vec2f(Maths::Min(-20, (-1.9f*vars.B_DAMAGE-0.05f*vars.BUL_PER_SHOT)*(we_pron?0.3f:1)), -40*flip_factor/vars.BUL_PER_SHOT).RotateBy(bulletAngle+angle_flip_factor));
		//preventing altfire grenader shoot 5 grenades from a shotgun :P
		if (do_altfire)
			break;
	}
	
	if(isServer() && !gunBlob.hasTag("vehicle") && gunBlob.get_u8("clip") > 0 && gunBlob.get_u8("clip") != 255 && !do_altfire){
		gunBlob.sub_u8("clip",1);
		CBitStream params;
		params.write_u8(gunBlob.get_u8("clip"));
		params.write_u8(gunBlob.get_u8("total"));
		gunBlob.SendCommand(gunBlob.getCommandID("set_clip"),params);
	}
	if (gunBlob.hasTag("blobconsuming")) {
		CBlob@ storage_blob = getBlobByNetworkID(gunBlob.get_u16("storage_id"));
		if (storage_blob !is null && storage_blob.getInventory() !is null)
			storage_blob.TakeBlob(vars.AMMO_TYPE[0], 1);
	}
	
	const int pitch_range = 10;
	if(false) {
		//gunBlob.getSprite().PlaySound((do_altfire?"grenade_launcher_shot":vars.FIRE_SOUND),1.0f,float(100*vars.FIRE_PITCH-pitch_range+XORRandom(pitch_range*2))*0.01f);
	}
	//CBlob@ localblob = getLocalPlayerBlob();
	CCamera@ localcamera = getCamera();
	if (localcamera !is null && !gunBlob.hasTag("looped_sound")) {
		Vec2f cam_pos = localcamera.getPosition();
		Vec2f shooter_pos = gunBlob.getPosition();
		f32 dist = (cam_pos-shooter_pos).Length();
		//if (dist > 800)
		Sound::Play(do_altfire?"grenade_launcher_shot":vars.FIRE_SOUND, cam_pos, Maths::Max(0.1f, 1.0f-(dist/((getMap().tilemapwidth*getMap().tilesize)+vars.B_DAMAGE*vars.FIRE_INTERVAL))), Maths::Max(0.2f, float(100*vars.FIRE_PITCH-pitch_range+r.NextRanged(pitch_range*2))*0.01f-(dist/(2000+vars.B_DAMAGE))));
	}
	
	u16 too_fast = 2; //ticks
	
	if (((vars.FIRE_INTERVAL < too_fast && shot_count % (too_fast+1) == 0) || vars.FIRE_INTERVAL >= too_fast) && !muzzle_blocked)
	{
		if (flash !is null && !do_altfire) {
			flash.SetFrameIndex(0);
			flash.SetVisible(true);
		}
		if (!v_fastrender && !(vars.BURST>1)) {
			Vec2f onomatopoeia_pos = gunBlob.get_Vec2f("fromBarrel")
				+ Vec2f(r.NextRanged(11)-5,-r.NextRanged(4)-1)
				+ Vec2f(gunBlob.getSprite().getFrameWidth()/2, 0).RotateBy(gunBlob.get_f32("gunSpriteAngle")+(gunBlob.isFacingLeft()?180:0));
			MakeBangEffect(gunBlob, vars.ONOMATOPOEIA, 1.0f, false, Vec2f((r.NextRanged(10)-5) * 0.1, -(3/2)), onomatopoeia_pos);
		}
		if (!(vars.FIRE_INTERVAL < too_fast)) {
			gunBlob.set_bool("make_recoil", true);
		}
	}
	
	gunBlob.add_u16("shotcount", 1);
	gunBlob.set_bool("do_cycle_sound", true);
	gunBlob.set_u32("last_shot_time", getGameTime());
}

void makeRayBullet(CBlob@ gun, CBlob@ shooter, f32 angle, Vec2f startPos, u8 bullet_index)
{
	CMap@ map = getMap();
	FirearmVars@ vars;
	if (!gun.get("firearm_vars", @vars)) return;
	gun.set_u32("last_shot_time", getGameTime());
	
	f32 facing = shooter.isFacingLeft() ? -1.0f : 1.0f;
	bool flip = shooter.isFacingLeft();
	Vec2f dir = Vec2f(facing, 0.0f).RotateBy(angle);
	//gun.set_Vec2f("for_render", startPos);
	Vec2f endPos = startPos + dir * vars.RANGE;
	Vec2f hitPos;
	f32 length;
	f32 renderLength = vars.RANGE;
	
	HitInfo@[] hitInfos;
	bool mapHit = map.rayCastSolidNoBlobs(startPos, endPos, hitPos);
	hitPos += dir * 0.01f;
	
	length = (hitPos - startPos).Length();
	
	bool blobHit = map.getHitInfosFromRay(startPos, angle + (flip ? 180.0f : 0.0f),length,shooter,@hitInfos);
	bool endBullet = false;
	
	if(true) 
	{
		const bool force_nonsolid = gun.exists("gun_force_nonsolid") && gun.get_bool("gun_force_nonsolid");
	
		if(blobHit) 
		{
			f32 falloff=1;
			for(u32 i=0;i<hitInfos.length;i++) 
			{
				if(hitInfos[i].blob !is null)
				{	
					CBlob@ blob=hitInfos[i].blob;
					if (blob is null) return;
					
					if(rayHits(blob, shooter, angle)) 
					{
						f32 dmg = vars.B_DAMAGE*Maths::Max(0.1,falloff);//*(blob.hasTag("door") ? 0.2f : 1.0f);
						Vec2f dir = blob.getPosition() - shooter.getPosition();
						dir.Normalize();
						
						shooter.server_Hit(blob, hitInfos[i].hitpos, dir, dmg, vars.B_HITTER, false);
						
						if (blob.hasTag("flesh"))
							makeGibParticle("GenericGibs", hitInfos[i].hitpos, getRandomVelocity(angle, 1.0f + dmg, 90.0f) + Vec2f(0.0f, -2.0f), 4, XORRandom(8), Vec2f(8, 8), 2.0f, 0, "", 0);
						
						makeBulletHitParticle(hitInfos[i].hitpos, angle, vars.BULLET_SPRITE);
						renderLength = (hitInfos[i].hitpos - startPos).Length();
						//if (blob.hasTag("door") || blob.hasScript("Vehicle.as")) break;
						
						falloff=falloff * 0.8f;
						endBullet = true;
						break;
					}
				}
			}
		}
		if(mapHit && !endBullet)
		{
			TileType tile = map.getTile(hitPos).type;
			renderLength = (hitPos - startPos).Length();
			
			if (true) {
				if (XORRandom(100)<100) {
					doHitTile(hitPos, vars.B_DAMAGE, angle);
				}
			}
			makeBulletHitParticle(hitPos, angle, vars.BULLET_SPRITE);
		}
	}
	if(isClient())
	{
		//init tracer layers
		AddTracerLayers(gun.getSprite(), bullet_index, vars);
		//sending bullet vars to the gun where on hook onTick(CSprite) it will be processed
		gun.set_f32("bullet_length"+bullet_index, renderLength / 32);
		gun.set_f32("bullet_angle"+bullet_index, angle);
	}
}

void makeBulletHitParticle(Vec2f pos, f32 angle, string fileName)
{
	CParticle@ b_hit = ParticleAnimated(fileName+"_hit", pos, Vec2f_zero, angle+(XORRandom(2)*180), 1.0f, 2, 0, true);
	if (b_hit !is null) {
		b_hit.deadeffect = -1;
		b_hit.Z = 1500;
	}
}


void AddTracerLayers(CSprite@ this, u8 bullet_index, FirearmVars@ vars)
{
	CSpriteLayer@ tracer=this.getSpriteLayer("tracer" + bullet_index);
	if (tracer is null)
		@tracer = this.addSpriteLayer("tracer" + bullet_index, vars.BULLET_SPRITE+"_tracer", 32, 16, this.getBlob().getTeamNum(),0);
}

bool isTilePiercable(CBlob@ gunBlob, Vec2f world_pos) {
	return false; // todo: make good piercing logic
	CMap@ map = getMap();
	FirearmVars@ vars;
	gunBlob.get("firearm_vars", @vars);
	TileType tile = map.getTile(world_pos).type;
	if (vars.B_HITTER == HittersKIWI::bullet_rifle &&
		(map.isTileWood(tile) || map.isTileCastle(tile)))
		return true;
	
	if (map.isTileWood(tile))
		return true;
	return false;
}

void doHitTile(const Vec2f hitPos, const f32 damage, const f32 angle) {
	CMap@ map = getMap();
	TileType tile = map.getTile(hitPos).type;
	
	for (int times_we_hit_block = 0; times_we_hit_block < damage; ++times_we_hit_block) {
		if (map.hasTileFlag(map.getTileOffset(hitPos), Tile::SOLID) && XORRandom(100)<50*damage) {//no backwall hitting!! happens if bullet hits a door or a very corner of a tile
			map.server_DestroyTile(hitPos, 1.0f);
			continue;
			if (!v_fastrender && map.hasTileFlag(map.getTileOffset(hitPos), Tile::SOLID)) {
				if (map.isTileWood(tile))
					makeGibParticle("GenericGibs", hitPos, getRandomVelocity(angle, 1.0f + damage, 90.0f) + Vec2f(0.0f, -2.0f), 1, XORRandom(8), Vec2f(8, 8), 2.0f, 0, "", 0);
				else if (map.isTileCastle(tile))
					makeGibParticle("GenericGibs", hitPos, getRandomVelocity(angle, 1.0f + damage, 90.0f) + Vec2f(0.0f, -2.0f), 2, 4+XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);
				/* else if (isTileIron(tile)||isTileRustyIron(tile))
					makeGibParticle("GenericGibs", hitPos, getRandomVelocity(angle, 1.0f + damage, 90.0f) + Vec2f(0.0f, -2.0f), 9, 4+XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);
				else if (isTileConcrete(tile))
					makeGibParticle("GenericGibs", hitPos, getRandomVelocity(angle, 1.0f + damage, 90.0f) + Vec2f(0.0f, -2.0f), 10, 4+XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);
				else if (map.isTileGroundStuff(tile))
					makeGibParticle("GenericGibs", hitPos, getRandomVelocity(angle, 1.0f + damage, 90.0f) + Vec2f(0.0f, -2.0f), 0, XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);
				 */
			}
		}
	}
}