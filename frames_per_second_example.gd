class_name FramesPerSecondExample extends Control

@onready var label: Label = %Label
@onready var check_button: CheckButton = %CheckButton
@onready var frames_per_second: FramesPerSecond = %FramesPerSecond

func _ready() -> void:
	check_button.toggled.connect(on_button_toggled)
	frames_per_second.frames_per_second_updated.connect(on_frames_per_second_updated)

func on_frames_per_second_updated(fps: int) -> void:
	label.text = str("FPS: ", fps)

func on_button_toggled(on: bool) -> void:
	if on:
		frames_per_second.start()
	else:
		frames_per_second.stop()
