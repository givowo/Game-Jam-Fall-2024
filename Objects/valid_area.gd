extends Area2D

var color = -1;
var colors = [Color(1, 0.45098, 0), Color(0.635294, 0, 1), Color(0.639216, 1, 0)];
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var temp = $"..".modulate 
	color = colors.find(temp)
