## Monitor and calculate a metric value on a set timer. Timer activity determines how 
## often metric is calculated/reported. A stopped timer will not invoke metric calculation. 
@abstract
class_name MetricMonitor extends Node

## Emitted with the newly updated value
signal value_updated
@export var timer: Timer

var _last_value: Variant:
	set(new):
		_last_value = new
		value_updated.emit(_last_value)

func _ready() -> void:
	_setup()
	if timer:
		timer.timeout.connect(_update)
	else:
		printerr("No timer set on MetricMonitor: ", self)

## Do any setup required at the start of _ready before timer is connected
func _setup() -> void:
	pass

## Implementations that return null must handle setting _last_value themselves.
@abstract
func _get_metric() -> Variant

func _update() -> void:
	var update_value = _get_metric()
	if update_value:
		_last_value = update_value
