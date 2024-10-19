extends CharacterBody2D
class_name Player
const speed = 100 # speed in delta units (not pixels. argh...)
var _char = 0
var can_interact = false
var died = false
var input_dir = 0
signal update_character_2
@onready var world = $"../Procedural Generation"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	##_char = MultiplayerManager.players[multiplayer.get_unique_id()].character
	print(_char)
	position = world.tileSize* (Vector2(world.worldSize, world.worldSize) + Vector2(1, 1)) + (world.tileSize/2)
	update_character()
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if died:
		can_interact = false
	if Input.is_action_just_pressed("debug_character"):
			GlobalPref.main_char = fmod((GlobalPref.main_char + 1), GlobalPref.charname.size())
			update_character()
	
	if !died:
		input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		velocity = input_dir * speed
		move_and_slide()
	
	can_interact = false #disables after everything so when objects set it doesnt instantly disapear lol
	MultiplayerManager.rpc("updateCharacter", _char, global_position, $AnimationHandler.sprite.animation, input_dir)

func update_character():
	update_character_2.emit()
