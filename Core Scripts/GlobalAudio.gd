extends Node
## Handles most audio playback. Mainly for music and 
## global non-positional sound effects.

## Ammount of dedicated sound channels 
## (or [AudioStreamPlayer] for exclusively sound effects)
@export var channels = 10

## Audio to be played on the music channel
var queue_track : AudioStream
## Speed to fade the music back in after a change. In decibels.
var music_fadein : float = 0
## Speed to fade the current music out. In decibels.
var music_fadeout : float = 0
## The current music fading state.
var fade = 0
## Decibels removed from the music volume during fading
var music_db_add = 0
## Signed value that determines what ring bus to use
var ringpan = 0
## Array used for finding if to play sounds
var status_arr = [false]

## The states of [member fade]
enum FADE{
	## Will make the music fade in after it was queued 
	IN = -1,
	## Fades the music out before playing the queue
	OUT = 1
	
}

# Called when the node enters the scene tree for the first time.
func _ready():
	## create music channel
	var channels = channels - 1
	var node = Node.new()
	node.name = "SoundChannels"
	add_child(node)
	node = AudioStreamPlayer.new()
	node.name = "MusicChannel"
	node.bus = "Music"
	add_child(node)
	
	## create sound channels
	for i in channels:
		node = AudioStreamPlayer.new()
		node.name = "Channel"+str(i)
		node.bus = "Sound Effect"
		status_arr.push_back(false)
		$SoundChannels.add_child(node)
	
	## create ring channels
	node = AudioStreamPlayer.new()
	node.name = "Ring-1"
	node.bus = "RingLeft"
	$SoundChannels.add_child(node)
	node = AudioStreamPlayer.new()
	node.name = "Ring1"
	node.bus = "RingRight"
	$SoundChannels.add_child(node)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	#loops through all channels
	for i in channels:
		if status_arr[i] == true:
			var node = $"SoundChannels".get_node("Channel" +str(i)) 
			#disable playing status if sample isnt playing
			if !node.playing:
				status_arr[i] = false
	
	if $MusicChannel.stream != queue_track:
		if music_fadeout != 0:
			fade = 1
			music_db_add = 0
		if fade == 0:
			$MusicChannel.stream = queue_track
			$MusicChannel.play()
	
	match fade:
		1:
			music_db_add -= music_fadeout
			if music_db_add < -60: #is muted?
				fade = 0
				music_fadeout = 0
		-1:
			music_db_add += music_fadein
			if music_db_add > 0:
				fade = 0
				music_fadein = 0
	
	if $MusicChannel.stream == queue_track:
		if music_fadein != 0:
			#start muted 
			fade = -1
			music_db_add = -60 
		else:
			music_db_add = 0
	
	$MusicChannel.volume_db = (-60 * GlobalPref.MusicVol) + music_db_add

## Plays a sound at a volume or pitch. If you dont set a channel: the system
## will find the next free channel to use. You can also make a sound play only once before 
## playing again, but you must set a channel for it to work.
func _play_sound(soundID, volume = 1, pitch = 1, channel = -1, play_once = false):
	var to_channel = channel
	if to_channel == -1:
		for j in channels:
			var node = $"SoundChannels".get_node("Channel" + str(j))
			if !node.playing:
				to_channel = j
				break
			if j == channels:
				to_channel = 0
				break
	
	var channel_idx
	
	if status_arr[to_channel] == false:
		if to_channel != -2:
			channel_idx = $"SoundChannels".get_node("Channel" +str(to_channel)) 
		else:
			ringpan = clamp(-1 - (ringpan * 2), -1, 1)
			channel_idx = $"SoundChannels".get_node("Ring" + str(ringpan)) 
		channel_idx.stop()
		channel_idx.stream = soundID
		channel_idx.pitch_scale = pitch
		channel_idx.volume_db = (-60 * GlobalPref.SoundVol) * volume
		channel_idx.play()
		
		if to_channel != 1 or to_channel != 2:
			if play_once:
				status_arr[channel] = true

## Useful for changing the [AudioStreamPlayer] directly
func _get_sound_channel(channel):
	return $"SoundChannels".get_node(str(channel)) 

## Queues a music track to play with fading options. If no fade settings
## are set, the track will play instantly.
func _play_music(musicID, fadeOut = 0, fadeIn = 0):
	queue_track = musicID
	if music_fadein == 0:
		music_fadein = fadeIn
	if music_fadeout == 0:
		music_fadeout = fadeOut

## Finds the sound and stops it.
func _stop_specific_sound(soundID):
	for j in channels:
		var node = $"SoundChannels".get_node("Channel" + str(j))
		if node.stream == soundID:
			node.stop()
		
