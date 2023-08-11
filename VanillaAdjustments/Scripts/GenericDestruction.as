// GenericDestruction.as

void onHealthChange(CBlob@ this, f32 health_old)
{
	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;

	Animation@ animation = sprite.getAnimation("destruction");
	if (animation is null) return;

	sprite.animation.frame = u8((this.getInitialHealth() - this.getHealth()) / (this.getInitialHealth() / sprite.animation.getFramesCount()))+animation.getFrame(0);
	
	
	//additionally i want this script to change blob's inventory frame
	this.inventoryIconFrame=sprite.animation.frame;
}