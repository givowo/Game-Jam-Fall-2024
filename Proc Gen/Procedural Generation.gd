extends Node2D
class_name ProcGen

static var Instance;
# name, right down left up
# -2 not wall, -1: any, 0: open, 1: door, 2: wall
@onready var tiles = [];

var rng = RandomNumberGenerator.new();
var colors = [Color(1, 0.45098, 0), Color(0.635294, 0, 1), Color(0.639216, 1, 0)];
var colorCounts = [1, 1, 1];
@onready var tileContainer = $Tiles;
var tileSize = Vector2(80, 80);
var worldSize = 5;
var emptyTiles = [];
var placedTiles = {};
var tilePositions = {};
var needToColor = [];
var emptySpaces = [];
var needToTraverse = [];
var accessibleAreas = [];
var worldColors = {};
var tileCandles = {};
var allDecorations = ["res://Assets/Decoration/Broom.png", "res://Assets/Decoration/Cauldron.png", "res://Assets/Decoration/Chair_F.png", "res://Assets/Decoration/Chair_L.png", "res://Assets/Decoration/Coffen.png", "res://Assets/Decoration/Crystal_Ball.png", "res://Assets/Decoration/lamp.png", "res://Assets/Decoration/Mushroom.png", "res://Assets/Decoration/Skull.png", "res://Assets/Decoration/Table.png", "res://Assets/Decoration/Untitled_Artwork.png"];

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Instance = self;
	worldSize += MultiplayerManager.worldGenLevel
	position += tileSize * Vector2(worldSize,worldSize)
	print("before gen")
	if get_parent() == get_tree().root:
		GenerateWorld();
	else:
		GenerateWorld(MultiplayerManager.worldGenSeed);
		#$"../Node2D"._go_big()
	print("after gen")
	pass # Replace with function body.

func GenerateWorld(RNGseed = Time.get_unix_time_from_system()) -> void:
	seed(RNGseed);
	rng.seed = RNGseed;
	
	var dir := DirAccess.open("res://Proc Gen/Tiles/");
	dir.list_dir_begin()
	var letterToNumber = {"O": 0, "D": 1, "W": 2};
	for direc in dir.get_directories():
		var newTile = [direc, [letterToNumber[direc.substr(0, 1)], letterToNumber[direc.substr(1, 1)], letterToNumber[direc.substr(2, 1)], letterToNumber[direc.substr(3, 1)]]];
		newTile.append([newTile[1][3], newTile[1][0], newTile[1][1], newTile[1][2]]);
		newTile.append([newTile[1][2], newTile[1][3], newTile[1][0], newTile[1][1]]);
		newTile.append([newTile[1][1], newTile[1][2], newTile[1][3], newTile[1][0]]);
		tiles.append(newTile);
		#print(newTile);
	
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
	startingTile.name = str(Vector2(0, 0)) + ", " + startingRandom[0];
	tileContainer.add_child(startingTile);
	placedTiles[Vector2(0, 0)] = startingRandom[1];
	tilePositions[Vector2(0, 0)] = startingTile;
	needToColor.append(Vector2(0, 0));
	emptyTiles.remove_at(emptyTiles.find(Vector2(0, 0)));
	
	if get_parent() != get_tree().root:
		var area = load("res://Objects/valid_area.tscn").instantiate();
		area.position = Vector2(0, 0);
		startingTile.add_child(area);
	
	for i in emptyTiles:
		var newRandom = PickRandomTile(GetTilesAround(i));
		if (newRandom == null):
			print("COULDNT PLACE TILE AT ", i)
			continue;
		var newTile = load("res://Proc Gen/Tiles/" + newRandom[0]).instantiate();
		newTile.name = str(i) + ", " + newRandom[0];
		newTile.position = i * tileSize;
		tileContainer.add_child(newTile);
		placedTiles[i] = newRandom[1];
		tilePositions[i] = newTile;
		needToColor.append(i);
		var area_n = load("res://Objects/valid_area.tscn").instantiate();
		area_n.position = i * tileSize;
		newTile.add_child(area_n);
		
		if get_parent() == get_tree().root:
			continue;
		
		var candle = load("res://Objects/candle.tscn").instantiate();
		var candlePos = Vector2(randi_range(28, 52), randi_range(28, 52));
		candle.position = (i * tileSize) + candlePos;
		add_child(candle);
		tileCandles[i] = candlePos;
		MultiplayerManager.worldCandles.append(candle);
		
	
	needToTraverse = needToColor.duplicate(true);
	while needToTraverse.size() > 0:
		FindConneceted(needToTraverse.pick_random());
		pass
		
	for i in range(1, accessibleAreas.size()):
		for tile in accessibleAreas[i]:
			var preserveTiles = [];
			if placedTiles[tile][0] == 2:
				preserveTiles.append(-2);
			else:
				preserveTiles.append(placedTiles[tile][0]);
				
			if placedTiles[tile][1] == 2:
				preserveTiles.append(-2);
			else:
				preserveTiles.append(placedTiles[tile][1]);
				
			if placedTiles[tile][2] == 2:
				preserveTiles.append(-2);
			else:
				preserveTiles.append(placedTiles[tile][2]);
				
			if placedTiles[tile][3] == 2:
				preserveTiles.append(-2);
			else:
				preserveTiles.append(placedTiles[tile][3]);
				
			PickRandomTileAndReplace(tile, preserveTiles);
	
	while needToColor.size() > 0:
		ColorTheTiles(needToColor.pick_random());
		pass
	
	if get_parent() == get_tree().root:
		return;
	
	"""for i in placedTiles.size():
		var array = placedTiles.values()[i];
		for j in array.size():
			if (array[j] == 0 || array[j] == 1): 
				var value = (placedTiles.keys()[i] * tileSize + Vector2(40,40)) + Vector2(40, 0).rotated(deg_to_rad(j*90)) 
				if emptySpaces.find(value) == -1:
					var obj = load("res://Objects/placeholder_place.tscn").instantiate();
					add_child(obj);
					obj.position = value
					#emptySpaces.append(value)"""

