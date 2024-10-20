extends Label

var letters = [];
var waveStrength = 0;
var textColor = Color(1, 1, 1);
var timer = 0;

# Called when the node enters the scene tree for the first time.
func _init() -> void:
	for i in range(text.length()):
		var charLabel = Label.new();
		add_child(charLabel);
		letters.append([charLabel, Vector2(i * 8, 0)]);
		charLabel.text = text[i];
		charLabel.label_settings = label_settings;
		charLabel.position = Vector2(i * 8, 0);
	
	text = "";
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if timer < 1:
		var tempTimer = timer;
		modulate.a = tempTimer;
		waveStrength = (1 - tempTimer) + 0.25;
	elif timer < 3:
		var tempTimer = timer - 3;
		modulate.a = (1.0 - tempTimer);
		waveStrength = 0.25;
	elif timer < 4:
		var tempTimer = timer - 3;
		modulate.a = max(1.0 - tempTimer, 0);
		waveStrength = tempTimer * 3 + 0.25;
	else:
		visible = false;
	
	for i in range(letters.size()):
		letters[i][0].modulate = textColor;
		letters[i][0].position = letters[i][1] + Vector2(0, sin(Time.get_ticks_msec() / 150.0 - i) * 2 * waveStrength);
	
	timer += delta;
	pass
