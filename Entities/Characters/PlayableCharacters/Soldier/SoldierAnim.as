#include "FireCommon.as"
#include "Requirements.as"
#include "RunnerAnimCommon.as"
#include "RunnerCommon.as"
#include "Knocked.as"
#include "PixelOffsets.as"
#include "RunnerTextures.as"
#include "SoldierCommon.as";

const string shiny_layer = "shiny bit";
const Vec2f trench_aim = Vec2f(0,0);

void onInit(CSprite@ this)
{
	addRunnerTextures(this, "soldat", "Soldier");

	this.getCurrentScript().runFlags |= Script::tick_not_infire;
	
	this.getBlob().set_f32("gun_aimangle", 69);
	
	this.SetEmitSound("panteri.ogg");
	this.SetEmitSoundSpeed(1);
	this.SetEmitSoundVolume(0.4);
	this.SetEmitSoundPaused(true);
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
	upper_body.SetVisible(this.getBlob().hasTag("dead") ? false : this.isVisible());
	
	return upper_body;
}

void onPlayerInfoChanged(CSprite@ this)
{
	addRunnerTextures(this, "soldat", "Soldier");
	//
	CSpriteLayer@ right_arm = getArmSprite(this);
	CSpriteLayer@ torso = getUpperBodySprite(this, "torso", 0);
	CSpriteLayer@ arms = getUpperBodySprite(this, "arms", 10);
	CSpriteLayer@ legs = getUpperBodySprite(this, "legs", 20);
}

void onTick(CSprite@ this)
{
	if (this is null) return;
	const bool flip = this.isFacingLeft();
	const f32 flip_factor = flip ? -1: 1;
	// store some vars for ease and speed
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
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

	if (blob.hasTag("dead"))
	{
		this.SetAnimation("dead");
		return;
	}
	
	/* CPlayer@ player = blob.getPlayer();
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
	
	CSpriteLayer@ right_arm = this.getSpriteLayer("right_arm");
	if (right_arm is null) @right_arm = getArmSprite(this);
	
	CSpriteLayer@ torso = this.getSpriteLayer("torso");
	if (torso is null) @torso = getUpperBodySprite(this, "torso", 0);
	CSpriteLayer@ arms = this.getSpriteLayer("arms");
	if (arms is null) @arms = getUpperBodySprite(this, "arms", 10);
	CSpriteLayer@ legs = this.getSpriteLayer("legs");
	if (legs is null) @legs = getUpperBodySprite(this, "legs", 20);
	
	CBlob@ carried = blob.getCarriedBlob();
	Vec2f default_shoulder = Vec2f(0, 0);
	Vec2f anim_shoulder_offset = Vec2f_zero;
	
	bool aiming = false;
	if (carried !is null && carried.hasTag("firearm") || blob.isAttachedToPoint("MACHINEGUNNER"))
	{
		f32 aimangle = 0;
		if (carried !is null)
			aimangle = carried.get_f32("gunSpriteAngle");
		right_arm.SetVisible(true||!blob.hasTag("isInVehicle"));
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
	else if (blob.hasTag("seated") || (blob.isKeyPressed(key_down) && !blob.isOnLadder() && !walking && !(right || left)) || blob.isAttached())
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
	else if (right || left)
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
	else if (walking ||
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
		if(carried.hasTag("trench_aim")) anim_shoulder_offset+=trench_aim;
		carried.set_Vec2f("gun_trans_from_carrier", anim_shoulder_offset);
	}
	right_arm.SetOffset(Vec2f(-2, 0) + anim_shoulder_offset);
	torso.SetRelativeZ(this.getRelativeZ()+0.1);
	legs.SetRelativeZ(this.getRelativeZ()+0.2);
	arms.SetRelativeZ(this.getRelativeZ()+0.3);
	right_arm.SetRelativeZ(!blob.hasTag("isInVehicle")?(this.getRelativeZ()+500):(this.getRelativeZ()+0.3f));
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
