extends Player
class_name Player_Peer

var player_id = -2
func _ready():
	MultiplayerManager.player_disconnected.connect(_on_player_disconnected)
func _process(delta: float) -> void:
	if MultiplayerManager.players.has(player_id):
		global_position = MultiplayerManager.players[player_id].position 
		if _char != MultiplayerManager.players[player_id].character: 
			_char = MultiplayerManager.players[player_id].character
			update_character_2.emit()
		$AnimationHandler.animationQueue.emit(MultiplayerManager.players[player_id].animation)
	
func _on_player_disconnected(id):
	if player_id == id:
		queue_free()
