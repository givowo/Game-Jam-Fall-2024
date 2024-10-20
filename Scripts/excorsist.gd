extends CharacterBody2D


var SPEED = 300
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
@onready var sprite = $AnimatedSprite2D;
@export var candles_lit = 0
var lastPositions = []

func _ready():
	position = world.tileSize* (Vector2(world.worldSize, world.worldSize) + Vector2(0, -1)) + (world.tileSize/2)
	move_arr = path.start_new_path(position, Vector2(path.astar_grid.size.x /2,path.astar_grid.size.y - 5) , true)
	moving = true
	
	while global_position.distance_to(ProcGen.Instance.global_position) < 240:
		global_position = ProcGen.Instance.global_position + ProcGen.Instance.placedTiles.keys().pick_random() * 80 - Vector2(40, 40)


func _process(delta: float) -> void:
	
	SPEED = 300 + (candles_lit * 10)
	
	lastPositions.append(position);
	
	if lastPositions.size() >= 3:
		lastPositions.remove_at(0);
	
	timeout = 0
	move_timer = move_timer + (SPEED * delta) 
	if move_timer >= 100:
		move_index = (move_index + 1)
		if move_index >=  move_arr.size()-1:
			_got_lost()
		move_timer = 0
		_determine_status()
		_update_status()
	if move_arr.size() > 1:
		position = lerp(move_arr[min(move_index, move_arr.size()-1)], move_arr[min(move_index+1, move_arr.size()-1)], move_timer /100)
		$Area2D.rotation = move_arr[min(move_index, move_arr.size()-1)].angle_to_point(move_arr[min(move_index+1, move_arr.size()-1)]) - deg_to_rad(90)
		
	move_and_slide()
	
	var moveOffset = (position - lastPositions[0]).normalized();
	if abs(Vector2(1, 0).angle_to(moveOffset)) < PI / 4:
		sprite.play("Right");
	if abs(Vector2(0, 1).angle_to(moveOffset)) < PI / 4:
		sprite.play("Down");
	if abs(Vector2(-1, 0).angle_to(moveOffset)) < PI / 4:
		sprite.play("Left");
	if abs(Vector2(0, -1).angle_to(moveOffset)) < PI / 4:
		sprite.play("Up");
	
	_kill_goul()
	pass

func _determine_status():
	var found = $Area2D.get_overlapping_bodies()
	
	for i in found.size():
		var obj = found[i]
		if obj is Player && !obj.died:
			$SightBeem.target_position = obj.position - position
			$SightBeem.force_raycast_update()
			if $SightBeem.is_colliding() and ($SightBeem.get_collider() is Player) and ($SightBeem.get_collider().canBeSee):
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
	var obj = MultiplayerManager.worldCandles.pick_random()
	staus_queue.append([obj.global_position, 1])
	
func _kill_goul():
	var found = $TouchPlayer.get_overlapping_bodies()
	
	for i in found.size():
		var obj = found[i]
		if obj is Player && !obj.died:
			obj.died = true
				
