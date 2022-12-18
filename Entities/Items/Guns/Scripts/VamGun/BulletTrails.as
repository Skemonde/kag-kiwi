//Bullet trails

class BulletFade
{
    SColor Col = SColor(255,255,255,255);
	SColor BackCol = SColor(0,255,255,255);

    Vec2f Back;
    Vec2f Front;
	f32 TimeLeft = 100;
    string Texture = "";

    BulletFade(Vec2f p)
    {
        Back = p;
        Front = p;
    }

    void onRender()
    {
        
        TimeLeft -= 3.0f * ((1000.0f/30.0f) * getRenderDeltaTime());
		Col.setAlpha(TimeLeft*2.5f);
		
		if(TimeLeft > 0){
			Vec2f Over = Vec2f(0,1.5);
			Vec2f Under = Vec2f(0,-1.5);
			Vec2f Aim = Back-Front;
			Over.RotateByDegrees(-Aim.AngleDegrees());
			Under.RotateByDegrees(-Aim.AngleDegrees());
			
            Vertex[]@ fade_vertex;
            if(getRules().get(Texture, @fade_vertex)){
                fade_vertex.push_back(Vertex(Front.x+Over.x, Front.y+Over.y, 1, 1, 0, Col)); // top left
                fade_vertex.push_back(Vertex(Front.x+Under.x, Front.y+Under.y, 1, 0, 0, Col)); // top right
                fade_vertex.push_back(Vertex(Back.x + Over.x*0.5f, Back.y + Over.y*0.5f,1, 0, 1, BackCol)); // bot right
                fade_vertex.push_back(Vertex(Back.x+ Under.x*0.5f, Back.y + Under.y*0.5f,1, 1, 1, BackCol)); // bot left
            }
		}
    }
}
