extends Label

var letters = [];
var waveStrength = 0;
var textColor = Color(1, 1, 1);

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
	for i in range(letters.size()):
		letters[i][0].modulate = textColor;
		letters[i][0].position = letters[i][1] + Vector2(0, sin(Time.get_ticks_msec() / 150.0 - i) * 2 * waveStrength);
	pass
