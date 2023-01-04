#include "FirearmVars.as";

// custom variables

//this.set_f32("ClampedAimangle", FLOAT); sets angle of shooting for a firearm
//this.set_string("CustomMuzzleFlash", STRING); custom file for muzzle flash
//this.set_string("CustomCycleSound", STRING); sets sound for playing after each shot made
//this.set_string("CustomReloadingEnding", STRING); sets sound for playing after reloading
//this.set_string("CustomEmptyCase", STRING); custom file for empty case firearm drops
//this.set_string("CustomShotFX", STRING); custom file for shooting FX

// custom tags

//this.Tag("CustomMuzzleLeft"); sets muzzle flash in the opposite direction
//this.Tag("ReloadByOneRound"); reloads firearm by one round a cycle instead of filling full magazine
//this.Tag("NoBurstPenalty"); you don't get penalty after each burst you made (for automatic guns)
//this.Tag("NoAccuracyBonus"); removes super accuracy bonus for first made shots in a burst (for automatic guns)
//this.Tag("EmptyCaseDuringReload"); makes firearm drop empty cases from made shots when you reload the firearm instead of dropping them after each made shot
//this.Tag("UniformSpread"); makes bullets from one shot go in a uniform spread (for shotguns)
//this.Tag("UniformSpeed"); removes RNG from bullet speed
//this.Tag("EmptyMagazineParticle"); makes firearm drop empty magazine when you reaload the firearm (name file of magazine FIREARM_BLOBNAME + "_magazine")

void onInit(CBlob@ this)
{
	FirearmVars vars = FirearmVars();
	
	vars.FIRE_INTERVAL = 0; // time in between shots
	vars.INACCURACY = 3; // for bullet spread
	vars.BURST = 20; // how many bullets we shoot after LMB?
	
	vars.MAG = 20; // round capacity
	//vars.CLIP = 0; // rounds at firearm's init
	vars.AMMO = "highpow"; // ammo blob
	vars.RELOAD = 45; // reloading time. Set in ticks
	//vars.RELOAD_SOUND = "LeverRifle_Load"; // reloading sound
	
	vars.PROJ_SPEED = 25; // bullet speed
	//vars.PROJ_AMOUNT = 10; // how many bullets we shot per each shot?
	vars.PROJ_BLOB = "bullet"; // bullet blob
	vars.PROJ_HITTER = HittersKIWI::bullet_hmg; // hitter. You guessed it
	vars.PROJ_DAMAGE = 4; // damage one bullet deals
	vars.PROJ_RANGE = 820; // how far should bullet go? Set in pixels
	
	vars.FIRE_SOUND = "ruhm_shot"; // shooting sound
	
	vars.MUZZLE_OFFSET = Vec2f(-30, -1); // where is firearm's barrel ends?
	vars.GUN_TRANS = Vec2f(16, -2); // where do we want to hold our firearm?
	vars.KICKBACK_FORCE = Vec2f(-3, 0); // how far firearm's kicked when shot?
	
	vars.RELOAD_SOUND_PITCH = 0.75f; // reloading sound pitch
	//vars.FIRE_SOUND_PITCH = 1.0f; // fire sound pitch
	//vars.RELOAD_ENDING_SOUND_PITCH = 1.0f; // reload ending sound pitch
	//vars.CYCLE_SOUND_PITCH = 1.0f; // shot cycle sound pitch
	
	this.set("firearm_vars", @vars);
	
	// custom tags and variables
	this.Tag("EmptyMagazineParticle");
	this.Tag("heavy weight");
}