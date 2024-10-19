extends Control

var playerCharacter;
var playerName;
@onready var spites = []

func SetInfo(data):
	playerName = data.name;
	playerCharacter = data.character;
	
	pass
