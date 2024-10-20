extends Node2D

var cell_size = Vector2(16, 16)
var astar_grid = AStarGrid2D.new()
var grid_size
@onready var world = $"/root/Stage/Procedural Generation"
@onready var player = $"../Player"
var start = Vector2.ZERO
var end = Vector2.ZERO
var moving_arr
var arr = []
var has_created = false
func _ready():
	initialize_grid()
	#WHOS READY FOR NESTED LOOPS!!!
	print("before big")

func _physics_process(delta: float) -> void:
	if !has_created:
		_go_big()
		has_created =true

func _go_big():
	for i in astar_grid.size.x:
		for j in astar_grid.size.y:
			$ColGrid.global_position = Vector2(-world.worldSize*world.tileSize.x, -world.worldSize*world.tileSize.y) + Vector2( 8,8) + Vector2(i* 16, j* 16)  
			$ColGrid.force_shapecast_update()
			arr.append($ColGrid.global_position)
			$ColGrid2.global_position = $ColGrid.global_position
			$ColGrid2.force_shapecast_update()
			#var obj2 = load("res://Objects/placeholder_place.tscn").instantiate();
			#add_child(obj2);
			#obj2.position = $ColGrid.global_position
			#if !$ColGrid2.is_colliding():
				#var pos = $ColGrid.global_position / cell_size
				#if astar_grid.is_in_boundsv(pos):
					#pass

			for k in $ColGrid.get_collision_count():
				var obj = $ColGrid.get_collider(k)
				if $ColGrid.is_colliding():
					var pos = $ColGrid.global_position / cell_size
					if astar_grid.is_in_boundsv(pos):
						astar_grid.set_point_solid(pos, true)
						#var obj2 = load("res://Objects/placeholder_place.tscn").instantiate();
						#add_child(obj2);
						#obj2.position = $ColGrid.global_position

func initialize_grid():
	grid_size = Rect2(0, 0, (world.worldSize * 2)* cell_size.x, (world.worldSize * 2)* cell_size.y) 
	astar_grid.region = grid_size
	astar_grid.cell_size = cell_size
	astar_grid.offset = cell_size / 2
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	astar_grid.update()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start_new_path(start_pos, end_pos, must_complete = false):
	start = start_pos / cell_size
	end = end_pos / cell_size
	#while astar_grid.is_point_solid(end):
		#if !astar_grid.is_point_solid(end + Vector2(0,1)) && astar_grid.is_in_boundsv(end + Vector2(0,1)):
			#end += Vector2(0,1)
		#if !astar_grid.is_point_solid(end + Vector2(0,-1))&& astar_grid.is_in_boundsv(end + Vector2(0,-1)):
			#end += Vector2(0,-1)
		#if !astar_grid.is_point_solid(end + Vector2(1,0))&& astar_grid.is_in_boundsv(end + Vector2(1,0)):
			#end += Vector2(1,0)
		#if !astar_grid.is_point_solid(end + Vector2(-1,0))&& astar_grid.is_in_boundsv(end + Vector2(-1,0)):
			#end += Vector2(-1,0)
	return astar_grid.get_point_path(start, end, must_complete)

func _draw():
	pass
	draw_grid()
	fill_walls()
	for i in arr.size():
		draw_rect(Rect2(arr[i].x, arr[i].y,1, 1), Color(1,0,0,1))
	#draw_rect(Rect2(start * cell_size, cell_size), Color.GREEN_YELLOW)
	#draw_rect(Rect2(end * cell_size, cell_size), Color.ORANGE_RED)
	
func draw_grid():
	for x in grid_size.size.x:
		draw_line(Vector2(x * cell_size.x, 0), Vector2(x * cell_size.x, grid_size.size.y * cell_size.y), (Color.DARK_GRAY), 2.0)
	for y in grid_size.size.y:
		draw_line(Vector2(0, y * cell_size.y), Vector2(grid_size.size.x * cell_size.x, y * cell_size.y), Color.DARK_GRAY, 2.0)

func fill_walls():
	for x in grid_size.size.x:
		for y in grid_size.size.y:
			if astar_grid.is_point_solid(Vector2i(x, y)):
				draw_rect(Rect2(x * cell_size.x, y * cell_size.y, cell_size.x, cell_size.y), Color(0.5,0.5,0.5,0.5))
