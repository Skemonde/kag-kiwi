bool isHoldingBrickHammer(CBlob@ blob)
{
	//CBlob@ carried = blob.getCarriedBlob();
	//if (carried is null) return false;
	//if (carried.getName()=="masonhammer") return true;
	return blob.getBlobCount("masonhammer")>0;
	
	return false;
}