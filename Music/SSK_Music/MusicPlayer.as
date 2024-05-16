// Game Music

#include "MusicCommon.as"

#define CLIENT_ONLY

bool introPlayed = false;
SColor textColor = SColor(255, 60, 90, 110);

void onInit(CRules@ this)
{
	this.set_bool("init vars", false);

	this.set_u16("song timer", 0);
	this.Sync("song timer", false);
	this.set_s8("song index", -1);
	this.Sync("song index", false);

	this.addCommandID("play song");

	s8 songIndex = this.get_s8("song index");
	if (songIndex >= 0)
	{
		AddSongToMixer(this, songIndex);

		CMixer@ mixer = getMixer();
		if (mixer !is null)
		{
			// play current song if player just joined
			if (!mixer.isPlaying(0))
			{
				mixer.StopAll();

				client_AddToChat( "Jukebox is now playing: " + Music::songs[songIndex].description, textColor );

				this.set_bool("isMusicOn", false);
			}
		}
	}
}

void onRestart(CRules@ this)
{
	this.set_bool("init vars", false);

	this.set_u16("song timer", 0);
	this.Sync("song timer", false);
}

void onTick(CRules@ this)
{
	CMixer@ mixer = getMixer();
	if (mixer is null)
		return;

	if (!this.get_bool("init vars"))
	{
		this.set_bool("isMusicOn", false);
		this.set_bool("intro started", false);
		this.set_bool("play loop", false);
		this.set_f32("fade volume", 1.0f);

		this.set_bool("init vars", true);
	}

	if (s_gamemusic && s_musicvolume > 0.0f)
	{
		GameMusicLogic(this, mixer);
	}
	else
	{
		mixer.StopAll();

		// this bool used to determine that a song should only start from begining when music is re-enabled OR on init()
		this.set_bool("isMusicOn", false);
	}
}

//sound references with tag
void AddAllSongsToMixer(CRules@ this)
{
	CMixer@ mixer = getMixer();
	if (mixer is null)
		return;

	mixer.ResetMixer();
	for (uint i = 0; i < Music::songs.length; ++i)
	{
		mixer.AddTrack(Music::songs[i].mainFileHandle, i);
	}
}

void AddSongToMixer(CRules@ this, s8 songIndex)
{
	CMixer@ mixer = getMixer();
	if (mixer is null)
		return;

	mixer.ResetMixer();
	mixer.AddTrack(Music::songs[songIndex].mainFileHandle, 0);
}

void GameMusicLogic(CRules@ this, CMixer@ mixer)
{
	if (mixer is null)
		return;

	u16 songTimer = this.get_u16("song timer");

	// check if we should start the main loop after the intro song is played or main loop is over
	if (this.get_bool("intro started") && !mixer.isPlaying(0) && !mixer.isPlaying(1))
	{
		mixer.PlayRandom(0);
		if (mixer.isPlaying(0))
			this.set_bool("isMusicOn", true);
	}

	// fade out current song if game over or song is close to being finished
	if (this.get_bool("isMusicOn") && (this.isGameOver() || songTimer < 24))	
	{
		f32 fadeVolume = this.get_f32("fade volume");
		mixer.FadeOutAll(fadeVolume, 0.0f);	// 0.0f
		this.set_f32("fade volume", Maths::Min(fadeVolume*0.995, fadeVolume - 0.001f));
	}
	else
	{
		s8 songIndex = this.get_s8("song index");
		if (songIndex >= 0 && !this.get_bool("isMusicOn"))
		{
			u16 playBuffer = this.get_u16("music play buffer");
			if (playBuffer <= 0)
			{
				AddSongToMixer(this, songIndex);
				if (Music::songs[songIndex].introFileHandle != "")
				{
					mixer.AddTrack(Music::songs[songIndex].introFileHandle, 1);
					mixer.PlayRandom(1);
					if (mixer.isPlaying(1))
					{
						this.set_bool("isMusicOn", true);	
						this.set_bool("intro started", true);
					}
				}
				else
				{
					mixer.PlayRandom(0);
					if (mixer.isPlaying(0))
					{
						this.set_bool("isMusicOn", true);
						this.set_bool("intro started", true);
					}
				}
			}
			else
			{
				playBuffer--;
				this.set_u16("music play buffer", playBuffer);
			}
		}
	}

	if (songTimer > 0 && !getNet().isServer())	// check if isServer so that the song timer is not decremented twice on localhost
	{
		if (getGameTime() % getTicksASecond() == 0)
		{
			songTimer--;
			this.set_u16("song timer", songTimer);
		}
	}
	
	/*
	if (songTimer == SONG_BUFFER && getGameTime() % getTicksASecond() == 0)
		Sound::Play("songchange.ogg");
	*/
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("play song"))
	{
		u8 randSongIndex = params.read_u8();

		CMixer@ mixer = getMixer();
		if (mixer != null)
		{
			mixer.StopAll();

			client_AddToChat( "Jukebox is now playing: " + Music::songs[randSongIndex].description, textColor );

			this.set_s8("song index", randSongIndex);
			this.set_bool("isMusicOn", false);
			this.set_u16("song timer", Music::songs[randSongIndex].maxLengthSeconds + SONG_BUFFER);
			this.set_bool("intro started", false);
			this.set_f32("fade volume", 1.0f);
		}
	}
}
