#include "Hitters.as";
#include "HittersKIWI.as";


enum AltFire
{
    Unequip = 0,
    Bayonet,
	UnderbarrelNader,
	UnderbarrelFlamer
}



class FirearmVars
{
	
    
    //Gun
	int   	T_TO_DIE; 				//Defines how many seconds before gun disspears if it hasnt been picked up. (less than 1 means disabled)
	string 	C_TAG; 					//Tag given to gun
	Vec2f 	MUZZLE_OFFSET;			//A point which bullet flies from
	Vec2f 	SPRITE_TRANSLATION;		//Moves a gun in your hand according to the offset
    int     ALT_FIRE;               //The function to perform when rightclicking

	//Ammo
	uint8 	CLIP; 					//Amount of space in the clip
	uint8 	TOTAL; 					//The amount of 'spare' ammo a gun can store
	string 	AMMO_TYPE; 				//Blob used when reloading. When it's empty the gun doesn't need any ammo at all (and reloading too)
	
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
	
	//SUS
	bool	MELEE;
	
	FirearmVars()
	{
		//GUN
		T_TO_DIE = -1;
		C_TAG = "amogus";
		MUZZLE_OFFSET = Vec2f(-10, -10);
		SPRITE_TRANSLATION = Vec2f_zero;
        ALT_FIRE = AltFire::Unequip;
		//AMMO
		CLIP = 0;
		TOTAL = 0;
		AMMO_TYPE = "lowcal";
		//RELOAD
		RELOAD_HANDFED_ROUNDS = 0;
		EMPTY_RELOAD = false;
		RELOAD_TIME = 30;
		RELOAD_ANGLE = 20;
		//FIRING
		FIRE_INTERVAL = 5;
		FIRE_AUTOMATIC = false;
		ONOMATOPOEIA = "bang";
		FLASH_SPRITE = "flash_bullet32.png";
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
		RICOCHET_CHANCE = 10;
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
		//SUS LOGIC
		MELEE = false;
	}
};