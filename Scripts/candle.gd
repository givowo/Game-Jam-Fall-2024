extends Area2D

var interacted = false
var is_interactable = false

var color = [0,0.5,0.7]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$CollisionShape2D.debug_color = Color(0,0,1,0.5)
	is_interactable = false
	if interacted:
		$CollisionShape2D.debug_color = Color(1,0,1,0.5)
	
	var bodys = get_overlapping_bodies()
	
	for i in bodys.size():
		if bodys[i] is CharacterBody2D:
			if !interacted:
				is_interactable = true
				$Interact.material.set_shader_parameter("cycleOffset",color[bodys[i]._char])
			if Input.is_action_just_pressed("interact_object") && !interacted:
				interacted = true
				
	$Interact.visible = is_interactable

func _on_body_entered(body: Node2D) -> void:
	pass
			
