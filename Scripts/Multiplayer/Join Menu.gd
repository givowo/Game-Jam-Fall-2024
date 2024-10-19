extends Control

@onready var arrowSelector = $"Arrow Selector";
@onready var mainMenuOptions = [$Name, $Server, $Join, $Back];
@onready var serverActualView = $"Server Actual";
@onready var nameActualView = $"Name Actual";
@onready var hiddenServerInput = $LineEdit;
@onready var hiddenNameInput = $LineEdit2;
@onready var mainMenuFunctions = [Callable.create(self, "TypeName"), Callable.create(self, "TypeServer"), Callable.create(self, "Join"), Callable.create(self, "Back")];
var highlighted = 0;
var typingServer = false;
var typingName = false;
var server = "";
var playerName = "";
var spaceDelay = 0;
var serverRegex;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mainMenuOptions[highlighted].waveStrength = 2;
	mainMenuOptions[highlighted].textColor = Color(1, 1, 0);
	
	serverRegex = RegEx.new();
	serverRegex.compile("^((25[0-5]|(2[0-4]|1\\d|[1-9]|)\\d)\\.?\\b){4}$");
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
			nameview += "_" if fmod(Time.get_ticks_msec() / 200, 2) < 1 else " ";
			
		for i in range(9 - nameview.length()):
			nameview += "_";
	
		nameActualView.text = nameview;
		return;
		
	if typingServer:
		server = hiddenServerInput.text;
		var serverView = hiddenServerInput.text;
		
		if server.length() > 0 && server[server.length() - 1] == " ":
			server = server.substr(0, server.length() - 1);
			typingServer = false;
			mainMenuOptions[highlighted].waveStrength = 1;
			mainMenuOptions[highlighted].textColor = Color(1, 1, 0);
			serverActualView.text = server;
			
			hiddenServerInput.text = hiddenServerInput.text.substr(0, hiddenServerInput.text.length() - 1);
			if hiddenServerInput.text == "":
				serverActualView.text = "_._._._";
			
			var fakeClick = InputEventKey.new();
			fakeClick.keycode = KEY_ESCAPE;
			fakeClick.pressed = true;
			Input.parse_input_event(fakeClick);
			await get_tree().process_frame;
			fakeClick.pressed = false;
			Input.parse_input_event(fakeClick);
			return;
		
		serverView += "_" if fmod(Time.get_ticks_msec() / 200, 2) < 1 else " ";
	
		serverActualView.text = serverView;
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
		
	if playerName == "" || !((server != "" && server == "localhost") || (server != "" && serverRegex.search(server) != null)):
		$"Join Cover".waveStrength = mainMenuOptions[2].waveStrength;
		$"Join Cover".visible = true;
	else:
		$"Join Cover".visible = false;
		
	if Input.is_action_just_pressed("interact_object") && spaceDelay <= 0:
		mainMenuFunctions[highlighted].call();
		
	spaceDelay -= delta;
	pass

func TypeServer():
	typingServer = true;
	
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
	
	hiddenServerInput.caret_column = server.length();
	
func TypeName():
	typingName = true;
	
	mainMenuOptions[highlighted].waveStrength = 0.5;
	mainMenuOptions[highlighted].textColor = Color(1, 1, 0.5);
	
	var fakeClick = InputEventMouseButton.new();
	fakeClick.position = DisplayServer.window_get_size();
	fakeClick.button_index = MOUSE_BUTTON_LEFT;
	fakeClick.pressed = true;
	Input.parse_input_event(fakeClick);
	await get_tree().process_frame;
	fakeClick.pressed = false;
	Input.parse_input_event(fakeClick);
	
	hiddenNameInput.caret_column = playerName.length();
	
func Join():
	if playerName != "" && ((server != "" && server == "localhost") || (server != "" && serverRegex.search(server) != null)):
		MultiplayerManager.player_info.name = playerName;
		MultiplayerManager.join_game(server);
		
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
