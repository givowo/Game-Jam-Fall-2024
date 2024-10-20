extends Camera2D

@onready var tracking : Node2D = $"../Player"
@onready var player : Node2D = $"../Player"
var prev_tracked = -1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = tracking.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = tracking.position
	if player.spectate && prev_tracked != player.spec_player:
		for i in $"..".get_child_count():
			if $"..".get_child(i) is Player_Peer && $"..".get_child(i).player_id == MultiplayerManager.players.keys()[player.spec_player]:
				tracking = $"..".get_child(i)
				prev_tracked = player.spec_player
			
