#include "HittersKIWI.as";

class FirearmVars
{
	u8 FIRE_INTERVAL;
	u8 INACCURACY;
	u16 BURST;
	
	u16 MAG;
	u16 CLIP;
	string AMMO;
	u8 RELOAD;
	string RELOAD_SOUND;
	
	int8 PROJ_SPEED;
	u16 PROJ_AMOUNT;
	string PROJ_BLOB;
	u8 PROJ_HITTER;
	float PROJ_DAMAGE;
	float PROJ_RANGE;
	
	string FIRE_SOUND;
	
	Vec2f MUZZLE_OFFSET;
	Vec2f GUN_TRANS;
	Vec2f KICKBACK_FORCE;
	
	float RELOAD_SOUND_PITCH;
	float FIRE_SOUND_PITCH;
	float RELOAD_ENDING_SOUND_PITCH;
	float CYCLE_SOUND_PITCH;

	FirearmVars()
	{
		FIRE_INTERVAL = 5;
		INACCURACY = 5;
		BURST = 3;
		
		MAG = 20;
		CLIP = 0;
		AMMO = "lowcal";
		RELOAD = 30;
		RELOAD_SOUND = "smg_reload";
		
		PROJ_SPEED = 30;
		PROJ_AMOUNT = 1;
		PROJ_BLOB = "bullet";
		PROJ_HITTER = HittersKIWI::bullet_pistol;
		PROJ_DAMAGE = 1.0f;
		PROJ_RANGE = 128.0f;
		
		FIRE_SOUND = "M16_Shoot";
		
		MUZZLE_OFFSET = Vec2f(-10, -10);
		GUN_TRANS = Vec2f(3, -2);
		KICKBACK_FORCE = Vec2f(-3, 4);
		
		RELOAD_SOUND_PITCH = 1.0f;
		FIRE_SOUND_PITCH = 1.0f;
		RELOAD_ENDING_SOUND_PITCH = 1.0f;
		CYCLE_SOUND_PITCH = 1.0f;
	}
};