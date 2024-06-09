#include "FireCommon.as"
#include "Requirements.as"
#include "RunnerAnimCommon.as"
#include "RunnerCommon.as"
#include "Knocked.as"
#include "PixelOffsets.as"
#include "RunnerTextures.as"
#include "FirearmVars.as";
#include "SoldatInfo"

const string shiny_layer = "shiny bit";
//const Vec2f trench_aim = Vec2f(0,0);

void onInit(CSprite@ this)
{
	addRunnerTextures(this, "soldat", "Soldier");

	this.getCurrentScript().runFlags |= Script::tick_not_infire;
	
	this.getBlob().set_f32("gun_aimangle", 69);
	
	this.SetEmitSound("panteri.ogg");
	this.SetEmitSoundSpeed(0.8);
	this.SetEmitSoundVolume(0.4);
	this.SetEmitSoundPaused(true);
	
	CSpriteLayer@ backpack = this.addSpriteLayer("backpack", "BackPack.png", 16, 16, this.getBlob().getTeamNum(), 0);
	if (backpack !is null) {
		backpack.SetVisible(false);
	}
	CSpriteLayer@ cape = this.addSpriteLayer("cape", "SoldierCape", 32, 32, this.getBlob().getTeamNum(), 0);
	cape.SetOffset(Vec2f(0, -4));
}

CSpriteLayer@ getArmSprite (CSprite@ this)
{
	this.RemoveSpriteLayer("right_arm");
	CSpriteLayer@ right_arm = this.addSpriteLayer("right_arm", "right_arm.png", 16, 16, this.getBlob().getTeamNum(), 0);
	
	Animation@ anim = right_arm.addAnimation("default", 1, false);
	anim.AddFrame(0);
	Animation@ aim_anim = right_arm.addAnimation("aim", 1, false);
	aim_anim.AddFrame(1);
	right_arm.SetRelativeZ(50.0f);
	right_arm.SetOffset(Vec2f(-2, 0));
	right_arm.SetVisible(false);
	
	return right_arm;
}

CSpriteLayer@ getUpperBodySprite (CSprite@ this, string part_name = "torso", u8 starting_frame = 16)
{
	this.RemoveSpriteLayer(part_name);
	CSpriteLayer@ upper_body = this.addSpriteLayer(part_name, "SoldierParts", 32, 32, this.getBlob().getTeamNum(), 0);
	
	u8 spite_sheet_shift = starting_frame;
	
	Animation@ idle_anim = upper_body.addAnimation("idle", 1, false);
	int[] idle_frames = { spite_sheet_shift };
	idle_anim.AddFrame(spite_sheet_shift);
	
	Animation@ walking_anim = upper_body.addAnimation("walking", 3, true);
	int[] walking_frames = { spite_sheet_shift+1, spite_sheet_shift+2, spite_sheet_shift+3, spite_sheet_shift+4 };
	walking_anim.AddFrames(walking_frames);
	
	Animation@ crouching_anim = upper_body.addAnimation("crouching", 1, false);
	int[] crouching_frames = { spite_sheet_shift+5 };
	crouching_anim.AddFrames(crouching_frames);
	
	Animation@ falling_anim = upper_body.addAnimation("falling", 5, true);
	int[] falling_frames = { spite_sheet_shift+7, spite_sheet_shift+8, spite_sheet_shift+9 };
	falling_anim.AddFrames(falling_frames);
	
	Animation@ aiming_anim = upper_body.addAnimation("aiming", 1, false);
	//frame with index 6 is empty
	int[] aiming_frames = { 6 };
	aiming_anim.AddFrames(aiming_frames);
	
	Animation@ aiming_crouching_anim = upper_body.addAnimation("aiming_crouching", 1, false);
	int[] aiming_crouching_frames = { 6 };
	aiming_crouching_anim.AddFrames(aiming_crouching_frames);
	
	Animation@ aiming_falling_anim = upper_body.addAnimation("aiming_falling", 5, true);
	int[] aiming_falling_frames = { 6 };
	aiming_falling_anim.AddFrames(aiming_falling_frames);
	
	upper_body.SetRelativeZ(0.1f);
	upper_body.SetOffset(Vec2f(0, -4));
	
	return upper_body;
}

