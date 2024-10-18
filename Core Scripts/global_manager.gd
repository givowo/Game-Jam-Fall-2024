@tool
extends Node
## Global script that hold any useful functions and other logic that needs to run constantly

## The games constant timer. Goes up every frame from game start.
var timer = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta: float) -> void:
	#if not Engine.is_editor_hint():
		#if !has_node("/root/DebugHUD"):
			#var dev = preload("res://GD-Sonic/Core-Objects/Cores/hud.tscn").instantiate()
			#$/root.add_child(dev)
	pass

func _run():
	timer = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	timer += 1

## Cuts off any decimal place
func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

## Spills out rings based on an objects position 

func bit_shift(shift : float):
	return pow(2, -shift);
	
func angle_dif_degree(from : float, to : float):
	var ans = fposmod(to - from, 360);
	if ans > 180:
		ans -= 360;
	return ans;
