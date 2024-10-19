extends Control

@onready var arrowSelector = $"Arrow Selector";
@onready var mainMenuOptions = [$Host, $Join, $Quit];
@onready var mainMenuFunctions = [Callable.create(self, "Host"), null, Callable.create(self, "Quit")];
var highlighted = 0;
var spaceDelay = 0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mainMenuOptions[highlighted].waveStrength = 1;
	mainMenuOptions[highlighted].textColor = Color(1, 1, 0);
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
		
	if Input.is_action_just_pressed("interact_object") && spaceDelay < 0:
		mainMenuFunctions[highlighted].call();
	
	spaceDelay -= delta;
	pass

func Host():
	self.visible = false;
	self.process_mode = Node.PROCESS_MODE_DISABLED;
	$"../Host".visible = true;
	$"../Host".process_mode = Node.PROCESS_MODE_ALWAYS;
	$"../Host".WakeUp();
	$"../Host".spaceDelay = 0.1;

func Quit():
	get_tree().quit();

func WakeUp():
	mainMenuOptions[highlighted].waveStrength = 1;
	mainMenuOptions[highlighted].textColor = Color(1, 1, 0);