void onPlayerInfoChanged(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	addRunnerTextures(this, "soldat", "Soldier");
	//
	CSpriteLayer@ right_arm = getArmSprite(this);
	
	this.RemoveSpriteLayer("torso");
	this.RemoveSpriteLayer("arms");
	this.RemoveSpriteLayer("legs");
}

void onTick(CSprite@ this)
{
	if (this is null) return;
	const bool flip = this.isFacingLeft();
	const f32 flip_factor = flip ? -1: 1;
	// store some vars for ease and speed
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	CBlob@ carried = blob.getCarriedBlob();
	RunnerMoveVars@ moveVars;
	if (!blob.get("moveVars", @moveVars))
	{
		return;
	}
	Vec2f pos = blob.getPosition();
	Vec2f aimpos;

	const u8 knocked = getKnocked(blob);

	bool pressed_a1 = blob.isKeyPressed(key_action1);
	bool pressed_a2 = blob.isKeyPressed(key_action2);

	bool walking = (blob.isKeyPressed(key_left) || blob.isKeyPressed(key_right));

	aimpos = blob.getAimPos();
	bool inair = (!blob.isOnGround() && !blob.isOnLadder());

	Vec2f vel = blob.getVelocity();
	
	bool kinda_dead = blob.hasTag("dead")||blob.hasTag("halfdead");

	if (kinda_dead)
	{
		this.SetAnimation("dead");
		//return;
	}
	
	CPlayer@ player = blob.getPlayer();
	/*
	if (player !is null) {
		if (player.isMyPlayer())
			this.SetZ(this.getZ()+0.1);
		// so you're above other player sprites :>
	} */

	// get the angle of aiming with mouse
	Vec2f vec;
	int direction = blob.getAimDirection(vec);
	
	const bool left = blob.isKeyPressed(key_left);
	const bool right = blob.isKeyPressed(key_right);
	
	CSpriteLayer@ backpack = this.getSpriteLayer("backpack");
	CSpriteLayer@ head = this.getSpriteLayer("head");
	if (backpack !is null && head !is null && isClient()) {
		backpack.SetVisible(backpack.isVisible()&&!(blob.isAttached()&&blob.hasTag("isInVehicle")));
		bool we_pron = kinda_dead||blob.getVelocity().Length()<0.3f&&(blob.isKeyPressed(key_left)||blob.isKeyPressed(key_right))&&blob.isKeyPressed(key_down);
		Vec2f pack_offset = Vec2f(head.getOffset().x, head.getOffset().y*(we_pron?0:1))+Vec2f(6, 4*(we_pron?-0.1:1));
		Vec2f pack_rotoff = -Vec2f(pack_offset.x*flip_factor, pack_offset.y);
		backpack.SetOffset(head.getOffset()+Vec2f(6, 4));
		backpack.SetRelativeZ(this.getRelativeZ()-1.3);
		f32 pack_angle = Maths::Clamp(blob.get_f32("head_angle"), (flip?-50:-10), (flip?10:50));
		//print("AAA "+pack_angle);
		backpack.ResetTransform();
		backpack.RotateBy((we_pron?60*flip_factor:pack_angle), pack_rotoff);
		if (we_pron)
			backpack.SetOffset(backpack.getOffset()+Vec2f(-2,-1));
	}
	
	CSpriteLayer@ right_arm = this.getSpriteLayer("right_arm");
	if (right_arm is null) @right_arm = getArmSprite(this);
	
	CSpriteLayer@ torso = this.getSpriteLayer("torso");
	bool needs_update = blob.hasTag("needs a torso update");
	if (torso is null || (needs_update && isClient())) {
		if (player !is null) {
			string player_name = player.getUsername();
			
			SoldatInfo our_info = getSoldatInfoFromUsername(player_name);
			if (our_info is null) return;
			
			if (our_info.rank>4)
				@torso = getUpperBodySprite(this, "torso", 40);
			else
				@torso = getUpperBodySprite(this, "torso", 0);
		} else
			@torso = getUpperBodySprite(this, "torso", 0);
		blob.Untag("needs a torso update");
	}
	CSpriteLayer@ arms = this.getSpriteLayer("arms");
	if (arms is null) @arms = getUpperBodySprite(this, "arms", 10);
	CSpriteLayer@ legs = this.getSpriteLayer("legs");
	if (legs is null) @legs = getUpperBodySprite(this, "legs", 20);
	CSpriteLayer@ cape = this.getSpriteLayer("cape");
	
	Vec2f default_shoulder = Vec2f(0, 0);
	Vec2f anim_shoulder_offset = Vec2f_zero;
	
	bool aiming = false;
	
	bool got_carried_item = carried !is null;
	
	bool carried_is_gun = got_carried_item && (carried.hasTag("firearm") || carried.hasTag("melsee"));
	
	bool crouch = gunCrouching(blob);
	
	bool gun_just_shot = carried_is_gun && (getGameTime()-carried.get_u32("last_shot_time"))<5;
	
	if (carried_is_gun || blob.isAttachedToPoint("MACHINEGUNNER"))
	{
		bool proning = this.isAnimation("pron");
		f32 aimangle = 0;
		if (carried !is null) {
			if (carried.get_u8("gun_state")==RELOADING||carried.getName()=="bino"||proning)
				aimangle = carried.get_f32("gunSpriteAngle");
			else {//getting angle
				aimangle = getAimAngle(carried, blob);
				
				f32 upper_line = 45;
				f32 lower_line = 95;
				if (blob.getName()=="hmg")
					aimangle = Maths::Clamp(aimangle, flip?360-lower_line:upper_line, flip?360-upper_line:lower_line);
				if (flip)
					aimangle+=90;
				else
					aimangle-=90;
			}
		}
		right_arm.SetVisible((true||!blob.hasTag("isInVehicle"))||carried.getName()!="combatknife");
		right_arm.ResetTransform();
		
		if (carried !is null) {
			right_arm.RotateBy(aimangle, Vec2f(5 * flip_factor, 0));
			
			//for soldat's arm
			if (carried.hasTag("trench_aim"))
				right_arm.SetAnimation("aim");
			else
				right_arm.SetAnimation("default");
		} else {
			right_arm.RotateBy(aimangle, Vec2f(5 * flip_factor, 0));
			right_arm.SetAnimation("aim");
		}
		//for soldat's torso
		//we don't set for his legs because he can obviously walk while aiming
		//torso.SetAnimation("aiming");
		arms.SetAnimation("aiming");
		//legs.SetAnimation("aiming");
		//you can easily tell aiming torso animation has most priority B)
		aiming = true;
		anim_shoulder_offset = Vec2f(0, 2);
		//return;
	}
	else
	{
		right_arm.SetVisible(false);
		aiming = false;
		CBlob@ localblob = getLocalPlayerBlob();
		if (localblob !is null && localblob is blob) {
			getHUD().SetDefaultCursor();
		}
	}
	if (carried !is null && carried.hasScript("StandardFire2.as"))
		right_arm.SetVisible(false);
	
	if (blob.hasTag("dead"))
	{
		this.SetAnimation("dead");
		Vec2f vel = blob.getVelocity();

		if (vel.y < -1.0f)
		{
			this.SetFrameIndex(0);
		}
		else if (vel.y > 1.0f)
		{
			this.SetFrameIndex(2);
		}
		else
		{
			this.SetFrameIndex(1);
		}
		return;
	}
	else if (isKnocked(blob))
	{
		if (inair&&false)
		{
			this.SetAnimation("crouch");
		}
		else
		{
			anim_shoulder_offset = Vec2f(0, 1);
			this.SetAnimation("crouch");
			
			torso.SetAnimation("crouching");	
			arms.SetAnimation("crouching");	
			legs.SetAnimation("crouching");
			
			if (aiming) {
				arms.SetAnimation("aiming_crouching");
			}
		}
	}
	else if (inair && !blob.isAttached())
	{
		f32 vy = vel.y;
		if (vy < -0.0f && moveVars.walljumped)
		{
			this.SetAnimation("run");
			
			torso.SetAnimation("walking");
			legs.SetAnimation("walking");
			arms.SetAnimation("walking");
				
			if (aiming) {
				arms.SetAnimation("aiming");
			}
		}
		else
		{
			this.SetAnimation("fall");
			torso.SetAnimation("falling");
			arms.SetAnimation("falling");
			legs.SetAnimation("falling");
			
			if (aiming) {
				//torso.SetAnimation("aiming_falling");
				arms.SetAnimation("aiming_falling");
				//legs.SetAnimation("aiming_falling");
			}
			
			this.animation.timer = 0;
			torso.animation.timer = 0;
			arms.animation.timer = 0;
			legs.animation.timer = 0;

			if (vy < -1.5)
			{
				this.animation.frame = 0;
				torso.animation.frame = 0;
				arms.animation.frame = 0;
				legs.animation.frame = 0;
				anim_shoulder_offset = Vec2f(2, -2);
			}
			else if (vy > 1.5)
			{
				this.animation.frame = 2;
				torso.animation.frame = 2;
				arms.animation.frame = 2;
				legs.animation.frame = 2;
				anim_shoulder_offset = Vec2f(0, -1);
			}
			else
			{
				this.animation.frame = 1;
				torso.animation.frame = 1;
				arms.animation.frame = 1;
				legs.animation.frame = 1;
				anim_shoulder_offset = Vec2f(1, -3);
			}
		}
	}
	else if (kinda_dead || blob.hasTag("seated") || (blob.isKeyPressed(key_down) && !blob.isOnLadder() && blob.getVelocity().Length()<=0.3f) || blob.isAttached())
	{
		if ((left || right || kinda_dead) && !blob.isAttached()) {
			anim_shoulder_offset = Vec2f(-3, 4);
			this.SetAnimation("dead");
			
			torso.SetAnimation("aiming_crouching");	
			arms.SetAnimation("aiming_crouching");	
			legs.SetAnimation("aiming_crouching");
			
			if (aiming) {
				this.SetAnimation("pron");
			}
		} else {
			anim_shoulder_offset = Vec2f(0, 1);
			this.SetAnimation("crouch");
			
			torso.SetAnimation("crouching");	
			arms.SetAnimation("crouching");	
			legs.SetAnimation("crouching");
			
			if (aiming) {
				arms.SetAnimation("aiming_crouching");
			}
		}
	}
	else if ((right || left)&&false)
	{
		this.SetAnimation("run");
		
		torso.SetAnimation("walking");			
		legs.SetAnimation("walking");

		Animation@ torso_walking_anim = torso.getAnimation("walking");
		Animation@ legs_walking_anim = legs.getAnimation("walking");
		Animation@ arms_walking_anim = arms.getAnimation("walking");
		u8 walking_speed = Maths::Min(3, 3*Maths::Max(0, 5-Maths::Abs(blob.getVelocity().x)));
		//walking_speed = 6;
		torso_walking_anim.time = walking_speed;
		legs_walking_anim.time = walking_speed;
		arms_walking_anim.time = walking_speed;
		
		if (!aiming) {
			arms.SetAnimation("walking");			
		}
			
		anim_shoulder_offset = default_shoulder;
	}
	else if (walking&&blob.getVelocity().Length()>0.3f ||
	         (blob.isOnLadder() && (blob.isKeyPressed(key_up) || blob.isKeyPressed(key_down))))
	{
		this.SetAnimation("run");
		
		torso.SetAnimation("walking");
		legs.SetAnimation("walking");
		
		if (!aiming) {
			arms.SetAnimation("walking");
		}
			
		anim_shoulder_offset = default_shoulder;
	}
	else
	{
		this.SetAnimation("idle");
		
		torso.SetAnimation("idle");
		legs.SetAnimation("idle");
		
		if (!aiming) {
			arms.SetAnimation("idle");
		}
		anim_shoulder_offset = default_shoulder;
		
		//blob.Untag("dead head");
	}
	if (carried !is null)
	{
		//if(carried.hasTag("trench_aim")) anim_shoulder_offset+=trench_aim;
		carried.set_Vec2f("gun_trans_from_carrier", anim_shoulder_offset);
	}
	right_arm.SetOffset(Vec2f(-2, 0) + anim_shoulder_offset);
	cape.SetOffset(Vec2f(0, -4) + anim_shoulder_offset);
	torso.SetRelativeZ(this.getRelativeZ()+0.1);
	legs.SetRelativeZ(this.getRelativeZ()+0.2);
	arms.SetRelativeZ(this.getRelativeZ()+0.4);
	cape.SetRelativeZ(this.getRelativeZ()+0.5);
	cape.SetFrame(aiming?1:0);
	cape.SetVisible(false);
	right_arm.SetRelativeZ(!blob.hasTag("isInVehicle")?(this.getRelativeZ()+150):(this.getRelativeZ()+0.3f));
	
	torso.SetVisible(this.isVisible());
	legs.SetVisible(this.isVisible());
	arms.SetVisible(this.isVisible());
	
	if ((kinda_dead||crouch)&&!carried_is_gun)
	{
		blob.Tag("dead head");
	}
	else if (gun_just_shot)
	{
		blob.Tag("attack head");
		blob.Untag("dead head");
	}
	else
	{
		blob.Untag("attack head");
		blob.Untag("dead head");
	}
}

