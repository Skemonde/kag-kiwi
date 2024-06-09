void onInit(CBlob@ this)
{
	//these don't actually use it, they take the controls away
	this.push("names to activate", "lantern");
	this.push("names to activate", "crate");
	this.push("names to activate", "froggy"); // handgrenade
	this.push("names to activate", "flashy"); // flash grenade
	this.push("names to activate", "molotov"); // fire grenade
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}
