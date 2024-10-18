extends CharacterBody2D

var speed = 100 # speed in delta units (not pixels. argh...)
var _char = GlobalPref.main_char
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	velocity = input_dir * speed
	move_and_slide()
