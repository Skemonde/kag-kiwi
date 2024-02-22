#include "ResearchCommon.as"
#include "Requirements_Tech.as"

string getButtonRequirementsText(CBitStream& inout bs,bool missing)
{
	string text,requiredType,name,friendlyName;
	u16 quantity=0;
	bs.ResetBitIndex();

	while (!bs.isBufferEnd())
	{
		ReadRequirement(bs,requiredType,name,friendlyName,quantity);
		string quantityColor;

		if(missing)
		{
			quantityColor="$RED$";
		}
		else
		{
			quantityColor="$GREEN$";
		}

		if(requiredType=="blob")
		{
			if(quantity>0)
			{
				text += quantity;
				text += " ";
			}
			text += quantityColor;
			if (missing)
				text += "   more";
			text += "$"; text += name; text += "$";
			text += " ";
			text += friendlyName;
			text += " required\n";
			text += quantityColor;
			text += "\n";
		}
		else if(requiredType=="tech")
		{
			text += " \n$"; text += name; text += "$ ";
			text += quantityColor;
			text += friendlyName;
			text += quantityColor;
			// text += "\n\ntechnology required.\n";
		}
		else if(requiredType=="not tech" && missing)
		{
			text += " \n";
			text += quantityColor;
			text += friendlyName;
			text += " technology already acquired.\n";
			text += quantityColor;
		}
		else if(requiredType=="coin")
		{
			text += quantity;
			text += quantityColor;
			if (missing)
				text += "   more";
			text += " $icon_dogtag$";
			text += " required\n";
			text += quantityColor;
		}
		else if(requiredType=="no more" && missing)
		{
			text += quantityColor;
			text += "Only "+quantity+" "+friendlyName+" per-team possible. \n";
			text += quantityColor;
		}
		else if(requiredType=="no less" && missing)
		{
			text += quantityColor;
			text += "At least "+quantity+" "+friendlyName+" required. \n";
			text += quantityColor;
		}

	}

	return text;
}

void SetItemDescription(CGridButton@ button,CBlob@ caller,CBitStream &in reqs,const string& in description,CInventory@ anotherInventory=null)
{
	if(button !is null && caller !is null && caller.getInventory() !is null)
	{
		CBitStream missing;

		if(hasRequirements(caller.getInventory(),anotherInventory,reqs,missing))
		{
			button.hoverText=description+"\n\n "+getButtonRequirementsText(reqs,false);
		}
		else
		{
			button.hoverText=description+"\n\n "+getButtonRequirementsText(missing,true);
			button.SetEnabled(false);
		}
	}
}

// read/write

void AddRequirement(CBitStream &inout bs,const string &in req,const string &in blobName,const string &in friendlyName,u16 &in quantity=1)
{
	bs.write_string(req);
	bs.write_string(blobName);
	bs.write_string(friendlyName);
	bs.write_u16(quantity);
}

void AddHurtRequirement(CBitStream &inout bs)
{
	bs.write_string("hurt");
}

bool ReadRequirement(CBitStream &inout bs,string &out req,string &out blobName,string &out friendlyName,u16 &out quantity)
{
	if(!bs.saferead_string(req))
	{
		return false;
	}

	if(!bs.saferead_string(blobName))
	{
		return false;
	}

	if(!bs.saferead_string(friendlyName))
	{
		return false;
	}

	if(!bs.saferead_u16(quantity))
	{
		return false;
	}

	return true;
}

CBlob@[] getBaseBlobs(CBlob@ playerBlob)
{
	CBlob@[] baseBlobs;
	
	f32 maxStorageReach = 32.0f;
	getBlobsByTag("remote_storage", @baseBlobs);
	getBlobsByName("compactor", @baseBlobs);
	for (int i = 0; i < baseBlobs.length; i++)
	{
		//baseBlobs[i].getTeamNum() != playerBlob.getTeamNum()
		if (!baseBlobs[i].isInventoryAccessible(playerBlob) || (baseBlobs[i].getName()=="compactor" && baseBlobs[i].get_u32("compactor_quantity")<=0))
		{
			baseBlobs.erase(i);
			i--;
		}
	}
	//bool canPass = false;
	for (int i = 0; i < baseBlobs.length; i++)
	{
		// disabled to not make confusion as it's a simple gamemode
		if (!((baseBlobs[i].getPosition() - playerBlob.getPosition()).Length() < maxStorageReach))
		{
			baseBlobs.erase(i);
			//canPass = true;
			//break;
		}
	}
	/* 
	if (!canPass)
	{
		baseBlobs.clear();
	}
	 */
	return baseBlobs;
}

bool isStorageEnabled(CBlob@ playerBlob)
{
	return true;
}