void onGib(CSprite@ this)
{
	if (g_kidssafe)
	{
		return;
	}

	CBlob@ blob = this.getBlob();
	Vec2f pos = blob.getPosition();
	Vec2f vel = blob.getVelocity();
	vel.y -= 3.0f;
	f32 hp = Maths::Min(Maths::Abs(blob.getHealth()), 2.0f) + 1.0f;
	const u8 team = blob.getTeamNum();
	
	if(!isClient()){return;}
	CParticle@ Legs   = makeGibParticle("SoldierGibsLegs.png", pos, vel + getRandomVelocity(90, hp , 30), 0, XORRandom(3), Vec2f(16, 16), 2.0f, 20, "/BodyGibFall", team);
	CParticle@ Body   = makeGibParticle("SoldierGibsTorso.png", pos, vel + getRandomVelocity(90, hp - 0.2f , 30), 0, XORRandom(3), Vec2f(16, 16), 2.0f, 20, "/BodyGibFall", team);
}

// render cursors

void DrawCursorAt(Vec2f position, string& in filename)
{
	position = getMap().getAlignedWorldPos(position);
	if (position == Vec2f_zero) return;
	position = getDriver().getScreenPosFromWorldPos(position - Vec2f(1, 1));
	GUI::DrawIcon(filename, position, getCamera().targetDistance * getDriver().getResolutionScaleFactor());
}

