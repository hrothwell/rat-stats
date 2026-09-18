## Measure ping in milliseconds to multiplayer peer host
class_name Ping extends Node

## emits with ping in ms
signal ping_updated

## emits with peer_to_last_reported_ping 
signal peer_ping_report_updated

@export var update_interval_seconds: float = 60.0

## On server connect pings will begin
@export var auto_start: bool = true

## Record all client ping on server under peer_to_last_reported_ping
@export var record_ping_to_server: bool = false

@onready var timer: Timer = $Timer
var last_ping_ms: int = 0

var peer_to_last_reported_ping: Dictionary[int, int] = {}

func _ready() -> void:
	timer.wait_time = update_interval_seconds
	timer.one_shot = false
	timer.timeout.connect(initiate_ping)
	multiplayer.server_disconnected.connect(stop_pinging)
	if auto_start:
		multiplayer.connected_to_server.connect(start_pinging)
	
	multiplayer.peer_disconnected.connect(remove_client_ping)

## Start pinging the server
func start_pinging() -> void: 
	timer.start()

## Stop pinging the server 
func stop_pinging() -> void:
	timer.stop()

func initiate_ping() -> void:
	var time: int = Time.get_ticks_msec()
	if multiplayer.multiplayer_peer && multiplayer.multiplayer_peer is not OfflineMultiplayerPeer && multiplayer.get_unique_id() != 1:
		ping_server.rpc_id(1, time)

@rpc("any_peer", "call_remote", "unreliable")
func ping_server(request_time: int) -> void:
	pong.rpc_id(multiplayer.get_remote_sender_id(), request_time)

@rpc("any_peer", "call_remote", "unreliable")
func pong(request_time: int) -> void:
	var current_time: int = Time.get_ticks_msec()
	last_ping_ms = current_time - request_time
	ping_updated.emit(last_ping_ms)
	if record_ping_to_server:
		record_ping.rpc_id(1, last_ping_ms)

## Record client ping back to server
@rpc("any_peer", "call_remote", "unreliable")
func record_ping(ping_ms: int) -> void:
	peer_to_last_reported_ping[multiplayer.get_remote_sender_id()] = ping_ms
	peer_ping_report_updated.emit(peer_ping_report_updated)

func remove_client_ping(peer_id: int) -> void:
	peer_to_last_reported_ping.erase(peer_id)
	peer_ping_report_updated.emit(peer_ping_report_updated)