int getBlobReqCount(CInventory@ inv1, CInventory@ inv2, string blobName)
{
	int sum=(inv1 !is null ? inv1.getBlob().getBlobCount(blobName) : 0)+(inv2 !is null ? inv2.getBlob().getBlobCount(blobName) : 0);
	if (inv1 is null) return 0;
	CBlob@ playerBlob = inv1.getBlob();
	if (playerBlob is null) return 0;
	//print("gotthere");
	
	if (isStorageEnabled(playerBlob))
	{
		CBlob@[] baseBlobs = getBaseBlobs(playerBlob);
		for (int base_index = 0; base_index< baseBlobs.size(); ++base_index)
		{
			CBlob@ base = baseBlobs[base_index];
			if (base is null) continue;
			if (base.getName()=="compactor") {
				string item_inside = base.get_string("compactor_resource");
				u32 item_quantity = base.get_u32("compactor_quantity");
				if (item_inside == blobName && item_quantity > 0) {
					sum += item_quantity;
				}
			}
			else {
				sum += baseBlobs[base_index].getBlobCount(blobName);
			}
		}
	}
	
	return sum;
}

bool isPlayerCheater(CBlob@ playerBlob)
{
	if (playerBlob !is null && (/* playerBlob.getName() == "engineer" ||  */playerBlob.hasTag("cheater"))) return true;
	
	return false;
}

//upd this
bool hasRequirements(CInventory@ inv1,CInventory@ inv2,CBitStream &inout bs,CBitStream &inout missingBs, bool &in inventoryOnly = false)
{
	string req, blobName, friendlyName;
	u16 quantity = 0;
	missingBs.Clear();
	bs.ResetBitIndex();
	bool has = true;

	CBlob@ playerBlob = (inv1 !is null ? (inv1.getBlob().getPlayer() !is null ? inv1.getBlob() : (inv2 !is null ? (inv2.getBlob().getPlayer() !is null ? inv2.getBlob() : null) : null)) : (inv2 !is null ? (inv2.getBlob().getPlayer() !is null ? inv2.getBlob() : null) : null));
	CBlob@[] baseBlobs;
	
	bool storageEnabled = false;
	
	if (playerBlob !is null)
	{
		if (isPlayerCheater(playerBlob)) return true; //cheater xd
		
		if (getRules().get_bool("free shops")) return true;
		
		storageEnabled = isStorageEnabled(playerBlob);
		if (storageEnabled)
		{
			baseBlobs = getBaseBlobs(playerBlob);
		}
	}

	while (!bs.isBufferEnd()) 
	{
		ReadRequirement(bs,req,blobName,friendlyName,quantity);
		if(req=="blob") {
			int sum = getBlobReqCount(inv1, inv2, blobName);
			if (friendlyName == "friendlyName" && g_debug > 0) {
				print("req blob sum "+sum);
				print("req blob quant "+quantity);
			}
			
			if(sum<quantity) {
				if (friendlyName == "friendlyName" && g_debug > 0) {
					print("req blob missing "+(quantity-sum)+"\n");
				}
				AddRequirement(missingBs,req,blobName,friendlyName,quantity-sum);
				has=false;
			}
		}else if(req=="coin") 
		{
			CPlayer@ player1=	inv1 !is null ? inv1.getBlob().getPlayer() : null;
			CPlayer@ player2=	inv2 !is null ? inv2.getBlob().getPlayer() : null;
			CRules@ rules = getRules();
			u32 sum=			(player1 !is null ? player1.getCoins() : 0)+(player2 !is null ? player2.getCoins() : 0);
			if(sum<quantity) 
			{
				AddRequirement(missingBs,req,blobName,friendlyName,quantity-sum);
				has=false;
			}
		}
		else if((req=="no more" || req=="no less") && inv1 !is null) 
		{
			int teamNum=inv1.getBlob().getTeamNum();
			int count=	0;
			CBlob@[] blobs;
			if(getBlobsByName(blobName,@blobs)) {
				for(uint step=0; step<blobs.length; ++step) {
					CBlob@ blob=blobs[step];
					if(blob.getTeamNum()==teamNum) {
						count++;
					}
				}
			}
			if((req=="no more" && count >= quantity) || (req=="no less" && count<quantity)) {
				AddRequirement(missingBs,req,blobName,friendlyName,quantity);
				has=false;
			}
		}
		else if (req == "tech")
		{
			int teamNum = playerBlob.getTeamNum();

			//for filthy neutrals >:(
			if (teamNum > 6) {
				int sum=(inv1 !is null ? inv1.getBlob().getBlobCount("bp_"+blobName.substr(5)) : 0)+(inv2 !is null ? inv2.getBlob().getBlobCount("bp_"+blobName.substr(5)) : 0);
				if (storageEnabled)
				{
					for (int i = 0; i< baseBlobs.length; i++)
					{
						sum += baseBlobs[i].getBlobCount("bp_"+blobName.substr(5));
					}
				}
				
				if(sum<quantity) {
					AddRequirement(missingBs,req,blobName,friendlyName,quantity);
					has=false;
				}
			}
			else {
				if (HasFakeTech(getRules(), blobName, teamNum))
				{
					//print(blobName + " is gud");
				}
				else
				{
					AddRequirement(missingBs, req, blobName, friendlyName, quantity);
					has = false;
				}
			}
		}
	}

	missingBs.ResetBitIndex();
	bs.ResetBitIndex();
	return has;
}

