extends Node2D
var stagger_update = 0
var win_mode = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MultiplayerManager.server_disconnected.connect(server_closed)
	$Player.player_id = MultiplayerManager.players.keys()[0]
	for i in MultiplayerManager.players.size() - 1:
		var obj = load("res://Objects/player_peer.tscn").instantiate();
		$Player.get_parent().add_child(obj);
		obj.global_position = $Player.global_position
		var value = MultiplayerManager.players.keys()[i + 1]
		obj.player_id = value


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	stagger_update += 1
	if stagger_update == 10:
		_everyone_died()
		_check_all_candles(delta)
		stagger_update = 0
	#if Input.is_action_just_pressed("ui_focus_next"):
		#MultiplayerManager.worldCandles.clear()
		#MultiplayerManager.worldGenSeed = Time.get_unix_time_from_system()
		#get_tree().reload_current_scene()

func _check_all_candles(delta):
	var ammount_lit = $Excorsist.candles_lit
	if ammount_lit >= MultiplayerManager.worldCandles.size():
		win_mode += (16 * delta)
		if win_mode >= 2.5:
			if multiplayer.is_server():
				MultiplayerManager.rpc("NewLevel")

func _everyone_died():
	if multiplayer.is_server() && $Player.spectate:
		var deaths = 0
		for i in MultiplayerManager.players.size() - 1:
			if MultiplayerManager.players.values()[i + 1].died:
				deaths += 1
				print(deaths)
		if deaths >= MultiplayerManager.players.size() - 1:
			multiplayer.multiplayer_peer.close()
			
		

func server_closed():
	MultiplayerManager.players.clear()
	if multiplayer.has_multiplayer_peer():
		multiplayer.multiplayer_peer.disconnect_peer(1)
	if multiplayer.multiplayer_peer != null && multiplayer.is_server():
		multiplayer.multiplayer_peer.close()
	get_tree().change_scene_to_file("res://Scenes/Menu.tscn");
	pass
