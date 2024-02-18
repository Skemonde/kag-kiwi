#define CLIENT_ONLY
#include "Tunes"
#include "HSVToRGB"

//depends of turned music in settings!
//and of music volume too

void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	
	this.SetEmitSoundSpeed(1);
	this.SetEmitSoundPaused(true);
	
	if (blob.get_u32("tune") < tunes.length-1) {
		blob.Tag("playing");
		this.SetEmitSound(tunes[blob.get_u32("tune")]);
		this.SetEmitSoundPaused(false);
	}
	this.SetZ(-2);
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	
	//don't want it to change facing direction
	this.SetFacingLeft(false);
	
	//boombox only plays music for guys of the same team
	CPlayer@ player = getLocalPlayer();
	if (player !is null && (player.getTeamNum() == blob.getTeamNum() || blob.getTeamNum() == 255) && !(blob.get_u32("tune") >= tunes.length-1))
		blob.Tag("playing");
	else
		blob.Untag("playing");
	
	//with this boombox knows itself how big should sprite offset be depending of scale of jumping you set
	f32 scale = 0.625;
	u8 shift = (16-16*scale)/2;
	//making weeble woble animation
	if (blob.hasTag("shrinked")) {
		this.ScaleBy(Vec2f(scale, 1.0f/scale));
		blob.Untag("shrinked");
		this.SetOffset(this.getOffset()+Vec2f(0, -shift));
	}
	//turn it on if it's playing and pause the music and animation if it's not
	if (blob.hasTag("playing") && s_gamemusic && s_musicvolume>0) {
		u32 tune_num = Maths::Min(tunes.length-1, blob.get_u32("tune"));
		this.SetEmitSound(tunes[tune_num]);
		this.SetEmitSoundPaused(false);
		this.SetEmitSoundVolume(s_musicvolume);
		if (getGameTime() % 10 == 0) {
			this.ScaleBy(Vec2f(1.0f/scale, scale));
			blob.Tag("shrinked");
			this.SetOffset(this.getOffset()+Vec2f(0, shift));
		}
		if (getGameTime() % 10 == 0 && !v_fastrender) {
			CParticle@ p = ParticleAnimated("particle_note_"+(XORRandom(3) + 1)+".png", blob.getPosition(), Vec2f((XORRandom(100)-50)*0.01,-2), 0,1, RenderStyle::Style::normal,0,Vec2f(8,8),0,0,true);
			if (p !is null)
			{
				p.fastcollision = true;
				p.diesoncollide = true;
				p.gravity = Vec2f(0,0.0625);
				p.lighting = false;
			}
		}
	} else {
		this.SetEmitSoundPaused(true);
	}
}

void onRender(CSprite@ this)
{
	if (g_videorecording || !u_showtutorial) return;

	CBlob@ blob = this.getBlob();
	Vec2f center = blob.getPosition();
	Vec2f mouseWorld = getControls().getMouseWorldPos();
	const f32 renderRadius = (blob.getRadius()) * 3;
	bool mouseOnBlob = (mouseWorld - center).getLength() < renderRadius;
	
	if (!mouseOnBlob) return;
	if (getLocalPlayerBlob() !is null && getLocalPlayerBlob().getTeamNum() != blob.getTeamNum() && blob.getTeamNum() != 255) return;
	
	u8 tune = blob.get_u32("tune");
	f32 living_speed = 4;
	SColor living_rainbow = HSVToRGB((getGameTime() % (360/living_speed))*living_speed, 1.0f, 1.0f);
	SColor light_gray(255, 200, 200, 200);
	SColor col;
	
	bool playing_actual_track = blob.get_u32("tune") < tunes.length-1;
	
	if (playing_actual_track)
		col = living_rainbow;
	else
		col = light_gray;
	Vec2f pos2d = blob.getInterpolatedScreenPos() + Vec2f(0, 8);
	GUI::SetFont("menu");
	if (s_gamemusic && s_musicvolume>0) {
		if (playing_actual_track)
			GUI::DrawTextCentered("\""+songnames[tune]+"\" is playing", pos2d+Vec2f(0, 8), col);
		else
			GUI::DrawTextCentered("Nothing is playing", pos2d+Vec2f(0, 8), col);
	} else {
		if (!s_gamemusic)
			GUI::DrawTextCentered("Turn on \"Game music\" in settings", pos2d+Vec2f(0, 8), light_gray);
		else if (s_musicvolume<1)
			GUI::DrawTextCentered("Increase music volume in settings", pos2d+Vec2f(0, 8), light_gray);
	}
}