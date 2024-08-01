#include "FirearmVars"
#include "KIWI_Locales"

void onInit(CBlob@ this)
{
	this.setInventoryName("Flamethrower");
	this.Tag("looped_sound");
	//this.Tag("has_zoom");
	OnBlobShot@ shot_funcdef = @onBlobShot;
	this.set("onBlobShot handle", @shot_funcdef);
	
	
	FirearmVars vars = FirearmVars();
	//GUN
	vars.T_TO_DIE 					= -1;
	vars.C_TAG						= "advanced_gun";
	vars.MUZZLE_OFFSET				= Vec2f(-28, 1);
	vars.SPRITE_TRANSLATION			= Vec2f(14, 1);
	vars.BULLET						= "napalm";
	//AMMO
	vars.CLIP						= 50; 
	vars.TOTAL						= 0; 
	vars.AMMO_TYPE.push_back("fuelcanister");
	//RELOAD
	vars.RELOAD_HANDFED_ROUNDS		= 0; 
	vars.EMPTY_RELOAD				= false;
	vars.RELOAD_TIME				= 60;
	vars.RELOAD_ANGLE				= -10;
	//FIRING
	vars.FIRE_INTERVAL				= 3; 
	vars.FIRE_AUTOMATIC				= true; 
	vars.ONOMATOPOEIA				= "";
	vars.FLASH_SPRITE				= "";
	vars.RECOIL						= 0;
	//EJECTION
	vars.SELF_EJECTING				= false; 
	vars.CART_SPRITE				= ""; 
	vars.CLIP_SPRITE				= "";
	//MULTISHOT
	vars.BURST						= 0;
	vars.BURST_INTERVAL				= 2;
	vars.BUL_PER_SHOT				= 2; 
	vars.B_SPREAD					= 15; 
	vars.UNIFORM_SPREAD				= false;
	//TRAJECTORY
	vars.B_GRAV						= Vec2f(0, 0);
	vars.B_SPEED					= 13; 
	vars.B_SPEED_RANDOM				= 2;
	vars.RANGE						= getMap().tilesize*100;
	//DAMAGE
	vars.B_DAMAGE					= 11; 
	vars.B_HITTER					= HittersKIWI::assault_rifle;
	vars.B_PENETRATION				= 0;
	//BULLET SOUNDS
	vars.S_FLESH_HIT				= "ArrowHitFlesh.ogg";
	vars.S_OBJECT_HIT				= "BulletImpact.ogg"; 
	//GUN SOUNDS
	vars.FIRE_SOUND					= "flamethrower_fire.ogg";
	vars.FIRE_PITCH					= 1.0f;
	vars.CYCLE_SOUND				= "";
	vars.CYCLE_PITCH				= 1.0f;
	vars.LOAD_SOUND					= "smg_load.ogg";
	vars.LOAD_PITCH					= 0.7f;
	vars.RELOAD_SOUND				= "metal_slug_fullok.ogg";
	vars.RELOAD_PITCH				= 1.0f;
	vars.FIRE_START_SOUND			= "flamethrower_flash.ogg";
	//BULLET SPRITES
	vars.BULLET_SPRITE				= "smg_bullet";
	vars.FADE_SPRITE				= "";
	this.set("firearm_vars", @vars);
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	CBlob@ prev_holder = getBlobByNetworkID(blob.get_u16("previous_holder"));
	if (prev_holder is null) return;
	
	CSprite@ holder_sprite = prev_holder.getSprite();
	
	CSpriteLayer@ tank = holder_sprite.getSpriteLayer("tank");
	if (tank is null) return;
	if (!tank.isVisible()) return;
	
	tank.SetOffset(blob.get_Vec2f("tank_layer_offset")+blob.get_Vec2f("gun_trans_from_carrier"));
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint) 
{
	if (!attached.hasTag("player")) return;
	
	CSprite@ sprite = attached.getSprite();
	CSpriteLayer@ tank = sprite.getSpriteLayer("tank");
	if (tank is null)
		@tank = createATankLayer(attached);
	if (tank is null) return;
	
	tank.SetVisible(true);
	tank.SetOffset(Vec2f(6, -8));
	tank.SetRelativeZ(-1.0f);
	
	this.set_Vec2f("tank_layer_offset", tank.getOffset());
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint @detachedPoint) 
{
	if (!detached.hasTag("player")) return;
	
	CSprite@ sprite = detached.getSprite();
	CSpriteLayer@ tank = sprite.getSpriteLayer("tank");
	if (tank is null)
		createATankLayer(detached);
	if (tank is null) return;
	
	tank.SetVisible(false);
}

CSpriteLayer@ createATankLayer(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	
	CSpriteLayer@ tank = sprite.addSpriteLayer("tank", "SteamEngine.png", 32, 32);
	if (tank !is null)
	{
		tank.SetVisible(false);
	}
	
	return tank;
}

void onBlobShot(u16 gun_id, f32 angle, u16 gunner_id, Vec2f pos, u16 proj_id)
{
	CBlob@ this = getBlobByNetworkID(gun_id);
	if (this is null) return;
	
	CBlob@ proj = getBlobByNetworkID(proj_id);
	if (proj is null) return;
	
	CBlob@ gunner = getBlobByNetworkID(gunner_id);
	if (gunner is null) return;
	
	const bool FLIP = proj.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	proj.getShape().SetGravityScale(1.9f);
	proj.server_SetTimeToDie(10.0f);
	proj.Tag("no_death_fire");
	proj.set_Vec2f("initial_pos", pos+gunner.getVelocity());
	proj.Sync("initial_pos", true);
	//proj.setPosition(pos-Vec2f(0, this.getWidth()).RotateBy(proj.getAngleDegrees()));
	//proj.set_Vec2f("owner_vel", Vec2f(gunner.getVelocity().x, 0));
	//proj.setVelocity(proj.getVelocity());
}