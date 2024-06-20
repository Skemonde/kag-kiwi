// Game Music

#include "MusicCommon.as"

#define SERVER_ONLY

void onInit(CRules@ this)
{
	this.set_s8("song index", -1);
	this.set_u16("song timer", 0);

	this.addCommandID("play song");
}

void onRestart(CRules@ this)
{
	this.set_u16("song timer", 0);
}

void onTick(CRules@ this)
{
	if (getNet().isServer())
	{
		if (!this.isGameOver())
		{
			u16 songTimer = this.get_u16("song timer");
			if (songTimer > 0)
			{
				if (getGameTime() % getTicksASecond() == 0)
				{
					songTimer--;
					this.set_u16("song timer", songTimer);
				}
			}
			else
			{
				playRandomSong(this);
			}
		}
	}
}

void playRandomSong(CRules@ this)
{
	u8 randSongIndex = XORRandom(Music::songs.length);
	if (randSongIndex == this.get_s8("song index"))
	{
		randSongIndex++;
		if ( !(randSongIndex < Music::songs.length) )
		{
			randSongIndex = 0;
		}
	}

	CBitStream bt;
	bt.write_u8( randSongIndex );	
	this.SendCommand( this.getCommandID("play song"), bt );

	this.set_s8("song index", randSongIndex);
	this.set_u16("song timer", Music::songs[randSongIndex].maxLengthSeconds + SONG_BUFFER);
}