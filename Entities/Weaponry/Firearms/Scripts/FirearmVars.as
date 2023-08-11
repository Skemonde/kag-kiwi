#include "Hitters.as";
#include "KIWI_Hitters.as";


enum AltFire
{
    Unequip = 0,
    Bayonet,
	UnderbarrelNader,
	UnderbarrelFlamer,
	LaserPointer
}

enum GunState
{
	NONE = 0,
	RELOADING, //no comments
	FIRING, //interval between main action
	ALTFIRING, //interval between RMB action
	BURSTFIRING, //interval between shots in a burst
	COOLING, //penalty after a burst
	KICKBACK //kickback animation without ejecting animation
};

class FirearmVars
{
    //Gun
	int   	T_TO_DIE; 				//Defines how many seconds before gun disspears if it hasnt been picked up. (less than 1 means disabled)
	string 	C_TAG; 					//Tag given to gun
	Vec2f 	MUZZLE_OFFSET;			//A point which bullet flies from
	Vec2f 	SPRITE_TRANSLATION;		//Moves a gun in your hand according to the offset
	Vec2f	AIM_OFFSET;
	string	BULLET;					//Type of bullet a gun shoots

	//Ammo
	uint8 	CLIP; 					//Amount of space in the clip
	uint8 	TOTAL; 					//The amount of 'spare' ammo a gun can store
	string[]AMMO_TYPE; 				//Blob used when reloading. When it's empty the gun doesn't need any ammo at all (and reloading too)
	
	//Reload
	uint8 	RELOAD_HANDFED_ROUNDS; 	//Gun loads X rounds at a time and can cancel reloads halfway. 0 turns this off and fully reloads weapon.
	bool 	EMPTY_RELOAD; 			//Gun empties the clip when reloading. This DELETES any remaining bullets in the clip. I legit don't remember why I added this, but if you wanna make realistic guns I guess it's useful.
	uint8 	RELOAD_TIME; 			//Reload timer (in ticks). This is per bullet set if using handfed
	f32		RELOAD_ANGLE;			//Angle a gun gets when it's reloading
	
	//Firing
	uint8 	FIRE_INTERVAL; 			//Time between trigger pulls (in ticks)
	bool 	FIRE_AUTOMATIC; 		//If you can hold in to shoot
	string 	ONOMATOPOEIA; 			//The text 'sound' the gun makes when fired
	string 	FLASH_SPRITE; 			//Muzzle flash sprite 16x16
	uint8 	COOLING_INTERVAL;		//Time till the moment you can shoot again after ending a shooting burst(in ticks)
	f32		RECOIL;					//Determines how far should you cursor go upwards after a single shot
	
	//Ejection
	bool 	SELF_EJECTING; 			//Whether the gun ejects cartridges per shot or on reload
	string 	CART_SPRITE; 			//Sprite used for ejected carts
	string 	CLIP_SPRITE; 			//Sprite used for ejected clips/mags
	
	//Multishot
	u8 		BURST; 					//How many rounds the gun shoots per click 
	u8 		BURST_INTERVAL; 		//Time between each bullet in a burst. (in ticks)
	uint8 	BUL_PER_SHOT; 			//Pellets per bullet
	int8  	B_SPREAD; 				//Bullet Spread as degrees of an arc.
	bool 	UNIFORM_SPREAD; 		//If bullets are evenly spaced
	
	//Trajectory
	Vec2f 	B_GRAV; 				//Bullet gravity drop \|/
	int8  	B_SPEED; 				//Bullet speed, STRONGLY AFFECTED/EFFECTS B_GRAV
	u8    	B_SPEED_RANDOM; 		//Up to this amount is added to the base speed randomly.
	u8    	B_TTL_TICKS; 			//TTL = Time To Live, bullets will live for X ticks before getting destoryed IF nothing has been hit
	u8    	RICOCHET_CHANCE; 		//The chance bullets will ricochet. 100 = 100% chance. Note the actual chance is lower than this amount, since due to bad code, bullets fail to ricochet about 25-50% of the time.
	u16		RANGE;
	
	//Damage
	float 	B_DAMAGE; 				//How many hearts of health the gun damages
	u8 		B_HITTER;				//Does it need an explanation?
	u8 		B_PENETRATION; 			//How many enemies it can pierce through. (However remember that 3 pierces means it can damage 4 enemies for example.)
	Vec2f 	B_KB;		 			//KnockBack velocity on hit
	
	//Coins
	int   	B_F_COINS; 				//Coins on hitting flesh (player or other blobs with 'flesh')
	int   	B_O_COINS; 				//Coins on hitting objects (like tanks, boulders etc)
	
