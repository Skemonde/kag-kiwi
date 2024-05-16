// Game Music

const u8 SONG_BUFFER = 3;

shared class Song
{
	string introFileHandle;
	string mainFileHandle;
	string description;
	u16 maxLengthSeconds;

	Song(string _introFileHandle, string _mainFileHandle, string _description, u16 _maxLengthSeconds)
	{
		introFileHandle = _introFileHandle;
		mainFileHandle = _mainFileHandle;
		description = _description;
		maxLengthSeconds = _maxLengthSeconds;
	}
};

namespace Music
{
	const ::Song@[] songs = 
	{
		Song("", "creepue_song_1.ogg", 
			"Creepue - NES Covers Collection, Blaster Master: Level 1 Theme", 127),

		Song("", "creepue_song_2.ogg", 
			"Creepue - NES Covers Collection, Song 2", 124),
			
		Song("", "creepue_song_3.ogg", 
			"Creepue - NES Covers Collection, Song 3", 100),
			
		Song("", "creepue_song_4.ogg", 
			"Creepue - NES Covers Collection, Song 4", 130),
			
		Song("", "creepue_song_5.ogg", 
			"Creepue - NES Covers Collection, Song 5", 78),
			
		Song("", "creepue_song_6.ogg", 
			"Creepue - NES Covers Collection, Song 6", 89),
			
		Song("", "creepue_song_7.ogg", 
			"Creepue - NES Covers Collection, Ninja Gaiden: Unbreakable Determination", 64),
			
		Song("", "creepue_song_8.ogg", 
			"Creepue - NES Covers Collection, Song 8", 97)
	};
}