func PickRandomTile(edges):
	var validTiles = [];
	
	var right = edges[0];
	var down = edges[1];
	var left = edges[2];
	var up = edges[3];
	
	for tile in tiles:
		if ((right == -1 || right == tile[1][0]) && (down == -1 || down == tile[1][1]) && (left == -1 || left == tile[1][2]) && (up == -1 || up == tile[1][3])):
			validTiles.append([tile[0] + "/R.tscn", tile[1].duplicate(true)]);
		if ((right == -1 || right == tile[2][0]) && (down == -1 || down == tile[2][1]) && (left == -1 || left == tile[2][2]) && (up == -1 || up == tile[2][3])):
			validTiles.append([tile[0] + "/D.tscn", tile[2].duplicate(true)]);
		if ((right == -1 || right == tile[3][0]) && (down == -1 || down == tile[3][1]) && (left == -1 || left == tile[3][2]) && (up == -1 || up == tile[3][3])):
			validTiles.append([tile[0] + "/L.tscn", tile[3].duplicate(true)]);
		if ((right == -1 || right == tile[4][0]) && (down == -1 || down == tile[4][1]) && (left == -1 || left == tile[4][2]) && (up == -1 || up == tile[4][3])):
			validTiles.append([tile[0] + "/U.tscn", tile[4].duplicate(true)]);
	
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
	
	return sides;
	pass

