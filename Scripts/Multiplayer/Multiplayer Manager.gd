extends Node

static var Instance;

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

const PORT = 7000
const DEFAULT_SERVER_IP = "127.0.0.1"
const MAX_CONNECTIONS = 3

var players = {}
var players_loaded = 0
var worldGenSeed = 0;
var worldCandles = [];
var worldGenLevel = 0

var player_info = {"name": "Name", "character": -1, "host": false, "position": Vector2(0,0), "animation": "Down", "input": Vector2(0,0), "died": false};

func _ready():
	Instance = self;
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	for i in range(OS.get_cmdline_args().size()):
		if OS.get_cmdline_args()[i] == "host":
			player_info.name = OS.get_cmdline_args()[i+1];
			create_game();
			
		if OS.get_cmdline_args()[i] == "join":
			player_info.name = OS.get_cmdline_args()[i+1];
			join_game();
	
	for command in OS.get_cmdline_args():
		if get_tree().current_scene.name == "Menu":
			if command == "host" || command == "join":
				$/root/Menu/Main.visible = false;
				$/root/Menu/Main.process_mode = Node.PROCESS_MODE_DISABLED;
				$/root/Menu/Host.visible = false;
				$/root/Menu/Host.process_mode = Node.PROCESS_MODE_DISABLED;
				$/root/Menu/Join.visible = false;
				$/root/Menu/Join.process_mode = Node.PROCESS_MODE_DISABLED;
				$/root/Menu/Lobby.visible = true;
				$/root/Menu/Lobby.process_mode = Node.PROCESS_MODE_ALWAYS;
				return;

func join_game(address = ""):
	print(address);
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	player_info.host = false;

func create_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

	players[1] = player_info
	player_connected.emit(1, player_info)
	player_info.host = true;
	print(player_info.name, ": hosting");

func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null

@rpc("call_local", "reliable")
func load_game(game_scene_path):
	get_tree().change_scene_to_file(game_scene_path)
	
func _on_player_connected(id):
	_register_player.rpc_id(id, player_info)

@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	print(player_info.name, ": ", new_player_info.name, " joined");
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)
	
	var lobbyPlayers = [$"../Menu/Lobby/Player 0", $"../Menu/Lobby/Player 1", $"../Menu/Lobby/Player 2"];
	for i in range(players.values().size()):
		lobbyPlayers[i].SetInfo(players.values()[i]);
	for i in range(players.values().size(), 3):
		lobbyPlayers[i].SetInfo([], false);

func _on_player_disconnected(id):
	#multiplayer.multiplayer_peer = null
	players.erase(id)
	player_disconnected.emit(id)

func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)

func _on_connected_fail():
	multiplayer.multiplayer_peer = null

func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()

@rpc("any_peer",  "call_local", "reliable")
func PlayGame(gameSeed):
	print("starting game!");
	worldGenSeed = gameSeed;
	if players[multiplayer.get_remote_sender_id()].character == -1:
		players[multiplayer.get_remote_sender_id()].character = randi_range(0,2)
	get_tree().change_scene_to_file("res://Scenes/stage.tscn");
	return;

@rpc("any_peer",  "call_local", "reliable")
func NewLevel():
	print("new level!");
	worldGenLevel += 2
	get_tree().change_scene_to_file("res://Scenes/stage.tscn");
	return;

@rpc("any_peer",  "call_local", "reliable")
func SetCharacter(character_id):
	var lobbyPlayers = [$"../Menu/Lobby/Player 0", $"../Menu/Lobby/Player 1", $"../Menu/Lobby/Player 2"];
	players[multiplayer.get_remote_sender_id()].character = character_id;
	lobbyPlayers[players.keys().find(multiplayer.get_remote_sender_id())].SetInfo(players[multiplayer.get_remote_sender_id()]);
	return;
	
@rpc("any_peer", "call_remote", "unreliable")
func updateCharacter(char, pos, ani, inp, died):
	players[multiplayer.get_remote_sender_id()].character = char
	players[multiplayer.get_remote_sender_id()].position = pos
	players[multiplayer.get_remote_sender_id()].animation = ani
	players[multiplayer.get_remote_sender_id()].input = char
	players[multiplayer.get_remote_sender_id()].died = died

@rpc("any_peer", "call_local", "reliable")
func LightCandle(index):
	worldCandles[index].Light(players[multiplayer.get_remote_sender_id()].character);
	pass
