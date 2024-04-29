
void MakeMat(CBlob@ this, Vec2f pos, string name, s32 amount)
{
	CBlob@ mat = server_CreateBlobNoInit(name);

	if (mat is null) return;

	//setup res
	mat.Tag("custom quantity");
	mat.Init();
	mat.setPosition(pos);
	mat.server_SetQuantity(amount);
}
