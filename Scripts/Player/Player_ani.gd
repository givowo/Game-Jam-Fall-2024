extends Node
@onready var prev = $".."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	prev.aniData["Win"] = {"loopPoint" : 12}
	match owner.input_dir:
		(Vector2(0,1)):
			prev.animationQueue.emit("Down")
		(Vector2(0,-1)):
			prev.animationQueue.emit("Up")
		(Vector2(1,0)):
			prev.animationQueue.emit("Right")
		(Vector2(-1,0)):
			prev.animationQueue.emit("Left")
	
	if owner.died:
		prev.animationQueue.emit("Death")
	if $"/root/Stage".win_mode > 0:
		prev.animationQueue.emit("Win")
