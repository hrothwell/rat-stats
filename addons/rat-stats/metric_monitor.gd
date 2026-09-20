@abstract
class_name MetricMonitor extends Node

signal value_updated
@export var timer: Timer

var last_value: Variant:
	set(new):
		last_value = new
		value_updated.emit(last_value)

func _ready() -> void:
	if timer:
		timer.timeout.connect(update)
	else:
		printerr("No timer set on MetricMonitor: ", self)

## Implementations that do not return values must handle setting last_value themselves.
## await/connect value_updated for async value fetching such as Ping.
@abstract
func get_metric() -> Variant

func update() -> void:
	var update_value = get_metric()
	if update_value:
		last_value = update_value
