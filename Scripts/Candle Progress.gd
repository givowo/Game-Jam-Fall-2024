extends Node2D

var d10 = false;
var d25 = false;
var d50 = false;
var d75 = false;
var d90 = false;
var d100 = false;
@onready var arrow = $Sprite2D;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var litCandles = 0.0;
	var unlitCandle = [Vector2(-9999999, -9999999), 9999999999];
	
	for candle in MultiplayerManager.worldCandles:
		if candle.interacted:
			litCandles += 1.0;
		else:
			if candle.global_position.distance_to($"../../Player".global_position) < unlitCandle[1]:
				unlitCandle = [candle.global_position - $"../../Player".global_position, candle.global_position.distance_to($"../../Player".global_position)];
	
	#print(litCandles, ", ", MultiplayerManager.worldCandles.size(), ", ", litCandles / MultiplayerManager.worldCandles.size());
	
	litCandles /= MultiplayerManager.worldCandles.size();
	
	if !d10 && litCandles >= 0.1:
		d10 = true;
		var progText = Label.new();
		add_child(progText);
		progText.modulate.a = 0;
		progText.size = Vector2(64, 16);
		progText.position = Vector2(48, 28);
		progText.vertical_alignment = VERTICAL_ALIGNMENT_CENTER;
		progText.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
		progText.text = "10% lit!";
		progText.label_settings = load("res://progress settings.tres");
		progText.set_script(load("res://Scripts/FaderText.gd"));
		d10 = progText;
	elif d10:
		d10._process(delta);
		
	if !d25 && litCandles >= 0.25:
		d25 = true;
		var progText = Label.new();
		add_child(progText);
		progText.modulate.a = 0;
		progText.size = Vector2(64, 16);
		progText.position = Vector2(48, 28);
		progText.vertical_alignment = VERTICAL_ALIGNMENT_CENTER;
		progText.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
		progText.text = "25% lit!";
		progText.label_settings = load("res://progress settings.tres");
		progText.set_script(load("res://Scripts/FaderText.gd"));
		d25 = progText;
	elif d25:
		d25._process(delta);
		
	if !d50 && litCandles >= 0.5:
		d50 = true;
		var progText = Label.new();
		add_child(progText);
		progText.modulate.a = 0;
		progText.size = Vector2(64, 16);
		progText.position = Vector2(48, 28);
		progText.vertical_alignment = VERTICAL_ALIGNMENT_CENTER;
		progText.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
		progText.text = "50% lit!";
		progText.label_settings = load("res://progress settings.tres");
		progText.set_script(load("res://Scripts/FaderText.gd"));
		d50 = progText;
	elif d50:
		d50._process(delta);
		
	if !d75 && litCandles >= 0.75:
		d75 = true;
		var progText = Label.new();
		add_child(progText);
		progText.modulate.a = 0;
		progText.size = Vector2(64, 16);
		progText.position = Vector2(48, 28);
		progText.vertical_alignment = VERTICAL_ALIGNMENT_CENTER;
		progText.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
		progText.text = "75% lit!";
		progText.label_settings = load("res://progress settings.tres");
		progText.set_script(load("res://Scripts/FaderText.gd"));
		d75 = progText;
	elif d75:
		d75._process(delta);
		
	if !d90 && litCandles >= 0.9:
		d90 = true;
		var progText = Label.new();
		add_child(progText);
		progText.modulate.a = 0;
		progText.size = Vector2(64, 16);
		progText.position = Vector2(48, 28);
		progText.vertical_alignment = VERTICAL_ALIGNMENT_CENTER;
		progText.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
		progText.text = "90% lit!";
		progText.label_settings = load("res://progress settings.tres");
		progText.set_script(load("res://Scripts/FaderText.gd"));
		d90 = progText;
	elif d90:
		d90._process(delta);
		
	if !d100 && litCandles >= 1:
		d100 = true;
		var progText = Label.new();
		add_child(progText);
		progText.modulate.a = 0;
		progText.size = Vector2(64, 16);
		progText.position = Vector2(48, 28);
		progText.vertical_alignment = VERTICAL_ALIGNMENT_CENTER;
		progText.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
		progText.text = "all lit!";
		progText.label_settings = load("res://progress settings.tres");
		progText.set_script(load("res://Scripts/FaderText.gd"));
		d100 = progText;
	elif d100:
		d100._process(delta);
	
	arrow.visible = false;
	if litCandles > 0.9 && unlitCandle[0] != Vector2(-9999999, -9999999) && unlitCandle[1] > 65:
		var angle = unlitCandle[0].angle();
		arrow.visible = true;
		arrow.rotation = angle;
	
	pass
