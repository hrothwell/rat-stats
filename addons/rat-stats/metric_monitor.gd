## Monitor a specific metric value on a set timer. Connect to value_updated to reliably 
## know when value has been updated. Do not rely 
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
		timer.timeout.connect(_update)
	else:
		printerr("No timer set on MetricMonitor: ", self)

## Implementations that do return null must handle setting last_value themselves.
## await/connect value_updated for async value fetching such as Ping.
@abstract
func _get_metric() -> Variant

func _update() -> void:
	var update_value = _get_metric()
	if update_value:
		last_value = update_value