	//Sound configs
	string 	S_FLESH_HIT; 			//Sound we make when hitting a fleshy object
	string 	S_OBJECT_HIT; 			//Sound we make when hitting a wall
	string 	FIRE_SOUND;				//Does it need an explanation?
	string 	CYCLE_SOUND; 			//Plays when gun is ready to do a next shot
	string 	LOAD_SOUND; 			//Plays at the start of each reload, and with every round loaded if the gun takes multiple rounds to reload
	string 	RELOAD_SOUND; 			//Plays when done reloading
	string 	FIRE_START_SOUND; 		//Plays when start shooting (eg. burst start for flamethrower)
	string 	FIRE_END_SOUND; 		//Plays when finished shooting (eg. powerdown sound for energy guns)
	f32		FIRE_PITCH;				//
	f32		CYCLE_PITCH;			//All of these four change a pitch of the main sounds of a gun
	f32		LOAD_PITCH;				//
	f32		RELOAD_PITCH;			//
	
	//Bullet Sprites
	string 	BULLET_SPRITE;
	string 	FADE_SPRITE;
	
	//Explosives
	bool 	EXPLOSIVE;
	f32 	EXPL_RADIUS;
	f32 	EXPL_DAMAGE;
	f32 	EXPL_MAP_RADIUS;
	f32 	EXPL_MAP_DAMAGE;
	bool 	EXPL_RAYCAST;
	bool 	EXPL_TEAMKILL;
	
	//Alternative Fire
    int     ALT_FIRE;               //The function to perform when rightclicking
	uint8	ALTFIRE_INTERVAL;		//Time between secondary function (in ticks)	
	
	//SUS
	bool	MELEE;
	
	FirearmVars()
	{
		//GUN
		T_TO_DIE = -1;
		C_TAG = "amogus";
		MUZZLE_OFFSET = Vec2f(-10, -10);
		SPRITE_TRANSLATION = Vec2f_zero;
		AIM_OFFSET = Vec2f_zero;
		BULLET = "bullet";
		//AMMO
		CLIP = 0;
		TOTAL = 0;
		// note for ammo do vars.AMMO_TYPE.push_back(BLOB_NAME); for the ammo gun will use for shooting
		// you can additionally push another strin for ammo type so gun does auto pickup it too
		// check example in AssaultRifle.as
		//RELOAD
		RELOAD_HANDFED_ROUNDS = 0;
		EMPTY_RELOAD = false;
		RELOAD_TIME = 30;
		RELOAD_ANGLE = 20;
		//FIRING
		FIRE_INTERVAL = 5;
		FIRE_AUTOMATIC = false;
		ONOMATOPOEIA = "bang";
		FLASH_SPRITE = "";
		COOLING_INTERVAL = 0;
		RECOIL = 0;
		//EJECTION
		SELF_EJECTING = true;
		CART_SPRITE = "RoundCase.png";
		CLIP_SPRITE = "";
		//MULTISHOT
		BURST = 1;
		BURST_INTERVAL = FIRE_INTERVAL;
		BUL_PER_SHOT = 1;
		B_SPREAD = 20;
		UNIFORM_SPREAD = false;
		//TRAJECTORY
		B_GRAV = Vec2f_zero;
		B_SPEED = 10;
		B_SPEED_RANDOM = 0;
		B_TTL_TICKS = 30;
		RICOCHET_CHANCE = 0;
		RANGE = 128;
		//DAMAGE
		B_DAMAGE = 1;
		B_HITTER = HittersKIWI::bullet_pistol;
		B_PENETRATION = 0;
		B_KB = Vec2f_zero;
		//COINS
		B_F_COINS = 0;
		B_O_COINS = 0;
		//BULLET SOUNDS
		S_FLESH_HIT = "ArrowHitFlesh.ogg";
		S_OBJECT_HIT = "BulletImpact.ogg";
		//GUN SOUNDS
		FIRE_SOUND = "rifle_shot.ogg";
		CYCLE_SOUND = "rifle_cycle.ogg";
		LOAD_SOUND = "rifle_load.ogg";
		RELOAD_SOUND = "rechamber.ogg";
		FIRE_START_SOUND = "";
		FIRE_END_SOUND = "";
		FIRE_PITCH = 1.0f;
		CYCLE_PITCH = 1.0f;
		LOAD_PITCH = 1.0f;
		RELOAD_PITCH = 1.0f;
		//BULLET SPRITES
		BULLET_SPRITE = "regular_bullet.png";
		FADE_SPRITE = "";
		//EXPLOSIVE LOGIC
		EXPLOSIVE = false;
		EXPL_RADIUS = 16;
		EXPL_DAMAGE = 15;
		EXPL_MAP_RADIUS = 16;
		EXPL_MAP_DAMAGE = 0.01;
		EXPL_RAYCAST = false;
		EXPL_TEAMKILL = false;
		//ALTERNATIVE FIRE
        ALT_FIRE = AltFire::Unequip;
		ALTFIRE_INTERVAL = 30;
		//SUS LOGIC
		MELEE = false;
	}
};

string findAmmo(CBlob@ hoomanBlob, FirearmVars@ vars)
{
	CInventory @inv = hoomanBlob.getInventory();
	if (inv is null) return "";
	for (int item_index = 0; item_index < inv.getItemsCount(); ++ item_index)
	{
		//int last_item_index = inv.getItemsCount()-1;
		CBlob@ item = inv.getItem(item_index);
		//we check the whole AMMO_TYPE array starting from the second element because the first one is reserved as a main ammo
		for (int ammo_index = 1; ammo_index < vars.AMMO_TYPE.size(); ++ammo_index) {
			string ammo_name = vars.AMMO_TYPE[ammo_index];
			if (item.getName()==ammo_name) {
				return item.getName();
			}
		}
	}
	return "";
}

