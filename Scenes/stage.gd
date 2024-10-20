extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in MultiplayerManager.players.size() - 1:
		var obj = load("res://Objects/player_peer.tscn").instantiate();
		add_child(obj);
		obj.position = $Player.global_position
		var value = MultiplayerManager.players.keys()[i + 1]
		obj.player_id = value


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !multiplayer.has_multiplayer_peer():
		get_tree().change_scene_to_file("res://Scenes/Menu.tscn")
