extends CharacterBody2D
class_name Player

const speed = 100 # speed in delta units (not pixels. argh...)
var _char = 0
var can_interact = false
var died = false
var spectate = false
var spec_player = 0
var input_dir = 0
var input_delay = 10
signal update_character_2
@onready var world = $"../Procedural Generation"
var death_timer = 0 
var player_id
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_char = MultiplayerManager.players[multiplayer.get_unique_id()].character
	print(_char)
	position = world.tileSize* (Vector2(world.worldSize, world.worldSize) + Vector2(1, 1)) + (world.tileSize/2)
	update_character()
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#input_delay -= 1
	#input_delay = max(0, input_delay)
	
	if died:
		input_dir = Vector2.ZERO
		can_interact = false
		death_timer += 1 * delta
		if death_timer > 2:
			spectate = true
		
		if spectate:
			if Input.is_action_just_pressed("interact_object"):
				spec_player += 1
				spec_player = spec_player % (MultiplayerManager.players.size())
			if MultiplayerManager.players.keys()[spec_player] == player_id:
				spec_player += 1
				spec_player = spec_player % (MultiplayerManager.players.size())
	
	if !died:
		input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		velocity = input_dir * speed
		move_and_slide()
	
	can_interact = false #disables after everything so when objects set it doesnt instantly disapear lol
	if multiplayer.has_multiplayer_peer():
		MultiplayerManager.rpc("updateCharacter", _char, global_position, $AnimationHandler.sprite.animation, input_dir)

func update_character():
	update_character_2.emit()
