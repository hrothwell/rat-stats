class_name PingExample extends Control

@onready var label: Label = %Label
@onready var ping: Ping = %Ping
@onready var server: Button = %Server
@onready var client: Button = %Client

func _ready() -> void:
	ping.ping_updated.connect(on_ping_updated)
	server.pressed.connect(start_server)
	client.pressed.connect(join_server)

func on_ping_updated(new_value: int) -> void:
	label.text = str("ping: ", new_value, "ms")

func start_server() -> void:
	var enet_peer := ENetMultiplayerPeer.new()
	enet_peer.create_server(8080, 1)
	multiplayer.multiplayer_peer = enet_peer
	print("started server")

func join_server() -> void:
	var enet_peer := ENetMultiplayerPeer.new()
	enet_peer.create_client("127.0.0.1", 8080)
	multiplayer.multiplayer_peer = enet_peer
	print("joined server")
