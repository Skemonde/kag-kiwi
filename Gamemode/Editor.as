#include "CanUse.as";

bool editor_cursor = false;

const string editor_place = "editor place";
const string editor_destroy = "editor destroy";
const string editor_copy = "editor copy";

const string cursorTexture = "../Mods/PrimitiveEditor/EditorCursor.png";
 
void onInit( CRules@ this )
{
    this.addCommandID(editor_place);
    this.addCommandID(editor_destroy);
	this.addCommandID(editor_copy);
}

void onTick(CRules@ this)
{
	if(getNet().isClient())
	{
		CPlayer@ p = getLocalPlayer();
		CMap@ map = getMap();
		if (p !is null)
		{
			CControls@ controls = p.getControls();
			bool op = CanUse(p.getUsername()) || (isServer()&&isClient());

			if(op)
			{
				if (controls.isKeyJustPressed(KEY_LCONTROL))
				{
					editor_cursor = !editor_cursor;
					//print("change");
				}

				if (controls.isKeyJustPressed(KEY_KEY_Z))
				{
					CBitStream params;
					params.write_u16(p.getNetworkID());
					this.SendCommand(this.getCommandID(editor_destroy), params);
					//print("death");
				}
				if (controls.isKeyPressed(KEY_LSHIFT))
				{
					if (controls.isKeyJustPressed(KEY_KEY_X))
					{
						CBitStream params;
						params.write_u16(p.getNetworkID());
						this.SendCommand(this.getCommandID(editor_place), params);
						//print("place!!");
					}
					if (controls.isKeyJustPressed(KEY_KEY_Z))
					{
						CBitStream params;
						params.write_u16(p.getNetworkID());
						this.SendCommand(this.getCommandID(editor_destroy), params);
						//print("destroy!!");
					}
				}
				else
				{
					if (controls.isKeyPressed(KEY_KEY_X))
					{
						CBitStream params;
						params.write_u16(p.getNetworkID());
						this.SendCommand(this.getCommandID(editor_place), params);
						//print("placeeeeeee!!");
					}
					if (controls.isKeyPressed(KEY_KEY_Z))
					{
						CBitStream params;
						params.write_u16(p.getNetworkID());
						this.SendCommand(this.getCommandID(editor_destroy), params);
						//print("destroyyyyyyy!!");
					}
				}
				if (controls.isKeyJustPressed(KEY_KEY_B))
				{
					CBitStream params;
					params.write_u16(p.getNetworkID());
					this.SendCommand(this.getCommandID(editor_copy), params);
					//print("copied!!");
				}
			}
		}
	}
}

void onRender(CRules@ this)
{
	if(editor_cursor)
	{
		CPlayer@ p = getLocalPlayer();

		if (p is null || !p.isMyPlayer()) { return; }
		CBlob@ player_blob = p.getBlob();
		if (player_blob !is null)
		{
			Vec2f position = player_blob.getAimPos();
			position = getDriver().getScreenPosFromWorldPos(position) + Vec2f(16, 16);
			if (!player_blob.get_string("blob_to_copy").empty())
				if (CFileMatcher(player_blob.get_string("blob_to_copy")).hasMatch())
					GUI::DrawIcon(player_blob.get_string("blob_to_copy")+".png", position, getCamera().targetDistance * getDriver().getResolutionScaleFactor());
		}
	}
}

void onCommand( CRules@ this, u8 cmd, CBitStream@ params )
{
    if (!getNet().isServer())
		return;

    if (cmd == this.getCommandID(editor_destroy))
	{
	    CPlayer@ p = ResolvePlayer(params);
		CMap@ map = getMap();
		CBlob@ blob = p.getBlob();
		if (blob !is null)
		{
			Vec2f pos = blob.getAimPos();
			CBlob@ behindBlob = getMap().getBlobAtPosition(pos);
			if (behindBlob !is null)
			{
				behindBlob.server_Die();
			}
			else
			{
				map.server_SetTile(pos, CMap::tile_empty);
			}
		}
	}
	else if (cmd == this.getCommandID(editor_place))
	{
	    CPlayer@ p = ResolvePlayer(params);
		CMap@ map = getMap();
		CBlob@ blob = p.getBlob();
		if (blob !is null)
		{
			Vec2f pos = blob.getAimPos();
			if (blob.get_TileType("buildtile") != 0 && blob.getCarriedBlob() is null)
				map.server_SetTile(pos, blob.get_TileType("buildtile"));
			else
			{
				if (canPlaceBlobAtPos(getBottomOfCursor(pos)))
				{
					if (blob.getCarriedBlob() !is null) {
						CBlob@ newblob = server_CreateBlob(blob.getCarriedBlob().getName(), blob.getCarriedBlob().getTeamNum(), getBottomOfCursor(pos));
						if (newblob.isSnapToGrid())
						{
							CShape@ shape = newblob.getShape();
							shape.SetStatic(true);
						}
					}
					else if (!blob.get_string("blob_to_copy").empty()){
						CBlob@ newblob = server_CreateBlob(blob.get_string("blob_to_copy"), blob.get_u16("blob_to_copy_team"), getBottomOfCursor(pos));
						if (newblob.isSnapToGrid())
						{
							CShape@ shape = newblob.getShape();
							shape.SetStatic(true);
						}
					}
				}
			}
		}
	}
	else if (cmd == this.getCommandID(editor_copy))
	{
	    CPlayer@ p = ResolvePlayer(params);
		CMap@ map = getMap();
		CBlob@ blob = p.getBlob();
		if (blob !is null)
		{
			Vec2f aimpos = blob.getAimPos();
			blob.set_TileType("buildtile", 0);
			CBlob@[] blobs;
			if(getMap().getBlobsInRadius(aimpos, 1.0f, blobs))
			{
				CBlob@ blob_to_copy = blobs[XORRandom(blobs.length)];
				blob.set_string("blob_to_copy", blob_to_copy.getName());
				blob.set_u16("blob_to_copy_team", blob_to_copy.getTeamNum());
			}
			else {
				blob.set_string("blob_to_copy", "");
				blob.set_TileType("buildtile", map.getTile(aimpos).type);
			}
		}
	}
}

bool canPlaceBlobAtPos( Vec2f pos )
{
	CBlob@ _tempBlob; CShape@ _tempShape;
	
	  @_tempBlob = getMap().getBlobAtPosition( pos );
	if(_tempBlob !is null && _tempBlob.isCollidable())
	{
		  @_tempShape = _tempBlob.getShape();
		if(_tempShape.isStatic())
		    return false;
	}
	return true;
}

CPlayer@ ResolvePlayer( CBitStream@ data )
{
    u16 playerNetID;
	if(!data.saferead_u16(playerNetID)) return null;
	
	return getPlayerByNetworkId(playerNetID);
}

Vec2f getBottomOfCursor(Vec2f cursorPos)
{
	cursorPos = getMap().getTileSpacePosition(cursorPos);
	cursorPos = getMap().getTileWorldPosition(cursorPos);
	f32 w = getMap().tilesize / 2.0f;
	f32 h = getMap().tilesize / 2.0f;
	int offsetY = Maths::Max(1, Maths::Round(8 / getMap().tilesize)) - 1;
	h -= offsetY * getMap().tilesize / 2.0f;
	return Vec2f(cursorPos.x + w, cursorPos.y + h);
}