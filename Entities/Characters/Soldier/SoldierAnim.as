#include "FireCommon.as"
#include "Requirements.as"
#include "RunnerAnimCommon.as"
#include "RunnerCommon.as"
#include "Knocked.as"
#include "PixelOffsets.as"
#include "RunnerTextures.as"
#include "SoldierCommon.as";

const string shiny_layer = "shiny bit";

void onInit(CSprite@ this)
{
	addRunnerTextures(this, "soldat", "Soldier");

	this.getCurrentScript().runFlags |= Script::tick_not_infire;
	
	this.getBlob().set_f32("gun_aimangle", 69);
}

CSpriteLayer@ getArmSprite (CSprite@ this)
{
	this.RemoveSpriteLayer("right_arm");
	CSpriteLayer@ right_arm = this.addSpriteLayer("right_arm", "right_arm.png", 16, 16, this.getBlob().getTeamNum(), 0);
	
	Animation@ anim = right_arm.addAnimation("default", 1, false);
	anim.AddFrame(0);
	Animation@ aim_anim = right_arm.addAnimation("aim", 1, false);
	aim_anim.AddFrame(1);
	right_arm.SetRelativeZ(11.0f);
	right_arm.SetOffset(Vec2f(-2, 0));
	right_arm.SetVisible(false);
	
	return right_arm;
}

CSpriteLayer@ getUpperBodySprite (CSprite@ this)
{
	this.RemoveSpriteLayer("upper_body");
	CSpriteLayer@ upper_body = this.addSpriteLayer("upper_body", "SoldierFemale", 32, 32, this.getBlob().getTeamNum(), 0);
	
	u8 spite_sheet_shift = 16;
	
	Animation@ idle_torso = upper_body.addAnimation("idle_torso", 1, false);
	int[] idle_frames = { spite_sheet_shift };
	idle_torso.AddFrame(spite_sheet_shift);
	
	Animation@ walking_torso = upper_body.addAnimation("walking_torso", 3, true);
	int[] walking_frames = { spite_sheet_shift+1, spite_sheet_shift+2, spite_sheet_shift+3, spite_sheet_shift+4 };
	walking_torso.AddFrames(walking_frames);
	
	Animation@ crouching_torso = upper_body.addAnimation("crouching_torso", 1, false);
	int[] crouching_frames = { spite_sheet_shift+8 };
	crouching_torso.AddFrames(crouching_frames);
	
	Animation@ falling_torso = upper_body.addAnimation("falling_torso", 5, true);
	int[] falling_frames = { spite_sheet_shift+5, spite_sheet_shift+6, spite_sheet_shift+7 };
	falling_torso.AddFrames(falling_frames);
	
	Animation@ aiming_torso = upper_body.addAnimation("aiming_torso", 1, false);
	int[] aiming_frames = { spite_sheet_shift+9 };
	aiming_torso.AddFrames(aiming_frames);
	
	Animation@ aiming_falling_torso = upper_body.addAnimation("aiming_falling_torso", 5, true);
	int[] aiming_falling_frames = { 8+spite_sheet_shift+5, 8+spite_sheet_shift+6, 8+spite_sheet_shift+7 };
	aiming_falling_torso.AddFrames(aiming_falling_frames);
	
	upper_body.SetRelativeZ(0.1f);
	upper_body.SetOffset(Vec2f(0, -4));
	upper_body.SetVisible(true);
	
	return upper_body;
}

void onPlayerInfoChanged(CSprite@ this)
{
	addRunnerTextures(this, "soldat", "Soldier");
	//
	CSpriteLayer@ right_arm = getArmSprite(this);
	CSpriteLayer@ upper_body = getUpperBodySprite(this);
}

