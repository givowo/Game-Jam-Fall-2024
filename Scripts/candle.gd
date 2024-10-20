extends StaticBody2D
class_name Candle

@export var interacted = false
@export var is_interactable = false
@export var ani_state = 0
@onready var excor = $"/root/Stage/Excorsist"
@export var color = [0,0.5,0.7]

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
		if bodys[i] is Player && !bodys[i].died && bodys[i] is not Player_Peer:
			if !interacted:
				is_interactable = true
				$Interact.material.set_shader_parameter("cycleOffset",color[bodys[i]._char])
			if Input.is_action_just_pressed("interact_object") && !interacted:
				MultiplayerManager.rpc("LightCandle", MultiplayerManager.worldCandles.find(self));
				
	$Interact.visible = is_interactable
	
	if interacted && ani_state == 0:
		$AnimatedSprite2D.play("just_lit")
		ani_state = 1

func _on_animated_sprite_2d_animation_looped() -> void:
	if $AnimatedSprite2D.animation == "just_lit":
		$AnimatedSprite2D.play("used")

func Light(char):
	interacted = true
	if excor.move_mode <= 1:
		if excor.move_mode == 0:
			excor.staus_queue.clear()
		excor.staus_queue.append([global_position, 1])
	$AnimatedSprite2D.material.set_shader_parameter("cycleOffset", color[char]);
	excor.candles_lit += 1
	pass
