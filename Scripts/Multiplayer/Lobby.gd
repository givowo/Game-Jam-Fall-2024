extends Control

@onready var arrowSelector = $"Arrow Selector";
@onready var leftArrowChar = $"Player 0/Left";
@onready var rightArrowChar = $"Player 0/Right";
@onready var mainMenuOptions = [$"Player 0/Sprite?", $Start, $Leave];
@onready var mainMenuFunctions = [Callable.create(self, "Change"), Callable.create(self, "Start"), Callable.create(self, "Leave")];
var highlighted = 0;
var spaceDelay = 0;
var changingCharacter = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	WakeUp();
	leftArrowChar.visible = false;
	rightArrowChar.visible = false;
	
	if !multiplayer.is_server():
		mainMenuOptions[1].visible = false;
		mainMenuOptions.remove_at(1);
		mainMenuFunctions.remove_at(1);
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if changingCharacter:
		leftArrowChar.position.x = -64 + cos(Time.get_ticks_msec() / 150) * 2;
		rightArrowChar.position.x = -40 - cos(Time.get_ticks_msec() / 150) * 2;
		
		if MultiplayerManager.player_info.character == -1:
			leftArrowChar.visible = false;
			rightArrowChar.visible = true;
		elif MultiplayerManager.player_info.character == 2:
			rightArrowChar.visible = false;
			leftArrowChar.visible = true;
		else:
			rightArrowChar.visible = true;
			leftArrowChar.visible = true;
			
		if Input.is_action_just_pressed("move_right"):
			MultiplayerManager.player_info.character = min(MultiplayerManager.player_info.character + 1, 2);
		
		if Input.is_action_just_pressed("move_left"):
			MultiplayerManager.player_info.character = max(MultiplayerManager.player_info.character - 1, -1);
			
		MultiplayerManager.rpc("SetCharacter", MultiplayerManager.player_info.character);
		
		if Input.is_action_just_pressed("interact_object"):
			changingCharacter = false;
			arrowSelector.visible = true;
			leftArrowChar.visible = false;
			rightArrowChar.visible = false;
			
			if MultiplayerManager.player_info.character == -1:
				mainMenuOptions[highlighted].waveStrength = 1;
				mainMenuOptions[highlighted].textColor = Color(1, 1, 0);
		return;
	
	arrowSelector.global_position.y = mainMenuOptions[highlighted].global_position.y;
	arrowSelector.global_position.x = mainMenuOptions[highlighted].global_position.x - 12 + cos(Time.get_ticks_msec() / 150) * 3;
	
	if Input.is_action_just_pressed("move_down"):
		mainMenuOptions[highlighted].waveStrength = 0;
		mainMenuOptions[highlighted].textColor = Color(1, 1, 1);
		highlighted = min(highlighted + 1, mainMenuOptions.size() - 1);
		mainMenuOptions[highlighted].waveStrength = 1;
		mainMenuOptions[highlighted].textColor = Color(1, 1, 0);
		
	if Input.is_action_just_pressed("move_up"):
		mainMenuOptions[highlighted].waveStrength = 0;
		mainMenuOptions[highlighted].textColor = Color(1, 1, 1);
		highlighted = max(highlighted - 1, 0);
		mainMenuOptions[highlighted].waveStrength = 1;
		mainMenuOptions[highlighted].textColor = Color(1, 1, 0);

		
	if Input.is_action_just_pressed("interact_object") && spaceDelay <= 0:
		mainMenuFunctions[highlighted].call();
		
	spaceDelay -= delta;
	pass

func Change():
	changingCharacter = true;
	arrowSelector.visible = false;
	leftArrowChar.visible = true;
	rightArrowChar.visible = true;
	
	mainMenuOptions[highlighted].waveStrength = 0;
	mainMenuOptions[highlighted].textColor = Color(1, 1, 1);
	pass

func Start():
	MultiplayerManager.rpc("PlayGame", Time.get_unix_time_from_system());
	pass

func Leave():
	#MultiplayerManager.remove_multiplayer_peer();
	pass
	
func WakeUp():
	mainMenuOptions[highlighted].waveStrength = 1;
	mainMenuOptions[highlighted].textColor = Color(1, 1, 0);
	
	var lobbyPlayers = [$"Player 0", $"Player 1", $"Player 2"];
	for i in range(MultiplayerManager.players.values().size()):
		lobbyPlayers[i].SetInfo(MultiplayerManager.players.values()[i]);
	for i in range(MultiplayerManager.players.values().size(), 3):
		lobbyPlayers[i].SetInfo([], false);
