extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MultiplayerManager.server_disconnected.connect(server_closed)
	$Player.player_id = MultiplayerManager.players.keys()[0]
	for i in MultiplayerManager.players.size() - 1:
		var obj = load("res://Objects/player_peer.tscn").instantiate();
		add_child(obj);
		obj.position = $Player.global_position
		var value = MultiplayerManager.players.keys()[i + 1]
		obj.player_id = value


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func server_closed():
	MultiplayerManager.players.clear()
	if multiplayer.has_multiplayer_peer():
		multiplayer.multiplayer_peer.disconnect_peer(1)
	if multiplayer.is_server():
		multiplayer.multiplayer_peer.close()
	get_tree().change_scene_to_file("res://Scenes/Menu.tscn");
	pass
