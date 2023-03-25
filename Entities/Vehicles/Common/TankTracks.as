
#define CLIENT_ONLY

void onInit( CSprite@ this )
{
    CBlob@ blob = this.getBlob();
    
    Vec2f[] tracks_points;
	blob.get("tracks_points", tracks_points);
    Vec2f sprite_half_size = Vec2f(this.getFrameWidth(), this.getFrameHeight())/2.0f;
	sprite_half_size -= this.getOffset();
	for(int i = 0; i < tracks_points.size(); i++)
	{
		tracks_points[i] -= sprite_half_size;
	}

    Vec2f[] new_tracks_points;

    for(int i = 0; i < tracks_points.size(); i++)
    {
        Vec2f cur_point = tracks_points[i];
        Vec2f next_point = i == tracks_points.size()-1 ? tracks_points[0] : tracks_points[i+1];

        Vec2f direction = next_point - cur_point;
        float dist = direction.Length();

        int steps = dist / 5.0f;

        direction /= float(steps);

        Vec2f new_point = cur_point;

        for(int j = 0; j < steps; j++)
        {
            new_tracks_points.push_back(new_point);
            new_point += direction;
        }
    }
    blob.set("tracks_points", new_tracks_points);

    string track_texture = blob.get_string("tracks_texture");
    if(!Texture::exists(track_texture))
        Texture::createFromFile(track_texture, CFileMatcher(track_texture).getFirst());
    int track_width = Texture::width(track_texture);
    int track_height = Texture::height(track_texture);
    blob.set_Vec2f("track_size", Vec2f(track_width, track_height));

    int tracks_render_id = Render::addBlobScript(Render::layer_objects, blob, "TankTracks.as", "DrawTracks");
    blob.set_s32("tracks_render_id", tracks_render_id);
}

void DrawTracks(CBlob@ this, int id)
{
    Vec2f[] tracks_points;
	this.get("tracks_points", tracks_points);

    Vec2f blob_pos = this.getInterpolatedPosition();
    float angle = this.getAngleDegrees();
    float facing = this.isFacingLeft() ? -1.0f : 1.0f;

    // the actual movement animation
    float anim_time = this.get_f32("track_anim");
    anim_time += (this.getVelocity().x*facing)*getRenderApproximateCorrectionFactor()/5.2f;
    this.set_f32("track_anim", anim_time % 1.0f);

    Vec2f track_size = this.get_Vec2f("track_size");
    Vec2f track_half_size = track_size/2.0f;

    float[] mat;
    Matrix::MakeIdentity(mat);
    Matrix::SetRotationDegrees(mat, 0, 0, angle);
    Matrix::SetTranslation(mat, blob_pos.x, blob_pos.y, 0);
    Render::SetModelTransform(mat);

    SColor light = getMap().getColorLight(blob_pos);

    Vertex[] verts;
    Vec2f a, b, c, d;
    Vec2f vert1 = Vec2f(-track_half_size.x * facing,-track_half_size.y);
    Vec2f vert2 = Vec2f(track_half_size.x * facing,-track_half_size.y);
    Vec2f vert3 = Vec2f(track_half_size.x * facing,track_half_size.y);
    Vec2f vert4 = Vec2f(-track_half_size.x * facing,track_half_size.y);

    for(int i = 0; i < tracks_points.size(); i++)
    {
        a = i-1 < 0 ? tracks_points[tracks_points.size()-1] : tracks_points[i-1];
        b = tracks_points[i];
        c = i+1 == tracks_points.size() ? tracks_points[0] : tracks_points[i+1];
        d = i+2 >= tracks_points.size() ? (i+1 == tracks_points.size() ? tracks_points[1] : tracks_points[0]) : tracks_points[i+2];
        Vec2f new_point = Vec2f_lerp(b, c, anim_time);
        new_point.x *= facing;
        
        float dir1 = -(a - c).AngleDegrees();
        float dir2 = -(b - d).AngleDegrees();

        float difference = Maths::Abs(dir1 - dir2);
        if (difference > 180)
        {
            if (dir2 > dir1)
                dir1 += 360;
            else
                dir2 += 360;
        }

        float dir = Maths::Lerp(dir1, dir2, anim_time) * facing;

        verts.push_back(Vertex(new_point + (vert1+Vec2f_zero).RotateByDegrees(dir), -10, Vec2f(0,0), light));
        verts.push_back(Vertex(new_point + (vert2+Vec2f_zero).RotateByDegrees(dir), -10, Vec2f(1,0), light));
        verts.push_back(Vertex(new_point + (vert3+Vec2f_zero).RotateByDegrees(dir), -10, Vec2f(1,1), light));
        verts.push_back(Vertex(new_point + (vert4+Vec2f_zero).RotateByDegrees(dir), -10, Vec2f(0,1), light));
    }
    
    Render::RawQuads(this.get_string("tracks_texture"), verts);
}