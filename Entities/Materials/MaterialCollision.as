
bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return !(blob.hasTag("flesh") || blob.hasTag("vehicle"));
}