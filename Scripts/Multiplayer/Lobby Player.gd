extends Control

var playerCharacter;
var playerName;
var playerHost;

@onready var sprites = ["res://Assets/Characters/Green.tres", "res://Assets/Characters/Orange.tres", "res://Assets/Characters/Purple.tres"];

func SetInfo(data, exists = true):
	if !exists:
		$Sprite.stop();
		$Sprite.sprite_frames = null;
		playerName = "";
		$Name.text = playerName;
		$"Sprite?".visible = false;
		return;
	
	playerName = data.name;
	playerCharacter = data.character;
	playerHost = data.host;
	
	if playerCharacter == -1:
		$"Sprite?".visible = true;
		$Sprite.stop();
		$Sprite.sprite_frames = null;
	else:
		$"Sprite?".visible = false;
		$Sprite.stop();
		$Sprite.sprite_frames = load(sprites[playerCharacter]);
		$Sprite.play("Down");
		
	$Name.text = (PackedByteArray([1]).get_string_from_ascii() if playerHost else "") + playerName;
	pass 
