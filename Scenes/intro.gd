extends Control

var string = ["DEATH WENT ROUGE", "AND KILLED THE", "OTHER HORSEMEN!", " ", "GO!", "LIGHT THE CANDLES", "TO COME BACK"]
var progress = 0
var progress2 = 0
var progress3 = 0
var done = false
var done_string = ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scale = Vector2(160 / size.x, 144 / size.y)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact_object"):
		get_tree().change_scene_to_file("res://Scenes/Menu.tscn");
	
	if !done:
		progress += 1 * delta
		if progress > 1:
			progress = 0
			if progress2 >= string.size():
				done = true
				done_string = $Label.text
				progress3 = $Label.text.length()
				await get_tree().create_timer(0.5).timeout
				return
			$Label.text += string[min(progress2,string.size()-1)] + "\n"
			progress2 += 1
	else:
		progress3 -= (32* delta)
		if (progress3 <= 0):
			get_tree().change_scene_to_file("res://Scenes/Menu.tscn");
		$Label.text = done_string.substr(0, floor(progress3))
		
