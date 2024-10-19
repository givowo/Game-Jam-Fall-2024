extends Player
class_name Player_Peer

var player_id = -2

func _process(delta: float) -> void:
	global_position = MultiplayerManager.players[player_id].position 
	if _char != MultiplayerManager.players[player_id].character: 
		_char = MultiplayerManager.players[player_id].character
		update_character_2.emit()
	$AnimationHandler.animationQueue.emit(MultiplayerManager.players[player_id].animation)
