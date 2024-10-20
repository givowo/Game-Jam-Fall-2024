extends CharacterBody2D
#class_name Excosist
#static var Instance

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
@export var stuck_timer = 0
@export var lastPositions = []

func _ready():
	#Instance = self;
	position = world.tileSize* (Vector2(world.worldSize, world.worldSize) + Vector2(0, -1)) + (world.tileSize/2)
	
	if multiplayer.is_server():
		_got_lost()
		moving = true
		while global_position.distance_to(ProcGen.Instance.global_position) < 240:
			global_position = ProcGen.Instance.global_position + ProcGen.Instance.placedTiles.keys().pick_random() * 80 + Vector2(40, 40)


func _process(delta: float) -> void:
	if multiplayer.is_server():
		processMove(delta);
	
	_kill_goul()
	pass

func processMove(delta):
	SPEED = 400 + (candles_lit * 2)
	
	lastPositions.append(position);
	
	if lastPositions.size() >= 3:
		lastPositions.remove_at(0);
	
	timeout = 0
	move_timer = move_timer + (SPEED * delta) 
	if move_timer >= 100:
		move_index = (move_index + 1)
		move_timer = 0
		_determine_status()
		if move_index >=  move_arr.size()-1:
			_got_lost()
		_update_status()
	if move_arr.size() > 1:
		position = lerp(move_arr[min(move_index, move_arr.size()-1)], move_arr[min(move_index+1, move_arr.size()-1)], move_timer /100)
		$Area2D.rotation = move_arr[min(move_index, move_arr.size()-1)].angle_to_point(move_arr[min(move_index+1, move_arr.size()-1)]) - deg_to_rad(90)
		
	move_and_slide()
	
	if lastPositions.size() >= 3 && lastPositions[2] == position:
		stuck_timer += 1
		if stuck_timer == 60:
			var obj = MultiplayerManager.worldCandles.pick_random()
			staus_queue.append([obj.global_position, 0])
	else:
		stuck_timer = 0
	
	var moveOffset = (position - lastPositions[0]).normalized();
	if abs(Vector2(1, 0).angle_to(moveOffset)) < PI / 4:
		sprite.play("Right");
	if abs(Vector2(0, 1).angle_to(moveOffset)) < PI / 4:
		sprite.play("Down");
	if abs(Vector2(-1, 0).angle_to(moveOffset)) < PI / 4:
		sprite.play("Left");
	if abs(Vector2(0, -1).angle_to(moveOffset)) < PI / 4:
		sprite.play("Up");

func _determine_status():
	var found = $Area2D.get_overlapping_bodies()
	
	for i in found.size():
		var obj = found[i]
		if obj is Player && !obj.died:
			$SightBeem.target_position = obj.global_position - global_position;
			$SightBeem.force_raycast_update()
			if $SightBeem.is_colliding() and ($SightBeem.get_collider() is Player || $SightBeem.get_collider() is Player_Peer) and ($SightBeem.get_collider().canBeSee):
				#MultiplayerManager.rpc("ChasePlayer", obj.global_position);
				print("chasing ", MultiplayerManager.players[$SightBeem.get_collider().player_id].name);
				ChasePlayer(obj.global_position)

func ChasePlayer(position):
	if move_mode == 0:
		staus_queue.clear()
	staus_queue.append([position, 2])

func _update_status():
	for i in staus_queue.size():
		move_arr = path.start_new_path(global_position, staus_queue[i][0])
		move_index = 0
		move_mode = staus_queue[i][1]
		move_timer = 0
		staus_queue.remove_at(i)
		print(move_mode)
		return
		
func _got_lost():
	var obj = MultiplayerManager.worldCandles.pick_random()
	staus_queue.append([obj.global_position, 0])
	
func _kill_goul():
	var found = $TouchPlayer.get_overlapping_bodies()
	
	for i in found.size():
		var obj = found[i]
		if obj is Player && !obj.died && obj.canBeSee:
			obj.died = true
				
