#include "Knocked.as";
#include "Hitters.as";
const f32 max_range = 64.00f;
const float field_force = 1.0;
const float mass = 1.0;

const float first_radius = 32.0;
const float second_radius = 32.0;
void onInit(CBlob@ this)
{

	this.Tag("dont deactivate");


	this.getCurrentScript().tickFrequency = 1;
	this.Tag("vacuum");
}

void onTick(CBlob@ this)
{
CBlob@[] blobs;
	
	if (this.getMap().getBlobsInRadius(this.getPosition(), max_range, @blobs) && this.hasTag("vacuum"))
	{
		for (int i = 0; i < blobs.length; i++)
		{
			CBlob@ blob = blobs[i];
			
			if (!this.getMap().rayCastSolidNoBlobs(blob.getPosition(), this.getPosition()))
			{
				f32 dist = (blob.getPosition() - this.getPosition()).getLength();
				f32 factor = 1.00f - Maths::Pow(dist / max_range, 2);
			
				if (this.hasTag("vacuum")) 
	{
	
	

        CBlob@[] blobs;
        getMap().getBlobsInRadius(this.getPosition(), first_radius, blobs);
        for (int i=0; i < blobs.length; i++) 
		{
            CBlob@ blob = blobs[i];

            Vec2f delta = (this.getPosition() - blob.getPosition())*2;

            Vec2f force = delta;
            force.Normalize();
            force *= field_force * ((mass * blob.getMass()) * (delta.Length() / second_radius));

            blob.AddForce(force);
			//this.server_Die();
			
        }
        }
    }
			}
		}
	}
	

