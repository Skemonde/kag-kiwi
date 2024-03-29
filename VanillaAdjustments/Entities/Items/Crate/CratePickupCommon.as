// For crate autopickups

bool crateTake(CBlob@ this, CBlob@ blob)
{
    if (this.exists("packed"))
    {
        return false;
    }

    const string blobName = blob.getName();

    if (   blobName == "mat_gold"
        || blobName == "mat_stone"
        || blobName == "mat_wood"
        || blobName == "mat_bombs"
        || blobName == "mat_waterbombs"
        || blobName == "mat_arrows"
        || blobName == "mat_firearrows"
        || blobName == "mat_bombarrows"
        || blobName == "mat_waterarrows"
        || blobName == "log"
        || blobName == "fishy"
        || blobName == "froggy"
        || blobName == "grain"
        || blobName == "food"
        || blobName == "egg"
        )
    {
        return this.server_PutInInventory(blob);
    }
	if (!blob.isAttached() && (blob.hasTag("firearm") || blob.hasTag("material") || blob.hasTag("crate pickup")) && blob.getName() != "mat_arrows")
	{
        return this.server_PutInInventory(blob);
	}
    return false;
}
