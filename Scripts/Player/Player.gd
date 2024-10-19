extends CharacterBody2D

var speed = 100 # speed in delta units (not pixels. argh...)
var _char = GlobalPref.main_char
var can_interact = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_character"):
			GlobalPref.main_char = fmod((GlobalPref.main_char + 1), GlobalPref.charname.size())
			update_character()
	
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	velocity = input_dir * speed
	move_and_slide()
	
	can_interact = false #disables after everything so when objects set it doesnt instantly disapear lol

func update_character():
	_char = GlobalPref.main_char
