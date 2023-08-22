#include "Hitters.as";
#include "KIWI_Hitters.as";
#include "CommonHitFXs.as";
#include "FleshHitFXs.as";
#include "SteelHitFXs.as";
#include "Knocked"

//don't forget to put a DamageProcessing.as right after this script in blob's cfg!!!

void onInit(CBlob@ this)
{
	this.Tag("steel");
	setKnockable(this);
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{	
	bool do_damage = false;
	
	// steel guys don't get more than 1 HP of damage from gunfire
	switch (customData)
	{
		//heavy machine guns and rifles with a 100% chance deal damage (and keep their damage)
		case HittersKIWI::bullet_rifle:
		case HittersKIWI::bullet_hmg:
			if (isKnockable(this)) {
				SetKnocked(this, 300);
				print("tank knocked :)");
			}
			damage *= 1; break;
			
		//50% chance smg bullet will do damage + cube of damage up to 100% starting from 3 damage
		case HittersKIWI::bullet_pistol:
			do_damage = XORRandom(30) < Maths::Min(30, 14+Maths::Pow(damage,3));
			do_damage ? damage = 1 : damage = 0; break;
		
		//10% chance shotgun buckshot will do damage
		case HittersKIWI::pellet:
			do_damage = XORRandom(10) == 0;
			do_damage ? damage = 1 : damage = 0; break;
			
		case HittersKIWI::handgren:
			if (!this.hasTag("vehicle")) break;
			damage *= 2;
			damage += XORRandom(150)/10;
			break;
			
		case Hitters::fire:
		case Hitters::burn:
			this.hasTag("flesh") ? damage *= 1 : damage = 0; break;
			
		case Hitters::flying:
			damage/=10; break;
			
		default:
			damage *= 1;
	}
	
	if (gunfireHitter(customData))
		damage *= 0.1f;
		
	bool metal_hit_fx = false;
	bool doFXs = true;
	if (this.hasTag("steel")) {
		metal_hit_fx = true;
	}
	//ONLY after all calculations we do FXs
	if (doFXs) {
		//print_damagelog(this, damage);
		if (damage > 0) {
			switch (customData) {
				case Hitters::fire:
				case Hitters::burn:
					metal_hit_fx = false;
			}
			if (metal_hit_fx) {
				playMetalSound(this);
				makeSteelGib(this.getPosition(), worldPoint, damage);
			}
		} else {
			//shieldHit(damage, this.getVelocity(), worldPoint);
		}
	}
	
	return damage;
	// blobs that have the script get only damage multiple to 1 heart in vanilla terms or half a heart in KIWI terms(1 HP)
	return Maths::Round(damage/1);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (!solid)
	{
		return;
	}

	//if (!isServer())
	//{
	//	return;
	//}

	f32 vellen = this.getShape().vellen;
	bool heavy = this.hasTag("heavy weight");
	// sound
	const f32 soundbase = heavy ? 0.7f : 2.5f;
	const f32 sounddampen = heavy ? soundbase : soundbase * 2.0f;

	if (vellen > soundbase)
	{
		f32 volume = Maths::Min(1.25f, Maths::Max(0.2f, (vellen - soundbase) / soundbase));

		if (heavy)
		{
			if (vellen > 3.0f)
			{
				this.getSprite().PlayRandomSound("BaseHitSound", volume);
			}
			else
			{
				this.getSprite().PlayRandomSound("BaseHitSound", volume);
			}
		}
		else
		{
			Vec2f sprite_dim = Vec2f(this.getSprite().getFrameWidth(), this.getSprite().getFrameHeight());
			//the bigger sprite the lower the metal sound pitch
			f32 sound_mod = (sprite_dim.x*sprite_dim.y)/750;
			this.getSprite().PlayRandomSound("BaseHitSound", volume, Maths::Max(0.3f, 2.0-sound_mod) + (XORRandom(100) / 1000.0f));
		}
	}

	const f32 base = heavy ? 5.0f : 7.0f;
	const f32 ramp = 1.2f;

	//print("stone vel " + vellen + " base " + base );
	// damage
	if (isServer() && vellen > base && !this.hasTag("ignore fall"))
	{
		if (vellen > base * ramp)
		{
			f32 damage = 0.0f;

			if (vellen < base * Maths::Pow(ramp, 1))
			{
				damage = 0.5f;
			}
			else if (vellen < base * Maths::Pow(ramp, 2))
			{
				damage = 1.0f;
			}
			else if (vellen < base * Maths::Pow(ramp, 3))
			{
				damage = 2.0f;
			}
			else if (vellen < base * Maths::Pow(ramp, 3))
			{
				damage = 3.0f;
			}
			else //very dead
			{
				damage = 100.0f;
			}

			// check if we aren't touching a trampoline
			CBlob@[] overlapping;

			if (this.getOverlapping(@overlapping))
			{
				for (uint i = 0; i < overlapping.length; i++)
				{
					CBlob@ b = overlapping[i];

					if (b.hasTag("no falldamage"))
					{
						return;
					}
				}
			}

			this.server_Hit(this, point1, normal, damage, Hitters::fall);
		}
	}
}