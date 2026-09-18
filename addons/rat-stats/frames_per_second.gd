## Measure the current frames per second at only at specifed interval
class_name FramesPerSecond extends Node

## emitted with frame count
signal frames_per_second_updated

@export var update_interval_seconds: float = 1.0

@onready var timer: Timer = %Timer
var last_frames_per_second: int = -1

func _ready() -> void:
	timer.wait_time = update_interval_seconds
	timer.one_shot = false
	timer.timeout.connect(update)

func start() -> void:
	timer.start()

func stop() -> void:
	timer.stop()

func update() -> void:
	last_frames_per_second = Engine.get_frames_per_second()
	frames_per_second_updated.emit(last_frames_per_second)
