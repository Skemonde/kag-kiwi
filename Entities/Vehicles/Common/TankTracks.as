
#define CLIENT_ONLY

void onInit( CSprite@ this )
{
    CBlob@ blob = this.getBlob();
    Vec2f[] tracks_points;
	blob.get("tracks_points", tracks_points);
    float distance = blob.get_f32("tracks_distanced");
    Vec2f tracks_rotation_center = blob.get_Vec2f("tracks_rotation_center");
    Vec2f tracks_rotation_offset = blob.get_Vec2f("tracks_rotation_offset");
    string track_tex = blob.get_string("tracks_texture");

    Vec2f[] new_tracks_points;
    for(int i = 0; i < tracks_points.size(); i++)
    {
        Vec2f cur_point = tracks_points[i];
        Vec2f next_point = i == tracks_points.size()-1 ? tracks_points[0] : tracks_points[i+1];

        Vec2f direction = next_point - cur_point;
        float dist = direction.Length();

        int steps = Maths::Ceil(dist / distance);

        if(steps > 1)
        {
            float _t = 1.0f / float(steps);
            float t = _t;
            Vec2f new_pos;

            Vec2f p0 = i-1 < 0 ? tracks_points[tracks_points.size()-1] : tracks_points[i-1];
            Vec2f p1 = tracks_points[i];
            Vec2f p2 = i+1 == tracks_points.size() ? tracks_points[0] : tracks_points[i+1];
            Vec2f p3 = i+2 >= tracks_points.size() ? (i+1 == tracks_points.size() ? tracks_points[1] : tracks_points[0]) : tracks_points[i+2];

            Vec2f a = p1 * 2.0f;
            Vec2f b = p2 - p0;
            Vec2f c = p0 * 2.0f - p1 * 5.0f + p2* 4.0f - p3;
            Vec2f d = -p0 + p1 * 3.0f - p2 * 3.0f + p3;

            for(int j = 0; j < steps; j++)
            {
                new_pos = (a + (b * t) + (c * (t * t)) + (d * (t * t * t))) * 0.5f;
                new_tracks_points.push_back(new_pos - tracks_rotation_center);
                t += _t;
            }
        }
    }

    AnimatedTracks tracks(track_tex, new_tracks_points, tracks_rotation_offset, distance);
    blob.set("tracks_system", @tracks);

    int tracks_render_id = Render::addBlobScript(Render::layer_objects, blob, "TankTracks.as", "DrawTracks");
    //blob.set_s32("tracks_render_id", tracks_render_id);
}

void onTick(CSprite@ this)
{
    CBlob@ blob = this.getBlob();
    AnimatedTracks@ tracks;
    blob.get("tracks_system", @tracks);
    tracks.Update(blob);
}

void DrawTracks(CBlob@ this, int id)
{
    AnimatedTracks@ tracks;
    this.get("tracks_system", @tracks);
    tracks.Render(this);
}

class AnimatedTracks
{
    string track_segment_texture;
    TrackSegment@[] segments;
    Vertex[] verts;
    Vec2f tracks_rotation_offset;
    float[] mat;
    float angle;
    float facing;
    SColor color;
    float prev_anim_timer;
    float anim_timer;
    float anim_dist;
    float time_delta;

    // track quad
    Vec2f vert1;
    Vec2f vert2;
    Vec2f vert3;
    Vec2f vert4;

    AnimatedTracks(string tex, Vec2f[] points, Vec2f _offset, float _anim_dist)
    {
        track_segment_texture = tex;
        if(!Texture::exists(track_segment_texture))
            Texture::createFromFile(track_segment_texture, CFileMatcher(track_segment_texture).getFirst());
        int track_width = Texture::width(track_segment_texture);
        int track_height = Texture::height(track_segment_texture);
        Vec2f track_size_half = Vec2f(track_width, track_height)/2.0f;

        vert1 = Vec2f(-track_size_half.x,-track_size_half.y);
        vert2 = Vec2f(track_size_half.x,-track_size_half.y);
        vert3 = Vec2f(track_size_half.x,track_size_half.y);
        vert4 = Vec2f(-track_size_half.x,track_size_half.y);

        tracks_rotation_offset = _offset;
        anim_dist = _anim_dist;

        verts.set_length(points.size()*4);

        Vec2f a, b, c, d;
        for(int i = 0; i < points.size(); i++)
        {
            a = i-1 < 0 ? points[points.size()-1] : points[i-1];
            b = points[i];
            c = i+1 == points.size() ? points[0] : points[i+1];
            d = i+2 >= points.size() ? (i+1 == points.size() ? points[1] : points[0]) : points[i+2];

            TrackSegment segment(a,b,c,d);
            @segment.tracks = @this;
            segments.push_back(@segment);
        }
    }

