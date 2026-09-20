## Measure ping in milliseconds to multiplayer peer host
class_name Ping extends MetricMonitor

## emits with peer_to_last_reported_ping 
signal peer_ping_report_updated

## Record all client ping on server under peer_to_last_reported_ping. 
@export var record_ping_to_server: bool = false

## peer_id to last ping value in milliseconds. Only populated on server
var peer_to_last_reported_ping: Dictionary[int, int] = {}

var _connected: bool = false

func _setup() -> void:
	multiplayer.connected_to_server.connect(func(): _connected = true)
	multiplayer.server_disconnected.connect(func(): _connected = false)
	multiplayer.peer_disconnected.connect(_remove_client_ping)

func get_metric_name() -> String:
	return "Ping (ms)"

func _get_metric() -> Variant:
	var time: int = Time.get_ticks_msec()
	if _connected:
		_ping_server.rpc_id(1, time)
	return null

@rpc("any_peer", "call_remote", "unreliable")
func _ping_server(request_time: int) -> void:
	_pong.rpc_id(multiplayer.get_remote_sender_id(), request_time)

@rpc("any_peer", "call_remote", "unreliable")
func _pong(request_time: int) -> void:
	var current_time: int = Time.get_ticks_msec()
	_last_value = current_time - request_time
	if record_ping_to_server:
		_record_ping.rpc_id(1, _last_value)

## Record client ping back to server
@rpc("any_peer", "call_remote", "unreliable")
func _record_ping(ping_ms: int) -> void:
	peer_to_last_reported_ping[multiplayer.get_remote_sender_id()] = ping_ms
	peer_ping_report_updated.emit(peer_to_last_reported_ping)

func _remove_client_ping(peer_id: int) -> void:
	peer_to_last_reported_ping.erase(peer_id)
	peer_ping_report_updated.emit(peer_to_last_reported_ping)
