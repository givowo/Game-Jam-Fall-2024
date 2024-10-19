extends Camera2D 

func _ready(): 
	if get_parent().get_parent() != get_tree().root:
		queue_free();
	pass 
	
func _process(delta):
	var moveVector = Input.get_vector("move_left", "move_right", "move_up", "move_down");
	position += moveVector * 100 * delta;
	
	var zoomInput = Input.get_axis("debug_zoom_out", "debug_zoom_in");
	zoom += Vector2.ONE * zoomInput * delta;
