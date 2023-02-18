#include "StandardFire.as";
#include "HittersKIWI.as";

//vars.BURST = 1;

//Gun
const int   T_TO_DIE = -1; //how many seconds before gun disspears if it hasnt been picked up. (less than 1 means disabled)
const string C_TAG   = "basic_gun"; //Tag given to gun
const Vec2f MUZZLE_OFFSET = Vec2f(6,-0.5);
const Vec2f SPRITE_TRANSLATION = Vec2f(4.5, -1.5);

//Ammo
const uint8 CLIP        = 6; //Amount of space in the clip
const uint8 TOTAL       = 0; //The amount of 'spare' ammo a gun can store
const string AMMO_TYPE   = "lowcal"; //Blob used when reloading

//Reload
const uint8 RELOAD_HANDFED_ROUNDS = 1; //Gun loads X rounds at a time and can cancel reloads halfway. 0 turns this off and fully reloads weapon.
const bool EMPTY_RELOAD = false; //Gun empties the clip when reloading. This DELETES any remaining bullets in the clip. I legit don't remember why I added this, but if you wanna make realistic guns I guess it's useful.
const uint8 RELOAD_TIME = 7; //Reload timer (in ticks). This is per bullet set if using handfed

//Firing
const uint8 FIRE_INTERVAL = 2; //Time between trigger pulls (in ticks)
const bool FIRE_AUTOMATIC = false; //If you can hold in to shoot
const string ONOMATOPOEIA = "bang"; //The text 'sound' the gun makes when fired

//Ejection
const bool SELF_EJECTING = false; //Whether the gun ejects cartridges per shot or on reload
const string CART_SPRITE = "RoundCase.png"; //Sprite used for ejected carts
const string CLIP_SPRITE = ""; //Sprite used for ejected clips/mags

//Multishot
const u8 BURST = 1; //How many rounds the gun shoots per click 
const u8 BURST_INTERVAL = 1; //Time between each bullet in a burst. (in ticks)
const uint8 BUL_PER_SHOT= 1; //Pellets per bullet
const int8  B_SPREAD = 5; //Bullet Spread as degrees of an arc.
const bool UNIFORM_SPREAD = false; //If bullets are evenly spaced

//Trajectory
const Vec2f B_GRAV   = Vec2f(0,0); //Bullet gravity drop \|/
const int8  B_SPEED  = 10; //Bullet speed, STRONGLY AFFECTED/EFFECTS B_GRAV
const u8    B_SPEED_RANDOM = 0; //Up to this amount is added to the base speed randomly.
const u8    B_TTL    = 24; //TTL = Time To Live, bullets will live for X ticks before getting destoryed IF nothing has been hit
const u8    RICOCHET_CHANCE = 10; //The chance bullets will ricochet. 100 = 100% chance. Note the actual chance is lower than this amount, since due to bad code, bullets fail to ricochet about 25-50% of the time.

//Damage
const float B_DAMAGE = 2; //How many hearts of health the gun damages
const u8 DMG_TYPE = HittersKIWI::bullet_pistol;
const u8 PIERCES = 0; //How many enemies it can pierce through. (However remember that 3 pierces means it can damage 4 enemies for example.)
const Vec2f B_KB = Vec2f(0,0); //KnockBack velocity on hit

//Coins
const int   B_F_COINS= 0; //Coins on hitting flesh (player or other blobs with 'flesh')
const int   B_O_COINS= 0; //Coins on hitting objects (like tanks, boulders etc)

//Sound configs
const string S_FLESH_HIT = "ArrowHitFlesh.ogg"; //Sound we make when hitting a fleshy object
const string S_OBJECT_HIT= "BulletImpact.ogg"; //Sound we make when hitting a wall

const string FIRE_SOUND    = "revolver_shot.ogg";
const string LOAD_SOUND  = "revolver_load.ogg"; //Plays at the start of each reload, and with every round loaded if the gun takes multiple rounds to reload
const string RELOAD_SOUND  = "revolver_roll.ogg"; //Plays when done reloading

//Bullet Sprites
const string BULLET_SPRITE = "regular_bullet.png";
const string FADE_SPRITE = "";
