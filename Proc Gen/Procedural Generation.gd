extends Node2D

# name, right down left up
# -1: any, 0: open, 1: door, 2: wall
@onready var tiles = [
	["OOOW", [0, 2, 2, 2], [2, 0, 2, 2], [2, 2, 0, 2], [2, 2, 2, 0]],
	["OOOD", [1, 2, 2, 2], [2, 1, 2, 2], [2, 2, 1, 2], [2, 2, 2, 1]],
	["OWWO", [0, 2, 2, 0], [0, 0, 2, 2], [2, 0, 0, 2], [2, 2, 0, 0]],
	["DWWO", [1, 2, 2, 0], [0, 1, 2, 2], [2, 0, 1, 2], [2, 2, 0, 1]],
	["OWWD", [0, 2, 2, 1], [1, 0, 2, 2], [2, 1, 0, 2], [2, 2, 1, 0]],
	["OWOO", [0, 2, 0, 0], [0, 0, 2, 0], [0, 0, 0, 2], [2, 0, 0, 0]],
	["OWDO", [0, 2, 1, 0], [0, 0, 2, 1], [1, 0, 0, 2], [2, 1, 0, 0]],
	["DWDO", [1, 2, 1, 0], [0, 1, 2, 1], [1, 0, 1, 2], [2, 1, 0, 1]],
	["DWDD", [1, 2, 1, 1], [1, 1, 2, 1], [1, 1, 1, 2], [2, 1, 1, 1]],
	["DWOO", [1, 2, 0, 0], [0, 1, 2, 0], [0, 0, 1, 2], [2, 0, 0, 1]],
	["DWOD", [1, 2, 0, 1], [1, 1, 2, 0], [0, 1, 1, 2], [2, 0, 1, 1]],
	["OWDD", [0, 2, 1, 1], [1, 0, 2, 1], [1, 1, 0, 2], [2, 1, 1, 0]],
	["OOOO", [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
	["DDDD", [1, 1, 1, 1], [1, 1, 1, 1], [1, 1, 1, 1], [1, 1, 1, 1]],
	["DDDO", [1, 1, 1, 0], [0, 1, 1, 1], [1, 0, 1, 1], [1, 1, 0, 1]],
	["WWWW", [2, 2, 2, 2], [2, 2, 2, 2], [2, 2, 2, 2], [1, 1, 1, 1]],
	["OWOW", [0, 2, 0, 2], [2, 0, 2, 0], [0, 2, 0, 2], [2, 0, 2, 0]],
	["OWDO", [0, 2, 1, 0], [0, 0, 2, 1], [1, 0, 0, 2], [2, 1, 0, 0]],
	["DWDW", [1, 2, 1, 2], [2, 1, 2, 1], [1, 2, 1, 2], [2, 1, 2, 1]]
];

var tileSize = Vector2(80, 80);
var worldSize = 3;
var emptyTiles = [];
var placedTiles = {};

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GenerateWorld();
	pass # Replace with function body.

func GenerateWorld() -> void:
	for i in range(0, worldSize * 2 + 1):
		for j in range(0, worldSize * 2 + 1):
			var x = j;
			if (x > worldSize):
				x = (x - worldSize) * -1;
			var y = i;
			if (y > worldSize):
				y = (y - worldSize) * -1;
				
			if (Vector2(0, 0).distance_to(Vector2(x, y)) <= worldSize):
				emptyTiles.append(Vector2(x, y)); 
	
	var startingRandom = PickRandomTile([-1, -1, -1, -1]);
	var startingTile = load("res://Will/Tiles/" + startingRandom[0]).instantiate();
	startingTile.position = Vector2(0, 0);
	add_child(startingTile);
	placedTiles[Vector2(0, 0)] = startingRandom[1];
	emptyTiles.remove_at(emptyTiles.find(Vector2(0, 0)));
	
	for i in emptyTiles:
		var newRandom = PickRandomTile(GetTilesAround(i));
		if (newRandom == null):
			continue;
		var newTile = load("res://Will/Tiles/" + newRandom[0]).instantiate();
		newTile.position = i * tileSize;
		add_child(newTile);
		placedTiles[i] = newRandom[1];
	pass

func PickRandomTile(edges):
	var validTiles = [];
	
	var right = edges[0];
	var down = edges[1];
	var left = edges[2];
	var up = edges[3];
	
	for tile in tiles:
		if ((right == -1 || right == tile[1][0]) && (down == -1 || down == tile[1][1]) && (left == -1 || left == tile[1][2]) && (up == -1 || up == tile[1][3])):
			validTiles.append([tile[0] + "/R.tscn", tile[1]]);
		if ((right == -1 || right == tile[2][0]) && (down == -1 || down == tile[2][1]) && (left == -1 || left == tile[2][2]) && (up == -1 || up == tile[2][3])):
			validTiles.append([tile[0] + "/D.tscn", tile[2]]);
		if ((right == -1 || right == tile[3][0]) && (down == -1 || down == tile[3][1]) && (left == -1 || left == tile[3][2]) && (up == -1 || up == tile[3][3])):
			validTiles.append([tile[0] + "/L.tscn", tile[3]]);
		if ((right == -1 || right == tile[4][0]) && (down == -1 || down == tile[4][1]) && (left == -1 || left == tile[4][2]) && (up == -1 || up == tile[4][3])):
			validTiles.append([tile[0] + "/U.tscn", tile[4]]);
	
	return validTiles.pick_random();
	pass

func GetTilesAround(tile):
	var sides = [];
	
	if (!placedTiles.has(tile + Vector2(1, 0)) && Vector2(0, 0).distance_to(tile + Vector2(1, 0)) <= worldSize):
		sides.append(-1);
	elif (Vector2(0, 0).distance_to(tile + Vector2(1, 0)) > worldSize):
		sides.append(2);
	else:
		sides.append(placedTiles[tile + Vector2(1, 0)][2]);
		
	if (!placedTiles.has(tile + Vector2(0, 1)) && Vector2(0, 0).distance_to(tile + Vector2(0, 1))  <= worldSize):
		sides.append(-1);
	elif (Vector2(0, 0).distance_to(tile + Vector2(0, 1)) > worldSize):
		sides.append(2);
	else:
		sides.append(placedTiles[tile + Vector2(0, 1)][3]);
		
	if (!placedTiles.has(tile + Vector2(-1, 0)) && Vector2(0, 0).distance_to(tile + Vector2(-1, 0))  <= worldSize):
		sides.append(-1);
	elif (Vector2(0, 0).distance_to(tile + Vector2(-1, 0)) > worldSize):
		sides.append(2);
	else:
		sides.append(placedTiles[tile + Vector2(-1, 0)][0]);
		
	if (!placedTiles.has(tile + Vector2(0, -1)) && Vector2(0, 0).distance_to(tile + Vector2(0, -1))  <= worldSize):
		sides.append(-1);
	elif (Vector2(0, 0).distance_to(tile + Vector2(0, -1)) > worldSize):
		sides.append(2);
	else:
		sides.append(placedTiles[tile + Vector2(0, -1)][1]);
	
	return sides;
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
