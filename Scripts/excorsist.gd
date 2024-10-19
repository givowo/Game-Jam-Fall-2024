extends CharacterBody2D


const SPEED = 60
var direction = 0
var sight_dist = 64
var sight_direction = 1
var move_index = 0
var move_timer = 0
var moving = false
var move_arr
var move_mode = 0
var scan_mode = 0
var timeout = 0
@onready var world = $"/root/Stage/Procedural Generation"
@onready var player = $"/root/Stage/Player"
@onready var path = $"/root/Stage/Node2D"

func _ready():
	position = world.tileSize* (Vector2(world.worldSize, world.worldSize) + Vector2(0, -1)) + (world.tileSize/2)
	move_arr = path.start_new_path(position, Vector2(0,world.worldSize) * path.cell_size.x, true)
	moving = true


func _process(delta: float) -> void:
	if (moving):
		timeout = 0
		move_timer = fmod(move_timer + 5, 100) 
		if move_timer == 0:
			_determine_status()
			move_index = (move_index + 1) 
			if move_index >= move_arr.size() -1:
				moving = false
				return
		if move_arr.size() > 1:
			position = lerp(move_arr[move_index], move_arr[move_index+1], move_timer /100)
	else:
		_got_lost()
		
	move_and_slide()
	pass

func _determine_status():
	if move_arr.size() <= 1:
		return
	$Area2D/CollisionShape2D.rotation = move_arr[move_index].angle_to_point(move_arr[move_index+1]) - deg_to_rad(90)
	var found = $Area2D.get_overlapping_bodies()
	
	for i in found.size():
		var obj = found[i]
		if obj is Player:
			$SightBeem.target_position = obj.position - position
			$SightBeem.force_raycast_update()
			if $SightBeem.is_colliding() and ($SightBeem.get_collider() is Player):
				move_arr = path.start_new_path(move_arr[move_index], player.position)
				move_index = 0
				move_mode = 1
				moving = true
				
func _got_lost():
	match move_mode:
		0:
			$SightBeem.force_raycast_update()
			if !$SightBeem.is_colliding():
				move_arr = path.start_new_path(position, position + $SightBeem.target_position)
				move_index = 0
				moving = true
			else:
				scan_mode -= 1
				$SightBeem.target_position = $SightBeem.target_position.rotated(deg_to_rad(scan_mode))
			
		1:
			timeout += 1
			$Area2D/CollisionShape2D.rotation += deg_to_rad(8)
			var found = $Area2D.get_overlapping_bodies()
			
			for i in found.size():
				var obj = found[i]
				if obj is Player:
					$SightBeem.target_position = obj.position - position
					$SightBeem.force_raycast_update()
					if $SightBeem.is_colliding() and ($SightBeem.get_collider() is Player):
						move_arr = path.start_new_path(move_arr[move_index], player.position)
						move_index = 0
						moving = true
			
			if timeout >= 60:
				move_index = 0
				move_mode = 0
				timeout = 0
	
				