bool hasRequirements(CInventory@ inv,CBitStream &inout bs,CBitStream &inout missingBs, bool &in inventoryOnly = false)
{
	return (hasRequirements(inv,null,bs,missingBs,inventoryOnly));
}

void server_TakeRequirements(CInventory@ inv1,CInventory@ inv2,CBitStream &inout bs)
{
	if(!isServer()) {
		return;
	}

	CBlob@ playerBlob = (inv1 !is null ? (inv1.getBlob().getPlayer() !is null ? inv1.getBlob() : (inv2 !is null ? (inv2.getBlob().getPlayer() !is null ? inv2.getBlob() : null) : null)) : (inv2 !is null ? (inv2.getBlob().getPlayer() !is null ? inv2.getBlob() : null) : null));
	CBlob@[] baseBlobs;
	
	bool storageEnabled = false;

	if (playerBlob !is null)
	{
		if (isPlayerCheater(playerBlob)) return; //cheater xd
		
		if (getRules().get_bool("free shops")) return;
		
		storageEnabled = isStorageEnabled(playerBlob);
		if (storageEnabled)
		{
			baseBlobs = getBaseBlobs(playerBlob);
		}
	}

	string req,blobName,friendlyName;
	u16 quantity;
	bs.ResetBitIndex();
	while (!bs.isBufferEnd()) 
	{
		ReadRequirement(bs, req, blobName, friendlyName, quantity);
		if (req == "blob") 
		{
			u16 taken = 0;
			// print("init taken  " + taken);
			
			if (inv1 !is null && taken < quantity) 
			{
				// taken += inv1.getBlob().TakeBlob(blobName, quantity);
				CBlob@ invBlob = inv1.getBlob();
				invBlob.TakeBlob(blobName, quantity);
				//inv1.server_RemoveItems(blobName,quantity);
				taken += Maths::Min(invBlob.getBlobCount(blobName), quantity - taken);
			}
			
			if (inv2 !is null && taken < quantity) 
			{
				//taken += inv2.getBlob().TakeBlob(blobName, quantity - taken);
				//inv2.server_RemoveItems(blobName, quantity - taken);
				CBlob@ invBlob = inv2.getBlob();
            	invBlob.TakeBlob(blobName, quantity - taken);
				taken += Maths::Min(invBlob.getBlobCount(blobName), quantity - taken);
			}
			
			// print("pre loop taken " + taken);
			
			if (storageEnabled)
			{
				for (int i = 0; i < baseBlobs.length; i++)
				{
					// print("loop" + taken);
				
					if (taken >= quantity)
					{
						break;
					}
					CBlob@ base = baseBlobs[i];
					if (base is null) return;
					if (base.getName()=="compactor") {
						string item_inside = base.get_string("compactor_resource");
						if (item_inside != blobName) continue;
						f32 item_quantity = base.get_u32("compactor_quantity");
						base.set_u32("compactor_quantity", Maths::Max(0, item_quantity - (quantity - taken)));
						taken += Maths::Min(base.get_u32("compactor_quantity"), quantity - taken);
						print("loop taken " + taken);
					}
					else {
						base.TakeBlob(blobName, quantity - taken);
						taken += Maths::Min(base.getBlobCount(blobName), quantity - taken);
						// print("loop taken " + taken);
					}
				}
			}
		}
		else if(req=="coin") 
		{ // TODO...
			CPlayer@ player1=inv1 !is null ? inv1.getBlob().getPlayer() : null;
			CPlayer@ player2=inv2 !is null ? inv2.getBlob().getPlayer() : null;
			CRules@ rules = getRules();
			int taken = 0;
			if (player1 !is null) 
			{
				u32 current_coins = player1.getCoins();
				taken=Maths::Min(current_coins, quantity);
				player1.server_setCoins(current_coins - taken);
			}
			if (player2 !is null) 
			{
				u32 current_coins = player2.getCoins();
				taken=quantity-taken;
				taken=Maths::Min(current_coins, quantity);
				player2.server_setCoins(current_coins - taken);
			}
		}
	}

	bs.ResetBitIndex();
}

void server_TakeRequirements(CInventory@ inv,CBitStream &inout bs)
{
	server_TakeRequirements(inv,null,bs);
}

