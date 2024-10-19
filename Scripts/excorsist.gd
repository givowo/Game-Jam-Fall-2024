extends CharacterBody2D


const SPEED = 300
@export var direction = 0
@export var sight_dist = 64
@export var sight_direction = 1
@export var move_index = 0
@export var move_timer = 0
@export var moving = false
@export var move_arr = []
@export var move_mode = 0
@export var scan_mode = 0
@export var timeout = 0
@export var staus_queue : Array = [[Vector2.ZERO,0]]
@onready var world = $"/root/Stage/Procedural Generation"
@onready var player = $"/root/Stage/Player"
@onready var path = $"/root/Stage/Node2D"

func _ready():
	position = world.tileSize* (Vector2(world.worldSize, world.worldSize) + Vector2(0, -1)) + (world.tileSize/2)
	move_arr = path.start_new_path(position, Vector2(path.astar_grid.size.x /2,path.astar_grid.size.y - 5) , true)
	moving = true


func _process(delta: float) -> void:
	
	timeout = 0
	move_timer = move_timer + (SPEED * delta) 
	if move_timer >= 100:
		move_index = (move_index + 1) 
		move_timer = 0
		_determine_status()
		_update_status()
	if move_arr.size() > 1:
		position = lerp(move_arr[min(move_index, move_arr.size()-1)], move_arr[min(move_index+1, move_arr.size()-1)], move_timer /100)
		$Area2D.rotation = move_arr[min(move_index, move_arr.size()-1)].angle_to_point(move_arr[min(move_index+1, move_arr.size()-1)]) - deg_to_rad(90)
		
	move_and_slide()
	pass

func _determine_status():
	var found = $Area2D.get_overlapping_bodies()
	
	for i in found.size():
		var obj = found[i]
		if obj is Player:
			$SightBeem.target_position = obj.position - position
			$SightBeem.force_raycast_update()
			if $SightBeem.is_colliding() and ($SightBeem.get_collider() is Player):
				staus_queue.append([obj.global_position, 1])
				
func _update_status():
	for i in staus_queue.size():
		move_arr = path.start_new_path(global_position, staus_queue[i][0])
		move_index = 0
		move_mode = staus_queue[i][1]
		move_timer = 0
		staus_queue.remove_at(i)
		return
func _got_lost():
	match move_mode:
		0:
			_determine_status()
			moving = true
		1:
			timeout += 1
			$Area2D.rotation += deg_to_rad(8)
			var found = $Area2D.get_overlapping_bodies()
			
			for i in found.size():
				var obj = found[i]
				if obj is Player:
					$SightBeem.target_position = obj.position - position
					$SightBeem.force_raycast_update()
					if $SightBeem.is_colliding() and ($SightBeem.get_collider() is Player):
						staus_queue.append([obj.global_position, 1])
			
			if timeout >= 60:
				move_index = 0
				move_mode = 0
				timeout = 0
	
				