func ColorTheTiles(tilePosition, color = -1):
	var tile = tilePositions[tilePosition];
	var tileSides = placedTiles[tilePosition];
	
	var existingItems = [];
	if tileCandles.has(tilePosition):
		existingItems.append(tileCandles[tilePosition]);
	
	for i in randi_range(0, 2):
		var newSprite = Sprite2D.new();
		newSprite.scale.x = 1 if randf() < 0.5 else -1;
		newSprite.texture = load(allDecorations.pick_random());
		tile.add_child(newSprite);
		var overlap = true;
		var tries = 0;
		while overlap && tries < 10:
			newSprite.position = Vector2(randi_range(28, 52), randi_range(28, 52));
			overlap = false;
			for thing in existingItems:
				if thing.distance_to(newSprite.position) < 16:
					overlap = true;
					
			tries += 1;
			
		if tries >= 10:
			newSprite.queue_free();
		else:
			existingItems.append(newSprite.position);
		
		

	if color == -1:
		var maxThing = max(colorCounts[0], max(colorCounts[1], colorCounts[2]));
		var colorIndex = rng.rand_weighted(PackedFloat32Array([-colorCounts[0] * 5 + maxThing * 5 + 1, -colorCounts[1] * 5 + maxThing * 5 + 1, -colorCounts[2] * 5 + maxThing * 5 + 1]));
		colorCounts[colorIndex] += 1;
		color = colorIndex;
		
	tile.modulate = colors[color];
	#print(tile.get_children())
	#tile.object_ref.color = color
	needToColor.remove_at(needToColor.find(tilePosition));
	worldColors[tilePosition] = color;
	
	if tileSides[0] == 0 && needToColor.find(tilePosition + Vector2(1, 0)) != -1:
		ColorTheTiles(tilePosition + Vector2(1, 0), color);
		
	if tileSides[1] == 0 && needToColor.find(tilePosition + Vector2(0, 1)) != -1:
		ColorTheTiles(tilePosition + Vector2(0, 1), color);
		
	if tileSides[2] == 0 && needToColor.find(tilePosition - Vector2(1, 0)) != -1:
		ColorTheTiles(tilePosition - Vector2(1, 0), color);
		
	if tileSides[3] == 0 && needToColor.find(tilePosition - Vector2(0, 1)) != -1:
		ColorTheTiles(tilePosition - Vector2(0, 1), color);

func FindConneceted(tilePosition, array = -1, line = null):
	var tileSides = placedTiles[tilePosition];

	if array == -1:
		accessibleAreas.append([]);
		#line = Line2D.new();
		#line.default_color = Color(randf(), randf(), randf());
		#add_child(line);
	array = accessibleAreas.size() - 1;
		
	accessibleAreas[array].append(tilePosition);
	#line.add_point(tilePosition * tileSize + tileSize / 2);
	
	needToTraverse.remove_at(needToTraverse.find(tilePosition));
	
	if tileSides[0] != 2 && needToTraverse.find(tilePosition + Vector2(1, 0)) != -1:
		FindConneceted(tilePosition + Vector2(1, 0), array, line);
		#line.add_point(tilePosition * tileSize + tileSize / 2);
		
	if tileSides[1] != 2 && needToTraverse.find(tilePosition + Vector2(0, 1)) != -1:
		FindConneceted(tilePosition + Vector2(0, 1), array, line);
		#line.add_point(tilePosition * tileSize + tileSize / 2);
		
	if tileSides[2] != 2 && needToTraverse.find(tilePosition - Vector2(1, 0)) != -1:
		FindConneceted(tilePosition - Vector2(1, 0), array, line);
		#line.add_point(tilePosition * tileSize + tileSize / 2);
		
	if tileSides[3] != 2 && needToTraverse.find(tilePosition - Vector2(0, 1)) != -1:
		FindConneceted(tilePosition - Vector2(0, 1), array, line);
		#line.add_point(tilePosition * tileSize + tileSize / 2);
		
	if (false && line.points.size() == 1):
		line.points[0].x -= 5;
		line.add_point(tilePosition * tileSize + tileSize / 2 + Vector2(5, 0));

