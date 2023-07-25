

void onInit(CBlob@ this)
{
	CRules@ rules = getRules();
	rules.set_u16("gunfire_handle", this.getNetworkID());
}