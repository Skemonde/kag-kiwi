namespace HittersKIWI
{
	shared enum hits_kiwi
	{
		//for pistols, smgs or somthing that will not even scratch steel
		bullet_pistol = 100,
		//for good old rifle
		bullet_rifle,
		//heavy machine gun or heavy bullets. Made for something that can tear even steel as newspaper
		bullet_hmg,
		//shotguns?
		pellet,
		//boom is boom
		boom,
		//Commander Officer's will - cos will
		//if commander want's to execute someone - we use this hitter
		cos_will,
		//funny
		chair,
		//zomb
		zomb,
		
		bayonet,
		shovel,
		
		reg = 150,
		spp,
		usar,
		shag,
		hmg,
		
		miz = 200,
		kep,
		tesr,
		ptz,
		hord,
		tank_mg,
		
		landmine = 250,
		tankmine,
		tank_cannon,
		apc_cannon,
		atr,
		sentry,
		handgren,
		rocketer,
		
		//i made this so i don't need to rearrange comma if i decide to add a new hitter in a list above :P
		thrown_kiwi
	};
}

bool explosionHitter(u8 hitterData)
{
	return hitterData==HittersKIWI::tank_cannon
		|| hitterData==HittersKIWI::handgren
		|| hitterData==HittersKIWI::rocketer
		//|| hitterData==HittersKIWI::landmine
		|| hitterData==HittersKIWI::tankmine
		|| hitterData==HittersKIWI::boom;
}

bool gunfireHitter(u8 hitterData)
{
	return hitterData >= HittersKIWI::reg && hitterData < HittersKIWI::landmine
		|| hitterData == HittersKIWI::cos_will;
}