const string cursorTexture = "Entities/Characters/Sprites/TileCursor.png";

void onRender(CSprite@ this)
{
	const f32 SCALEX = getDriver().getResolutionScaleFactor();
	const f32 ZOOM = getCamera().targetDistance * SCALEX;
	
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	
	if (!blob.isMyPlayer()) return;
	
	Vec2f screen_pos = blob.getInterpolatedScreenPos();
	Vec2f text_dims;
	
	string help = "hold S to aim\n\nhold A + S + D to lay prone\n(saves from gunfire a bit)\n\n press R to reload\r\rLMB for main gun\n\nRMB for active ability\n(you need hand grenades for this)";
	string text = help;
	GUI::SetFont("default");
	GUI::GetTextDimensions(text, text_dims);
	GUI::DrawText(text, screen_pos+Vec2f(-text_dims.x/2, 48*ZOOM), color_white);
}
/*
void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (!blob.isMyPlayer())
	{
		return;
	}
	if (getHUD().hasButtons())
	{
		return;
	}
	if (!blob.exists("render_z"))
		blob.set_f32("render_z", this.getZ()+0.5f);
	f32 render_z = blob.get_f32("render_z");
	CPlayer@ player = blob.getPlayer();
	if (player !is null) {
		if (player.isMyPlayer())
			this.SetZ(render_z);
		// so you're above other player sprites :>
	}

	// draw tile cursor

	if (false)//blob.isKeyPressed(key_action1))
	{
		CMap@ map = blob.getMap();
		Vec2f position = blob.getPosition();
		Vec2f cursor_position = blob.getAimPos();
		Vec2f surface_position;
		map.rayCastSolid(position, cursor_position, surface_position);
		Vec2f vector = surface_position - position;
		f32 distance = vector.getLength();
		Tile tile = map.getTile(surface_position);

		if ((map.isTileSolid(tile) || map.isTileGrass(tile.type)) && map.getSectorAtPosition(surface_position, "no build") is null && distance < 16.0f)
		{
			DrawCursorAt(surface_position, cursorTexture);
		}
	}
}
