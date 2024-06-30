#include "FirearmVars"

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	bool friend = this.getTeamNum()==blob.getTeamNum();
	bool is_player = blob.hasTag("player");
	bool blob_crouching = gunCrouching(blob);
	bool blob_proning = lyingProne(blob);
	bool this_crouching = gunCrouching(this);
	bool this_proning = lyingProne(this);
	bool this_above = blob.getPosition().y>this.getPosition().y+12-this.getVelocity().y;
	bool blob_above = this.getPosition().y>blob.getPosition().y+12-blob.getVelocity().y;
	
	bool player_collision = ((((!friend||this_crouching)&&blob_above&&!this_proning)||((!friend||blob_crouching)&&this_above&&!blob_proning))&&is_player);
	bool non_player_collision = !blob.hasTag("player")&&!blob.hasTag("material");
	
	return player_collision||non_player_collision;
}