    void Update(CBlob@ this)
    {
        anim_timer = anim_timer % 1.0f;
        color = getMap().getColorLight(this.getPosition());
        angle = this.getAngleDegrees();
        facing = this.isFacingLeft() ? -1.0f : 1.0f;
        prev_anim_timer = anim_timer;
        anim_timer += this.getVelocity().x/anim_dist;
        if(anim_timer < 0)
        {
            anim_timer += 1.0f;
            prev_anim_timer += 1.0f;
        }
        time_delta = 0;
    }

    void Render(CBlob@ this)
    {
        float render_anim_time = Maths::Lerp(prev_anim_timer, anim_timer, time_delta);

        Vec2f pos = this.getInterpolatedPosition();

        Matrix::MakeIdentity(mat);
        float[] _mat = mat;
        Matrix::SetTranslation(mat, tracks_rotation_offset.x*(-facing), tracks_rotation_offset.y, 0);
        Matrix::SetRotationDegrees(_mat, 0, 0, 0);
        Matrix::MultiplyImmediate(mat, _mat);

        Matrix::SetRotationDegrees(_mat, 0, 0, angle);
        Matrix::MultiplyImmediate(_mat, mat);

        Matrix::SetTranslation(mat, pos.x, pos.y, 0);
        Matrix::MultiplyImmediate(mat, _mat);
        Render::SetModelTransform(mat);

        for(int i = 0; i < segments.size(); i++)
        {
            segments[i].Render(render_anim_time % 1.0f, i*4);
        }

        Render::RawQuads(track_segment_texture, verts);

        Render::SetTransformWorldspace();

        time_delta += getRenderDeltaTime()*getTicksASecond();
    }
}

class TrackSegment
{
    AnimatedTracks@ tracks;

    Vec2f a, b, c, d;
    bool should_bump;

    TrackSegment(Vec2f p0, Vec2f p1, Vec2f p2, Vec2f p3)
    {
        // Calculate the coefficients of the spline
        a = p1 * 2.0f;
        b = p2 - p0;
        c = p0 * 2.0f - p1 * 5.0f + p2* 4.0f - p3;
        d = -p0 + p1 * 3.0f - p2 * 3.0f + p3;
    }

    void calculateCatmullRomSpline(float t, Vec2f&out position, Vec2f&out direction)
    {
        position = (a + (b * t) + (c * (t * t)) + (d * (t * t * t))) * 0.5f;
        direction = (b + (c * 2.0f * t) + (d * 3.0f * (t * t))) * 0.5f;
    }

    void Render(float render_anim_time, int index)
    {
        Vec2f new_point, tangent;
        calculateCatmullRomSpline(tracks.facing == 1.0f ? render_anim_time : 1.0f - render_anim_time, new_point, tangent);
        tangent.y *= -tracks.facing;
        new_point.x *= tracks.facing;
        float angl = tangent.AngleDegrees()+180;
        
        tracks.verts[index  ] = Vertex(new_point + Vec2f(tracks.vert1.x*tracks.facing, tracks.vert1.y).RotateByDegrees(angl), -10, Vec2f(0,0), tracks.color);
        tracks.verts[index+1] = Vertex(new_point + Vec2f(tracks.vert2.x*tracks.facing, tracks.vert2.y).RotateByDegrees(angl), -10, Vec2f(1,0), tracks.color);
        tracks.verts[index+2] = Vertex(new_point + Vec2f(tracks.vert3.x*tracks.facing, tracks.vert3.y).RotateByDegrees(angl), -10, Vec2f(1,1), tracks.color);
        tracks.verts[index+3] = Vertex(new_point + Vec2f(tracks.vert4.x*tracks.facing, tracks.vert4.y).RotateByDegrees(angl), -10, Vec2f(0,1), tracks.color);
    }
}