func PickRandomTileAndReplace(position, preserve):
	var validTiles = [];
	
	var right = preserve[0];
	var down = preserve[1];
	var left = preserve[2];
	var up = preserve[3];
	
	if Vector2(0, 0).distance_to(position + Vector2(1, 0)) > worldSize:
		right = 2;
		
	if Vector2(0, 0).distance_to(position + Vector2(0, 1)) > worldSize:
		down = 2;
		
	if Vector2(0, 0).distance_to(position - Vector2(1, 0)) > worldSize:
		left = 2;
		
	if Vector2(0, 0).distance_to(position - Vector2(0, 1)) > worldSize:
		up = 2;
	
	preserve = [right, down, left, up];
	#print("");
	#print("preserve ", position, " with ", preserve);
	
	for tile in tiles:
		if ((right == -1 || (right == -2 && tile[1][0] != 2) || right == tile[1][0]) && (down == -1 || (down == -2 && tile[1][1] != 2) || down == tile[1][1]) && (left == -1 || (left == -2 && tile[1][2] != 2) || left == tile[1][2]) && (up == -1 || (up == -2 && tile[1][3] != 2) || up == tile[1][3])):
			validTiles.append([tile[0] + "/R.tscn", tile[1].duplicate(true)]);
		if ((right == -1 || (right == -2 && tile[2][0] != 2) || right == tile[2][0]) && (down == -1 || (down == -2 && tile[2][1] != 2) || down == tile[2][1]) && (left == -1 || (left == -2 && tile[2][2] != 2) || left == tile[2][2]) && (up == -1 || (up == -2 && tile[2][3] != 2) || up == tile[2][3])):
			validTiles.append([tile[0] + "/D.tscn", tile[2].duplicate(true)]);
		if ((right == -1 || (right == -2 && tile[3][0] != 2) || right == tile[3][0]) && (down == -1 || (down == -2 && tile[3][1] != 2) || down == tile[3][1]) && (left == -1 || (left == -2 && tile[3][2] != 2) || left == tile[3][2]) && (up == -1 || (up == -2 && tile[3][3] != 2) || up == tile[3][3])):
			validTiles.append([tile[0] + "/L.tscn", tile[3].duplicate(true)]);
		if ((right == -1 || (right == -2 && tile[4][0] != 2) || right == tile[4][0]) && (down == -1 || (down == -2 && tile[4][1] != 2) || down == tile[4][1]) && (left == -1 || (left == -2 && tile[4][2] != 2) || left == tile[4][2]) && (up == -1 || (up == -2 && tile[4][3] != 2) || up == tile[4][3])):
			validTiles.append([tile[0] + "/U.tscn", tile[4].duplicate(true)]);
	
	var newTileForSpot = validTiles.pick_random();
	#print("fix tile ", newTileForSpot);
	
	
	var newTile = load("res://Proc Gen/Tiles/" + newTileForSpot[0]).instantiate();
	newTile.position = position * tileSize;
	tileContainer.add_child(newTile);
	newTile.name = str(position) + ", " + newTileForSpot[0];
	var existingTile = tilePositions[position];
	
	placedTiles[position] = newTileForSpot[1];
	tilePositions[position] = newTile;
	existingTile.queue_free();
	
	var directions = [Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0), Vector2(0, -1)];
	for direction in directions:
		var dirIndex = directions.find(direction);
		if preserve[directions.find(direction)] != -2:
			continue;
		
		#print("fixing ", position + direction);
		
		var newSides = placedTiles[position + direction].duplicate();
		newSides[(dirIndex + 2) % 4] = newTileForSpot[1][dirIndex];
		var newSideTileData = GetSpecificTile(newSides);
		
		#print("sides ", placedTiles[position + direction], " new ", newSides, " with ", newSideTileData);
		
		var newSideTile = load("res://Proc Gen/Tiles/" + newSideTileData[0]).instantiate();
		newSideTile.position = (position + direction) * tileSize;
		tileContainer.add_child(newSideTile);
		newSideTile.name = str(position + direction) + ", " + newSideTileData[0];
		var existingSideTile = tilePositions[position + direction];
		
		placedTiles[position + direction] = newSideTileData[1];
		tilePositions[position + direction] = newSideTile;
		existingSideTile.queue_free();
	
	pass
	
func GetSpecificTile(sides):
	for tile in tiles:
		if AreArraysSame(sides, tile[1], tile[0]):
			return [tile[0] + "/R.tscn", tile[1].duplicate(true)];
		if AreArraysSame(sides, tile[2], tile[0]):
			return [tile[0] + "/D.tscn", tile[2].duplicate(true)];
		if AreArraysSame(sides, tile[3], tile[0]):
			return [tile[0] + "/L.tscn", tile[3].duplicate(true)];
		if AreArraysSame(sides, tile[4], tile[0]):
			return [tile[0] + "/U.tscn", tile[4].duplicate(true)];

func AreArraysSame(arr1, arr2, name):
	if arr1.size() != arr2.size():
		return false;
		
	for i in arr1.size():
		if arr1[i] != arr2[i]:
			return false;
			
	return true;
