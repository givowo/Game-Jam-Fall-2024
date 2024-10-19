extends Node2D

# name, right down left up
# -2 not wall, -1: any, 0: open, 1: door, 2: wall
@onready var tiles = [
	["OWWW", [0, 2, 2, 2]],
	["DWWW", [1, 2, 2, 2]],
	["OWWO", [0, 2, 2, 0]],
	["DWWO", [1, 2, 2, 0]],
	["OWWD", [0, 2, 2, 1]],
	["OWOO", [0, 2, 0, 0]],
	["OWDO", [0, 2, 1, 0]],
	["DWDO", [1, 2, 1, 0]],
	["DWDD", [1, 2, 1, 1]],
	["DWOO", [1, 2, 0, 0]],
	["DWOD", [1, 2, 0, 1]],
	["OWDD", [0, 2, 1, 1]],
	["OOOO", [0, 0, 0, 0]],
	["DDDD", [1, 1, 1, 1]],
	["DDDO", [1, 1, 1, 0]],
	["WWWW", [2, 2, 2, 2]],
	["OWOW", [0, 2, 0, 2]],
	["OWDO", [0, 2, 1, 0]],
	["DWDW", [1, 2, 1, 2]],
	["ODDO", [0, 1, 1, 0]],
	["ODOO", [0, 1, 0, 0]],
	["ODOD", [0, 1, 0, 1]],
	["DWWD", [1, 2, 2, 1]]
];

var colors = [Color(0.639216, 1, 0, 0.25), Color(1, 0.45098, 0, 0.25), Color(0.635294, 0, 1, 0.25)];
@onready var tileContainer = $Tiles;
var tileSize = Vector2(80, 80);
var worldSize = 2;
var emptyTiles = [];
var placedTiles = {};
var tileColors = {};
var emptySpaces = [];

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position += tileSize * Vector2(worldSize,worldSize)
	GenerateWorld();
	pass # Replace with function body.

func GenerateWorld() -> void:
	for tile in tiles:
		tile.append([tile[1][3], tile[1][0], tile[1][1], tile[1][2]]);
		tile.append([tile[1][2], tile[1][3], tile[1][0], tile[1][1]]);
		tile.append([tile[1][1], tile[1][2], tile[1][3], tile[1][0]]);
	
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
	var startingTile = load("res://Proc Gen/Tiles/" + startingRandom[0]).instantiate();
	startingTile.position = Vector2(0, 0);
	tileContainer.add_child(startingTile);
	placedTiles[Vector2(0, 0)] = startingRandom[1];
	emptyTiles.remove_at(emptyTiles.find(Vector2(0, 0)));
	var testColorStart = ColorRect.new();
	testColorStart.name = "color";
	testColorStart.color = Color(1, 1, 1, 0.25);
	testColorStart.size = Vector2(80, 80);
	startingTile.add_child(testColorStart);
	
	if get_parent() != get_tree().root:
		var area = load("res://Objects/valid_area.tscn").instantiate();
		area.position = Vector2(0, 0);
		add_child(area);
	
	for i in emptyTiles:
		var newRandom = PickRandomTile(GetTilesAround(i));
		if (newRandom == null):
			print("COULDNT PLACE TILE AT ", i)
			continue;
		var newTile = load("res://Proc Gen/Tiles/" + newRandom[0]).instantiate();
		newTile.position = i * tileSize;
		tileContainer.add_child(newTile);
		var testColor = ColorRect.new();
		testColor.name = "color";
		testColor.color = Color(1, 1, 1, 0.25);
		testColor.size = Vector2(80, 80);
		newTile.add_child(testColor);
		placedTiles[i] = newRandom[1];
		
		print(newRandom[1])
		
		if get_parent() == get_tree().root:
			continue;
		
		var area_n = load("res://Objects/valid_area.tscn").instantiate();
		area_n.position = i * tileSize;
		add_child(area_n);
		var candle = load("res://Objects/candle.tscn").instantiate();
		candle.position = (i * tileSize) + Vector2(40, 40);
		add_child(candle);
	
	if get_parent() == get_tree().root:
		return;
	
	for i in placedTiles.size():
		var array = placedTiles.values()[i];
		for j in array.size():
			if (array[j] == 0 || array[j] == 1): 
				var value = (placedTiles.keys()[i] * tileSize + Vector2(40,40)) + Vector2(40, 0).rotated(deg_to_rad(j*90)) 
				if emptySpaces.find(value) == -1:
					var obj = load("res://Objects/placeholder_place.tscn").instantiate();
					add_child(obj);
					obj.position = value
					#emptySpaces.append(value)
	
	for tile in placedTiles:
		if tile.get_node("color") == Color(1, 1, 1, 0.25):
			var color
		pass
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
		
	if (!placedTiles.has(tile + Vector2(0, 1)) && Vector2(0, 0).distance_to(tile + Vector2(0, 1)) <= worldSize):
		sides.append(-1);
	elif (Vector2(0, 0).distance_to(tile + Vector2(0, 1)) > worldSize):
		sides.append(2);
	else:
		sides.append(placedTiles[tile + Vector2(0, 1)][3]);
		
	if (!placedTiles.has(tile + Vector2(-1, 0)) && Vector2(0, 0).distance_to(tile + Vector2(-1, 0)) <= worldSize):
		sides.append(-1);
	elif (Vector2(0, 0).distance_to(tile + Vector2(-1, 0)) > worldSize):
		sides.append(2);
	else:
		sides.append(placedTiles[tile + Vector2(-1, 0)][0]);
		
	if (!placedTiles.has(tile + Vector2(0, -1)) && Vector2(0, 0).distance_to(tile + Vector2(0, -1)) <= worldSize):
		sides.append(-1);
	elif (Vector2(0, 0).distance_to(tile + Vector2(0, -1)) > worldSize):
		sides.append(2);
	else:
		sides.append(placedTiles[tile + Vector2(0, -1)][1]);
	
	print(tile, sides);
	
	return sides;
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
