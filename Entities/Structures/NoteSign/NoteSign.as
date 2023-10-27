// Sign logic

namespace Sign
{
	enum State
	{
		blank = 0,
		written
	}
}

void onInit(CBlob@ this)
{
	//setup blank state
	this.set_u8("state", Sign::blank);
	this.Tag("building");

	if (!this.exists("text"))
	{
		this.set_string("text", "$amogus_icon7$"); // Should be ok even if the server and the client run it?
	}

	this.getSprite().SetAnimation("written");

	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getSprite().SetZ(-10.0f);
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;

	if (getHUD().menuState != 0) return;

	CBlob@ localBlob = getLocalPlayerBlob();
	if (localBlob is null) return;
	
	Vec2f pos2d = blob.getScreenPos();
	
	const f32 SCALEX = getDriver().getResolutionScaleFactor();
	const f32 ZOOM = getCamera().targetDistance * SCALEX;

	Vec2f center = blob.getPosition();
	Vec2f mouseWorld = getControls().getMouseScreenPos();
	const f32 renderRadius = (blob.getRadius()) * ZOOM * 2;
	bool mouseOnBlob = (mouseWorld - pos2d).getLength() < renderRadius;
	bool overlapping = (localBlob.getPosition() - blob.getPosition()).Length() < 0.5f * (localBlob.getRadius() + blob.getRadius());
	
	if (!overlapping && !mouseOnBlob || getHUD().hasButtons()) return;

	{
		// draw drop time progress bar
		int top = pos2d.y - 2.5f * blob.getHeight() + 000.0f;
		int left = 200.0f;
		int margin = 4;
		Vec2f dim;
		string label = getTranslatedString(blob.get_string("text"));
		label += "\n";
		GUI::SetFont("menu");
		GUI::GetTextDimensions(label , dim);
		dim.x = Maths::Min(dim.x, 200.0f);
		dim.x += margin;
		dim.y += margin;
		dim.y *= 1.0f;
		top += dim.y;
		Vec2f upperleft(pos2d.x - dim.x / 2 - left, top - Maths::Min(int(2 * dim.y), 250));
		Vec2f lowerright(pos2d.x + dim.x / 2 - left, top - dim.y);
		GUI::DrawText(label, Vec2f(upperleft.x + margin, upperleft.y + margin + margin),
		              Vec2f(upperleft.x + margin + dim.x, upperleft.y + margin + dim.y),
		              SColor(255, 0, 0, 0), false, false, true);
	}
}
