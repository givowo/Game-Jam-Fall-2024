extends Area2D

var interacted = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$CollisionShape2D.debug_color = Color(0,0,1,0.5)
	 
	if interacted:
		$CollisionShape2D.debug_color = Color(1,0,1,0.5)
	
	var bodys = get_overlapping_bodies()
	
	for i in bodys.size():
		if bodys[i] is CharacterBody2D:
			if Input.is_action_just_pressed("interact_object") && !interacted:
				interacted = true

func _on_body_entered(body: Node2D) -> void:
	pass
			
