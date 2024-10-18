extends Node

#var looping = false
var aniData = {}
var aniState
signal animationQueue(animation)
var frameDiration = -1
@onready var sprite = $"."
#@onready var tail = $"../Tails Tail"

# Called when the node enters the scene tree for the first time.
func _ready():
	_on_player_update_character()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	#if owner.facingLeft:
		#sprite.flip_h = true
		#sprite.offset.x = 0
	#elif !owner.facingLeft:
		#sprite.flip_h = false
		#sprite.offset.x = -2
	
	if aniData.has(sprite.animation):
		if aniData[sprite.animation].has("diration"):
			sprite.sprite_frames.set_animation_speed(sprite.animation, 1)
			sprite.frame_progress += (60.0 / (60.0 * (frameDiration + 1)))
			


func _on_animation_queue(animation):
	if sprite.animation != animation:
		sprite.animation = animation
		if aniData.has(sprite.animation):
			if aniData[sprite.animation].has("diration"):
				frameDiration = aniData[sprite.animation].diration
				sprite.set_frame_progress(0)


func _on_frame_changed():
	if aniData.has(sprite.animation):
		if aniData[sprite.animation].has("diration"):
			#pass
			frameDiration = aniData[sprite.animation].diration
			sprite.set_frame_progress(0)

func _on_animation_looped():
	if aniData.has(sprite.animation):
		if aniData[sprite.animation].has("next"):
			animationQueue.emit(aniData[sprite.animation].next)
		if aniData[sprite.animation].has("next_state"):
			aniState = aniData[sprite.animation].next_state
		if aniData[sprite.animation].has("loopPoint"):
			sprite.set_frame_and_progress(aniData[sprite.animation].loopPoint,0)


func _on_player_update_character() -> void:
	var children : Array = get_children();
	for i in children.size():
		children[i].process_mode = Node.PROCESS_MODE_DISABLED
	
	children = $"../SpriteManager".get_children();
	for i in children.size():
		children[i].visible = false
		if children[i].animation_looped.is_connected(_on_animation_looped):
			children[i].animation_looped.disconnect(_on_animation_looped)
			children[i].frame_changed.disconnect(_on_frame_changed)
	
	
	get_node(NodePath("ANI_" + String(GlobalPref.charname[owner._char]))).process_mode = Node.PROCESS_MODE_INHERIT
	sprite = get_node(NodePath("../SpriteManager/CHAR_" + String(GlobalPref.charname[owner._char])))
	
	sprite.play()
	sprite.visible = true
	
	sprite.animation_looped.connect(_on_animation_looped)
	sprite.frame_changed.connect(_on_frame_changed)
