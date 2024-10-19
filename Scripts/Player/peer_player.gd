extends CharacterBody2D

const speed = 100 # speed in delta units (not pixels. argh...)
var _char = 0
var can_interact = false
var died = false
var input_dir = 0
signal update_character_2


func _process(delta: float) -> void:
	

	move_and_slide()

func update_character():
	update_character_2.emit()