void onTick(CSprite@ this)
{
	if (this is null) return;
	const bool flip = this.isFacingLeft();
	const f32 flip_factor = flip ? -1: 1;
	// store some vars for ease and speed
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	Vec2f pos = blob.getPosition();
	Vec2f aimpos;

	const u8 knocked = getKnocked(blob);

	bool pressed_a1 = blob.isKeyPressed(key_action1);
	bool pressed_a2 = blob.isKeyPressed(key_action2);

	bool walking = (blob.isKeyPressed(key_left) || blob.isKeyPressed(key_right));

	aimpos = blob.getAimPos();
	bool inair = (!blob.isOnGround() && !blob.isOnLadder());

	Vec2f vel = blob.getVelocity();

	if (blob.hasTag("dead"))
	{
		this.SetAnimation("dead");
		return;
	}

	// get the angle of aiming with mouse
	Vec2f vec;
	int direction = blob.getAimDirection(vec);
	
	const bool left = blob.isKeyPressed(key_left);
	const bool right = blob.isKeyPressed(key_right);
	
	CSpriteLayer@ right_arm = this.getSpriteLayer("right_arm");
	if (right_arm is null) @right_arm = getArmSprite(this);
	
	CSpriteLayer@ upper_body = this.getSpriteLayer("upper_body");
	if (upper_body is null) @upper_body = getUpperBodySprite(this);
	
	CBlob@ carried = blob.getCarriedBlob();
	
	bool aiming = false;
	if (carried !is null && carried.hasTag("firearm"))
	{
		f32 aimangle = carried.get_f32("aimangle");
		right_arm.SetVisible(true);
		right_arm.ResetTransform();
		right_arm.RotateBy(aimangle, Vec2f(5 * flip_factor, 0));
		
		//for soldat's arm
		if (carried.get_bool("aiming"))
			right_arm.SetAnimation("aim");
		else
			right_arm.SetAnimation("default");
			
		//for soldat's torso
		//we don't set for his legs because he can obviously walk while aiming
		upper_body.SetAnimation("aiming_torso");
		//you can easily tell aiming torso animation has most priority B)
		// todo: aiming torso anims for run, jump and crouch
		// todo: changing shoulder offset for crouch and jump dynamically
		aiming = true;
		//return;
	}
	else
	{
		right_arm.SetVisible(false);
		aiming = false;
	}
	
	Vec2f anim_shoulder_offset = Vec2f_zero;
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
	else if (knocked > 0)
	{
		if (inair)
		{
			this.SetAnimation("knocked_air");
		}
		else
		{
			this.SetAnimation("knocked");
		}
	}
	else if (inair && !blob.isAttached())
	{
		RunnerMoveVars@ moveVars;
		if (!blob.get("moveVars", @moveVars))
		{
			return;
		}
		f32 vy = vel.y;
		if (vy < -0.0f && moveVars.walljumped)
		{
			this.SetAnimation("run");
			if (!aiming)
				upper_body.SetAnimation("walking_torso");
		}
		else
		{
			this.SetAnimation("fall");
			this.animation.timer = 0;
			
			if (aiming)
				upper_body.SetAnimation("aiming_falling_torso");
			else
				upper_body.SetAnimation("falling_torso");
			upper_body.animation.timer = 0;

			if (vy < -1.5)
			{
				this.animation.frame = 0;
				upper_body.animation.frame = 0;
				anim_shoulder_offset = Vec2f(2, -2);
			}
			else if (vy > 1.5)
			{
				this.animation.frame = 2;
				upper_body.animation.frame = 2;
			}
			else
			{
				this.animation.frame = 1;
				upper_body.animation.frame = 1;
				anim_shoulder_offset = Vec2f(1, -3);
			}
			right_arm.SetOffset(Vec2f(-2, 0) + anim_shoulder_offset);
			if (carried !is null)
				carried.set_Vec2f("gun_trans_from_carrier", anim_shoulder_offset);
		}
	}
	else if (blob.hasTag("seated") || (blob.isKeyPressed(key_down) && !blob.isOnLadder() && !walking && !(right || left)) || blob.isAttached())
	{
		anim_shoulder_offset = Vec2f(0, -22);
		this.SetAnimation("crouch");
		if (!aiming)
			upper_body.SetAnimation("crouching_torso");
		right_arm.SetOffset(Vec2f(-2, 0) + anim_shoulder_offset);
		if (carried !is null)
			carried.set_Vec2f("gun_trans_from_carrier", anim_shoulder_offset);
		//blob.Tag("dead head");
	}
	else if (right || left)
	{
		this.SetAnimation("run");
		if (!aiming)
			upper_body.SetAnimation("walking_torso");
			
		anim_shoulder_offset = Vec2f_zero;
		right_arm.SetOffset(Vec2f(-2, 0) + anim_shoulder_offset);
		if (carried !is null)
			carried.set_Vec2f("gun_trans_from_carrier", anim_shoulder_offset);
	}
	else if (walking ||
	         (blob.isOnLadder() && (blob.isKeyPressed(key_up) || blob.isKeyPressed(key_down))))
	{
		this.SetAnimation("run");
		if (!aiming)
			upper_body.SetAnimation("walking_torso");
			
		anim_shoulder_offset = Vec2f_zero;
		right_arm.SetOffset(Vec2f(-2, 0) + anim_shoulder_offset);
		if (carried !is null)
			carried.set_Vec2f("gun_trans_from_carrier", anim_shoulder_offset);
	}
	else
	{
		this.SetAnimation("idle");
		if (!aiming)
			upper_body.SetAnimation("idle_torso");
		
		anim_shoulder_offset = Vec2f_zero;
		right_arm.SetOffset(Vec2f(-2, 0) + anim_shoulder_offset);
		if (carried !is null)
			carried.set_Vec2f("gun_trans_from_carrier", anim_shoulder_offset);
		//blob.Untag("dead head");
	}
	/*

	CSpriteLayer@ chop = this.getSpriteLayer("chop");

	bool wantsChopLayer = false;
	s32 chopframe = 0;
	f32 chopAngle = 0.0f;

	if (chop !is null)
	{
		chop.SetVisible(wantsChopLayer);
		if (wantsChopLayer)
		{
			printf("e");
			f32 choplength = 5.0f;

			chop.animation.frame = chopframe;
			Vec2f offset = Vec2f(choplength, 0.0f);
			offset.RotateBy(chopAngle, Vec2f_zero);
			if (!this.isFacingLeft())
				offset.x *= -1.0f;
			offset.y += this.getOffset().y * 0.5f;

			chop.SetOffset(offset);
			chop.ResetTransform();
			if (this.isFacingLeft())
				chop.RotateBy(180.0f + chopAngle, Vec2f());
			else
				chop.RotateBy(chopAngle, Vec2f());
		}
	}
	//set the head anim
	if (knocked > 0)
	{
		blob.Tag("dead head");
	}
	else if (blob.isKeyPressed(key_action2))
	{
		blob.Tag("attack head");
		blob.Untag("dead head");
	}
	else
	{
		blob.Untag("attack head");
		blob.Untag("dead head");
	}
	*/
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
	CParticle@ Legs   = makeGibParticle("SoldierGibs.png", pos, vel + getRandomVelocity(90, hp , 80), 0, 0, Vec2f(16, 16), 2.0f, 20, "/BodyGibFall", team);
	CParticle@ Body   = makeGibParticle("SoldierGibs.png", pos, vel + getRandomVelocity(90, hp - 0.2 , 80), 1, 0, Vec2f(16, 16), 2.0f, 20, "/BodyGibFall", team);
	//CParticle@ Helm   = makeGibParticle("SoldierGibs.png", pos, vel + getRandomVelocity(90, hp , 80), 2, 0, Vec2f(16, 16), 2.0f, 0, "Sounds/material_drop.ogg", team);
	// todo: make them drop hats upon death
	//CParticle@ Hat    = makeGibParticle(blob.get_string("hat_name"), pos, vel + getRandomVelocity(90, hp + 1 , 80), 3, 0, Vec2f(32, 32), 2.0f, 0, "Sounds/material_drop.ogg", team);
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
	CBlob@ blob = this.getBlob();
	if (!blob.isMyPlayer())
	{
		return;
	}
	if (getHUD().hasButtons())
	{
		return;
	}

	// draw tile cursor

	if (blob.isKeyPressed(key_action1))
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