bool rayHits(CBlob@ target, CBlob@ attacker, f32 angle)
{
	if (target is null || attacker is null) return false;
	
	return (target.isCollidable() || target.hasTag("flesh")) && (!target.hasTag("invincible"))&&!target.hasTag("firearm")&&CollidesWithPlatform(target, angle, attacker.isFacingLeft()) && !(target.getTeamNum() == attacker.getTeamNum()) && !target.hasTag("food");
}

const bool CollidesWithPlatform(CBlob@ platform, const f32 bullet_angle, bool gun_facing_left)
{
	if (platform.getName()!="wooden_platform"&&platform.getName()!="iron_platform") return true;
	f32 initial_platform_angle = platform.getAngleDegrees();	
	f32 platform_angle = initial_platform_angle;	
	Vec2f direction = Vec2f(0.0f, -1.0f);
	direction.RotateBy(platform_angle);
	float angle_difference = platform_angle-bullet_angle;
	
	//это пиздец...
	//have to solve the problem or super weird gun angles so i can get rid of this shittery code
	
	if (gun_facing_left) {
		platform_angle -= 90;
		angle_difference = platform_angle-bullet_angle;
		//print("platform "+platform_angle+" n bullet "+bullet_angle);
		return Maths::Abs(angle_difference)<90;
	}
	else {
		if (initial_platform_angle==0) {
			platform_angle = -270;
		}
		else if (initial_platform_angle==180) {
			platform_angle = -90;
		}
		else if (initial_platform_angle==90) {
			if (bullet_angle>-90)
				platform_angle = -360;
			else
				platform_angle = 0;
		}
		else if (initial_platform_angle==270) {
			if (bullet_angle<-90)
				platform_angle = -360;
			else
				platform_angle = 0;
		}
		angle_difference = platform_angle-bullet_angle;
		//print("platform "+platform_angle+" n bullet "+bullet_angle);
		return Maths::Abs(angle_difference)<90;
	}
	return true;
}

const Vec2f trench_aim = Vec2f(3, -5);
f32 getAimAngle( CBlob@ this, CBlob@ holder )
{
	FirearmVars@ vars;
	this.get("firearm_vars", @vars);
	CSprite@ sprite = this.getSprite();
	const Vec2f SPRITE_OFFSET = sprite.getOffset();
	const bool FLIP = this.isFacingLeft();
	const f32 FLIP_FACTOR = FLIP ? -1 : 1;
	const u16 ANGLE_FLIP_FACTOR = FLIP ? 180 : 0;
	
	CBlob@ target = null;
	if (this.get_u16("target_id")>0) {
		@target = getBlobByNetworkID(this.get_u16("target_id"));
	}
	
	const bool flip = holder.isFacingLeft();
	const f32 flip_factor = flip ? -1 : 1;
	const u16 angle_flip_factor = flip ? 180 : 0;
	this.set_Vec2f("gun_pos", (Vec2f(this.get_Vec2f("shoulder").x, vars.SPRITE_TRANSLATION.y - vars.MUZZLE_OFFSET.y)));
	Vec2f endPos = holder.getAimPos();
	if (target !is null) {
		if (holder.getPosition().x<holder.getAimPos().x&&target.getPosition().x>holder.getPosition().x
		||holder.getPosition().x>holder.getAimPos().x&&target.getPosition().x<holder.getPosition().x) {
			endPos = target.getPosition();
		}
	}
	Vec2f startPos = this.getPosition() + Vec2f(-this.get_Vec2f("shoulder").x,this.get_Vec2f("shoulder").y) + (this.hasTag("trench_aim") ? Vec2f(0,trench_aim.y) : Vec2f_zero) + Vec2f(-SPRITE_OFFSET.x, SPRITE_OFFSET.y + vars.SPRITE_TRANSLATION.y+1 + vars.AIM_OFFSET.y);
 	Vec2f aimvector = endPos - startPos;
	
	Vec2f hitPos;
	
	HitInfo@[] hitInfos;
	bool mapHit = getMap().rayCastSolid(startPos, endPos, hitPos);
	f32 length = (hitPos - startPos).Length();
	bool blobHit = getMap().getHitInfosFromRay(startPos, -aimvector.Angle(), length, this, @hitInfos);
	
	f32 return_angle = Maths::Clamp(constrainAngle(-aimvector.Angle()+angle_flip_factor), -90, 90);
	return_angle = return_angle+90;
	if (FLIP)
		return_angle = 180+return_angle;
	return_angle = Maths::Clamp(return_angle, FLIP?180:0,FLIP?360:180);
	//print("gun angle "+((return_angle*FLIP_FACTOR)+90));
	if (g_debug>0&&getGameTime()%45==0)
		print("gun angle "+return_angle);
    return return_angle;
}

f32 constrainAngle(f32 x)
{
	x = (x + 180) % 360;
	if (x < 0) x += 360;
	return x - 180;
}