class_name MetricMonitorExample extends Control

@onready var fps_value: Label = %FPSValue
@onready var frames_per_second: FramesPerSecond = %FramesPerSecond
@onready var memory_value: Label = %MemoryValue
@onready var memory_usage: MemoryUsage = %MemoryUsage
@onready var server_button: Button = %ServerButton
@onready var client_button: Button = %ClientButton
@onready var ping: Ping = %Ping
@onready var ping_value: Label = %PingValue

func _ready() -> void:
	frames_per_second.value_updated.connect(func(v: Variant): fps_value.text = str(v))
	memory_usage.value_updated.connect(func(v: Variant): memory_value.text = str(v))
	ping.value_updated.connect(func(v: Variant): ping_value.text = str(v))
	ping.peer_ping_report_updated.connect(func(v: Variant): ping_value.text = str(v))
	server_button.pressed.connect(start_server)
	client_button.pressed.connect(join_server)

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
