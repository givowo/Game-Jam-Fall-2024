extends Control

@onready var arrowSelector = $"Arrow Selector";
@onready var mainMenuOptions = [$Name, $Create, $Back];
@onready var nameActualView = $"Name Actual";
@onready var hiddenNameInput = $LineEdit;
@onready var mainMenuFunctions = [Callable.create(self, "TypeName"), Callable.create(self, "Create"), Callable.create(self, "Back")];
var highlighted = 0;
var typingName = false;
var playerName = "";
var spaceDelay = 0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mainMenuOptions[highlighted].waveStrength = 2;
	mainMenuOptions[highlighted].textColor = Color(1, 1, 0);
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if typingName:
		playerName = hiddenNameInput.text;
		var nameview = hiddenNameInput.text;
		
		if hiddenNameInput.text.length() == 10:
			hiddenNameInput.text = hiddenNameInput.text.substr(0, 9);
			hiddenNameInput.caret_column = 9;
		
		if playerName.length() > 0 && playerName[playerName.length() - 1] == " ":
			playerName = playerName.substr(0, playerName.length() - 1);
			typingName = false;
			mainMenuOptions[highlighted].waveStrength = 1;
			mainMenuOptions[highlighted].textColor = Color(1, 1, 0);
			nameActualView.text = playerName;
			
			hiddenNameInput.text = playerName;
			if hiddenNameInput.text == "":
				nameActualView.text = "_________";
			
			var fakeClick = InputEventKey.new();
			fakeClick.keycode = KEY_ESCAPE;
			fakeClick.pressed = true;
			Input.parse_input_event(fakeClick);
			await get_tree().process_frame;
			fakeClick.pressed = false;
			Input.parse_input_event(fakeClick);
			return;
			
		
		if nameview.length() < 9:
			nameview += "_" if fmod(Time.get_ticks_msec() / 200.0, 2) < 1 else " ";
			
		for i in range(9 - nameview.length()):
			nameview += "_";
	
		nameActualView.text = nameview;
		return;
	
	arrowSelector.global_position.y = mainMenuOptions[highlighted].global_position.y;
	arrowSelector.global_position.x = mainMenuOptions[highlighted].global_position.x - 12 + cos(Time.get_ticks_msec() / 150.0) * 3;
	
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
		
	if playerName == "":
		$"Create Cover".waveStrength = mainMenuOptions[1].waveStrength;
		$"Create Cover".visible = true;
	else:
		$"Create Cover".visible = false;
		
	if Input.is_action_just_pressed("interact_object") && spaceDelay <= 0:
		mainMenuFunctions[highlighted].call();
		
	spaceDelay -= delta;
	pass

func TypeName():
	typingName = true;
	
	mainMenuOptions[highlighted].waveStrength = 0.5;
	mainMenuOptions[highlighted].textColor = Color(1, 1, 0.5);
	
	var fakeClick = InputEventMouseButton.new();
	fakeClick.position = Vector2(0, 0);
	fakeClick.button_index = MOUSE_BUTTON_LEFT;
	fakeClick.pressed = true;
	Input.parse_input_event(fakeClick);
	await get_tree().process_frame;
	fakeClick.pressed = false;
	Input.parse_input_event(fakeClick);
	
	hiddenNameInput.caret_column = playerName.length();
	
func Create():
	if playerName != "":
		MultiplayerManager.player_info.name = playerName;
		MultiplayerManager.create_game();
		
		self.visible = false;
		self.process_mode = Node.PROCESS_MODE_DISABLED;
		$"../Lobby".visible = true;
		$"../Lobby".process_mode = Node.PROCESS_MODE_ALWAYS;
		$"../Lobby".WakeUp();
		$"../Lobby".spaceDelay = 0.1;
		pass

func Back():
	self.visible = false;
	self.process_mode = Node.PROCESS_MODE_DISABLED;
	$"../Main".visible = true;
	$"../Main".process_mode = Node.PROCESS_MODE_ALWAYS;
	$"../Main".WakeUp();
	$"../Main".spaceDelay = 0.1;

func WakeUp():
	mainMenuOptions[highlighted].waveStrength = 1;
	mainMenuOptions[highlighted].textColor = Color(1, 1, 0);
