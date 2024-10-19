extends Node
## Handles all global values/settings, and scene handling


## Size of the games window at native 1x resolution.
var VisibleViewport : Vector2 = Vector2(160,144)
## Multiplier to the window size.
var ScreenScale : int = 6

#if you somehow get this beyond or below the limit: your ears are not safe
## For all sound effects. Scales from 0 - 1. 0 is highest volume, 
## 1 is muted or no volume. any number outside this range SHOULD be clamped.
var SoundVol : float = 0.2
## For music. Scales from 0 - 1. 0 is highest volume, 
## 1 is muted or no volume. any number outside this range SHOULD be clamped.
var MusicVol : float = 0.2

## Refrence to the camera node
var Camera = null
## Refrence to the object node and its children
var Objects = null

var current_scene = null
var current_scene_path = null

## Nodes saved for later cashed loading
var savecashe := []
## Nodes saved for later cashed loading, but packed
var savecashe_pack := []
## Saved index of the saved nodes
var s_index := []

## What character the main player is
var main_char = CHAR.WAR

var charname : Array = ["WAR", "FAMINE", "PLAGUE"]


## Assigned slots for each character
enum CHAR {
	WAR = 0,
	FAMINE = 1,
	PLAGUE = 2,
}

#var Audio : Node = preload("res://GD-Sonic/Core-Objects/Cores/global_audio.tscn").instantiate()

# Called when the node enters the scene tree for the first time.
func _ready():
	#add_child(Audio)
	#Audio = $"GlobalAudio"
	
	on_load()
	
	DisplayServer.window_set_size(VisibleViewport * ScreenScale)
	DisplayServer.window_set_position(DisplayServer.screen_get_size() / 2 - DisplayServer.window_get_size() / 2);
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	
func _process(delta):
	#lets not blow out peoples ears
	MusicVol = clamp(MusicVol, 0, 1)
	SoundVol = clamp(SoundVol, 0, 1)

## Called when the node is ready, and changing the level.
## Clears saved cache, then saves the new nodepaths. Calls [method reload]
func on_load():
	savecashe.clear()
	s_index.clear()
	savecashe_pack.clear()
	#if has_node("/root/Stage"):
		#savecashe.push_back("/root/Stage/Player")
		#savecashe.push_back("/root/Stage/Camera2D")
		#savecashe.push_back("/root/Stage/Objects")
		#savecashe.push_back("/root/Stage/ObjectCulling")
		#savecashe.push_back("/root/Stage/MasterHUD")
		#for i in savecashe.size() :
			#s_index.push_back(get_node(savecashe[i]).get_index())
			#savecashe_pack.push_back(PackedScene.new())
		#reload(get_tree().current_scene.scene_file_path)

## When given a scene, it will add the new stage nodes refrences.
## Then calls [method store_original_nodes] and [method preload_scene]
func reload(path):
	print(path )
	current_scene_path = path
	#Camera = $"/root/Stage/Camera2D"
	#Objects = $"/root/Stage/Objects/Spawner"
	
	store_original_nodes()
	
	preload_scene(current_scene_path)

## Calls a thread for loading the cache when needed.
func preload_scene(path):
	ResourceLoader.load_threaded_request(path)
	#pass
	#if !cashe_.has(path):
		#cashe_[path] = (load(path))

## Stores all the nodes in the current scene
func store_original_nodes():
	for i in savecashe.size():
		for c in get_node(savecashe[i]).get_children():
			if c.owner != null:
				c.set_owner(get_node(savecashe[i]))
		savecashe_pack[i].pack(get_node(savecashe[i]))

	
## Calls the deferred version of reset_scene
func reset_scene():
	call_deferred("_deferred_reset_scene")
	
## Pauses the tree, then replaces all nodes  
## with the cached counterparts before unpausing it.
func _deferred_reset_scene():
	get_tree().paused = true
	
	for i in savecashe.size():
		get_node(savecashe[i]).free()
		#$"/root/Stage".add_child(savecashe_pack[i].instantiate())
		#$"/root/Stage".move_child(get_node(savecashe[i]), s_index[i])
	
	#Camera = $"/root/Stage/Camera2D"
	#Objects = $"/root/Stage/Objects/Spawner"
	get_tree().paused = false
