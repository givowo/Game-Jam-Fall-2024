extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scale = Vector2(160 / size.x, 144 / size.y)
			
	if $Main.visible:
		$Host.visible = false;
		$Host.process_mode = Node.PROCESS_MODE_DISABLED;
		$Join.visible = false;
		$Join.process_mode = Node.PROCESS_MODE_DISABLED;
		$Lobby.visible = false;
		$Lobby.process_mode = Node.PROCESS_MODE_DISABLED;
	elif $Host.visible:
		$Main.visible = false;
		$Main.process_mode = Node.PROCESS_MODE_DISABLED;
		$Join.visible = false;
		$Join.process_mode = Node.PROCESS_MODE_DISABLED;
		$Lobby.visible = false;
		$Lobby.process_mode = Node.PROCESS_MODE_DISABLED;
	elif $Join.visible:
		$Main.visible = false;
		$Main.process_mode = Node.PROCESS_MODE_DISABLED;
		$Host.visible = false;
		$Host.process_mode = Node.PROCESS_MODE_DISABLED;
		$Lobby.visible = false;
		$Lobby.process_mode = Node.PROCESS_MODE_DISABLED;
	
