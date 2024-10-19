extends StaticBody2D
class_name Candle
var interacted = false
var is_interactable = false
var ani_state = 0
@onready var excor = $"/root/Stage/Excorsist"
var color = [0,0.5,0.7]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play("unused")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$CollisionShape2D.debug_color = Color(0,0,1,0.5)
	is_interactable = false
	if interacted:
		$CollisionShape2D.debug_color = Color(1,0,1,0.5)
	
	var bodys = $Area2D.get_overlapping_bodies()
	
	for i in bodys.size():
		if bodys[i] is Player:
			if !interacted:
				is_interactable = true
				$Interact.material.set_shader_parameter("cycleOffset",color[bodys[i]._char])
			if Input.is_action_just_pressed("interact_object") && !interacted:
				interacted = true
				excor.staus_queue.append([global_position, 1])
				
	$Interact.visible = is_interactable
	
	if interacted && ani_state == 0:
		$AnimatedSprite2D.play("just_lit")
		ani_state = 1

func _on_animated_sprite_2d_animation_looped() -> void:
	if $AnimatedSprite2D.animation == "just_lit":
		$AnimatedSprite2D.play("used")
