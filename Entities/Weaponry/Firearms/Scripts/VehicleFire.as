#include "FirearmVars"

void onInit(CBlob@ this) 
{
	FirearmVars@ vars;
	this.get("firearm_vars", @vars);CRules @rules = getRules();

    if (isClient())
	{
		if (vars.BULLET_SPRITE != ""){

			Vertex[]@ bullet_vertex;
			rules.get(vars.BULLET_SPRITE, @bullet_vertex);

			if (bullet_vertex is null)
			{
				Vertex[] vert;
				rules.set(vars.BULLET_SPRITE, @vert);
			}

			// #blamekag
			if (!rules.exists("VertexBook"))
			{
				string[] book;
				rules.set("VertexBook", @book);
				book.push_back(vars.BULLET_SPRITE);
			}
			else
			{
				string[]@ book;
				rules.get("VertexBook", @book);
				book.push_back(vars.BULLET_SPRITE);
			}
		}
		
		if(vars.FADE_SPRITE != ""){
			Vertex[]@ fade_vertex;
			rules.get(vars.FADE_SPRITE, @fade_vertex);

			if (fade_vertex is null)
			{
				Vertex[] vert;
				rules.set(vars.FADE_SPRITE, @vert);
			}

			// #blamekag
			if (!rules.exists("VertexBook"))
			{
				string[] book;
				rules.set("VertexBook", @book);
				book.push_back(vars.FADE_SPRITE);
			}
			else
			{
				string[]@ book;
				rules.get("VertexBook", @book);
				book.push_back(vars.FADE_SPRITE);
			}
		}
	}
}